--!strict
-- Sends the player's UI snapshot to their client. Changes in the same frame
-- are coalesced into a single send.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)
local Remotes = require(ReplicatedStorage.Shared.Remotes)

type Builder = (Player) -> Types.Snapshot?

local StateSync = {}

local remote = Remotes.Get("StateSync")
local builder: Builder? = nil
local pending: { [Player]: boolean } = {}

-- The bootstrap provides the builder so this module has no service dependencies.
function StateSync.SetBuilder(fn: Builder)
	builder = fn
end

function StateSync.MarkDirty(player: Player)
	if pending[player] then
		return
	end
	pending[player] = true
	task.defer(function()
		pending[player] = nil
		if player.Parent ~= Players then
			return
		end
		local build = builder
		if build == nil then
			return
		end
		local snapshot = build(player)
		if snapshot ~= nil then
			remote:FireClient(player, snapshot)
		end
	end)
end

return StateSync
