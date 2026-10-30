--!strict
-- Eggs sitting in nest slots. Timers are timestamps (they keep running while
-- the player is offline). Tapping an egg shaves time off; tapping a ready egg
-- hatches it, using eruption odds if an eruption is active at that moment.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Types = require(Shared.Types)
local Clock = require(Shared.Clock)
local Economy = require(Shared.Config.Economy)
local Eggs = require(Shared.Config.Eggs)
local World = require(Shared.Config.World)

local Services = script.Parent
local DataService = require(Services.DataService)
local PlotService = require(Services.PlotService)
local HatchService = require(Services.HatchService)
local EruptionService = require(Services.EruptionService)
local AnnounceService = require(Services.AnnounceService)
local StateSync = require(Services.StateSync)
local RateLimiter = require(Services.RateLimiter)
local WorldService = require(Services.WorldService)

local IncubationService = {}

local tapLimiter = RateLimiter.new(10, 8)
local eggVisuals: { [Player]: { [number]: BasePart } } = {}

local function slotKey(index: number): string
	return tostring(index)
end

local function readyAt(entry: Types.IncubatingEgg): number
	return entry.StartedAt + entry.Duration - entry.Reduced
end

local function buildEggPart(egg: Types.EggDef, slotCFrame: CFrame, parent: Instance): BasePart
	local part = Instance.new("Part")
	part.Name = "Egg"
	part.Size = Vector3.new(3, 4, 3)
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	part.Color = egg.Color
	part.Material = Enum.Material.SmoothPlastic
	part.CFrame = slotCFrame * CFrame.new(0, 2, 0)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = part
	part:SetAttribute("EggId", egg.Id)
	part:SetAttribute("EggName", egg.DisplayName)
	WorldService.MakeBillboard(part, Vector2.new(6, 2), 3.5, 80)
	part.Parent = parent
	CollectionService:AddTag(part, "IncubatingEgg")
	return part
end

local function renderSlot(player: Player, index: number)
	local plot = PlotService.Get(player)
	local data = DataService.Get(player)
	if plot == nil or data == nil then
		return
	end
	local visuals = eggVisuals[player]
	if visuals == nil then
		visuals = {}
		eggVisuals[player] = visuals
	end

	local entry = data.Incubating[slotKey(index)]
	local existing = visuals[index]
	if entry == nil then
		if existing ~= nil then
			existing:Destroy()
			visuals[index] = nil
		end
		return
	end

	local egg = Eggs.Defs[entry.EggId]
	if egg == nil then
		return
	end
	if existing ~= nil and existing:GetAttribute("EggId") ~= entry.EggId then
		existing:Destroy()
		existing = nil
	end
	local part = existing
	if part == nil then
		local slotModel = plot.SlotModels[index]
		local slotCFrame = plot.SlotCFrames[index]
		if slotModel == nil or slotCFrame == nil then
			return
		end
		part = buildEggPart(egg, slotCFrame, slotModel)
		visuals[index] = part
	end
	part:SetAttribute("ReadyAt", readyAt(entry))
end

local function firstFreeSlot(data: Types.PlayerData): number?
	for index = 1, data.NestSlots do
		if data.Incubating[slotKey(index)] == nil then
			return index
		end
	end
	return nil
end

function IncubationService.HasFreeSlot(player: Player): boolean
	local data = DataService.Get(player)
	return data ~= nil and firstFreeSlot(data) ~= nil
end

-- Puts an egg in the first free slot. Returns false if there is no free slot.
function IncubationService.PlaceEgg(player: Player, eggId: string): boolean
	local data = DataService.Get(player)
	local egg = Eggs.Defs[eggId]
	if data == nil or egg == nil then
		return false
	end
	local index = firstFreeSlot(data)
	if index == nil then
		return false
	end
	data.Incubating[slotKey(index)] = {
		EggId = eggId,
		StartedAt = Clock.Now(),
		Duration = egg.HatchSeconds,
		Reduced = 0,
	}
	renderSlot(player, index)
	StateSync.MarkDirty(player)
	return true
end

function IncubationService.RenderAll(player: Player)
	local plot = PlotService.Get(player)
	if plot == nil then
		return
	end
	for index = 1, #plot.SlotModels do
		renderSlot(player, index)
	end
end

function IncubationService.ClearVisuals(player: Player)
	local visuals = eggVisuals[player]
	if visuals == nil then
		return
	end
	for _, part in visuals do
		part:Destroy()
	end
	eggVisuals[player] = nil
end

local function onSlotClicked(player: Player, plot: PlotService.PlotInfo, index: number)
	if not tapLimiter:Allow(player) then
		return
	end
	local data = DataService.Get(player)
	if data == nil then
		return
	end
	local key = slotKey(index)
	local entry = data.Incubating[key]
	if entry == nil then
		return
	end
	local slotCFrame = plot.SlotCFrames[index]
	if slotCFrame == nil or not PlotService.IsNear(player, slotCFrame.Position, World.InteractDistance) then
		return
	end

	local now = Clock.Now()
	local remaining = readyAt(entry) - now
	if remaining > 0 then
		local egg = Eggs.Defs[entry.EggId]
		if egg == nil then
			return
		end
		local maxReduction = egg.MaxTapReduction * entry.Duration
		local step = math.min(Economy.TapSeconds, maxReduction - entry.Reduced, remaining)
		if step > 0 then
			entry.Reduced += step
			renderSlot(player, index)
		end
		return
	end

	local ok, reason = HatchService.Hatch(player, entry.EggId, {
		Eruption = EruptionService.IsActive(),
		Source = "Nest",
		EmbersAwarded = 0,
	})
	if ok then
		data.Incubating[key] = nil
		renderSlot(player, index)
		StateSync.MarkDirty(player)
	elseif reason == "StorageFull" then
		AnnounceService.Notify(player, "Your dragon storage is full!", "Error")
	end
end

function IncubationService.Start()
	PlotService.OnSlotClicked(onSlotClicked)
end

return IncubationService
