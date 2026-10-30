--!strict
-- Small UI construction kit: consistent colors, rounded panels, scaled text,
-- and buttons with press feedback. Layout is designed at 1280x720 and scaled
-- per element by UIRoot, so offsets here are "design pixels".

local TweenService = game:GetService("TweenService")

local UiKit = {}

UiKit.Colors = {
	Panel = Color3.fromRGB(34, 26, 40),
	PanelLight = Color3.fromRGB(58, 44, 66),
	Accent = Color3.fromRGB(255, 140, 40),
	Good = Color3.fromRGB(70, 200, 95),
	Bad = Color3.fromRGB(225, 70, 70),
	Disabled = Color3.fromRGB(90, 90, 100),
	Text = Color3.fromRGB(255, 255, 255),
	Muted = Color3.fromRGB(200, 190, 210),
	Stroke = Color3.fromRGB(20, 12, 24),
}

UiKit.Font = Enum.Font.FredokaOne

export type FrameProps = {
	Name: string,
	Size: UDim2,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	Color: Color3?,
	Transparency: number?,
	CornerRadius: number?,
	Parent: Instance,
}

export type LabelProps = {
	Name: string,
	Text: string,
	Size: UDim2,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	TextColor: Color3?,
	MaxTextSize: number?,
	XAlignment: Enum.TextXAlignment?,
	Parent: Instance,
}

export type ButtonProps = {
	Name: string,
	Text: string,
	Size: UDim2,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	Color: Color3?,
	MaxTextSize: number?,
	Parent: Instance,
	OnClick: () -> (),
}

function UiKit.Corner(parent: Instance, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
end

function UiKit.Stroke(parent: Instance, thickness: number, color: Color3)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness
	stroke.Color = color
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
end

function UiKit.Frame(props: FrameProps): Frame
	local frame = Instance.new("Frame")
	frame.Name = props.Name
	frame.Size = props.Size
	frame.Position = props.Position or UDim2.new()
	frame.AnchorPoint = props.AnchorPoint or Vector2.zero
	frame.BackgroundColor3 = props.Color or UiKit.Colors.Panel
	frame.BackgroundTransparency = props.Transparency or 0
	frame.BorderSizePixel = 0
	UiKit.Corner(frame, props.CornerRadius or 16)
	frame.Parent = props.Parent
	return frame
end

function UiKit.Label(props: LabelProps): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = props.Name
	label.Text = props.Text
	label.Size = props.Size
	label.Position = props.Position or UDim2.new()
	label.AnchorPoint = props.AnchorPoint or Vector2.zero
	label.BackgroundTransparency = 1
	label.Font = UiKit.Font
	label.TextColor3 = props.TextColor or UiKit.Colors.Text
	label.TextScaled = true
	label.TextXAlignment = props.XAlignment or Enum.TextXAlignment.Center
	label.TextStrokeTransparency = 0.4
	label.TextStrokeColor3 = UiKit.Colors.Stroke
	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MaxTextSize = props.MaxTextSize or 36
	constraint.MinTextSize = 8
	constraint.Parent = label
	label.Parent = props.Parent
	return label
end

-- Quick scale "punch" on any GuiObject. A GuiObject may only have one UIScale,
-- so screen-scaled elements (UIRoot "ScreenScale") punch around their base scale.
function UiKit.Punch(target: GuiObject, amount: number)
	local uiScale: UIScale
	local base = 1
	local screenScale = target:FindFirstChild("ScreenScale")
	if screenScale ~= nil and screenScale:IsA("UIScale") then
		uiScale = screenScale
		local stored = screenScale:GetAttribute("BaseScale")
		base = if typeof(stored) == "number" then stored else screenScale.Scale
	else
		local existing = target:FindFirstChild("PunchScale")
		if existing ~= nil and existing:IsA("UIScale") then
			uiScale = existing
		else
			local created = Instance.new("UIScale")
			created.Name = "PunchScale"
			created.Parent = target
			uiScale = created
		end
	end
	uiScale.Scale = base * amount
	TweenService:Create(uiScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = base })
		:Play()
end

function UiKit.Button(props: ButtonProps): TextButton
	local button = Instance.new("TextButton")
	button.Name = props.Name
	button.Text = ""
	button.Size = props.Size
	button.Position = props.Position or UDim2.new()
	button.AnchorPoint = props.AnchorPoint or Vector2.zero
	button.BackgroundColor3 = props.Color or UiKit.Colors.Accent
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	UiKit.Corner(button, 14)
	UiKit.Stroke(button, 3, UiKit.Colors.Stroke)

	UiKit.Label({
		Name = "Text",
		Text = props.Text,
		Size = UDim2.new(1, -16, 1, -12),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		MaxTextSize = props.MaxTextSize or 34,
		Parent = button,
	})

	button.Activated:Connect(function()
		UiKit.Punch(button, 0.9)
		props.OnClick()
	end)
	button.Parent = props.Parent
	return button
end

function UiKit.SetButtonText(button: TextButton, text: string)
	local label = button:FindFirstChild("Text")
	if label ~= nil and label:IsA("TextLabel") then
		label.Text = text
	end
end

return UiKit
