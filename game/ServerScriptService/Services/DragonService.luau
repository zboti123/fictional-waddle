--!strict
-- Dragon inventory. The best dragons are auto-equipped on perches and set the
-- player's production rate. Perch visuals are rebuilt only when they change.

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Types = require(Shared.Types)
local Clock = require(Shared.Clock)
local Formulas = require(Shared.Formulas)
local Economy = require(Shared.Config.Economy)
local Dragons = require(Shared.Config.Dragons)
local Rarities = require(Shared.Config.Rarities)
local Mutations = require(Shared.Config.Mutations)

local Services = script.Parent
local DataService = require(Services.DataService)
local PlotService = require(Services.PlotService)
local ProductionService = require(Services.ProductionService)
local StateSync = require(Services.StateSync)
local WorldService = require(Services.WorldService)

type PerchVisual = {
	Id: string,
	Model: Model,
}

local DragonService = {}

local visualsByPlayer: { [Player]: { [number]: PerchVisual } } = {}

local function findTemplate(dragonId: string): Model?
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	if assets == nil then
		return nil
	end
	local folder = assets:FindFirstChild("Dragons")
	if folder == nil then
		return nil
	end
	local template = folder:FindFirstChild(dragonId)
	if template ~= nil and template:IsA("Model") then
		return template
	end
	return nil
end

local function buildVisual(record: Types.DragonRecord): Model?
	local def = Dragons.Defs[record.Species]
	if def == nil then
		return nil
	end
	local rarity = Rarities.Defs[def.Rarity]
	local mutation = Mutations.Defs[record.Mutation]
	local mutated = mutation ~= nil and record.Mutation ~= "None"

	local model: Model
	local template = findTemplate(def.Id)
	if template ~= nil then
		model = template:Clone()
		for _, descendant in model:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.Anchored = true
				descendant.CanCollide = false
				descendant.CastShadow = false
			end
		end
	else
		model = Instance.new("Model")
		local body = Instance.new("Part")
		body.Name = "Body"
		body.Shape = Enum.PartType.Ball
		body.Size = Vector3.new(3, 3, 3)
		body.Anchored = true
		body.CanCollide = false
		body.CastShadow = false
		body.Material = if mutated then Enum.Material.Neon else Enum.Material.SmoothPlastic
		body.Color = if mutation ~= nil and mutation.Color ~= nil then mutation.Color else def.Color
		body.Parent = model
		model.PrimaryPart = body
	end
	model.Name = def.Id

	local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
	if primary ~= nil and primary:IsA("BasePart") then
		local label = WorldService.MakeBillboard(primary, Vector2.new(7, 1.6), 3, 70)
		local prefix = if mutated and mutation ~= nil then mutation.DisplayName .. " " else ""
		label.Text = prefix .. def.DisplayName
		label.TextColor3 = if rarity ~= nil then rarity.Color else Color3.new(1, 1, 1)
	end

	if record.Mutation == "Rainbow" then
		CollectionService:AddTag(model, "RainbowDragon")
	end
	return model
end

function DragonService.Count(data: Types.PlayerData): number
	local count = 0
	for _ in data.Dragons do
		count += 1
	end
	return count
end

function DragonService.IsFull(player: Player): boolean
	local data = DataService.Get(player)
	if data == nil then
		return true
	end
	return DragonService.Count(data) >= Economy.MaxDragons
end

-- Ids of the highest-producing dragons (up to the perch count) and their rates.
function DragonService.GetEquipped(data: Types.PlayerData): ({ string }, { number })
	local entries: { { Id: string, Rate: number } } = {}
	for id, record in data.Dragons do
		table.insert(entries, { Id = id, Rate = Formulas.DragonRate(record.Species, record.Mutation) })
	end
	table.sort(entries, function(a, b)
		if a.Rate ~= b.Rate then
			return a.Rate > b.Rate
		end
		return a.Id < b.Id
	end)
	local ids: { string } = {}
	local rates: { number } = {}
	for i = 1, math.min(Economy.Perches, #entries) do
		ids[i] = entries[i].Id
		rates[i] = entries[i].Rate
	end
	return ids, rates
end

local function renderPerches(player: Player, data: Types.PlayerData, equipped: { string })
	local plot = PlotService.Get(player)
	if plot == nil then
		return
	end
	local visuals = visualsByPlayer[player]
	if visuals == nil then
		visuals = {}
		visualsByPlayer[player] = visuals
	end
	for index, perchCFrame in plot.PerchCFrames do
		local wantedId = equipped[index]
		local current = visuals[index]
		if current ~= nil and current.Id ~= wantedId then
			current.Model:Destroy()
			visuals[index] = nil
			current = nil
		end
		if current == nil and wantedId ~= nil then
			local record = data.Dragons[wantedId]
			local model = if record ~= nil then buildVisual(record) else nil
			if model ~= nil then
				model:PivotTo(perchCFrame * CFrame.new(0, 2, 0))
				model.Parent = plot.Model
				visuals[index] = { Id = wantedId, Model = model }
			end
		end
	end
end

-- Re-equips the best dragons, updates the production rate and the perches.
function DragonService.Refresh(player: Player)
	local data = DataService.Get(player)
	if data == nil then
		return
	end
	local equipped, rates = DragonService.GetEquipped(data)
	ProductionService.SetRate(player, Formulas.TotalRate(rates, data.NestLevel, data.Rebirths))
	renderPerches(player, data, equipped)
	StateSync.MarkDirty(player)
end

-- Adds a dragon and returns its id, or nil when storage is full.
function DragonService.Add(player: Player, species: string, mutation: string): string?
	local data = DataService.Get(player)
	if data == nil or Dragons.Defs[species] == nil then
		return nil
	end
	if DragonService.Count(data) >= Economy.MaxDragons then
		return nil
	end
	local id = tostring(data.NextDragonId)
	data.NextDragonId += 1
	data.Dragons[id] = {
		Species = species,
		Mutation = mutation,
		ObtainedAt = Clock.Now(),
	}
	DragonService.Refresh(player)
	return id
end

function DragonService.ClearVisuals(player: Player)
	local visuals = visualsByPlayer[player]
	if visuals == nil then
		return
	end
	for _, visual in visuals do
		visual.Model:Destroy()
	end
	visualsByPlayer[player] = nil
end

return DragonService
