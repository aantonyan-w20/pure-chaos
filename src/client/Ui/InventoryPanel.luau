--[[
	InventoryPanel
	The middle-left "Inventory" button and the panel it opens. The top
	shows free rolls earned from the secret button (click to claim one,
	which rolls a skin for free); below is the grid of owned skins —
	click an owned skin to equip it (the equipped one gets a green
	outline). Previews use the same Skins.apply styling as the board.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Skins = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Skins"))
local Widgets = require(script.Parent.Widgets)

local InventoryPanel = {}

local EQUIP_COLOR = Color3.fromRGB(90, 220, 90)
local CELL_COLOR = Color3.fromRGB(48, 52, 64)
local FREE_ROLLS = { { id = "mega", label = "Mega" }, { id = "lucky", label = "Lucky" } }

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

-- Builds the free-roll claim buttons; returns a function to refresh the counts.
local function buildFreeRolls(panel: Frame, onClaim: (string) -> any): (table) -> ()
	local result = Widgets.label(panel, "", UDim2.new(1, -20, 0, 22), UDim2.new(0, 10, 0, 78))
	result.TextColor3 = Color3.fromRGB(255, 225, 120)

	local function claim(rollId: string)
		local outcome = onClaim(rollId)
		if type(outcome) == "table" and outcome.ok then
			local skin = Skins.Catalog[outcome.skinId]
			result.Text = "Got " .. (skin and skin.name or outcome.skinId) .. (outcome.isNew and " — NEW!" or "")
		elseif type(outcome) == "table" and outcome.reason == "NoFreeRolls" then
			result.Text = "No free rolls left"
		else
			result.Text = "Try again"
		end
	end

	local buttons = {}
	for i, entry in ipairs(FREE_ROLLS) do
		buttons[entry.id] = Widgets.button(
			panel,
			entry.label .. " x0",
			UDim2.new(0, 170, 0, 34),
			UDim2.new(0, 10 + (i - 1) * 180, 0, 40),
			function()
				claim(entry.id)
			end
		)
	end

	return function(freeRolls)
		for _, entry in ipairs(FREE_ROLLS) do
			local count = (freeRolls or {})[entry.id] or 0
			buttons[entry.id].Text = entry.label .. " x" .. tostring(count)
		end
	end
end

function InventoryPanel.create(gui: ScreenGui, onEquip: (string) -> (), onClaim: (string) -> any, onOpened: () -> ())
	local panel = Widgets.frame(gui, UDim2.new(0, 372, 0, 410), UDim2.new(0, 154, 0.5, 0), Vector2.new(0, 0.5))
	panel.Visible = false
	Widgets.label(panel, "Free rolls & your skins", UDim2.new(1, -20, 0, 26), UDim2.new(0, 10, 0, 8))

	local refreshFreeRolls = buildFreeRolls(panel, onClaim)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -16, 1, -116)
	scroll.Position = UDim2.new(0, 8, 0, 108)
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
			refreshFreeRolls(profile.freeRolls)
			rebuild()
		end,
		close = function()
			panel.Visible = false
		end,
	}
end

return InventoryPanel
