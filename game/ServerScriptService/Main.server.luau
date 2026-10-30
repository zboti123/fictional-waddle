--!strict
-- Server bootstrap: validates config, builds the world, wires services, then
-- starts accepting players. This is the only server Script; everything else
-- is a ModuleScript under ServerScriptService.Services.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Types = require(Shared.Types)
local Formulas = require(Shared.Formulas)
local Economy = require(Shared.Config.Economy)

local Services = script.Parent.Services
local ConfigValidator = require(Services.ConfigValidator)
local DataService = require(Services.DataService)
local StateSync = require(Services.StateSync)
local WorldService = require(Services.WorldService)
local PlotService = require(Services.PlotService)
local ProductionService = require(Services.ProductionService)
local DragonService = require(Services.DragonService)
local IncubationService = require(Services.IncubationService)
local EruptionService = require(Services.EruptionService)
local ShopService = require(Services.ShopService)
local NestService = require(Services.NestService)

ConfigValidator.Run()

WorldService.Build()
PlotService.Start()

StateSync.SetBuilder(function(player: Player): Types.Snapshot?
	local data = DataService.Get(player)
	if data == nil then
		return nil
	end
	return {
		Gems = data.Gems,
		Embers = data.Embers,
		NestLevel = data.NestLevel,
		NestMaxLevel = Economy.NestMaxLevel,
		NextNestCost = Formulas.NestUpgradeCost(data.NestLevel),
		NestSlots = data.NestSlots,
		MaxGemSlots = Economy.StartingSlots + #Economy.SlotCosts,
		NextSlotCost = Formulas.SlotCost(data.NestSlots),
		Rate = ProductionService.GetRate(player),
		DragonCount = DragonService.Count(data),
		MaxDragons = Economy.MaxDragons,
		Perches = Economy.Perches,
		Rebirths = data.Rebirths,
	}
end)

DataService.OnLoaded(function(player: Player, data: Types.PlayerData)
	local plot = PlotService.Assign(player)
	if plot == nil then
		player:Kick("This server is full. Please join another server.")
		return
	end
	PlotService.RenderSlots(plot, data.NestSlots)
	ProductionService.OnLoaded(player, data)
	if not data.Ftue.StarterGiven then
		data.Ftue.StarterGiven = IncubationService.PlaceEgg(player, Economy.StarterEggId)
	end
	IncubationService.RenderAll(player)
	DragonService.Refresh(player)
	StateSync.MarkDirty(player)
end)

DataService.OnReleasing(function(player: Player, _data: Types.PlayerData)
	ProductionService.Remove(player)
	DragonService.ClearVisuals(player)
	IncubationService.ClearVisuals(player)
	PlotService.Release(player)
end)

ProductionService.Start()
IncubationService.Start()
ShopService.Start()
NestService.Start()
EruptionService.Start()

-- Last, so every OnLoaded handler is registered before the first player loads.
DataService.Start()
