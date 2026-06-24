--[[
	InventoryPanel
	The middle-left "Inventory" button and the panel it opens. The top
	shows free rolls earned from the secret button (click to claim one).
	Two tabs switch the grid between your X/O mark skins and your chair
	skins; click an item to equip it (the equipped one gets a green
	outline). A red "!" badge flags unclaimed free rolls.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Skins = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Skins"))
local ChairSkins = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ChairSkins"))
local Widgets = require(script.Parent.Widgets)

local InventoryPanel = {}

local EQUIP_COLOR = Color3.fromRGB(90, 220, 90)
local CELL_COLOR = Color3.fromRGB(48, 52, 64)
local TAB_ON = Color3.fromRGB(70, 110, 80)
local TAB_OFF = Color3.fromRGB(55, 60, 75)
local FREE_ROLLS = {
	{ id = "mega", label = "Mega" },
	{ id = "lucky", label = "Lucky" },
	{ id = "chairBasic", label = "Chair" },
	{ id = "chairElite", label = "Elite Chair" },
}

local function newCell(scroll: ScrollingFrame, index: number, equipped: boolean): TextButton
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
	cell.Parent = scroll
	return cell
end

local function addMarkPreview(cell: TextButton, skinId: string, symbol: string, xScale: number)
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.fromScale(0.5, 0.66)
	holder.Position = UDim2.fromScale(xScale, 0.04)
	holder.Parent = cell
	local label = Instance.new("TextLabel")
	label.Parent = holder
	Skins.apply(label, skinId, symbol)
end

local function addMarkCell(scroll, index, skinId, equipped, onEquip)
	local cell = newCell(scroll, index, equipped)
	addMarkPreview(cell, skinId, "X", 0)
	addMarkPreview(cell, skinId, "O", 0.5)
	local skin = Skins.Catalog[skinId]
	local name = Widgets.label(cell, skin and skin.name or skinId, UDim2.fromScale(0.94, 0.22), UDim2.fromScale(0.03, 0.74))
	if equipped then
		name.TextColor3 = EQUIP_COLOR
	end
	cell.Activated:Connect(function()
		onEquip("mark", skinId)
	end)
end

local function addChairCell(scroll, index, chairId, equipped, onEquip)
	local cell = newCell(scroll, index, equipped)
	local icon = Instance.new("Frame")
	icon.Size = UDim2.fromScale(0.5, 0.5)
	icon.Position = UDim2.fromScale(0.25, 0.08)
	icon.BackgroundColor3 = ChairSkins.previewColor(chairId)
	icon.BorderSizePixel = 0
	Widgets.round(icon, 6)
	icon.Parent = cell
	local skin = ChairSkins.Catalog[chairId]
	local name = Widgets.label(cell, skin and skin.name or chairId, UDim2.fromScale(0.94, 0.24), UDim2.fromScale(0.03, 0.72))
	if equipped then
		name.TextColor3 = EQUIP_COLOR
	end
	cell.Activated:Connect(function()
		onEquip("chair", chairId)
	end)
end

local function buildFreeRolls(panel: Frame, onClaim: (string) -> any): (table) -> ()
	local result = Widgets.label(panel, "", UDim2.new(1, -20, 0, 22), UDim2.new(0, 10, 0, 118))
	result.TextColor3 = Color3.fromRGB(255, 225, 120)

	local function claim(rollId: string)
		local outcome = onClaim(rollId)
		if type(outcome) == "table" and outcome.ok then
			local catalog = (outcome.kind == "chair") and ChairSkins.Catalog or Skins.Catalog
			local entry = catalog[outcome.skinId]
			local tag = outcome.isNew and " — NEW!" or (" (dupe, +" .. tostring(outcome.refund or 0) .. " Tacs)")
			result.Text = "Got " .. (entry and entry.name or outcome.skinId) .. tag
		elseif type(outcome) == "table" and outcome.reason == "NoFreeRolls" then
			result.Text = "No free rolls left"
		else
			result.Text = "Try again"
		end
	end

	-- two columns, two rows (Mega/Lucky on top, the chair rolls below)
	local buttons = {}
	for i, entry in ipairs(FREE_ROLLS) do
		local col = (i - 1) % 2
		local row = math.floor((i - 1) / 2)
		buttons[entry.id] = Widgets.button(panel, entry.label .. " x0", UDim2.new(0, 170, 0, 34), UDim2.new(0, 10 + col * 180, 0, 40 + row * 38), function()
			claim(entry.id)
		end)
	end

	return function(freeRolls)
		for _, entry in ipairs(FREE_ROLLS) do
			buttons[entry.id].Text = entry.label .. " x" .. tostring((freeRolls or {})[entry.id] or 0)
		end
	end
end

function InventoryPanel.create(gui: ScreenGui, onEquip: (string, string) -> (), onClaim: (string) -> any, onOpened: () -> ())
	local panel = Widgets.frame(gui, UDim2.new(0, 372, 0, 470), UDim2.new(0, 154, 0.5, 0), Vector2.new(0, 0.5))
	panel.Visible = false
	Widgets.label(panel, "Free rolls & cosmetics", UDim2.new(1, -20, 0, 26), UDim2.new(0, 10, 0, 8))

	local refreshFreeRolls = buildFreeRolls(panel, onClaim)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -16, 1, -192)
	scroll.Position = UDim2.new(0, 8, 0, 184)
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

	local category = "mark"
	local lastProfile = nil
	local marksTab, chairsTab

	local function rebuild()
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		if not lastProfile then
			return
		end
		if category == "chair" then
			for i, id in ipairs(ChairSkins.sortByOrder(lastProfile.chairs or {})) do
				addChairCell(scroll, i, id, id == lastProfile.equippedChair, onEquip)
			end
		else
			for i, id in ipairs(Skins.sortByOrder(lastProfile.owned)) do
				addMarkCell(scroll, i, id, id == lastProfile.equipped, onEquip)
			end
		end
	end

	local function refreshTabs()
		marksTab.BackgroundColor3 = category == "mark" and TAB_ON or TAB_OFF
		chairsTab.BackgroundColor3 = category == "chair" and TAB_ON or TAB_OFF
	end

	marksTab = Widgets.button(panel, "X / O", UDim2.new(0, 170, 0, 30), UDim2.new(0, 10, 0, 148), function()
		category = "mark"
		refreshTabs()
		rebuild()
	end)
	chairsTab = Widgets.button(panel, "Chairs", UDim2.new(0, 170, 0, 30), UDim2.new(0, 190, 0, 148), function()
		category = "chair"
		refreshTabs()
		rebuild()
	end)
	refreshTabs()

	local invButton = Widgets.button(gui, "Inventory", UDim2.new(0, 130, 0, 44), UDim2.new(0, 12, 0.5, -26), function()
		panel.Visible = not panel.Visible
		if panel.Visible then
			onOpened()
		end
	end, Vector2.new(0, 0.5))

	local badge = Instance.new("TextLabel")
	badge.Name = "Badge"
	badge.Size = UDim2.fromOffset(24, 24)
	badge.AnchorPoint = Vector2.new(0.5, 0.5)
	badge.Position = UDim2.new(1, 0, 0, 3)
	badge.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
	badge.Font = Enum.Font.GothamBold
	badge.TextScaled = true
	badge.TextColor3 = Color3.new(1, 1, 1)
	badge.Text = "!"
	badge.Visible = false
	Widgets.round(badge, 12)
	badge.Parent = invButton

	local function totalFreeRolls(freeRolls): number
		local total = 0
		for _, count in pairs(freeRolls or {}) do
			total += count
		end
		return total
	end

	return {
		update = function(profile)
			lastProfile = profile
			refreshFreeRolls(profile.freeRolls)
			badge.Visible = totalFreeRolls(profile.freeRolls) > 0
			rebuild()
		end,
		close = function()
			panel.Visible = false
		end,
	}
end

return InventoryPanel
