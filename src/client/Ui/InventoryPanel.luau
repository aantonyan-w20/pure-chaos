--[[
	InventoryPanel
	The middle-left "Inventory" button and the skin grid it opens.
	Click an owned skin to equip it; the equipped one gets a green
	outline. Previews use the exact same Skins.apply styling that the
	real board marks use, so what you see is what you get.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Skins = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Skins"))
local Widgets = require(script.Parent.Widgets)

local InventoryPanel = {}

local EQUIP_COLOR = Color3.fromRGB(90, 220, 90)
local CELL_COLOR = Color3.fromRGB(48, 52, 64)

local function addSymbolPreview(cell: TextButton, skinId: string, symbol: string, xScale: number)
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.fromScale(0.5, 0.66)
	holder.Position = UDim2.fromScale(xScale, 0.04)
	holder.Parent = cell

	local label = Instance.new("TextLabel")
	label.Parent = holder
	Skins.apply(label, skinId, symbol)
end

local function addCell(scroll: ScrollingFrame, index: number, skinId: string, equipped: boolean, onEquip: (string) -> ())
	local cell = Instance.new("TextButton")
	cell.Text = ""
	cell.LayoutOrder = index
	cell.BackgroundColor3 = CELL_COLOR
	cell.BorderSizePixel = 0
	Widgets.round(cell, 8)

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = EQUIP_COLOR
	stroke.Enabled = equipped
	stroke.Parent = cell

	addSymbolPreview(cell, skinId, "X", 0)
	addSymbolPreview(cell, skinId, "O", 0.5)

	local skin = Skins.Catalog[skinId]
	local name = Widgets.label(cell, skin and skin.name or skinId, UDim2.fromScale(0.94, 0.22), UDim2.fromScale(0.03, 0.74))
	if equipped then
		name.TextColor3 = EQUIP_COLOR
	end

	cell.Activated:Connect(function()
		onEquip(skinId)
	end)
	cell.Parent = scroll
end

function InventoryPanel.create(gui: ScreenGui, onEquip: (string) -> (), onOpened: () -> ())
	local panel = Widgets.frame(
		gui,
		UDim2.new(0, 372, 0, 340),
		UDim2.new(0, 154, 0.5, 0),
		Vector2.new(0, 0.5)
	)
	panel.Visible = false
	Widgets.label(panel, "Your X & O skins", UDim2.new(1, -20, 0, 28), UDim2.new(0, 10, 0, 8))

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -16, 1, -48)
	scroll.Position = UDim2.new(0, 8, 0, 42)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 6
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new()
	scroll.Parent = panel

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0, 108, 0, 112)
	grid.CellPadding = UDim2.new(0, 8, 0, 8)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = scroll

	Widgets.button(gui, "Inventory", UDim2.new(0, 130, 0, 44), UDim2.new(0, 12, 0.5, -26), function()
		panel.Visible = not panel.Visible
		if panel.Visible then
			onOpened()
		end
	end, Vector2.new(0, 0.5))

	local lastProfile = nil
	local function rebuild()
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		if not lastProfile then
			return
		end
		for index, skinId in ipairs(Skins.sortByOrder(lastProfile.owned)) do
			addCell(scroll, index, skinId, skinId == lastProfile.equipped, onEquip)
		end
	end

	return {
		update = function(profile)
			lastProfile = profile
			rebuild()
		end,
		close = function()
			panel.Visible = false
		end,
	}
end

return InventoryPanel
