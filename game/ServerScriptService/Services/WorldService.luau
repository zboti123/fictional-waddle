--!strict
-- Builds the shared world (ground, volcano, eruption field) from config at
-- server start and exposes part/billboard helpers used by other services.
-- Everything is anchored, low part count, and shadows are off on small parts.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local World = require(ReplicatedStorage.Shared.Config.World)

export type PartProps = {
	Name: string,
	Size: Vector3,
	CFrame: CFrame,
	Color: Color3,
	Material: Enum.Material?,
	Shape: Enum.PartType?,
	CanCollide: boolean?,
	CastShadow: boolean?,
	Transparency: number?,
	Parent: Instance,
}

local WorldService = {}

local LAVA_IDLE = Color3.fromRGB(200, 70, 20)
local LAVA_ERUPTING = Color3.fromRGB(255, 160, 40)
local ROCK = Color3.fromRGB(70, 56, 52)

local wildEggContainer: Model? = nil
local lavaTop: BasePart? = nil
local volcanoFire: Fire? = nil

function WorldService.MakePart(props: PartProps): Part
	local part = Instance.new("Part")
	part.Name = props.Name
	part.Anchored = true
	if props.Shape ~= nil then
		part.Shape = props.Shape
	end
	part.Size = props.Size
	part.CFrame = props.CFrame
	part.Color = props.Color
	part.Material = props.Material or Enum.Material.SmoothPlastic
	part.CanCollide = if props.CanCollide == nil then true else props.CanCollide
	part.CastShadow = if props.CastShadow == nil then true else props.CastShadow
	part.Transparency = props.Transparency or 0
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = props.Parent
	return part
end

-- Upright cylinder (Roblox cylinders run along X, so this rotates it to stand on Y).
function WorldService.VerticalCylinder(
	name: string,
	center: CFrame,
	diameter: number,
	height: number,
	color: Color3,
	material: Enum.Material,
	parent: Instance
): Part
	return WorldService.MakePart({
		Name = name,
		Size = Vector3.new(height, diameter, diameter),
		CFrame = center * CFrame.Angles(0, 0, math.rad(90)),
		Color = color,
		Material = material,
		Shape = Enum.PartType.Cylinder,
		Parent = parent,
	})
end

-- BillboardGui named "Label" with a TextLabel named "Text". Clients update the text.
function WorldService.MakeBillboard(adornee: BasePart, studs: Vector2, offsetY: number, maxDistance: number): TextLabel
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.new(studs.X, 0, studs.Y, 0)
	gui.StudsOffsetWorldSpace = Vector3.new(0, offsetY, 0)
	gui.MaxDistance = maxDistance
	gui.LightInfluence = 0
	gui.Adornee = adornee

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.3
	label.Text = ""
	label.Parent = gui

	gui.Parent = adornee
	return label
end

function WorldService.PlotAnchor(index: number): CFrame
	local angle = (index - 1) / World.PlotCount * math.pi * 2
	local position = Vector3.new(math.cos(angle) * World.PlotRadius, 0, math.sin(angle) * World.PlotRadius)
	return CFrame.lookAt(position, Vector3.zero)
end

-- Uniformly random point on the eruption ring, at ground height.
function WorldService.RandomEruptionPoint(rng: Random): Vector3
	local angle = rng:NextNumber() * math.pi * 2
	local inner = World.EruptionRingInner ^ 2
	local outer = World.EruptionRingOuter ^ 2
	local radius = math.sqrt(inner + (outer - inner) * rng:NextNumber())
	return Vector3.new(math.cos(angle) * radius, 0.2, math.sin(angle) * radius)
end

function WorldService.GetWildEggContainer(): Model
	local container = wildEggContainer
	assert(container ~= nil, "WorldService.Build must run first")
	return container
end

function WorldService.SetErupting(erupting: boolean)
	local top = lavaTop
	if top ~= nil then
		top.Color = if erupting then LAVA_ERUPTING else LAVA_IDLE
	end
	local fire = volcanoFire
	if fire ~= nil then
		fire.Enabled = erupting
	end
end

function WorldService.Build()
	local existing = Workspace:FindFirstChild("HatchWorld")
	if existing ~= nil then
		existing:Destroy()
	end

	local model = Instance.new("Model")
	model.Name = "HatchWorld"
	model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent

	WorldService.MakePart({
		Name = "Ground",
		Size = Vector3.new(World.GroundSize, 2, World.GroundSize),
		CFrame = CFrame.new(0, -1, 0),
		Color = Color3.fromRGB(96, 140, 70),
		Material = Enum.Material.Grass,
		Parent = model,
	})

	WorldService.VerticalCylinder(
		"LavaField",
		CFrame.new(0, 0.05, 0),
		World.EruptionRingOuter * 2,
		0.2,
		Color3.fromRGB(60, 48, 44),
		Enum.Material.Basalt,
		model
	)

	-- Volcano: three stacked tiers, narrowing toward the top.
	local tiers = {
		{ Diameter = 1.0, Height = 0.45 },
		{ Diameter = 0.75, Height = 0.3 },
		{ Diameter = 0.5, Height = 0.25 },
	}
	local y = 0
	for index, tier in tiers do
		local height = World.VolcanoHeight * tier.Height
		WorldService.VerticalCylinder(
			`VolcanoTier{index}`,
			CFrame.new(0, y + height / 2, 0),
			World.VolcanoRadius * 2 * tier.Diameter,
			height,
			ROCK,
			Enum.Material.Basalt,
			model
		)
		y += height
	end

	local top = WorldService.VerticalCylinder(
		"LavaTop",
		CFrame.new(0, y + 0.3, 0),
		World.VolcanoRadius * 0.8,
		0.6,
		LAVA_IDLE,
		Enum.Material.Neon,
		model
	)
	top.CastShadow = false
	lavaTop = top

	-- Upright, invisible holder so the fire points straight up.
	local vent = WorldService.MakePart({
		Name = "Vent",
		Size = Vector3.new(2, 2, 2),
		CFrame = CFrame.new(0, y + 1.5, 0),
		Color = LAVA_IDLE,
		CanCollide = false,
		CastShadow = false,
		Transparency = 1,
		Parent = model,
	})
	local fire = Instance.new("Fire")
	fire.Size = 25
	fire.Heat = 25
	fire.Enabled = false
	fire.Parent = vent
	volcanoFire = fire

	local container = Instance.new("Model")
	container.Name = "WildEggs"
	container.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	container.Parent = model
	wildEggContainer = container

	model.Parent = Workspace
end

return WorldService
