--!strict
-- Mutations are rolled at the moment an egg hatches. Hatching during an
-- eruption uses EruptionWeights. Weights are relative (they do not need to sum to 100).

local Types = require(script.Parent.Parent.Types)

local Defs: { [string]: Types.MutationDef } = {
	None = {
		Id = "None",
		DisplayName = "",
		Multiplier = 1,
		AlwaysAnnounce = false,
	},
	Golden = {
		Id = "Golden",
		DisplayName = "Golden",
		Multiplier = 3,
		Color = Color3.fromRGB(255, 205, 60),
		AlwaysAnnounce = false,
	},
	Magma = {
		Id = "Magma",
		DisplayName = "Magma",
		Multiplier = 2,
		Color = Color3.fromRGB(255, 100, 30),
		AlwaysAnnounce = false,
	},
	Rainbow = {
		Id = "Rainbow",
		DisplayName = "Rainbow",
		Multiplier = 10,
		Color = Color3.fromRGB(255, 255, 255),
		AlwaysAnnounce = true,
	},
}

local Order = { "None", "Golden", "Magma", "Rainbow" }

local NormalWeights: { [string]: number } = {
	None = 99,
	Golden = 1,
}

local EruptionWeights: { [string]: number } = {
	None = 86,
	Magma = 10,
	Golden = 2,
	Rainbow = 2,
}

return {
	Defs = Defs,
	Order = Order,
	NormalWeights = NormalWeights,
	EruptionWeights = EruptionWeights,
}
