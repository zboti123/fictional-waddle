--!strict
-- All dragon species. Rarity and EggId must match the egg that hatches them.
-- To use a custom model, put a Model named after the dragon Id in
-- ReplicatedStorage.Assets.Dragons; otherwise a colored orb is shown.

local Types = require(script.Parent.Parent.Types)

local Defs: { [string]: Types.DragonDef } = {}

local function add(id: string, displayName: string, rarity: string, eggId: string, color: Color3)
	Defs[id] = {
		Id = id,
		DisplayName = displayName,
		Rarity = rarity,
		EggId = eggId,
		Color = color,
	}
end

-- Ember Egg
add("EmberWhelp", "Ember Whelp", "Common", "EmberEgg", Color3.fromRGB(230, 120, 70))
add("EmberDrake", "Ember Drake", "Uncommon", "EmberEgg", Color3.fromRGB(255, 150, 60))
add("CinderWyvern", "Cinder Wyvern", "Rare", "EmberEgg", Color3.fromRGB(120, 110, 110))
add("BlazeSerpent", "Blaze Serpent", "Epic", "EmberEgg", Color3.fromRGB(255, 90, 40))
add("InfernoWarden", "Inferno Warden", "Legendary", "EmberEgg", Color3.fromRGB(255, 60, 20))
add("SolarPhoenix", "Solar Phoenix", "Mythic", "EmberEgg", Color3.fromRGB(255, 220, 90))

-- Lava Egg
add("MagmaPup", "Magma Pup", "Common", "LavaEgg", Color3.fromRGB(200, 80, 50))
add("LavaLurker", "Lava Lurker", "Uncommon", "LavaEgg", Color3.fromRGB(220, 70, 30))
add("MoltenWyvern", "Molten Wyvern", "Rare", "LavaEgg", Color3.fromRGB(255, 110, 0))
add("ScorchHorn", "Scorch Horn", "Epic", "LavaEgg", Color3.fromRGB(180, 40, 30))
add("VolcanoTitan", "Volcano Titan", "Legendary", "LavaEgg", Color3.fromRGB(110, 40, 30))
add("MagmaDragon", "Magma Dragon", "Mythic", "LavaEgg", Color3.fromRGB(255, 70, 0))

-- Obsidian Egg
add("ObsidianShardling", "Obsidian Shardling", "Common", "ObsidianEgg", Color3.fromRGB(60, 50, 70))
add("GlassFang", "Glass Fang", "Uncommon", "ObsidianEgg", Color3.fromRGB(150, 160, 190))
add("NightWyvern", "Night Wyvern", "Rare", "ObsidianEgg", Color3.fromRGB(40, 40, 90))
add("OnyxHydra", "Onyx Hydra", "Epic", "ObsidianEgg", Color3.fromRGB(30, 30, 30))
add("ObsidianColossus", "Obsidian Colossus", "Legendary", "ObsidianEgg", Color3.fromRGB(80, 20, 120))
add("VoidEmperor", "Void Emperor", "Mythic", "ObsidianEgg", Color3.fromRGB(120, 0, 200))

-- Celestial Egg
add("StarWhelp", "Star Whelp", "Common", "CelestialEgg", Color3.fromRGB(220, 230, 255))
add("NebulaDrake", "Nebula Drake", "Uncommon", "CelestialEgg", Color3.fromRGB(160, 120, 255))
add("CometWyvern", "Comet Wyvern", "Rare", "CelestialEgg", Color3.fromRGB(90, 200, 255))
add("AuroraSerpent", "Aurora Serpent", "Epic", "CelestialEgg", Color3.fromRGB(80, 255, 180))
add("GalaxyWarden", "Galaxy Warden", "Legendary", "CelestialEgg", Color3.fromRGB(70, 60, 200))
add("CelestialSovereign", "Celestial Sovereign", "Mythic", "CelestialEgg", Color3.fromRGB(255, 240, 200))

return {
	Defs = Defs,
}
