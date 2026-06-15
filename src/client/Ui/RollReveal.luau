--[[
	RollReveal
	The slot-machine animation played every time a roll succeeds. A
	dimmed overlay pops up, the X/O preview spins through the roll's
	possible skins (slowing down as it goes), then lands on the skin the
	server actually gave and shows its name. The result is decided by
	the server — this is purely the reveal.
]]

local Skins = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Skins"))
local Widgets = require(script.Parent.Widgets)

local RollReveal = {}

local rng = Random.new()
local SPIN_STEPS = 18

-- Rebuilds the X and O previews in `holder` with the given skin. Old
-- labels are destroyed each step so animated skins don't pile up loops.
local function setPreview(holder: Frame, skinId: string)
	holder:ClearAllChildren()
	for index, symbol in ipairs({ "X", "O" }) do
		local cell = Instance.new("Frame")
		cell.BackgroundTransparency = 1
		cell.Size = UDim2.fromScale(0.5, 1)
		cell.Position = UDim2.fromScale((index - 1) * 0.5, 0)
		cell.Parent = holder

		local label = Instance.new("TextLabel")
		label.Parent = cell
		Skins.apply(label, skinId, symbol)
	end
end

local function buildOverlay(gui: ScreenGui): (Frame, Frame, TextLabel)
	local dim = Instance.new("Frame")
	dim.Size = UDim2.fromScale(1, 1)
	dim.BackgroundColor3 = Color3.new(0, 0, 0)
	dim.BackgroundTransparency = 0.45
	dim.BorderSizePixel = 0
	dim.Active = true -- swallow clicks while revealing
	dim.ZIndex = 5
	dim.Parent = gui

	local card = Widgets.frame(dim, UDim2.fromOffset(300, 260), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))
	card.ZIndex = 6

	local title = Widgets.label(card, "Rolling...", UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 1, -52))
	title.ZIndex = 6

	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.new(1, -40, 1, -80)
	holder.Position = UDim2.new(0, 20, 0, 16)
	holder.ZIndex = 6
	holder.Parent = card

	return dim, holder, title
end

function RollReveal.create(gui: ScreenGui)
	local function play(roll, resultSkinId: string, isNew: boolean, onDone: () -> ())
		local dim, holder, title = buildOverlay(gui)

		task.spawn(function()
			for step = 1, SPIN_STEPS do
				local item = roll.items[rng:NextInteger(1, #roll.items)]
				setPreview(holder, item.skin)
				-- ease out: each step waits a little longer than the last
				task.wait(0.04 + (step / SPIN_STEPS) ^ 2 * 0.16)
			end

			setPreview(holder, resultSkinId)
			local skin = Skins.Catalog[resultSkinId]
			title.Text = (skin and skin.name or resultSkinId) .. (isNew and " — NEW!" or " (duplicate)")

			task.wait(1.8)
			dim:Destroy()
			onDone()
		end)
	end

	return { play = play }
end

return RollReveal
