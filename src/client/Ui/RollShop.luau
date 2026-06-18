--[[
	RollShop
	The middle-left "Rolls" button and the panel with the three skin
	rolls. The server does all validation and the actual dice throw;
	this panel just asks and shows what came out.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Rolls = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rolls"))
local Skins = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Skins"))
local Widgets = require(script.Parent.Widgets)
local RollReveal = require(script.Parent.RollReveal)

local RollShop = {}

local ROW_COLOR = Color3.fromRGB(48, 52, 64)

local REASON_TEXT = {
	NotEnoughTacs = "Not enough Tacs — win games to earn more!",
	ProductNotConfigured = "The Pro Roll isn't set up yet.",
	Restricted = "The Pro Roll isn't available for your account.",
	BadRequest = "Something went wrong, try again.",
}

local BUTTON_COLOR = Color3.fromRGB(55, 60, 75)
local DISABLED_COLOR = Color3.fromRGB(70, 70, 78)

local function costText(roll): string
	if roll.requiresProduct then
		return ("%d Robux each"):format(Config.ProRollRobuxPrice)
	end
	return roll.costTacs .. " Tacs"
end

local function oddsText(roll): string
	local parts = {}
	for _, item in ipairs(roll.items) do
		local skin = Skins.Catalog[item.skin]
		table.insert(parts, ("%s %d%%"):format(skin and skin.name or item.skin, item.weight))
	end
	return table.concat(parts, "  •  ")
end

local function addRow(panel: Frame, index: number, roll, onRoll: () -> ()): TextButton
	local row = Instance.new("Frame")
	row.BackgroundColor3 = ROW_COLOR
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, -20, 0, 88)
	row.Position = UDim2.new(0, 10, 0, 42 + (index - 1) * 96)
	Widgets.round(row, 8)
	row.Parent = panel

	local title = Widgets.label(row, roll.name .. " — " .. costText(roll), UDim2.new(1, -116, 0, 30), UDim2.new(0, 10, 0, 8))
	title.TextXAlignment = Enum.TextXAlignment.Left

	local odds = Widgets.label(row, oddsText(roll), UDim2.new(1, -116, 0, 40), UDim2.new(0, 10, 0, 42))
	odds.TextScaled = false
	odds.TextSize = 13
	odds.TextWrapped = true
	odds.TextXAlignment = Enum.TextXAlignment.Left
	odds.TextColor3 = Color3.fromRGB(190, 195, 205)

	return Widgets.button(row, "Roll!", UDim2.new(0, 90, 0, 40), UDim2.new(1, -100, 0.5, -20), onRoll)
end

function RollShop.create(
	gui: ScreenGui,
	requestRoll: (string) -> any,
	promptProduct: () -> (),
	rollResultEvent: RemoteEvent,
	onOpened: () -> ()
)
	local panel = Widgets.frame(
		gui,
		UDim2.new(0, 430, 0, 380),
		UDim2.new(0, 154, 0.5, 0),
		Vector2.new(0, 0.5)
	)
	panel.Visible = false
	Widgets.label(panel, "Skin Rolls", UDim2.new(1, -20, 0, 28), UDim2.new(0, 10, 0, 8))

	local result = Widgets.label(panel, "", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 1, -38))
	result.TextColor3 = Color3.fromRGB(255, 225, 120)

	local reveal = RollReveal.create(gui)

	-- A paid roll's outcome arrives later (after the Robux purchase), so
	-- the server pushes it here and we play the reveal then.
	rollResultEvent.OnClientEvent:Connect(function(outcome)
		if type(outcome) == "table" and outcome.ok then
			local roll = Rolls.byId(outcome.rollId)
			if roll then
				reveal.play(roll, outcome.skinId, outcome.isNew, function() end)
			end
		end
	end)

	-- Set true when Roblox policy bars this player from paid random items
	local restricted = false

	-- Paid (Robux) roll: open the purchase prompt; the reveal plays when
	-- the server confirms the purchase via rollResultEvent.
	local function doProductRoll()
		if restricted then
			result.Text = REASON_TEXT.Restricted
		elseif Config.ProRollProductId == 0 then
			result.Text = REASON_TEXT.ProductNotConfigured
		else
			result.Text = ""
			promptProduct()
		end
	end

	local rolling = false
	local function doTacsRoll(roll)
		if rolling then
			return
		end
		rolling = true
		result.Text = "Rolling..."
		local ok, outcome = pcall(requestRoll, roll.id)

		if not ok or type(outcome) ~= "table" then
			result.Text = REASON_TEXT.BadRequest
			rolling = false
			return
		end
		if outcome.ok then
			result.Text = ""
			-- the spinning reveal keeps `rolling` true until it finishes
			reveal.play(roll, outcome.skinId, outcome.isNew, function()
				rolling = false
			end)
		else
			result.Text = REASON_TEXT[outcome.reason] or REASON_TEXT.BadRequest
			rolling = false
		end
	end

	local function doRoll(roll)
		if roll.requiresProduct then
			doProductRoll()
		else
			doTacsRoll(roll)
		end
	end

	local proButton: TextButton? = nil
	for index, roll in ipairs(Rolls.Catalog) do
		local button = addRow(panel, index, roll, function()
			doRoll(roll)
		end)
		if roll.requiresProduct then
			proButton = button
		end
	end

	Widgets.button(gui, "Rolls", UDim2.new(0, 130, 0, 44), UDim2.new(0, 12, 0.5, 26), function()
		panel.Visible = not panel.Visible
		if panel.Visible then
			onOpened()
		end
	end, Vector2.new(0, 0.5))

	-- Greys out and locks the Pro Roll button for restricted players
	local function setRestricted(value: boolean)
		restricted = value
		if proButton then
			proButton.Text = value and "Locked" or "Roll!"
			proButton.Active = not value
			proButton.AutoButtonColor = not value
			proButton.BackgroundColor3 = value and DISABLED_COLOR or BUTTON_COLOR
		end
	end

	return {
		close = function()
			panel.Visible = false
		end,
		setRestricted = setRestricted,
	}
end

return RollShop
