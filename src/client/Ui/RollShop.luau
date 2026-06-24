--[[
	RollShop
	The middle-left "Rolls" button and the panel listing every roll in
	two sections: X/O skin rolls and chair rolls. The server validates
	and rolls; this panel just asks and shows the outcome.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Rolls = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rolls"))
local Skins = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Skins"))
local ChairSkins = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ChairSkins"))
local Widgets = require(script.Parent.Widgets)

local RollShop = {}

local ROW_COLOR = Color3.fromRGB(48, 52, 64)

local REASON_TEXT = {
	NotEnoughTacs = "Not enough Tacs — win games to earn more!",
	NeedGamepass = "You need the Pro gamepass for this roll.",
	GamepassNotConfigured = "The Pro gamepass isn't set up yet.",
	BadRequest = "Something went wrong, try again.",
}

local function catalogFor(kind: string?)
	return (kind == "chair") and ChairSkins.Catalog or Skins.Catalog
end

local function itemName(kind: string?, id: string): string
	local entry = catalogFor(kind)[id]
	return entry and entry.name or id
end

local function costText(roll): string
	if roll.requiresGamepass then
		return ("Gamepass (%d Robux)"):format(Config.ProRollRobuxPrice)
	end
	return roll.costTacs .. " Tacs"
end

local function oddsText(roll): string
	local parts = {}
	for _, item in ipairs(roll.items) do
		table.insert(parts, ("%s %d%%"):format(itemName(roll.kind, item.skin), item.weight))
	end
	return table.concat(parts, "  •  ")
end

local function addHeader(scroll: ScrollingFrame, order: number, text: string)
	local header = Widgets.label(scroll, text, UDim2.new(1, -8, 0, 26))
	header.LayoutOrder = order
	header.TextXAlignment = Enum.TextXAlignment.Left
end

local function addRow(scroll: ScrollingFrame, order: number, roll, onRoll: () -> ())
	local row = Instance.new("Frame")
	row.LayoutOrder = order
	row.BackgroundColor3 = ROW_COLOR
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, -8, 0, 92)
	Widgets.round(row, 8)
	row.Parent = scroll

	local title = Widgets.label(row, roll.name .. " — " .. costText(roll), UDim2.new(1, -116, 0, 30), UDim2.new(0, 10, 0, 8))
	title.TextXAlignment = Enum.TextXAlignment.Left

	local odds = Widgets.label(row, oddsText(roll), UDim2.new(1, -116, 0, 44), UDim2.new(0, 10, 0, 42))
	odds.TextScaled = false
	odds.TextSize = 13
	odds.TextWrapped = true
	odds.TextXAlignment = Enum.TextXAlignment.Left
	odds.TextColor3 = Color3.fromRGB(190, 195, 205)

	Widgets.button(row, "Roll!", UDim2.new(0, 90, 0, 40), UDim2.new(1, -100, 0.5, -20), onRoll)
end

local function buildList(scroll: ScrollingFrame, onRoll: (any) -> ())
	local order = 0
	local function section(title: string, wantChair: boolean)
		order += 1
		addHeader(scroll, order, title)
		for _, roll in ipairs(Rolls.Catalog) do
			if (roll.kind == "chair") == wantChair then
				order += 1
				addRow(scroll, order, roll, function()
					onRoll(roll)
				end)
			end
		end
	end
	section("X / O Skins", false)
	section("Chairs", true)
end

function RollShop.create(gui: ScreenGui, requestRoll: (string) -> any, promptGamepass: () -> (), onOpened: () -> ())
	local panel = Widgets.frame(gui, UDim2.new(0, 440, 0, 460), UDim2.new(0, 154, 0.5, 0), Vector2.new(0, 0.5))
	panel.Visible = false
	Widgets.label(panel, "Rolls", UDim2.new(1, -20, 0, 28), UDim2.new(0, 10, 0, 8))

	local result = Widgets.label(panel, "", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 1, -38))
	result.TextColor3 = Color3.fromRGB(255, 225, 120)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -16, 1, -86)
	scroll.Position = UDim2.new(0, 8, 0, 42)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 6
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new()
	scroll.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll

	local rolling = false
	local function doRoll(roll)
		if rolling then
			return
		end
		rolling = true
		result.Text = "Rolling..."
		local ok, outcome = pcall(requestRoll, roll.id)
		rolling = false

		if not ok or type(outcome) ~= "table" then
			result.Text = REASON_TEXT.BadRequest
			return
		end
		if outcome.ok then
			local tag = outcome.isNew and "— NEW!" or ("(duplicate, +%d Tacs)"):format(outcome.refund or 0)
			result.Text = ("You got: %s %s"):format(itemName(outcome.kind, outcome.skinId), tag)
		else
			result.Text = REASON_TEXT[outcome.reason] or REASON_TEXT.BadRequest
			if outcome.reason == "NeedGamepass" then
				promptGamepass()
			end
		end
	end

	buildList(scroll, doRoll)

	Widgets.button(gui, "Rolls", UDim2.new(0, 130, 0, 44), UDim2.new(0, 12, 0.5, 26), function()
		panel.Visible = not panel.Visible
		if panel.Visible then
			onOpened()
		end
	end, Vector2.new(0, 0.5))

	return {
		close = function()
			panel.Visible = false
		end,
	}
end

return RollShop
