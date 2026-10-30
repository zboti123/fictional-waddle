--!strict
-- Milestone 1 version: player data lives in memory for the session only.
-- The save-data milestone replaces this module with a ProfileStore-backed
-- version that keeps exactly this public API (Get, OnLoaded, OnReleasing, Start).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)
local DataTemplate = require(script.Parent.DataTemplate)

type DataCallback = (Player, Types.PlayerData) -> ()

local DataService = {}

local dataByPlayer: { [Player]: Types.PlayerData } = {}
local loadedCallbacks: { DataCallback } = {}
local releasingCallbacks: { DataCallback } = {}

local function runCallbacks(callbacks: { DataCallback }, player: Player, data: Types.PlayerData, label: string)
	for _, callback in callbacks do
		local ok, err = pcall(callback, player, data)
		if not ok then
			warn(`[DataService] {label} callback failed for {player.UserId}: {err}`)
		end
	end
end

local function load(player: Player)
	if dataByPlayer[player] ~= nil then
		return
	end
	local data = DataTemplate.New()
	dataByPlayer[player] = data
	runCallbacks(loadedCallbacks, player, data, "OnLoaded")
end

local function release(player: Player)
	local data = dataByPlayer[player]
	if data == nil then
		return
	end
	runCallbacks(releasingCallbacks, player, data, "OnReleasing")
	dataByPlayer[player] = nil
end

function DataService.Get(player: Player): Types.PlayerData?
	return dataByPlayer[player]
end

-- Called (in registration order) once a player's data is ready.
function DataService.OnLoaded(callback: DataCallback)
	table.insert(loadedCallbacks, callback)
end

-- Called (in registration order) right before a player's data is released.
function DataService.OnReleasing(callback: DataCallback)
	table.insert(releasingCallbacks, callback)
end

function DataService.Start()
	Players.PlayerAdded:Connect(load)
	Players.PlayerRemoving:Connect(release)
	for _, player in Players:GetPlayers() do
		task.spawn(load, player)
	end
end

return DataService
