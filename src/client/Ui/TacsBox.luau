--[[
	TacsBox
	The box in the bottom-left corner showing how many Tacs the
	player has.
]]

local Widgets = require(script.Parent.Widgets)

local TacsBox = {}

function TacsBox.create(gui: ScreenGui)
	local box = Widgets.frame(
		gui,
		UDim2.new(0, 170, 0, 46),
		UDim2.new(0, 12, 1, -12),
		Vector2.new(0, 1)
	)
	local label = Widgets.label(box, "Tacs: 0", UDim2.new(1, -20, 1, -12), UDim2.new(0, 10, 0, 6))
	label.TextColor3 = Color3.fromRGB(255, 225, 120)

	return {
		set = function(amount: number)
			label.Text = "Tacs: " .. tostring(amount)
		end,
	}
end

return TacsBox
