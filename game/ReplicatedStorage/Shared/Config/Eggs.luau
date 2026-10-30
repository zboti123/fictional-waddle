--!strict
-- All eggs. Odds are percentages per rarity and must add up to 100
-- (checked by ConfigValidator when the server starts). Species maps each
-- rarity to the dragon that hatches from this egg at that rarity.

local Types = require(script.Parent.Parent.Types)

local Defs: { [string]: Types.EggDef } = {
	StarterEgg = {
		Id = "StarterEgg",
		DisplayName = "Starter Egg",
		Currency = "Gems",
		Price = 0,
		HatchSeconds = 12,
		MaxTapReduction = 1,
		UnlockNestLevel = 1,
		UnlockRebirths = 0,
		TierMultiplier = 1,
		Color = Color3.fromRGB(255, 200, 130),
		Odds = {},
		Species = {},
		Fixed = { Species = "EmberDrake", Mutation = "None" },
		Purchasable = false,
	},
	EmberEgg = {
		Id = "EmberEgg",
		DisplayName = "Ember Egg",
		Currency = "Gems",
		Price = 20,
		HatchSeconds = 60,
		MaxTapReduction = 0.5,
		UnlockNestLevel = 1,
		UnlockRebirths = 0,
		TierMultiplier = 1,
		Color = Color3.fromRGB(255, 140, 60),
		Odds = { Common = 65, Uncommon = 25, Rare = 8, Epic = 1.8, Legendary = 0.19, Mythic = 0.01 },
		Species = {
			Common = "EmberWhelp",
			Uncommon = "EmberDrake",
			Rare = "CinderWyvern",
			Epic = "BlazeSerpent",
			Legendary = "InfernoWarden",
			Mythic = "SolarPhoenix",
		},
		Purchasable = true,
	},
	LavaEgg = {
		Id = "LavaEgg",
		DisplayName = "Lava Egg",
		Currency = "Gems",
		Price = 2_500,
		HatchSeconds = 600,
		MaxTapReduction = 0.5,
		UnlockNestLevel = 8,
		UnlockRebirths = 0,
		TierMultiplier = 5,
		Color = Color3.fromRGB(230, 60, 30),
		Odds = { Common = 55, Uncommon = 28, Rare = 12, Epic = 4, Legendary = 0.9, Mythic = 0.1 },
		Species = {
			Common = "MagmaPup",
			Uncommon = "LavaLurker",
			Rare = "MoltenWyvern",
			Epic = "ScorchHorn",
			Legendary = "VolcanoTitan",
			Mythic = "MagmaDragon",
		},
		Purchasable = true,
	},
	ObsidianEgg = {
		Id = "ObsidianEgg",
		DisplayName = "Obsidian Egg",
		Currency = "Gems",
		Price = 150_000,
		HatchSeconds = 3_600,
		MaxTapReduction = 0.5,
		UnlockNestLevel = 16,
		UnlockRebirths = 0,
		TierMultiplier = 25,
		Color = Color3.fromRGB(45, 35, 60),
		Odds = { Common = 45, Uncommon = 30, Rare = 16, Epic = 7, Legendary = 1.8, Mythic = 0.2 },
		Species = {
			Common = "ObsidianShardling",
			Uncommon = "GlassFang",
			Rare = "NightWyvern",
			Epic = "OnyxHydra",
			Legendary = "ObsidianColossus",
			Mythic = "VoidEmperor",
		},
		Purchasable = true,
	},
	CelestialEgg = {
		Id = "CelestialEgg",
		DisplayName = "Celestial Egg",
		Currency = "Embers",
		Price = 150,
		HatchSeconds = 14_400,
		MaxTapReduction = 0.5,
		UnlockNestLevel = 1,
		UnlockRebirths = 1,
		TierMultiplier = 100,
		Color = Color3.fromRGB(120, 200, 255),
		Odds = { Common = 30, Uncommon = 32, Rare = 22, Epic = 12, Legendary = 3.5, Mythic = 0.5 },
		Species = {
			Common = "StarWhelp",
			Uncommon = "NebulaDrake",
			Rare = "CometWyvern",
			Epic = "AuroraSerpent",
			Legendary = "GalaxyWarden",
			Mythic = "CelestialSovereign",
		},
		Purchasable = true,
	},
}

-- Display order in the egg shop.
local ShopOrder = { "EmberEgg", "LavaEgg", "ObsidianEgg", "CelestialEgg" }

return {
	Defs = Defs,
	ShopOrder = ShopOrder,
}
