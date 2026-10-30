--!strict
-- Nest level upgrades and extra nest slots, bought with gems.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes)
local Format = require(Shared.Format)
local Formulas = require(Shared.Formulas)

local Services = script.Parent
local DataService = require(Services.DataService)
local EconomyService = require(Services.EconomyService)
local DragonService = require(Services.DragonService)
local IncubationService = require(Services.IncubationService)
local PlotService = require(Services.PlotService)
local AnnounceService = require(Services.AnnounceService)
local RateLimiter = require(Services.RateLimiter)
local Validate = require(Services.Validate)

local NestService = {}

local upgradeLimiter = RateLimiter.new(4, 2)
local slotLimiter = RateLimiter.new(2, 1)

local function onUpgrade(player: Player, ...: unknown)
	if not Validate.NoArgs(...) or not upgradeLimiter:Allow(player) then
		return
	end
	local data = DataService.Get(player)
	if data == nil then
		return
	end
	local cost = Formulas.NestUpgradeCost(data.NestLevel)
	if cost == nil then
		AnnounceService.Notify(player, "Your nest is already max level!", "Info")
		return
	end
	if not EconomyService.Spend(player, "Gems", cost, "NestUpgrade") then
		AnnounceService.Notify(player, `You need 💎 {Format.Number(cost)}.`, "Error")
		return
	end
	data.NestLevel += 1
	DragonService.Refresh(player)
	AnnounceService.Notify(
		player,
		`Nest level {data.NestLevel}! Production ×{string.format("%.2f", Formulas.NestMultiplier(data.NestLevel))}`,
		"Success"
	)
end

local function onBuySlot(player: Player, ...: unknown)
	if not Validate.NoArgs(...) or not slotLimiter:Allow(player) then
		return
	end
	local data = DataService.Get(player)
	if data == nil then
		return
	end
	local cost = Formulas.SlotCost(data.NestSlots)
	if cost == nil then
		AnnounceService.Notify(player, "No more slots can be bought with gems.", "Info")
		return
	end
	if not EconomyService.Spend(player, "Gems", cost, "NestSlot") then
		AnnounceService.Notify(player, `You need 💎 {Format.Number(cost)}.`, "Error")
		return
	end
	data.NestSlots += 1
	local plot = PlotService.Get(player)
	if plot ~= nil then
		PlotService.RenderSlots(plot, data.NestSlots)
	end
	IncubationService.RenderAll(player)
	AnnounceService.Notify(player, `New nest slot! You now have {data.NestSlots}.`, "Success")
end

function NestService.Start()
	Remotes.Get("UpgradeNest").OnServerEvent:Connect(onUpgrade)
	Remotes.Get("BuySlot").OnServerEvent:Connect(onBuySlot)
end

return NestService
