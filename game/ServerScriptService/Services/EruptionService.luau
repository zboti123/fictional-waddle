--!strict
-- Server-wide eruption: on a schedule, wild eggs rain onto the lava field.
-- Each player may grab a limited number; a grabbed egg hatches instantly with
-- eruption mutation odds and awards Embers. Eggs in nests that hatch during an
-- eruption also use eruption odds (see IncubationService).

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Shared
local Types = require(Shared.Types)
local Clock = require(Shared.Clock)
local Format = require(Shared.Format)
local Config = require(Shared.Config.Eruption)
local Eggs = require(Shared.Config.Eggs)

local Services = script.Parent
local DataService = require(Services.DataService)
local DragonService = require(Services.DragonService)
local EconomyService = require(Services.EconomyService)
local HatchService = require(Services.HatchService)
local AnnounceService = require(Services.AnnounceService)
local PlotService = require(Services.PlotService)
local RateLimiter = require(Services.RateLimiter)
local WorldService = require(Services.WorldService)

local EruptionService = {}

local ERUPTION_COLOR = Color3.fromRGB(255, 120, 40)

local active = false
local endsAt = 0
local nextAt = 0
local queued = 0
local claims: { [Player]: number } = {}
local wildEggs: { [BasePart]: boolean } = {}
local rng = Random.new()
local claimLimiter = RateLimiter.new(4, 2)

local function publish()
	Workspace:SetAttribute("EruptionActive", active)
	Workspace:SetAttribute("EruptionEndsAt", endsAt)
	Workspace:SetAttribute("NextEruptionAt", nextAt)
end

local function claim(player: Player, part: BasePart)
	if not active or not wildEggs[part] then
		return
	end
	if not claimLimiter:Allow(player) then
		return
	end
	if (claims[player] or 0) >= Config.MaxClaimsPerPlayer then
		AnnounceService.Notify(player, `You already grabbed {Config.MaxClaimsPerPlayer} wild eggs this eruption!`, "Info")
		return
	end
	if not PlotService.IsNear(player, part.Position, Config.ClaimDistance) then
		return
	end
	if DragonService.IsFull(player) then
		AnnounceService.Notify(player, "Your dragon storage is full!", "Error")
		return
	end
	local data = DataService.Get(player)
	if data == nil then
		return
	end

	-- Remove first so a second click in the same frame cannot claim it again.
	wildEggs[part] = nil
	part:Destroy()
	claims[player] = (claims[player] or 0) + 1
	data.Stats.WildEggsClaimed += 1

	local embers = rng:NextInteger(Config.EmbersMin, Config.EmbersMax)
	EconomyService.Add(player, "Embers", embers, "WildEgg")
	HatchService.Hatch(player, Config.WildEggId, {
		Eruption = true,
		Source = "Wild",
		EmbersAwarded = embers,
	})
end

local function spawnWildEgg(egg: Types.EggDef)
	local target = WorldService.RandomEruptionPoint(rng) + Vector3.new(0, 2, 0)
	local part = Instance.new("Part")
	part.Name = "WildEgg"
	part.Size = Vector3.new(3, 4, 3)
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	part.Color = egg.Color
	part.Material = Enum.Material.Neon
	part.CFrame = CFrame.new(target + Vector3.new(0, 60, 0))
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = part
	local click = Instance.new("ClickDetector")
	click.MaxActivationDistance = Config.ClaimDistance
	click.Parent = part
	click.MouseClick:Connect(function(player: Player)
		claim(player, part)
	end)
	part.Parent = WorldService.GetWildEggContainer()
	CollectionService:AddTag(part, "WildEgg")
	wildEggs[part] = true

	local fall = TweenService:Create(
		part,
		TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ CFrame = CFrame.new(target) }
	)
	fall:Play()
end

local function beginEruption()
	active = true
	endsAt = Clock.Now() + Config.DurationSeconds
	table.clear(claims)
	publish()
	WorldService.SetErupting(true)
	AnnounceService.Broadcast(
		`🌋 ERUPTION! Wild eggs are falling — grab up to {Config.MaxClaimsPerPlayer}!`,
		ERUPTION_COLOR,
		true
	)

	local egg = Eggs.Defs[Config.WildEggId]
	if egg == nil then
		return
	end
	local count = math.clamp(
		math.ceil(#Players:GetPlayers() * Config.WildEggsPerPlayer),
		Config.MinWildEggs,
		Config.MaxWildEggs
	)
	for _ = 1, count do
		if not active then
			break
		end
		spawnWildEgg(egg)
		task.wait(Config.SpawnIntervalSeconds)
	end
end

local function finishEruption()
	active = false
	for part in wildEggs do
		part:Destroy()
	end
	table.clear(wildEggs)
	table.clear(claims)
	WorldService.SetErupting(false)

	local gap = Config.IntervalSeconds
	if queued > 0 then
		queued -= 1
		gap = Config.QueuedGapSeconds
	end
	nextAt = Clock.Now() + gap
	publish()
	AnnounceService.Broadcast(`The volcano calms down. Next eruption in {Format.Duration(gap)}.`, ERUPTION_COLOR, false)
end

local function run()
	nextAt = Clock.Now() + Config.FirstDelaySeconds
	publish()
	while true do
		local waitFor = nextAt - Clock.Now()
		if waitFor > 0 then
			task.wait(math.min(waitFor, 1))
		else
			beginEruption()
			local left = endsAt - Clock.Now()
			if left > 0 then
				task.wait(left)
			end
			finishEruption()
		end
	end
end

function EruptionService.IsActive(): boolean
	return active
end

-- Starts an eruption now, or queues one right after the current eruption.
-- Used by the paid "Trigger Eruption" product and admin tools.
function EruptionService.TriggerNow()
	if active then
		queued += 1
	else
		nextAt = Clock.Now()
		publish()
	end
end

function EruptionService.Start()
	Players.PlayerRemoving:Connect(function(player: Player)
		claims[player] = nil
	end)
	task.spawn(run)
end

return EruptionService
