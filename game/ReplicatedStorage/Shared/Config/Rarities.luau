--!strict
-- Rarity tiers. BaseProduction is gems per second before egg tier, mutation,
-- nest and rebirth multipliers. Announce controls the server-wide banner.

local Types = require(script.Parent.Parent.Types)

local Defs: { [string]: Types.RarityDef } = {
	Common = {
		Id = "Common",
		DisplayName = "Common",
		Order = 1,
		Color = Color3.fromRGB(190, 190, 190),
		BaseProduction = 1,
		Announce = "None",
	},
	Uncommon = {
		Id = "Uncommon",
		DisplayName = "Uncommon",
		Order = 2,
		Color = Color3.fromRGB(85, 205, 95),
		BaseProduction = 2,
		Announce = "None",
	},
	Rare = {
		Id = "Rare",
		DisplayName = "Rare",
		Order = 3,
		Color = Color3.fromRGB(60, 145, 255),
		BaseProduction = 5,
		Announce = "None",
	},
	Epic = {
		Id = "Epic",
		DisplayName = "Epic",
		Order = 4,
		Color = Color3.fromRGB(175, 85, 255),
		BaseProduction = 12,
		Announce = "Server",
	},
	Legendary = {
		Id = "Legendary",
		DisplayName = "Legendary",
		Order = 5,
		Color = Color3.fromRGB(255, 190, 40),
		BaseProduction = 30,
		Announce = "Server",
	},
	Mythic = {
		Id = "Mythic",
		DisplayName = "Mythic",
		Order = 6,
		Color = Color3.fromRGB(255, 60, 115),
		BaseProduction = 100,
		Announce = "Global",
	},
}

local Order = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic" }

return {
	Defs = Defs,
	Order = Order,
}
