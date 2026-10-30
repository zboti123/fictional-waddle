--!strict
-- Server-only random rolls for hatches. Never runs on the client.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Types = require(Shared.Types)
local Economy = require(Shared.Config.Economy)
local Dragons = require(Shared.Config.Dragons)
local Rarities = require(Shared.Config.Rarities)
local Mutations = require(Shared.Config.Mutations)

export type Roll = {
	Species: string,
	Rarity: string,
	Mutation: string,
}

local HatchRoller = {}

local rng = Random.new()

-- Weighted pick that walks `order` so results are independent of table iteration order.
local function pick(order: { string }, weights: { [string]: number }): string?
	local total = 0
	for _, id in order do
		total += math.max(0, weights[id] or 0)
	end
	if total <= 0 then
		return nil
	end
	local roll = rng:NextNumber() * total
	local accumulated = 0
	local last: string? = nil
	for _, id in order do
		local weight = math.max(0, weights[id] or 0)
		if weight > 0 then
			accumulated += weight
			last = id
			if roll < accumulated then
				return id
			end
		end
	end
	return last
end

-- luck >= 1 multiplies the weight of Rare and better rarities.
function HatchRoller.Roll(egg: Types.EggDef, eruption: boolean, luck: number): Roll?
	local fixed = egg.Fixed
	if fixed ~= nil then
		local def = Dragons.Defs[fixed.Species]
		if def == nil then
			return nil
		end
		return { Species = fixed.Species, Rarity = def.Rarity, Mutation = fixed.Mutation }
	end

	local weights: { [string]: number } = {}
	for _, rarityId in Rarities.Order do
		local weight = egg.Odds[rarityId] or 0
		local rarity = Rarities.Defs[rarityId]
		if luck > 1 and rarity ~= nil and rarity.Order >= Economy.LuckMinRarityOrder then
			weight *= luck
		end
		weights[rarityId] = weight
	end

	local rarityId = pick(Rarities.Order, weights)
	if rarityId == nil then
		return nil
	end
	local species = egg.Species[rarityId]
	if species == nil then
		return nil
	end
	local mutationWeights = if eruption then Mutations.EruptionWeights else Mutations.NormalWeights
	local mutation = pick(Mutations.Order, mutationWeights) or "None"
	return { Species = species, Rarity = rarityId, Mutation = mutation }
end

return HatchRoller
