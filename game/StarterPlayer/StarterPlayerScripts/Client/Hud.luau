--!strict
-- Always-visible HUD: currency counters with a rolling number tween, gem rate,
-- the eruption countdown banner, and the two big bottom buttons.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Types = require(Shared:WaitForChild("Types"))
local Format = require(Shared:WaitForChild("Format"))
local Clock = require(Shared:WaitForChild("Clock"))

local Client = script.Parent
local UiKit = require(Client:WaitForChild("UiKit"))
local UIRoot = require(Client:WaitForChild("UIRoot"))
local ClientState = require(Client:WaitForChild("ClientState"))

export type Callbacks = {
	OnEggs: () -> (),
	OnNest: () -> (),
}

export type HudHandle = {
	GemsLabel: TextLabel,
}

local Hud = {}

local ERUPTION_COLOR = Color3.fromRGB(255, 110, 30)
local CALM_COLOR = Color3.fromRGB(70, 50, 60)

local function rollingNumber(label: TextLabel, prefix: string): (number) -> ()
	local value = Instance.new("NumberValue")
	value.Value = 0
	value.Changed:Connect(function(current: number)
		label.Text = prefix .. Format.Number(math.floor(current))
	end)
	label.Text = prefix .. "0"
	return function(target: number)
		TweenService:Create(value, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Value = target })
			:Play()
	end
end

function Hud.Create(gui: ScreenGui, callbacks: Callbacks): HudHandle
	-- Top stack: currencies, rate and eruption banner, scaled as one unit.
	local top = Instance.new("Frame")
	top.Name = "TopStack"
	top.AnchorPoint = Vector2.new(0.5, 0)
	top.Position = UDim2.new(0.5, 0, 0, 8)
	top.Size = UDim2.fromOffset(560, 168)
	top.BackgroundTransparency = 1
	top.Parent = gui
	UIRoot.Scale(top)

	local bar = UiKit.Frame({
		Name = "Currencies",
		Size = UDim2.fromOffset(560, 100),
		Color = UiKit.Colors.Panel,
		Transparency = 0.1,
		Parent = top,
	})
	UiKit.Stroke(bar, 3, UiKit.Colors.Stroke)

	local gemsLabel = UiKit.Label({
		Name = "Gems",
		Text = "💎 0",
		Size = UDim2.new(0.62, -12, 0, 60),
		Position = UDim2.fromOffset(12, 6),
		MaxTextSize = 44,
		XAlignment = Enum.TextXAlignment.Left,
		Parent = bar,
	})
	local embersLabel = UiKit.Label({
		Name = "Embers",
		Text = "🔥 0",
		Size = UDim2.new(0.38, -12, 0, 60),
		Position = UDim2.new(0.62, 0, 0, 6),
		MaxTextSize = 40,
		XAlignment = Enum.TextXAlignment.Right,
		Parent = bar,
	})
	local rateLabel = UiKit.Label({
		Name = "Rate",
		Text = "+0 💎/s",
		Size = UDim2.new(1, -24, 0, 28),
		Position = UDim2.fromOffset(12, 66),
		TextColor = UiKit.Colors.Muted,
		MaxTextSize = 24,
		XAlignment = Enum.TextXAlignment.Left,
		Parent = bar,
	})

	local banner = UiKit.Frame({
		Name = "EruptionBanner",
		Size = UDim2.fromOffset(520, 52),
		Position = UDim2.fromOffset(20, 112),
		Color = CALM_COLOR,
		Transparency = 0.1,
		Parent = top,
	})
	local bannerLabel = UiKit.Label({
		Name = "Text",
		Text = "",
		Size = UDim2.new(1, -20, 1, -8),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		MaxTextSize = 28,
		Parent = banner,
	})

	local setGems = rollingNumber(gemsLabel, "💎 ")
	local setEmbers = rollingNumber(embersLabel, "🔥 ")
	ClientState.OnChanged(function(snapshot: Types.Snapshot)
		setGems(snapshot.Gems)
		setEmbers(snapshot.Embers)
		rateLabel.Text = `+{Format.Number(snapshot.Rate)} 💎/s  ·  Nest Lv {snapshot.NestLevel}`
	end)

	task.spawn(function()
		while gui.Parent ~= nil do
			local now = Clock.Now()
			if Workspace:GetAttribute("EruptionActive") == true then
				local endsAt = Workspace:GetAttribute("EruptionEndsAt")
				local left = if typeof(endsAt) == "number" then endsAt - now else 0
				bannerLabel.Text = `🌋 ERUPTION! {Format.Duration(left)} — grab wild eggs!`
				banner.BackgroundColor3 = ERUPTION_COLOR
			else
				local nextAt = Workspace:GetAttribute("NextEruptionAt")
				if typeof(nextAt) == "number" and nextAt > 0 then
					bannerLabel.Text = `🌋 Next eruption in {Format.Duration(nextAt - now)}`
				else
					bannerLabel.Text = "🌋 The volcano is rumbling..."
				end
				banner.BackgroundColor3 = CALM_COLOR
			end
			task.wait(0.25)
		end
	end)

	-- Bottom buttons: large touch targets, scaled as one unit.
	local bottom = Instance.new("Frame")
	bottom.Name = "BottomBar"
	bottom.AnchorPoint = Vector2.new(0.5, 1)
	bottom.Position = UDim2.new(0.5, 0, 1, -12)
	bottom.Size = UDim2.fromOffset(480, 104)
	bottom.BackgroundTransparency = 1
	bottom.Parent = gui
	UIRoot.Scale(bottom)

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 24)
	layout.Parent = bottom

	UiKit.Button({
		Name = "EggsButton",
		Text = "🥚 EGGS",
		Size = UDim2.fromOffset(228, 100),
		Color = UiKit.Colors.Accent,
		MaxTextSize = 40,
		Parent = bottom,
		OnClick = callbacks.OnEggs,
	})
	UiKit.Button({
		Name = "NestButton",
		Text = "🪺 NEST",
		Size = UDim2.fromOffset(228, 100),
		Color = UiKit.Colors.Good,
		MaxTextSize = 40,
		Parent = bottom,
		OnClick = callbacks.OnNest,
	})

	return { GemsLabel = gemsLabel }
end

return Hud
