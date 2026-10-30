--!strict
-- World-space labels and effects driven by server attributes: egg countdowns,
-- the gem pile counter, rainbow dragons and the tap wobble on your own eggs.
-- One low-frequency loop updates only what is tagged and streamed in.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Format = require(Shared:WaitForChild("Format"))
local Clock = require(Shared:WaitForChild("Clock"))

local WorldFx = {}

local UPDATE_INTERVAL = 0.2
local READY_COLOR = Color3.fromRGB(120, 255, 140)
local ERUPTION_COLOR = Color3.fromRGB(255, 150, 60)
local WAITING_COLOR = Color3.new(1, 1, 1)

local localPlayer = Players.LocalPlayer

local function labelOf(part: Instance): TextLabel?
	local gui = part:FindFirstChild("Label")
	if gui == nil then
		return nil
	end
	local text = gui:FindFirstChild("Text")
	if text ~= nil and text:IsA("TextLabel") then
		return text
	end
	return nil
end

local function numberAttribute(instance: Instance, name: string): number
	local value = instance:GetAttribute(name)
	return if typeof(value) == "number" then value else 0
end

local function updateEgg(part: Instance, now: number, erupting: boolean)
	local label = labelOf(part)
	if label == nil then
		return
	end
	local name = part:GetAttribute("EggName")
	local remaining = numberAttribute(part, "ReadyAt") - now
	if remaining > 0 then
		label.Text = `{if typeof(name) == "string" then name else "Egg"}\n⏱ {Format.Duration(remaining)}`
		label.TextColor3 = WAITING_COLOR
	elseif erupting then
		label.Text = "🌋 HATCH NOW!\nEruption bonus!"
		label.TextColor3 = ERUPTION_COLOR
	else
		label.Text = "TAP TO HATCH!"
		label.TextColor3 = READY_COLOR
	end
end

local function updatePile(part: Instance, now: number)
	local label = labelOf(part)
	if label == nil then
		return
	end
	local pile = numberAttribute(part, "Pile")
	local rate = numberAttribute(part, "Rate")
	local cap = numberAttribute(part, "Cap")
	local amount = pile + rate * math.max(0, now - numberAttribute(part, "PileAt"))
	local full = rate > 0 and amount >= cap
	if full then
		amount = math.max(pile, cap)
	end
	if amount < 1 then
		label.Text = if rate > 0 then "💎 filling..." else "💎 Hatch dragons\nto earn gems"
	elseif full then
		label.Text = `💎 {Format.Number(math.floor(amount))} FULL!\nTAP TO COLLECT`
	else
		label.Text = `💎 {Format.Number(math.floor(amount))}\nTAP TO COLLECT`
	end
end

local function updateRainbow(model: Instance, now: number)
	local color = Color3.fromHSV((now * 0.25) % 1, 0.8, 1)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Color = color
		end
	end
end

local function isOwnPlot(instance: Instance): boolean
	local current: Instance? = instance
	while current ~= nil do
		local owner = current:GetAttribute("OwnerUserId")
		if owner ~= nil then
			return owner == localPlayer.UserId
		end
		current = current.Parent
	end
	return false
end

-- Instant local wobble when you tap one of your own eggs; the server does the real work.
local function hookSlot(slot: Instance)
	local click = slot:FindFirstChildOfClass("ClickDetector")
	if click == nil then
		return
	end
	click.MouseClick:Connect(function()
		if not isOwnPlot(slot) then
			return
		end
		local egg = slot:FindFirstChild("Egg")
		if egg == nil then
			return
		end
		local mesh = egg:FindFirstChildOfClass("SpecialMesh")
		if mesh == nil then
			return
		end
		mesh.Scale = Vector3.new(1.25, 0.85, 1.25)
		TweenService:Create(mesh, TweenInfo.new(0.25, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
			Scale = Vector3.one,
		}):Play()
	end)
end

function WorldFx.Start()
	for _, slot in CollectionService:GetTagged("NestSlot") do
		hookSlot(slot)
	end
	CollectionService:GetInstanceAddedSignal("NestSlot"):Connect(hookSlot)

	task.spawn(function()
		while true do
			local now = Clock.Now()
			local erupting = Workspace:GetAttribute("EruptionActive") == true
			for _, part in CollectionService:GetTagged("IncubatingEgg") do
				updateEgg(part, now, erupting)
			end
			for _, part in CollectionService:GetTagged("GemPile") do
				updatePile(part, now)
			end
			for _, model in CollectionService:GetTagged("RainbowDragon") do
				updateRainbow(model, now)
			end
			task.wait(UPDATE_INTERVAL)
		end
	end)
end

return WorldFx
