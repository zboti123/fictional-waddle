--!strict
-- Creates the single ScreenGui and keeps every top-level element scaled to the
-- screen. Design size is 1280x720; on a phone the scale drops so the layout
-- fits, but never below MIN_SCALE so touch targets stay large.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local UIRoot = {}

local DESIGN_SIZE = Vector2.new(1280, 720)
local MIN_SCALE = 0.55
local MAX_SCALE = 1.6

local scaled: { UIScale } = {}
local currentScale = 1

local function computeScale(): number
	local camera = Workspace.CurrentCamera
	if camera == nil then
		return 1
	end
	local viewport = camera.ViewportSize
	local ratio = math.min(viewport.X / DESIGN_SIZE.X, viewport.Y / DESIGN_SIZE.Y)
	return math.clamp(ratio, MIN_SCALE, MAX_SCALE)
end

local function applyScale()
	currentScale = computeScale()
	for index = #scaled, 1, -1 do
		local uiScale = scaled[index]
		if uiScale.Parent == nil then
			table.remove(scaled, index)
		else
			uiScale.Scale = currentScale
			uiScale:SetAttribute("BaseScale", currentScale)
		end
	end
end

-- Adds a UIScale to a top-level element so it follows the screen size.
-- UiKit.Punch reuses this UIScale (an element may only have one).
function UIRoot.Scale(target: GuiObject)
	local uiScale = Instance.new("UIScale")
	uiScale.Name = "ScreenScale"
	uiScale.Scale = currentScale
	uiScale:SetAttribute("BaseScale", currentScale)
	uiScale.Parent = target
	table.insert(scaled, uiScale)
	-- Popups and banners are short-lived; drop them from the list when destroyed.
	uiScale.Destroying:Connect(function()
		local index = table.find(scaled, uiScale)
		if index ~= nil then
			table.remove(scaled, index)
		end
	end)
end

function UIRoot.Create(): ScreenGui
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gui = Instance.new("ScreenGui")
	gui.Name = "HatchUI"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.IgnoreGuiInset = false
	gui.Parent = playerGui

	local function watchCamera()
		local camera = Workspace.CurrentCamera
		if camera ~= nil then
			camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)
		end
		applyScale()
	end
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
	watchCamera()
	return gui
end

return UIRoot
