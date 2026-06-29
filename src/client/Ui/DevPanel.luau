--[[
	DevPanel
	Developer-only buttons in the top-right corner. Hidden until the
	server says this player is an admin (via the AdminPanel remote);
	clicking a button asks the server to run that dev action.
]]

local Widgets = require(script.Parent.Widgets)

local DevPanel = {}

function DevPanel.create(gui: ScreenGui, onAction: (string) -> ())
	local holder = Instance.new("Frame")
	holder.Name = "DevPanel"
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.fromOffset(150, 100)
	holder.AnchorPoint = Vector2.new(1, 0)
	holder.Position = UDim2.new(1, -12, 0, 12)
	holder.Visible = false
	holder.Parent = gui

	local title = Widgets.label(holder, "DEV", UDim2.new(1, 0, 0, 18), UDim2.new(0, 0, 0, 0))
	title.TextXAlignment = Enum.TextXAlignment.Right

	Widgets.button(holder, "Unlock All", UDim2.new(1, 0, 0, 34), UDim2.new(0, 0, 0, 22), function()
		onAction("unlockall")
	end)
	Widgets.button(holder, "+100k Tacs", UDim2.new(1, 0, 0, 34), UDim2.new(0, 0, 0, 62), function()
		onAction("give")
	end)

	return {
		show = function()
			holder.Visible = true
		end,
	}
end

return DevPanel
