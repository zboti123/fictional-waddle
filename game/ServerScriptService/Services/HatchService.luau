--!strict
-- Turns an egg into a dragon: roll, grant, tell the player, announce if rare.
-- Never yields, so a hatch cannot be interleaved with another request.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Types = require(Shared.Types)
local Remotes = require(Shared.Remotes)
local Formulas = require(Shared.Formulas)
local Eggs = require(Shared.Config.Eggs)
local Dragons = require(Shared.Config.Dragons)
local Mutations = require(Shared.Config.Mutations)

local Services = script.Parent
local DataService = require(Services.DataService)
local DragonService = require(Services.DragonService)
local HatchRoller = require(Services.HatchRoller)
local AnnounceService = require(Services.AnnounceService)

export type HatchContext = {
	Eruption: boolean,
	Source: string,
	EmbersAwarded: number,
}

type Listener = (Player, Types.HatchResult) -> ()

local HatchService = {}

local hatchRemote = Remotes.Get("HatchResult")
local listeners: { Listener } = {}

function HatchService.OnHatched(listener: Listener)
	table.insert(listeners, listener)
end

-- Returns false plus a reason ("StorageFull", "UnknownEgg", ...) when nothing was granted.
function HatchService.Hatch(player: Player, eggId: string, context: HatchContext): (boolean, string?)
	local data = DataService.Get(player)
	if data == nil then
		return false, "NoData"
	end
	local egg = Eggs.Defs[eggId]
	if egg == nil then
		return false, "UnknownEgg"
	end
	if DragonService.IsFull(player) then
		return false, "StorageFull"
	end
	local roll = HatchRoller.Roll(egg, context.Eruption, 1)
	if roll == nil then
		return false, "RollFailed"
	end
	local dragonId = DragonService.Add(player, roll.Species, roll.Mutation)
	if dragonId == nil then
		return false, "StorageFull"
	end

	data.Stats.EggsHatched += 1
	if roll.Rarity == "Mythic" then
		data.Stats.MythicsHatched += 1
	end

	local def = Dragons.Defs[roll.Species]
	local mutation = Mutations.Defs[roll.Mutation]
	local prefix = if mutation ~= nil and mutation.DisplayName ~= "" then mutation.DisplayName .. " " else ""
	local result: Types.HatchResult = {
		Species = roll.Species,
		DragonName = prefix .. (if def ~= nil then def.DisplayName else roll.Species),
		Rarity = roll.Rarity,
		Mutation = roll.Mutation,
		Source = context.Source,
		EmbersAwarded = context.EmbersAwarded,
		OneIn = Formulas.OneIn(egg, roll.Rarity, roll.Mutation, context.Eruption),
	}

	hatchRemote:FireClient(player, result)
	AnnounceService.OnHatch(player, result)
	for _, listener in listeners do
		task.spawn(listener, player, result)
	end
	return true, nil
end

return HatchService
