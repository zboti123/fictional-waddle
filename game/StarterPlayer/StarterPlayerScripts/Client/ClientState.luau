--!strict
-- Latest server snapshot for the UI. Display only: the client never decides
-- balances, prices or results.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Types = require(Shared:WaitForChild("Types"))
local Remotes = require(Shared:WaitForChild("Remotes"))

type Listener = (Types.Snapshot) -> ()

local ClientState = {}

local snapshot: Types.Snapshot? = nil
local listeners: { Listener } = {}

function ClientState.Get(): Types.Snapshot?
	return snapshot
end

-- Calls the listener now (if a snapshot exists) and on every change.
function ClientState.OnChanged(listener: Listener)
	table.insert(listeners, listener)
	local current = snapshot
	if current ~= nil then
		task.spawn(listener, current)
	end
end

function ClientState.Start()
	Remotes.Get("StateSync").OnClientEvent:Connect(function(payload: unknown)
		if typeof(payload) ~= "table" then
			return
		end
		local next = payload :: Types.Snapshot
		snapshot = next
		for _, listener in listeners do
			task.spawn(listener, next)
		end
	end)
end

return ClientState
