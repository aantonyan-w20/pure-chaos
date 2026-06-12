--[[
	Widgets
	Tiny factories for the dark frames, labels, and buttons the HUD
	panels share, so each panel file is about layout, not styling.
]]

local Widgets = {}

local PANEL_COLOR = Color3.fromRGB(28, 30, 38)
local BUTTON_COLOR = Color3.fromRGB(55, 60, 75)

function Widgets.round(instance: Instance, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

function Widgets.frame(parent: Instance, size: UDim2, position: UDim2, anchor: Vector2?): Frame
	local frame = Instance.new("Frame")
	frame.Size = size
	frame.Position = position
	frame.AnchorPoint = anchor or Vector2.new(0, 0)
	frame.BackgroundColor3 = PANEL_COLOR
	frame.BackgroundTransparency = 0.15
	frame.BorderSizePixel = 0
	Widgets.round(frame, 10)
	frame.Parent = parent
	return frame
end

function Widgets.label(parent: Instance, text: string, size: UDim2, position: UDim2?): TextLabel
	local label = Instance.new("TextLabel")
	label.Size = size
	label.Position = position or UDim2.new()
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Text = text
	label.Parent = parent
	return label
end

function Widgets.button(
	parent: Instance,
	text: string,
	size: UDim2,
	position: UDim2,
	onClick: () -> (),
	anchor: Vector2?
): TextButton
	local button = Instance.new("TextButton")
	button.Size = size
	button.Position = position
	button.AnchorPoint = anchor or Vector2.new(0, 0)
	button.BackgroundColor3 = BUTTON_COLOR
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Text = text
	Widgets.round(button, 8)
	button.Activated:Connect(onClick)
	button.Parent = parent
	return button
end

return Widgets
