--!strict
-- Egg shop. Every card shows price, hatch time and the exact drop odds
-- before purchase. Buying only sends the egg id; the server decides.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local Types = require(Shared:WaitForChild("Types"))
local Format = require(Shared:WaitForChild("Format"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Eggs = require(Config:WaitForChild("Eggs"))
local Rarities = require(Config:WaitForChild("Rarities"))

local Client = script.Parent
local UiKit = require(Client:WaitForChild("UiKit"))
local UIRoot = require(Client:WaitForChild("UIRoot"))
local ClientState = require(Client:WaitForChild("ClientState"))

export type Panel = {
	Open: () -> (),
	Close: () -> (),
	Toggle: () -> (),
}

type Card = {
	Egg: Types.EggDef,
	BuyButton: TextButton,
	LockLabel: TextLabel,
}

local ShopPanel = {}

local BUY_DEBOUNCE = 0.3

local function currencySymbol(egg: Types.EggDef): string
	return if egg.Currency == "Gems" then "💎" else "🔥"
end

local function buildCard(egg: Types.EggDef, order: number, parent: Instance, onBuy: (string) -> ()): Card
	local card = UiKit.Frame({
		Name = egg.Id,
		Size = UDim2.fromOffset(270, 500),
		Color = UiKit.Colors.PanelLight,
		Parent = parent,
	})
	card.LayoutOrder = order

	local swatch = UiKit.Frame({
		Name = "Egg",
		Size = UDim2.fromOffset(96, 120),
		Position = UDim2.new(0.5, 0, 0, 14),
		AnchorPoint = Vector2.new(0.5, 0),
		Color = egg.Color,
		CornerRadius = 48,
		Parent = card,
	})
	UiKit.Stroke(swatch, 3, UiKit.Colors.Stroke)

	UiKit.Label({
		Name = "Name",
		Text = egg.DisplayName,
		Size = UDim2.new(1, -16, 0, 36),
		Position = UDim2.fromOffset(8, 140),
		MaxTextSize = 30,
		Parent = card,
	})
	UiKit.Label({
		Name = "Price",
		Text = `{currencySymbol(egg)} {Format.Number(egg.Price)}   ⏱ {Format.Duration(egg.HatchSeconds)}`,
		Size = UDim2.new(1, -16, 0, 28),
		Position = UDim2.fromOffset(8, 178),
		TextColor = UiKit.Colors.Muted,
		MaxTextSize = 24,
		Parent = card,
	})

	-- Odds disclosure, shown before purchase.
	local oddsTop = 214
	local line = 0
	for _, rarityId in Rarities.Order do
		local odds = egg.Odds[rarityId]
		local rarity = Rarities.Defs[rarityId]
		if odds ~= nil and odds > 0 and rarity ~= nil then
			UiKit.Label({
				Name = `Odds_{rarityId}`,
				Text = `{rarity.DisplayName}  {Format.Percent(odds)}`,
				Size = UDim2.new(1, -32, 0, 24),
				Position = UDim2.fromOffset(16, oddsTop + line * 27),
				TextColor = rarity.Color,
				MaxTextSize = 22,
				XAlignment = Enum.TextXAlignment.Left,
				Parent = card,
			})
			line += 1
		end
	end

	local lastPress = 0
	local buyButton = UiKit.Button({
		Name = "Buy",
		Text = "BUY",
		Size = UDim2.new(1, -24, 0, 76),
		Position = UDim2.new(0.5, 0, 1, -12),
		AnchorPoint = Vector2.new(0.5, 1),
		Color = UiKit.Colors.Good,
		MaxTextSize = 36,
		Parent = card,
		OnClick = function()
			local now = os.clock()
			if now - lastPress < BUY_DEBOUNCE then
				return
			end
			lastPress = now
			onBuy(egg.Id)
		end,
	})

	local lockLabel = UiKit.Label({
		Name = "Lock",
		Text = "",
		Size = UDim2.new(1, -24, 0, 30),
		Position = UDim2.new(0.5, 0, 1, -94),
		AnchorPoint = Vector2.new(0.5, 1),
		TextColor = UiKit.Colors.Bad,
		MaxTextSize = 24,
		Parent = card,
	})

	return { Egg = egg, BuyButton = buyButton, LockLabel = lockLabel }
end

local function refreshCard(card: Card, snapshot: Types.Snapshot)
	local egg = card.Egg
	local locked = snapshot.NestLevel < egg.UnlockNestLevel or snapshot.Rebirths < egg.UnlockRebirths
	if locked then
		card.LockLabel.Text = if snapshot.Rebirths < egg.UnlockRebirths
			then `🔒 Rebirth {egg.UnlockRebirths}`
			else `🔒 Nest Lv {egg.UnlockNestLevel}`
		card.BuyButton.BackgroundColor3 = UiKit.Colors.Disabled
		UiKit.SetButtonText(card.BuyButton, "LOCKED")
		return
	end
	card.LockLabel.Text = ""
	local balance = if egg.Currency == "Gems" then snapshot.Gems else snapshot.Embers
	local affordable = balance >= egg.Price
	card.BuyButton.BackgroundColor3 = if affordable then UiKit.Colors.Good else UiKit.Colors.Disabled
	UiKit.SetButtonText(card.BuyButton, `BUY {currencySymbol(egg)} {Format.Number(egg.Price)}`)
end

function ShopPanel.Create(gui: ScreenGui): Panel
	local buyRemote = Remotes.Get("BuyEgg")

	local panel = UiKit.Frame({
		Name = "ShopPanel",
		Size = UDim2.fromOffset(940, 640),
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
		Text = "🥚 Egg Shop",
		Size = UDim2.new(1, -120, 0, 64),
		Position = UDim2.fromOffset(24, 12),
		MaxTextSize = 48,
		XAlignment = Enum.TextXAlignment.Left,
		Parent = panel,
	})

	local list = Instance.new("ScrollingFrame")
	list.Name = "Cards"
	list.Size = UDim2.new(1, -32, 1, -100)
	list.Position = UDim2.fromOffset(16, 88)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollingDirection = Enum.ScrollingDirection.X
	list.AutomaticCanvasSize = Enum.AutomaticSize.X
	list.CanvasSize = UDim2.new()
	list.ScrollBarThickness = 10
	list.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 16)
	layout.Parent = list

	local cards: { Card } = {}
	for order, eggId in Eggs.ShopOrder do
		local egg = Eggs.Defs[eggId]
		if egg ~= nil then
			table.insert(cards, buildCard(egg, order, list, function(id: string)
				buyRemote:FireServer(id)
			end))
		end
	end

	ClientState.OnChanged(function(snapshot: Types.Snapshot)
		for _, card in cards do
			refreshCard(card, snapshot)
		end
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

return ShopPanel
