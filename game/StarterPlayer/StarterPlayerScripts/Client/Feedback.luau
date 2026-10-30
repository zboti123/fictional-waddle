--!strict
-- "Juice": toasts, +gem popups, the hatch reveal card, server-wide banners
-- and camera shake on rare results. All of it is cosmetic and client-side.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local Types = require(Shared:WaitForChild("Types"))
local Format = require(Shared:WaitForChild("Format"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Rarities = require(Config:WaitForChild("Rarities"))

local Client = script.Parent
local UiKit = require(Client:WaitForChild("UiKit"))
local UIRoot = require(Client:WaitForChild("UIRoot"))

local Feedback = {}

local NOTICE_COLORS: { [string]: Color3 } = {
	Info = Color3.fromRGB(70, 90, 140),
	Success = Color3.fromRGB(50, 150, 75),
	Error = Color3.fromRGB(170, 55, 55),
}
local MAX_TOASTS = 3
local SHAKE_BIND = "HatchShake"

local shakeUntil = 0
local shakeStrength = 0

-- Camera shake that decays over `duration`; stronger calls override weaker ones.
function Feedback.Shake(strength: number, duration: number)
	local now = os.clock()
	if now < shakeUntil and strength < shakeStrength then
		return
	end
	shakeStrength = strength
	shakeUntil = now + duration
	local startedAt = now
	RunService:UnbindFromRenderStep(SHAKE_BIND)
	RunService:BindToRenderStep(SHAKE_BIND, Enum.RenderPriority.Camera.Value + 1, function()
		local camera = Workspace.CurrentCamera
		local t = os.clock()
		if camera == nil or t >= shakeUntil then
			RunService:UnbindFromRenderStep(SHAKE_BIND)
			shakeStrength = 0
			return
		end
		local fade = 1 - (t - startedAt) / duration
		local magnitude = shakeStrength * fade
		local offset = Vector3.new(
			(math.noise(t * 25, 0, 0)) * magnitude,
			(math.noise(0, t * 25, 0)) * magnitude,
			0
		)
		camera.CFrame = camera.CFrame * CFrame.new(offset)
	end)
end

local function fadeOutAndDestroy(frame: GuiObject, delaySeconds: number)
	task.delay(delaySeconds, function()
		local tween = TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
		for _, descendant in frame:GetDescendants() do
			if descendant:IsA("TextLabel") then
				TweenService:Create(descendant, TweenInfo.new(0.3), { TextTransparency = 1, TextStrokeTransparency = 1 })
					:Play()
			elseif descendant:IsA("UIStroke") then
				TweenService:Create(descendant, TweenInfo.new(0.3), { Transparency = 1 }):Play()
			end
		end
		tween:Play()
		tween.Completed:Wait()
		frame:Destroy()
	end)
end

function Feedback.Start(gui: ScreenGui, gemsLabel: TextLabel)
	-- Toasts (personal notices).
	local toastArea = Instance.new("Frame")
	toastArea.Name = "Toasts"
	toastArea.AnchorPoint = Vector2.new(0.5, 0)
	toastArea.Position = UDim2.fromScale(0.5, 0.3)
	toastArea.Size = UDim2.fromOffset(600, 220)
	toastArea.BackgroundTransparency = 1
	toastArea.Parent = gui
	UIRoot.Scale(toastArea)
	local toastLayout = Instance.new("UIListLayout")
	toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
	toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	toastLayout.Padding = UDim.new(0, 8)
	toastLayout.Parent = toastArea
	local toastCounter = 0

	Remotes.Get("Notify").OnClientEvent:Connect(function(payload: unknown)
		if typeof(payload) ~= "table" then
			return
		end
		local notice = payload :: Types.Notice
		toastCounter += 1
		local toast = UiKit.Frame({
			Name = "Toast",
			Size = UDim2.fromOffset(580, 60),
			Color = NOTICE_COLORS[notice.Kind] or NOTICE_COLORS.Info,
			Parent = toastArea,
		})
		toast.LayoutOrder = toastCounter
		UiKit.Label({
			Name = "Text",
			Text = tostring(notice.Text),
			Size = UDim2.new(1, -20, 1, -10),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			MaxTextSize = 28,
			Parent = toast,
		})
		UiKit.Punch(toast, 0.8)
		local toasts: { Frame } = {}
		for _, child in toastArea:GetChildren() do
			if child.Name == "Toast" and child:IsA("Frame") then
				table.insert(toasts, child)
			end
		end
		table.sort(toasts, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)
		for i = 1, #toasts - MAX_TOASTS do
			toasts[i]:Destroy()
		end
		fadeOutAndDestroy(toast, 2.5)
	end)

	-- "+123 💎" popups when collecting the gem pile.
	Remotes.Get("Collected").OnClientEvent:Connect(function(payload: unknown)
		if typeof(payload) ~= "table" then
			return
		end
		local collected = payload :: Types.Collected
		local holder = Instance.new("Frame")
		holder.Name = "GemPopup"
		holder.AnchorPoint = Vector2.new(0.5, 1)
		holder.Position = UDim2.fromScale(0.5, 0.78)
		holder.Size = UDim2.fromOffset(360, 80)
		holder.BackgroundTransparency = 1
		holder.Parent = gui
		UIRoot.Scale(holder)
		local label = UiKit.Label({
			Name = "Text",
			Text = `+{Format.Number(collected.Amount)} 💎`,
			Size = UDim2.fromScale(1, 1),
			TextColor = Color3.fromRGB(120, 230, 255),
			MaxTextSize = 64,
			Parent = holder,
		})
		UiKit.Punch(holder, 1.4)
		UiKit.Punch(gemsLabel, 1.15)
		local rise = TweenService:Create(
			holder,
			TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = UDim2.fromScale(0.5, 0.6) }
		)
		TweenService:Create(label, TweenInfo.new(0.9), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		rise:Play()
		rise.Completed:Connect(function()
			holder:Destroy()
		end)
	end)

	-- Hatch reveal card.
	local reveal = UiKit.Frame({
		Name = "HatchReveal",
		Size = UDim2.fromOffset(600, 280),
		Position = UDim2.fromScale(0.5, 0.48),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = gui,
	})
	reveal.Visible = false
	reveal.ZIndex = 10
	UiKit.Stroke(reveal, 5, UiKit.Colors.Stroke)
	UIRoot.Scale(reveal)
	local revealHeader = UiKit.Label({
		Name = "Header",
		Text = "",
		Size = UDim2.new(1, -24, 0, 40),
		Position = UDim2.fromOffset(12, 14),
		TextColor = UiKit.Colors.Muted,
		MaxTextSize = 30,
		Parent = reveal,
	})
	local revealName = UiKit.Label({
		Name = "Name",
		Text = "",
		Size = UDim2.new(1, -24, 0, 90),
		Position = UDim2.fromOffset(12, 60),
		MaxTextSize = 72,
		Parent = reveal,
	})
	local revealDetail = UiKit.Label({
		Name = "Detail",
		Text = "",
		Size = UDim2.new(1, -24, 0, 70),
		Position = UDim2.fromOffset(12, 160),
		TextColor = UiKit.Colors.Text,
		MaxTextSize = 30,
		Parent = reveal,
	})
	local revealToken = 0

	Remotes.Get("HatchResult").OnClientEvent:Connect(function(payload: unknown)
		if typeof(payload) ~= "table" then
			return
		end
		local result = payload :: Types.HatchResult
		local rarity = Rarities.Defs[result.Rarity]
		local color = if rarity ~= nil then rarity.Color else UiKit.Colors.Text
		local order = if rarity ~= nil then rarity.Order else 1

		revealHeader.Text = if result.Source == "Wild" then "🌋 WILD EGG HATCHED!" else "🥚 YOUR EGG HATCHED!"
		revealName.Text = string.upper(result.DragonName)
		revealName.TextColor3 = color
		local lines = { rarity and rarity.DisplayName or result.Rarity }
		if result.OneIn >= 50 then
			table.insert(lines, `1 in {Format.Number(result.OneIn)}`)
		end
		if result.EmbersAwarded > 0 then
			table.insert(lines, `+{result.EmbersAwarded} 🔥`)
		end
		revealDetail.Text = table.concat(lines, "  ·  ")
		reveal.BackgroundColor3 = UiKit.Colors.Panel

		reveal.Visible = true
		UiKit.Punch(reveal, 0.3)
		if order >= 4 or result.Mutation ~= "None" then
			Feedback.Shake(0.15 * order, 0.35 + 0.1 * order)
		end

		revealToken += 1
		local token = revealToken
		task.delay(if order >= 4 then 3.5 else 2.2, function()
			if token == revealToken then
				reveal.Visible = false
			end
		end)
	end)

	-- Server-wide announcement banners, shown one at a time.
	local queue: { Types.Announcement } = {}
	local showing = false
	local function showNext()
		local nextAnnouncement = table.remove(queue, 1)
		if nextAnnouncement == nil then
			showing = false
			return
		end
		showing = true
		local big = nextAnnouncement.Big == true
		local banner = UiKit.Frame({
			Name = "Announcement",
			Size = UDim2.fromOffset(if big then 1000 else 860, if big then 96 else 68),
			Position = UDim2.fromScale(0.5, 0.24),
			AnchorPoint = Vector2.new(0.5, 0),
			Color = UiKit.Colors.Panel,
			Transparency = 0.05,
			Parent = gui,
		})
		banner.ZIndex = 8
		UiKit.Stroke(banner, if big then 5 else 3, nextAnnouncement.Color)
		UIRoot.Scale(banner)
		UiKit.Label({
			Name = "Text",
			Text = tostring(nextAnnouncement.Text),
			Size = UDim2.new(1, -24, 1, -12),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			TextColor = nextAnnouncement.Color,
			MaxTextSize = if big then 44 else 30,
			Parent = banner,
		})
		UiKit.Punch(banner, if big then 1.3 else 1.1)
		if big then
			Feedback.Shake(0.25, 0.4)
		end
		local duration = if big then 5 else 3.5
		fadeOutAndDestroy(banner, duration)
		task.delay(duration + 0.35, showNext)
	end

	Remotes.Get("Announce").OnClientEvent:Connect(function(payload: unknown)
		if typeof(payload) ~= "table" then
			return
		end
		table.insert(queue, payload :: Types.Announcement)
		if not showing then
			showNext()
		end
	end)
end

return Feedback
