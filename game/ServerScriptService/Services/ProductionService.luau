--!strict
-- Gem production. Nothing runs per frame: the pile is settled from timestamps
-- whenever the rate changes or the player collects, and clients animate the
-- pile counter locally from the published attributes.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Types = require(Shared.Types)
local Clock = require(Shared.Clock)
local Remotes = require(Shared.Remotes)
local Economy = require(Shared.Config.Economy)
local World = require(Shared.Config.World)

local Services = script.Parent
local DataService = require(Services.DataService)
local PlotService = require(Services.PlotService)
local EconomyService = require(Services.EconomyService)
local RateLimiter = require(Services.RateLimiter)

local ProductionService = {}

local collectedRemote = Remotes.Get("Collected")
local collectLimiter = RateLimiter.new(6, 3)
local rates: { [Player]: number } = {}

-- Grows the pile up to the cap; a pile already above the cap (after a rate drop) is kept.
local function settle(data: Types.PlayerData, rate: number, now: number)
	local cap = rate * Economy.PileCapSeconds
	local elapsed = math.max(0, now - data.PileUpdatedAt)
	local grown = data.PileGems + rate * elapsed
	if grown > cap then
		grown = math.max(data.PileGems, cap)
	end
	data.PileGems = grown
	data.PileUpdatedAt = now
end

local function publish(player: Player, data: Types.PlayerData)
	local plot = PlotService.Get(player)
	if plot == nil then
		return
	end
	local rate = rates[player] or 0
	plot.Pile:SetAttribute("Pile", data.PileGems)
	plot.Pile:SetAttribute("PileAt", data.PileUpdatedAt)
	plot.Pile:SetAttribute("Rate", rate)
	plot.Pile:SetAttribute("Cap", rate * Economy.PileCapSeconds)
end

local function collect(player: Player, plot: PlotService.PlotInfo)
	if not collectLimiter:Allow(player) then
		return
	end
	if not PlotService.IsNear(player, plot.Pile.Position, World.InteractDistance) then
		return
	end
	local data = DataService.Get(player)
	if data == nil then
		return
	end
	settle(data, rates[player] or 0, Clock.Now())
	local amount = math.floor(data.PileGems)
	if amount < 1 then
		return
	end
	data.PileGems -= amount
	EconomyService.Add(player, "Gems", amount, "Production")
	publish(player, data)
	local payload: Types.Collected = { Amount = amount }
	collectedRemote:FireClient(player, payload)
end

function ProductionService.GetRate(player: Player): number
	return rates[player] or 0
end

function ProductionService.SetRate(player: Player, rate: number)
	local data = DataService.Get(player)
	if data == nil then
		return
	end
	settle(data, rates[player] or 0, Clock.Now())
	rates[player] = rate
	publish(player, data)
end

-- Session start: production does not accrue while offline (offline earnings
-- are a separate, capped system in the retention milestone).
function ProductionService.OnLoaded(player: Player, data: Types.PlayerData)
	data.PileUpdatedAt = Clock.Now()
	rates[player] = 0
	publish(player, data)
end

function ProductionService.Remove(player: Player)
	local data = DataService.Get(player)
	if data ~= nil then
		settle(data, rates[player] or 0, Clock.Now())
	end
	rates[player] = nil
end

function ProductionService.Start()
	PlotService.OnPileClicked(collect)
end

return ProductionService
