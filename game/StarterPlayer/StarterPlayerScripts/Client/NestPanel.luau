--!strict
-- Nest panel: upgrade nest level and buy extra slots. Shows the before/after
-- production multiplier so the value of each upgrade is obvious.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Types = require(Shared:WaitForChild("Types"))
local Format = require(Shared:WaitForChild("Format"))
local Formulas = require(Shared:WaitForChild("Formulas"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local Client = script.Parent
local UiKit = require(Client:WaitForChild("UiKit"))
local UIRoot = require(Client:WaitForChild("UIRoot"))
local ClientState = require(Client:WaitForChild("ClientState"))

export type Panel = {
	Open: () -> (),
	Close: () -> (),
	Toggle: () -> (),
}

local NestPanel = {}

local function multiplierText(level: number): string
	return "×" .. string.format("%.2f", Formulas.NestMultiplier(level))
end

local function row(parent: Instance, name: string, y: number): (TextLabel, TextLabel)
	local title = UiKit.Label({
		Name = name .. "Title",
		Text = "",
		Size = UDim2.new(0.58, -24, 0, 44),
		Position = UDim2.fromOffset(24, y),
		MaxTextSize = 34,
		XAlignment = Enum.TextXAlignment.Left,
		Parent = parent,
	})
	local detail = UiKit.Label({
		Name = name .. "Detail",
		Text = "",
		Size = UDim2.new(0.58, -24, 0, 30),
		Position = UDim2.fromOffset(24, y + 46),
		TextColor = UiKit.Colors.Muted,
		MaxTextSize = 24,
		XAlignment = Enum.TextXAlignment.Left,
		Parent = parent,
	})
	return title, detail
end

function NestPanel.Create(gui: ScreenGui): Panel
	local upgradeRemote = Remotes.Get("UpgradeNest")
	local slotRemote = Remotes.Get("BuySlot")

	local panel = UiKit.Frame({
		Name = "NestPanel",
		Size = UDim2.fromOffset(720, 470),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = gui,
	})
	UiKit.Stroke(panel, 4, UiKit.Colors.Stroke)
	panel.Visible = false
	panel.ZIndex = 5
	UIRoot.Scale(panel)

	UiKit.Label({
		Name = "Title",
		Text = "🪺 Your Nest",
		Size = UDim2.new(1, -120, 0, 64),
		Position = UDim2.fromOffset(24, 12),
		MaxTextSize = 48,
		XAlignment = Enum.TextXAlignment.Left,
		Parent = panel,
	})

	local levelTitle, levelDetail = row(panel, "Level", 96)
	local upgradeButton = UiKit.Button({
		Name = "Upgrade",
		Text = "UPGRADE",
		Size = UDim2.fromOffset(268, 84),
		Position = UDim2.new(1, -24, 0, 92),
		AnchorPoint = Vector2.new(1, 0),
		Color = UiKit.Colors.Good,
		Parent = panel,
		OnClick = function()
			upgradeRemote:FireServer()
		end,
	})

	local slotTitle, slotDetail = row(panel, "Slots", 210)
	local slotButton = UiKit.Button({
		Name = "BuySlot",
		Text = "BUY SLOT",
		Size = UDim2.fromOffset(268, 84),
		Position = UDim2.new(1, -24, 0, 206),
		AnchorPoint = Vector2.new(1, 0),
		Color = UiKit.Colors.Accent,
		Parent = panel,
		OnClick = function()
			slotRemote:FireServer()
		end,
	})

	local dragonsTitle, dragonsDetail = row(panel, "Dragons", 324)

	ClientState.OnChanged(function(snapshot: Types.Snapshot)
		levelTitle.Text = `Nest Level {snapshot.NestLevel}/{snapshot.NestMaxLevel}`
		local nextCost = snapshot.NextNestCost
		if nextCost ~= nil then
			levelDetail.Text = `Production {multiplierText(snapshot.NestLevel)} → {multiplierText(snapshot.NestLevel + 1)}`
			UiKit.SetButtonText(upgradeButton, `UPGRADE 💎 {Format.Number(nextCost)}`)
			upgradeButton.BackgroundColor3 = if snapshot.Gems >= nextCost then UiKit.Colors.Good else UiKit.Colors.Disabled
		else
			levelDetail.Text = `Production {multiplierText(snapshot.NestLevel)} (max)`
			UiKit.SetButtonText(upgradeButton, "MAX")
			upgradeButton.BackgroundColor3 = UiKit.Colors.Disabled
		end

		slotTitle.Text = `Egg Slots {snapshot.NestSlots}`
		local slotCost = snapshot.NextSlotCost
		if slotCost ~= nil then
			slotDetail.Text = `Hatch more eggs at once (gem max {snapshot.MaxGemSlots})`
			UiKit.SetButtonText(slotButton, `+1 SLOT 💎 {Format.Number(slotCost)}`)
			slotButton.BackgroundColor3 = if snapshot.Gems >= slotCost then UiKit.Colors.Accent else UiKit.Colors.Disabled
		else
			slotDetail.Text = "All gem slots unlocked"
			UiKit.SetButtonText(slotButton, "MAX")
			slotButton.BackgroundColor3 = UiKit.Colors.Disabled
		end

		dragonsTitle.Text = `Dragons {snapshot.DragonCount}/{snapshot.MaxDragons}`
		dragonsDetail.Text = `Best {snapshot.Perches} produce +{Format.Number(snapshot.Rate)} 💎/s`
	end)

	local handle: Panel
	handle = {
		Open = function()
			panel.Visible = true
			UiKit.Punch(panel, 0.85)
		end,
		Close = function()
			panel.Visible = false
		end,
		Toggle = function()
			if panel.Visible then
				handle.Close()
			else
				handle.Open()
			end
		end,
	}

	UiKit.Button({
		Name = "Close",
		Text = "✕",
		Size = UDim2.fromOffset(76, 76),
		Position = UDim2.new(1, -12, 0, 12),
		AnchorPoint = Vector2.new(1, 0),
		Color = UiKit.Colors.Bad,
		MaxTextSize = 40,
		Parent = panel,
		OnClick = handle.Close,
	})

	return handle
end

return NestPanel
