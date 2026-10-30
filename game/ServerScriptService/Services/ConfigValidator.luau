--!strict
-- Checks all content config at server start so a bad weekly data edit fails
-- loudly in Studio instead of silently breaking drops in live servers.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage.Shared.Config
local Eggs = require(Config.Eggs)
local Dragons = require(Config.Dragons)
local Rarities = require(Config.Rarities)
local Mutations = require(Config.Mutations)
local Economy = require(Config.Economy)
local Eruption = require(Config.Eruption)

local ConfigValidator = {}

local ODDS_TOLERANCE = 1e-6

function ConfigValidator.Run()
	local problems: { string } = {}
	local function check(condition: boolean, message: string)
		if not condition then
			table.insert(problems, message)
		end
	end

	for id, egg in Eggs.Defs do
		check(egg.Id == id, `Egg {id}: Id field is "{egg.Id}"`)
		check(egg.Price >= 0, `Egg {id}: negative price`)
		check(not egg.Purchasable or egg.Price > 0, `Egg {id}: purchasable eggs need a price above 0`)
		check(egg.HatchSeconds > 0, `Egg {id}: HatchSeconds must be above 0`)
		check(egg.MaxTapReduction >= 0 and egg.MaxTapReduction <= 1, `Egg {id}: MaxTapReduction must be 0..1`)
		check(egg.TierMultiplier > 0, `Egg {id}: TierMultiplier must be above 0`)
		check(egg.Currency == "Gems" or egg.Currency == "Embers", `Egg {id}: unknown currency`)

		local fixed = egg.Fixed
		if fixed ~= nil then
			check(Dragons.Defs[fixed.Species] ~= nil, `Egg {id}: fixed species {fixed.Species} does not exist`)
			check(Mutations.Defs[fixed.Mutation] ~= nil, `Egg {id}: fixed mutation {fixed.Mutation} does not exist`)
		else
			local total = 0
			for rarityId, odds in egg.Odds do
				check(Rarities.Defs[rarityId] ~= nil, `Egg {id}: unknown rarity {rarityId}`)
				check(odds >= 0, `Egg {id}: negative odds for {rarityId}`)
				total += odds
				if odds > 0 then
					local species = egg.Species[rarityId]
					local dragon = if species ~= nil then Dragons.Defs[species] else nil
					check(dragon ~= nil, `Egg {id}: no dragon for rarity {rarityId}`)
					if dragon ~= nil then
						check(dragon.Rarity == rarityId, `Egg {id}: {dragon.Id} is {dragon.Rarity}, listed as {rarityId}`)
						check(dragon.EggId == id, `Egg {id}: {dragon.Id} belongs to {dragon.EggId}`)
					end
				end
			end
			check(math.abs(total - 100) < ODDS_TOLERANCE, `Egg {id}: odds add up to {total}, expected 100`)
		end
	end

	for _, eggId in Eggs.ShopOrder do
		check(Eggs.Defs[eggId] ~= nil, `ShopOrder: egg {eggId} does not exist`)
	end

	for id, dragon in Dragons.Defs do
		check(dragon.Id == id, `Dragon {id}: Id field is "{dragon.Id}"`)
		check(Rarities.Defs[dragon.Rarity] ~= nil, `Dragon {id}: unknown rarity {dragon.Rarity}`)
		check(Eggs.Defs[dragon.EggId] ~= nil, `Dragon {id}: unknown egg {dragon.EggId}`)
	end

	for _, rarityId in Rarities.Order do
		check(Rarities.Defs[rarityId] ~= nil, `Rarities.Order: {rarityId} has no definition`)
	end

	for _, weights in { Mutations.NormalWeights, Mutations.EruptionWeights } do
		local total = 0
		for mutationId, weight in weights do
			check(Mutations.Defs[mutationId] ~= nil, `Mutation weights: unknown mutation {mutationId}`)
			check(table.find(Mutations.Order, mutationId) ~= nil, `Mutation weights: {mutationId} missing from Order`)
			total += weight
		end
		check(total > 0, "Mutation weights: total must be above 0")
	end

	local previous = 0
	for index, cost in Economy.SlotCosts do
		check(cost > previous, `Economy.SlotCosts[{index}] must be higher than the previous slot`)
		previous = cost
	end
	check(Eggs.Defs[Economy.StarterEggId] ~= nil, `Economy.StarterEggId {Economy.StarterEggId} does not exist`)
	check(Eggs.Defs[Eruption.WildEggId] ~= nil, `Eruption.WildEggId {Eruption.WildEggId} does not exist`)
	check(Eruption.EmbersMin <= Eruption.EmbersMax, "Eruption.EmbersMin must not exceed EmbersMax")

	if #problems > 0 then
		error(`[ConfigValidator] {#problems} problem(s):\n` .. table.concat(problems, "\n"))
	end
end

return ConfigValidator
