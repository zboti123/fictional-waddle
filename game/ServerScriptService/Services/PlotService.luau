--!strict
-- Builds one plot (nest) per server slot, assigns plots to players, sends
-- players home on spawn, and routes ClickDetector clicks to handlers.
-- Clicks on someone else's plot are ignored here, before any handler runs.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local World = require(ReplicatedStorage.Shared.Config.World)
local WorldService = require(script.Parent.WorldService)

export type PlotInfo = {
	Index: number,
	Model: Model,
	SlotModels: { Model },
	SlotPads: { BasePart },
	SlotCFrames: { CFrame },
	PerchCFrames: { CFrame },
	Pile: BasePart,
	SignLabel: TextLabel,
	SpawnCFrame: CFrame,
	Owner: Player?,
}

type SlotHandler = (Player, PlotInfo, number) -> ()
type PileHandler = (Player, PlotInfo) -> ()

local PlotService = {}

local ACTIVE_SLOT = Color3.fromRGB(150, 95, 60)
local LOCKED_SLOT = Color3.fromRGB(70, 70, 75)
local FREE_SIGN_TEXT = "Free Nest"

local plots: { PlotInfo } = {}
local plotByPlayer: { [Player]: PlotInfo } = {}
local slotHandlers: { SlotHandler } = {}
local pileHandlers: { PileHandler } = {}

local function dispatchSlot(player: Player, plot: PlotInfo, index: number)
	if plot.Owner ~= player then
		return
	end
	for _, handler in slotHandlers do
		task.spawn(handler, player, plot, index)
	end
end

local function dispatchPile(player: Player, plot: PlotInfo)
	if plot.Owner ~= player then
		return
	end
	for _, handler in pileHandlers do
		task.spawn(handler, player, plot)
	end
end

local function buildPlot(index: number, parent: Instance): PlotInfo
	local anchor = WorldService.PlotAnchor(index)
	local function at(offset: Vector3): CFrame
		return anchor * CFrame.new(offset)
	end

	local model = Instance.new("Model")
	model.Name = `Plot_{index}`
	model.ModelStreamingMode = Enum.ModelStreamingMode.PersistentPerPlayer
	model:SetAttribute("PlotIndex", index)
	model:SetAttribute("OwnerUserId", 0)

	local base = WorldService.MakePart({
		Name = "Base",
		Size = Vector3.new(World.PlotSize, 1, World.PlotSize),
		CFrame = at(Vector3.new(0, 0.5, 0)),
		Color = Color3.fromRGB(120, 165, 90),
		Material = Enum.Material.Grass,
		Parent = model,
	})
	model.PrimaryPart = base

	-- Nest slots, laid out in a grid behind the perches.
	local slotModels: { Model } = {}
	local slotPads: { BasePart } = {}
	local slotCFrames: { CFrame } = {}
	local slotClicks: { ClickDetector } = {}
	local slotTotal = World.SlotColumns * World.SlotRows
	for i = 1, slotTotal do
		local column = (i - 1) % World.SlotColumns
		local row = math.floor((i - 1) / World.SlotColumns)
		local x = (column - (World.SlotColumns - 1) / 2) * World.SlotSpacing
		local z = World.SlotRowStartZ + row * World.SlotSpacing

		local slotModel = Instance.new("Model")
		slotModel.Name = `Slot_{i}`
		slotModel:SetAttribute("SlotIndex", i)
		local pad = WorldService.VerticalCylinder(
			"Pad",
			at(Vector3.new(x, 1.3, z)),
			6,
			0.6,
			LOCKED_SLOT,
			Enum.Material.Slate,
			slotModel
		)
		pad.CastShadow = false
		slotModel.PrimaryPart = pad

		local click = Instance.new("ClickDetector")
		click.MaxActivationDistance = World.InteractDistance
		click.Parent = slotModel

		slotModel.Parent = model
		CollectionService:AddTag(slotModel, "NestSlot")

		slotModels[i] = slotModel
		slotPads[i] = pad
		slotCFrames[i] = at(Vector3.new(x, 1.6, z))
		slotClicks[i] = click
	end

	-- Perches where equipped dragons sit, facing the player's spawn point.
	local perchCFrames: { CFrame } = {}
	for i = 1, World.PerchCount do
		local x = (i - (World.PerchCount + 1) / 2) * World.PerchSpacing
		local perch = WorldService.VerticalCylinder(
			`Perch_{i}`,
			at(Vector3.new(x, 1.5, World.PerchRowZ)),
			3,
			1,
			Color3.fromRGB(110, 85, 70),
			Enum.Material.Wood,
			model
		)
		perch.CastShadow = false
		perchCFrames[i] = at(Vector3.new(x, 2, World.PerchRowZ))
	end

	local pile = WorldService.MakePart({
		Name = "GemPile",
		Size = Vector3.new(5, 2, 5),
		CFrame = at(World.PileOffset),
		Color = Color3.fromRGB(80, 220, 255),
		Material = Enum.Material.Neon,
		CastShadow = false,
		Parent = model,
	})
	local pileClick = Instance.new("ClickDetector")
	pileClick.MaxActivationDistance = World.InteractDistance
	pileClick.Parent = pile
	WorldService.MakeBillboard(pile, Vector2.new(8, 3), 3.5, 90)
	pile:SetAttribute("Pile", 0)
	pile:SetAttribute("PileAt", 0)
	pile:SetAttribute("Rate", 0)
	pile:SetAttribute("Cap", 0)
	CollectionService:AddTag(pile, "GemPile")

	local sign = WorldService.MakePart({
		Name = "Sign",
		Size = Vector3.new(18, 6, 1),
		CFrame = at(World.SignOffset),
		Color = Color3.fromRGB(90, 60, 40),
		Material = Enum.Material.Wood,
		Parent = model,
	})
	local surface = Instance.new("SurfaceGui")
	surface.Face = Enum.NormalId.Front
	surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surface.PixelsPerStud = 40
	surface.LightInfluence = 0
	surface.Parent = sign
	local signLabel = Instance.new("TextLabel")
	signLabel.Size = UDim2.fromScale(1, 1)
	signLabel.BackgroundTransparency = 1
	signLabel.TextScaled = true
	signLabel.Font = Enum.Font.FredokaOne
	signLabel.TextColor3 = Color3.fromRGB(255, 235, 200)
	signLabel.Text = FREE_SIGN_TEXT
	signLabel.Parent = surface

	local spawnPosition = at(World.SpawnOffset).Position
	local lookTarget = at(Vector3.new(0, World.SpawnOffset.Y, 0)).Position

	local info: PlotInfo = {
		Index = index,
		Model = model,
		SlotModels = slotModels,
		SlotPads = slotPads,
		SlotCFrames = slotCFrames,
		PerchCFrames = perchCFrames,
		Pile = pile,
		SignLabel = signLabel,
		SpawnCFrame = CFrame.lookAt(spawnPosition, lookTarget),
		Owner = nil,
	}

	for i, click in slotClicks do
		click.MouseClick:Connect(function(player: Player)
			dispatchSlot(player, info, i)
		end)
	end
	pileClick.MouseClick:Connect(function(player: Player)
		dispatchPile(player, info)
	end)

	model.Parent = parent
	return info
end

local function sendHome(player: Player)
	local plot = plotByPlayer[player]
	local character = player.Character
	if plot ~= nil and character ~= nil and character.Parent ~= nil then
		character:PivotTo(plot.SpawnCFrame)
	end
end

local function onCharacterAdded(player: Player, character: Model)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if root == nil then
		return
	end
	-- Let the default spawn finish before moving the character.
	task.wait()
	sendHome(player)
end

local function watchCharacters(player: Player)
	player.CharacterAdded:Connect(function(character: Model)
		onCharacterAdded(player, character)
	end)
end

function PlotService.Get(player: Player): PlotInfo?
	return plotByPlayer[player]
end

function PlotService.OnSlotClicked(handler: SlotHandler)
	table.insert(slotHandlers, handler)
end

function PlotService.OnPileClicked(handler: PileHandler)
	table.insert(pileHandlers, handler)
end

-- Server-side distance check; ClickDetector limits alone are not trusted.
function PlotService.IsNear(player: Player, position: Vector3, maxDistance: number): boolean
	local character = player.Character
	if character == nil then
		return false
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil or not root:IsA("BasePart") then
		return false
	end
	return (root.Position - position).Magnitude <= maxDistance
end

function PlotService.Assign(player: Player): PlotInfo?
	local existing = plotByPlayer[player]
	if existing ~= nil then
		return existing
	end
	for _, plot in plots do
		if plot.Owner == nil then
			plot.Owner = player
			plot.Model:SetAttribute("OwnerUserId", player.UserId)
			plot.Model:AddPersistentPlayer(player)
			plot.SignLabel.Text = `{player.DisplayName}'s Nest`
			plotByPlayer[player] = plot
			sendHome(player)
			return plot
		end
	end
	return nil
end

function PlotService.Release(player: Player)
	local plot = plotByPlayer[player]
	if plot == nil then
		return
	end
	plotByPlayer[player] = nil
	pcall(function()
		plot.Model:RemovePersistentPlayer(player)
	end)
	plot.Owner = nil
	plot.Model:SetAttribute("OwnerUserId", 0)
	plot.SignLabel.Text = FREE_SIGN_TEXT
	PlotService.RenderSlots(plot, 0)
end

-- Colors the first activeCount slot pads as usable and the rest as locked.
function PlotService.RenderSlots(plot: PlotInfo, activeCount: number)
	for i, pad in plot.SlotPads do
		local active = i <= activeCount
		pad.Color = if active then ACTIVE_SLOT else LOCKED_SLOT
		pad.Transparency = if active then 0 else 0.4
	end
end

function PlotService.Start()
	local folder = Instance.new("Folder")
	folder.Name = "Plots"
	folder.Parent = Workspace
	for index = 1, World.PlotCount do
		plots[index] = buildPlot(index, folder)
	end

	Players.PlayerAdded:Connect(watchCharacters)
	for _, player in Players:GetPlayers() do
		watchCharacters(player)
	end
end

return PlotService
