--!strict
-- Save-data schema migrations and sanitizing.
--
-- To change the data shape:
--   1. Bump DataTemplate.SchemaVersion (e.g. 1 -> 2) and update DataTemplate.New().
--   2. Add Steps[1] = function(data) ... end that turns a v1 save into a v2 save.
--      New fields with defaults do not need a step (Profile:Reconcile adds them);
--      steps are for renames, moves and value conversions.
-- Steps run on a copy, so a failing step never leaves a half-migrated save.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Economy = require(ReplicatedStorage.Shared.Config.Economy)
local World = require(ReplicatedStorage.Shared.Config.World)
local DataTemplate = require(script.Parent.DataTemplate)

type Step = (data: { [string]: any }) -> ()

local Migrations = {}

-- Steps[n] upgrades a save from version n to version n + 1.
local Steps: { [number]: Step } = {}

local function deepCopy<T>(value: T): T
	if typeof(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, item in value :: any do
		copy[key] = deepCopy(item)
	end
	return copy :: any
end

-- Upgrades `data` in place. Returns false plus a player-facing message when the
-- save cannot be used by this server (it is then left untouched).
function Migrations.Run(data: { [string]: any }): (boolean, string?)
	local current = DataTemplate.SchemaVersion
	local version = if typeof(data.SchemaVersion) == "number" then data.SchemaVersion else 1

	if version > current then
		-- Saved by a newer game version; an old server must not overwrite it.
		return false, "This server runs an older version of the game. Please rejoin to get a new server."
	end
	if version == current then
		data.SchemaVersion = current
		return true, nil
	end

	local copy = deepCopy(data)
	while version < current do
		local step = Steps[version]
		if step == nil then
			warn(`[Migrations] No step from schema v{version}`)
			return false, "We couldn't update your save. Your progress is safe; please try again later."
		end
		local ok, err = pcall(step, copy)
		if not ok then
			warn(`[Migrations] Step v{version} failed: {err}`)
			return false, "We couldn't update your save. Your progress is safe; please try again later."
		end
		version += 1
		copy.SchemaVersion = version
	end

	table.clear(data)
	for key, value in copy do
		data[key] = value
	end
	return true, nil
end

local function validNumber(value: any, fallback: number, min: number, max: number): number
	if typeof(value) ~= "number" or value ~= value then
		return fallback
	end
	return math.clamp(value, min, max)
end

-- Repairs impossible values (NaN, negatives, out-of-range levels) so one bad
-- save can never break server code. Never deletes dragons or eggs.
function Migrations.Sanitize(data: { [string]: any }, userId: number)
	local before = {
		Gems = data.Gems,
		Embers = data.Embers,
		NestLevel = data.NestLevel,
		NestSlots = data.NestSlots,
	}

	data.Gems = validNumber(data.Gems, 0, 0, math.huge)
	data.Embers = validNumber(data.Embers, 0, 0, math.huge)
	data.Rebirths = math.floor(validNumber(data.Rebirths, 0, 0, 1_000))
	data.NestLevel = math.floor(validNumber(data.NestLevel, 1, 1, Economy.NestMaxLevel))
	data.NestSlots = math.floor(
		validNumber(data.NestSlots, Economy.StartingSlots, Economy.StartingSlots, World.SlotColumns * World.SlotRows)
	)
	data.PileGems = validNumber(data.PileGems, 0, 0, math.huge)

	-- Keep new dragon ids above every existing one.
	local highestId = 0
	for id in data.Dragons do
		local numeric = tonumber(id)
		if numeric ~= nil and numeric > highestId then
			highestId = numeric
		end
	end
	data.NextDragonId = math.max(validNumber(data.NextDragonId, 1, 1, math.huge), highestId + 1)

	for key, value in before do
		if value ~= data[key] then
			warn(`[Migrations] Repaired {key} for {userId}: {value} -> {data[key]}`)
		end
	end
end

return Migrations
