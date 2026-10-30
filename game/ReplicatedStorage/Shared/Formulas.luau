--!strict
-- Pure economy formulas shared by server (authoritative) and client (display only).

local Shared = script.Parent
local Types = require(Shared.Types)
local Economy = require(Shared.Config.Economy)
local Eggs = require(Shared.Config.Eggs)
local Dragons = require(Shared.Config.Dragons)
local Rarities = require(Shared.Config.Rarities)
local Mutations = require(Shared.Config.Mutations)

local Formulas = {}

-- Gems needed to go from currentLevel to currentLevel + 1, or nil at max level.
function Formulas.NestUpgradeCost(currentLevel: number): number?
	if currentLevel >= Economy.NestMaxLevel then
		return nil
	end
	return math.floor(Economy.NestCostBase * Economy.NestCostGrowth ^ currentLevel + 0.5)
end

function Formulas.NestMultiplier(level: number): number
	return Economy.NestProductionGrowth ^ (level - 1)
end

function Formulas.RebirthMultiplier(rebirths: number): number
	return 1 + Economy.RebirthBonusPerRebirth * rebirths
end

-- Gems needed for the next nest slot, or nil when no more slots can be bought with gems.
function Formulas.SlotCost(currentSlots: number): number?
	local index = currentSlots - Economy.StartingSlots + 1
	if index < 1 or index > #Economy.SlotCosts then
		return nil
	end
	return Economy.SlotCosts[index]
end

-- Gems per second of one dragon before nest and rebirth multipliers.
function Formulas.DragonRate(species: string, mutation: string): number
	local def = Dragons.Defs[species]
	if def == nil then
		return 0
	end
	local rarity = Rarities.Defs[def.Rarity]
	local egg = Eggs.Defs[def.EggId]
	if rarity == nil or egg == nil then
		return 0
	end
	local mutationDef = Mutations.Defs[mutation]
	local mutationMultiplier = if mutationDef then mutationDef.Multiplier else 1
	return rarity.BaseProduction * egg.TierMultiplier * mutationMultiplier
end

function Formulas.TotalRate(dragonRates: { number }, nestLevel: number, rebirths: number): number
	local sum = 0
	for _, rate in dragonRates do
		sum += rate
	end
	return sum * Formulas.NestMultiplier(nestLevel) * Formulas.RebirthMultiplier(rebirths)
end

-- Probability (0..1) of a mutation for a hatch.
function Formulas.MutationChance(mutation: string, eruption: boolean): number
	local weights = if eruption then Mutations.EruptionWeights else Mutations.NormalWeights
	local total = 0
	for _, weight in weights do
		total += weight
	end
	if total <= 0 then
		return 0
	end
	return (weights[mutation] or 0) / total
end

-- "1 in N" odds of a specific rarity + mutation result, rounded. Fixed eggs return 1.
function Formulas.OneIn(egg: Types.EggDef, rarity: string, mutation: string, eruption: boolean): number
	if egg.Fixed ~= nil then
		return 1
	end
	local probability = ((egg.Odds[rarity] or 0) / 100) * Formulas.MutationChance(mutation, eruption)
	if probability <= 0 then
		return 0
	end
	return math.floor(1 / probability + 0.5)
end

return Formulas
