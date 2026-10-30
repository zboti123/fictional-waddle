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
