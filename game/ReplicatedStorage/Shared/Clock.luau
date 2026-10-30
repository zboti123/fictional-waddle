--!strict
-- Single time source (seconds, Unix-based) shared by server and client so
-- timestamps stored in attributes line up on both sides.

local Workspace = game:GetService("Workspace")

local Clock = {}

function Clock.Now(): number
	return Workspace:GetServerTimeNow()
end

return Clock
