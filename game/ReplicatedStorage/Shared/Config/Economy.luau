--!strict
-- Core economy tuning. Weekly balance changes are edits to these numbers only.

local Economy = {
	-- Egg placed in slot 1 for brand-new players.
	StarterEggId = "StarterEgg",

	-- Nest slots: players start with StartingSlots; each entry in SlotCosts
	-- buys one more slot with gems, in order.
	StartingSlots = 3,
	SlotCosts = { 5_000, 50_000, 500_000, 5_000_000 },

	-- Nest level: cost to go from level L to L + 1 is
	-- floor(NestCostBase * NestCostGrowth ^ L + 0.5).
	NestMaxLevel = 30,
	NestCostBase = 15,
	NestCostGrowth = 1.66,
	-- Production multiplier from nest level: NestProductionGrowth ^ (level - 1).
	NestProductionGrowth = 1.15,

	-- Permanent production multiplier: 1 + RebirthBonusPerRebirth * rebirths.
	RebirthBonusPerRebirth = 0.5,

	-- Number of dragons that produce gems (best ones are auto-equipped).
	Perches = 6,
	-- Dragon storage limit.
	MaxDragons = 60,

	-- The gem pile on a plot stops growing after this many seconds of production.
	PileCapSeconds = 900,

	-- Seconds removed from an incubating egg per tap.
	TapSeconds = 1,

	-- Luck boosts multiply the weight of rarities with Order >= this value (Rare and up).
	LuckMinRarityOrder = 3,
}

return Economy
