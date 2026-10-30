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
