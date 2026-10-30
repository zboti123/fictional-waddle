--!strict
-- Default data for a brand-new player. SchemaVersion is bumped whenever the
-- shape changes; migrations are added together with the save-data milestone.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)
local Economy = require(ReplicatedStorage.Shared.Config.Economy)

local DataTemplate = {}

DataTemplate.SchemaVersion = 1

function DataTemplate.New(): Types.PlayerData
	return {
		SchemaVersion = DataTemplate.SchemaVersion,
		Gems = 0,
		Embers = 0,
		NestLevel = 1,
		Rebirths = 0,
		NestSlots = Economy.StartingSlots,
		Incubating = {},
		Dragons = {},
		NextDragonId = 1,
		PileGems = 0,
		PileUpdatedAt = 0,
		Stats = {
			EggsHatched = 0,
			GemsEarned = 0,
			MythicsHatched = 0,
			WildEggsClaimed = 0,
		},
		Ftue = {
			StarterGiven = false,
		},
		PurchaseIds = {},
	}
end

return DataTemplate
