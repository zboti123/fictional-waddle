--!strict
-- Player data backed by ProfileStore (vendored in ServerScriptService.Packages):
--   * Session lock: only one server owns a player's profile at a time, so data
--     cannot be duplicated or overwritten by two servers.
--   * Auto-save every few minutes, save on leave, and save on shutdown
--     (ProfileStore's own BindToClose waits for all saves to finish).
--   * DataStore errors are retried inside ProfileStore; starting a session is
--     additionally retried here with exponential backoff.
-- Public API is unchanged from milestone 1: Get, OnLoaded, OnReleasing, Start,
-- plus SaveSoon for important moments.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Types = require(ReplicatedStorage.Shared.Types)
local DataTemplate = require(script.Parent.DataTemplate)
local Migrations = require(script.Parent.Migrations)
-- Third-party module; its generic types are kept out of strict code on purpose.
local ProfileStore = require(script.Parent.Parent.Packages.ProfileStore) :: any

-- Changing STORE_NAME starts every player from an empty save.
local STORE_NAME = "PlayerData"
-- true: Studio play tests use an in-memory store and never touch real saves.
local USE_MOCK_IN_STUDIO = false
local START_ATTEMPTS = 5
local SAVE_SOON_COOLDOWN = 30

type Signal = {
	Connect: (self: any, listener: (...any) -> ()) -> any,
}

type Profile = {
	Data: Types.PlayerData,
	IsActive: (self: Profile) -> boolean,
	Save: (self: Profile) -> (),
	EndSession: (self: Profile) -> (),
	Reconcile: (self: Profile) -> (),
	AddUserId: (self: Profile, userId: number) -> (),
	OnSessionEnd: Signal,
}

type DataCallback = (Player, Types.PlayerData) -> ()

local DataService = {}

local store = ProfileStore.New(STORE_NAME, DataTemplate.New())
local profiles: { [Player]: Profile } = {}
local releasing: { [Player]: boolean } = {}
local lastSaveSoon: { [Player]: number } = {}
local loadedCallbacks: { DataCallback } = {}
local releasingCallbacks: { DataCallback } = {}

local function activeStore(): any
	if USE_MOCK_IN_STUDIO and RunService:IsStudio() then
		return store.Mock
	end
	return store
end

local function runCallbacks(callbacks: { DataCallback }, player: Player, data: Types.PlayerData, label: string)
	for _, callback in callbacks do
		local ok, err = pcall(callback, player, data)
		if not ok then
			warn(`[DataService] {label} callback failed for {player.UserId}: {err}`)
		end
	end
end

local function profileKey(player: Player): string
	return `Player_{player.UserId}`
end

-- StartSessionAsync already retries DataStore calls; this outer loop covers
-- errors it throws (e.g. rejoining the same server while the old session is still closing).
local function startSession(player: Player): Profile?
	local delaySeconds = 1
	for attempt = 1, START_ATTEMPTS do
		local ok, result = pcall(function()
			return activeStore():StartSessionAsync(profileKey(player), {
				Cancel = function()
					return player.Parent ~= Players
				end,
			})
		end)
		if ok then
			return result :: Profile?
		end
		warn(`[DataService] Session start attempt {attempt} failed for {player.UserId}: {result}`)
		if player.Parent ~= Players or attempt == START_ATTEMPTS then
			break
		end
		task.wait(delaySeconds)
		delaySeconds *= 2
	end
	return nil
end

local function releaseCallbacksOnce(player: Player, profile: Profile)
	if releasing[player] then
		return
	end
	releasing[player] = true
	runCallbacks(releasingCallbacks, player, profile.Data, "OnReleasing")
	profiles[player] = nil
	lastSaveSoon[player] = nil
end

local function load(player: Player)
	if profiles[player] ~= nil then
		return
	end
	local profile = startSession(player)
	if profile == nil then
		if player.Parent == Players then
			player:Kick("We couldn't load your data. Your progress is safe; please rejoin in a minute.")
		end
		return
	end

	profile:AddUserId(player.UserId)
	local migrated, message = Migrations.Run(profile.Data :: any)
	if not migrated then
		profile:EndSession()
		player:Kick(message or "Your save could not be loaded. Please rejoin.")
		return
	end
	profile:Reconcile()
	Migrations.Sanitize(profile.Data :: any, player.UserId)

	profile.OnSessionEnd:Connect(function()
		-- Ended by another server (or by ProfileStore); stop using the data here.
		-- The identity check ignores late signals from an already released session.
		if profiles[player] == profile and not releasing[player] then
			releaseCallbacksOnce(player, profile)
			if player.Parent == Players then
				player:Kick("Your save was opened on another server. Please rejoin.")
			end
		end
	end)

	if player.Parent ~= Players then
		profile:EndSession()
		return
	end

	releasing[player] = nil
	profiles[player] = profile
	runCallbacks(loadedCallbacks, player, profile.Data, "OnLoaded")
end

local function release(player: Player)
	local profile = profiles[player]
	if profile == nil then
		return
	end
	-- Callbacks run while Get(player) still returns data so final values get saved.
	releaseCallbacksOnce(player, profile)
	profile:EndSession()
	releasing[player] = nil
end

function DataService.Get(player: Player): Types.PlayerData?
	local profile = profiles[player]
	return if profile ~= nil then profile.Data else nil
end

function DataService.OnLoaded(callback: DataCallback)
	table.insert(loadedCallbacks, callback)
end

function DataService.OnReleasing(callback: DataCallback)
	table.insert(releasingCallbacks, callback)
end

-- Saves right away after important moments (rare hatch, purchase); throttled per player.
function DataService.SaveSoon(player: Player)
	local profile = profiles[player]
	if profile == nil or not profile:IsActive() then
		return
	end
	local now = os.clock()
	local last = lastSaveSoon[player]
	if last ~= nil and now - last < SAVE_SOON_COOLDOWN then
		return
	end
	lastSaveSoon[player] = now
	profile:Save()
end

function DataService.Start()
	ProfileStore.OnError:Connect(function(message: string, storeName: string, key: string)
		warn(`[DataService] ProfileStore error ({storeName}/{key}): {message}`)
	end)
	ProfileStore.OnCriticalToggle:Connect(function(isCritical: boolean)
		warn(`[DataService] ProfileStore critical state: {isCritical}`)
	end)
	task.spawn(function()
		while ProfileStore.DataStoreState == "NotReady" do
			task.wait(0.5)
		end
		if ProfileStore.DataStoreState ~= "Access" then
			warn(
				`[DataService] DataStore state is {ProfileStore.DataStoreState}: progress will NOT be saved. `
					.. "Publish the game and enable Studio Access to API Services."
			)
		end
	end)

	-- Settle per-player state into the profile before ProfileStore's shutdown save.
	game:BindToClose(function()
		for player, profile in profiles do
			releaseCallbacksOnce(player, profile)
		end
	end)

	Players.PlayerAdded:Connect(load)
	Players.PlayerRemoving:Connect(release)
	for _, player in Players:GetPlayers() do
		task.spawn(load, player)
	end
end

return DataService
