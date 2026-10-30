-- Hatch a Dragon installer: paste this whole file into Studio's Command Bar
-- (View -> Command Bar) and press Enter. Safe to run again: it updates in place.
local function ensure(parent, className, name)
	local existing = parent:FindFirstChild(name)
	if existing and existing.ClassName == className then
		return existing
	end
	if existing then
		existing:Destroy()
	end
	local instance = Instance.new(className)
	instance.Name = name
	instance.Parent = parent
	return instance
end
local function setSource(parent, className, name, source)
	local script = ensure(parent, className, name)
	script.Source = source
end
local count = 0

local root = game:GetService("ReplicatedStorage")
local folder1 = ensure(root, "Folder", "Shared")
setSource(folder1, "ModuleScript", "Clock", [=[
--!strict
-- Single time source (seconds, Unix-based) shared by server and client so
-- timestamps stored in attributes line up on both sides.

local Workspace = game:GetService("Workspace")

local Clock = {}

function Clock.Now(): number
	return Workspace:GetServerTimeNow()
end

return Clock
]=])
count += 1
local folder2 = ensure(folder1, "Folder", "Config")
setSource(folder2, "ModuleScript", "Dragons", [=[
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
]=])
count += 1
setSource(folder2, "ModuleScript", "Economy", [=[
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
]=])
count += 1
setSource(folder2, "ModuleScript", "Eggs", [=[
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
]=])
count += 1
setSource(folder2, "ModuleScript", "Eruption", [=[
--!strict
-- Server-wide eruption event. For quick Studio testing, set FirstDelaySeconds to 20.

local Eruption = {
	FirstDelaySeconds = 180,
	IntervalSeconds = 900,
	DurationSeconds = 120,
	-- Gap between back-to-back eruptions when extra ones were triggered.
	QueuedGapSeconds = 30,

	-- Wild eggs hatch instantly when grabbed, always with eruption mutation odds.
	WildEggId = "LavaEgg",
	WildEggsPerPlayer = 1.5,
	MinWildEggs = 3,
	MaxWildEggs = 16,
	SpawnIntervalSeconds = 1.5,
	MaxClaimsPerPlayer = 2,
	ClaimDistance = 30,

	-- Embers awarded per wild egg.
	EmbersMin = 5,
	EmbersMax = 15,
}

return Eruption
]=])
count += 1
setSource(folder2, "ModuleScript", "Mutations", [=[
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
]=])
count += 1
setSource(folder2, "ModuleScript", "Rarities", [=[
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
]=])
count += 1
setSource(folder2, "ModuleScript", "World", [=[
--!strict
-- World layout. Plot-local offsets: -Z points toward the volcano, +X is the plot's right side.

local World = {
	GroundSize = 420,

	PlotCount = 8,
	PlotRadius = 110,
	PlotSize = 64,

	SlotColumns = 4,
	SlotRows = 3,
	SlotSpacing = 8,
	SlotRowStartZ = 6,

	PerchCount = 9,
	PerchSpacing = 4,
	PerchRowZ = -12,

	PileOffset = Vector3.new(24, 2, -2),
	SpawnOffset = Vector3.new(0, 4, -24),
	SignOffset = Vector3.new(0, 6, 29),

	-- Max distance for ClickDetectors on a plot and the matching server-side check.
	InteractDistance = 60,

	VolcanoRadius = 14,
	VolcanoHeight = 36,
	EruptionRingInner = 22,
	EruptionRingOuter = 48,
}

return World
]=])
count += 1
setSource(folder1, "ModuleScript", "Format", [=[
--!strict
-- Number, time and percentage formatting for UI text.

local Format = {}

local SUFFIXES = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }

local function trimZeros(text: string): string
	if string.find(text, ".", 1, true) == nil then
		return text
	end
	local trimmed = string.gsub(text, "0+$", "")
	trimmed = string.gsub(trimmed, "%.$", "")
	return trimmed
end

-- 1234 -> "1.23K", 15 -> "15", 2.5 -> "2.5"
function Format.Number(value: number): string
	if value ~= value then
		return "0"
	end
	local negative = value < 0
	local n = math.abs(value)
	local text: string
	if n < 1000 then
		if n < 10 and n % 1 ~= 0 then
			text = trimZeros(string.format("%.1f", n))
		else
			text = tostring(math.floor(n))
		end
	else
		local index = math.min(math.floor(math.log10(n) / 3), #SUFFIXES - 1)
		local scaled = n / 1000 ^ index
		if scaled >= 999.5 and index < #SUFFIXES - 1 then
			index += 1
			scaled = n / 1000 ^ index
		end
		local pattern = if scaled < 10 then "%.2f" elseif scaled < 100 then "%.1f" else "%.0f"
		text = trimZeros(string.format(pattern, scaled)) .. SUFFIXES[index + 1]
	end
	return if negative then "-" .. text else text
end

-- 75 -> "1:15", 4000 -> "1h 6m"
function Format.Duration(seconds: number): string
	local total = math.max(0, math.ceil(seconds))
	if total >= 3600 then
		local hours = math.floor(total / 3600)
		local minutes = math.floor((total % 3600) / 60)
		return string.format("%dh %dm", hours, minutes)
	end
	local minutes = math.floor(total / 60)
	return string.format("%d:%02d", minutes, total % 60)
end

-- 65 -> "65%", 1.8 -> "1.8%", 0.01 -> "0.01%"
function Format.Percent(percent: number): string
	local pattern = if percent >= 10 then "%.0f" elseif percent >= 1 then "%.1f" else "%.3f"
	return trimZeros(string.format(pattern, percent)) .. "%"
end

return Format
]=])
count += 1
setSource(folder1, "ModuleScript", "Formulas", [=[
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
]=])
count += 1
setSource(folder1, "ModuleScript", "Remotes", [=[
--!strict
-- Central list of RemoteEvents. The server creates them on first use;
-- clients wait for them. Client -> server events carry intents only.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

export type RemoteName =
	"BuyEgg"
	| "UpgradeNest"
	| "BuySlot"
	| "StateSync"
	| "HatchResult"
	| "Announce"
	| "Notify"
	| "Collected"

local FOLDER_NAME = "Remotes"

local Remotes = {}

local function getFolder(): Folder
	if RunService:IsServer() then
		local existing = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
		if existing and existing:IsA("Folder") then
			return existing
		end
		local folder = Instance.new("Folder")
		folder.Name = FOLDER_NAME
		folder.Parent = ReplicatedStorage
		return folder
	end
	return ReplicatedStorage:WaitForChild(FOLDER_NAME) :: Folder
end

function Remotes.Get(name: RemoteName): RemoteEvent
	local folder = getFolder()
	if RunService:IsServer() then
		local existing = folder:FindFirstChild(name)
		if existing and existing:IsA("RemoteEvent") then
			return existing
		end
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
		return remote
	end
	return folder:WaitForChild(name) :: RemoteEvent
end

return Remotes
]=])
count += 1
setSource(folder1, "ModuleScript", "Types", [=[
--!strict
-- Shared type definitions used by config modules, server services and client UI.

export type Currency = "Gems" | "Embers"
export type AnnounceLevel = "None" | "Server" | "Global"
export type NoticeKind = "Info" | "Success" | "Error"

export type RarityDef = {
	Id: string,
	DisplayName: string,
	Order: number,
	Color: Color3,
	BaseProduction: number,
	Announce: AnnounceLevel,
}

export type MutationDef = {
	Id: string,
	DisplayName: string,
	Multiplier: number,
	Color: Color3?,
	AlwaysAnnounce: boolean,
}

export type FixedResult = {
	Species: string,
	Mutation: string,
}

export type EggDef = {
	Id: string,
	DisplayName: string,
	Currency: Currency,
	Price: number,
	HatchSeconds: number,
	MaxTapReduction: number,
	UnlockNestLevel: number,
	UnlockRebirths: number,
	TierMultiplier: number,
	Color: Color3,
	Odds: { [string]: number },
	Species: { [string]: string },
	Fixed: FixedResult?,
	Purchasable: boolean,
}

export type DragonDef = {
	Id: string,
	DisplayName: string,
	Rarity: string,
	EggId: string,
	Color: Color3,
}

export type DragonRecord = {
	Species: string,
	Mutation: string,
	ObtainedAt: number,
}

export type IncubatingEgg = {
	EggId: string,
	StartedAt: number,
	Duration: number,
	Reduced: number,
}

export type PlayerStats = {
	EggsHatched: number,
	GemsEarned: number,
	MythicsHatched: number,
	WildEggsClaimed: number,
}

export type FtueState = {
	StarterGiven: boolean,
}

export type PlayerData = {
	SchemaVersion: number,
	Gems: number,
	Embers: number,
	NestLevel: number,
	Rebirths: number,
	NestSlots: number,
	Incubating: { [string]: IncubatingEgg },
	Dragons: { [string]: DragonRecord },
	NextDragonId: number,
	PileGems: number,
	PileUpdatedAt: number,
	Stats: PlayerStats,
	Ftue: FtueState,
	PurchaseIds: { string },
}

-- Everything the client UI needs, sent by the server after every change.
export type Snapshot = {
	Gems: number,
	Embers: number,
	NestLevel: number,
	NestMaxLevel: number,
	NextNestCost: number?,
	NestSlots: number,
	MaxGemSlots: number,
	NextSlotCost: number?,
	Rate: number,
	DragonCount: number,
	MaxDragons: number,
	Perches: number,
	Rebirths: number,
}

export type HatchResult = {
	Species: string,
	DragonName: string,
	Rarity: string,
	Mutation: string,
	Source: string,
	EmbersAwarded: number,
	OneIn: number,
}

export type Announcement = {
	Text: string,
	Color: Color3,
	Big: boolean,
}

export type Notice = {
	Text: string,
	Kind: NoticeKind,
}

export type Collected = {
	Amount: number,
}

return {}
]=])
count += 1
print(("[Installer] ReplicatedStorage: %d scripts installed"):format(count))
game:GetService("ChangeHistoryService"):SetWaypoint("Hatch a Dragon install")
