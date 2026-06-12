--[[
	Skins
	The catalog of every X/O skin and the one function that draws a
	skin onto a TextLabel. Both sides use it: the server styles the
	marks on the boards, the client styles the inventory previews —
	so a skin always looks identical everywhere.
]]

local Config = require(script.Parent.Config)

local Skins = {}

local GREEN = Color3.fromRGB(70, 200, 70)
local YELLOW = Color3.fromRGB(240, 210, 50)

Skins.Catalog = {
	Classic = { order = 1, name = "Classic" },
	Red = { order = 2, name = "Red", color = Color3.fromRGB(255, 40, 40) },
	Cursive = { order = 3, name = "Cursive", font = Enum.Font.Fondamento },
	ShinyGreen = { order = 4, name = "Shiny Green", animation = "shine" },
	Rainbow = { order = 5, name = "Rainbow", animation = "rainbow" },
	Blue = { order = 6, name = "Blue", color = Color3.fromRGB(60, 120, 255) },
	Pink = { order = 7, name = "Pink", color = Color3.fromRGB(255, 120, 200) },
	Yellow = { order = 8, name = "Yellow", color = YELLOW },
	Tiny = { order = 9, name = "Tiny", scale = 0.45 },
	ColorShift = { order = 10, name = "Color Shift", animation = "greenYellow" },
	Invisible = { order = 11, name = "Invisible", outlineOnly = true },
	Soccer = {
		order = 12,
		name = "Soccer",
		color = Color3.fromRGB(20, 20, 20),
		strokeColor = Color3.new(1, 1, 1),
		glyphs = { O = "⚽" },
	},
}

local animations = {
	rainbow = function(label: TextLabel, t: number)
		label.TextColor3 = Color3.fromHSV((t * 0.3) % 1, 1, 1)
	end,
	greenYellow = function(label: TextLabel, t: number)
		label.TextColor3 = GREEN:Lerp(YELLOW, (math.sin(t * 3) + 1) / 2)
	end,
	shine = function(label: TextLabel, t: number)
		label.TextColor3 = Color3.fromRGB(35, 150, 35)
			:Lerp(Color3.fromRGB(150, 255, 150), (math.sin(t * 5) + 1) / 2)
	end,
}

-- Runs until the label is destroyed (its game resets or the UI closes)
local function animate(label: TextLabel, kind: string)
	task.spawn(function()
		local t = 0
		while label.Parent do
			animations[kind](label, t)
			t += task.wait(0.08)
		end
	end)
end

-- Styles `label` as `symbol` ("X" or "O") in the given skin. The label
-- must already be parented so animations know when to stop.
function Skins.apply(label: TextLabel, skinId: string, symbol: string)
	local skin = Skins.Catalog[skinId] or Skins.Catalog.Classic
	local scale = skin.scale or 1

	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.5)
	label.Size = UDim2.fromScale(scale, scale)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = skin.font or Enum.Font.GothamBold
	label.Text = (skin.glyphs and skin.glyphs[symbol]) or symbol

	local color = skin.color or ((symbol == "X") and Config.Colors.X or Config.Colors.O)
	label.TextColor3 = color
	if skin.outlineOnly then
		label.TextTransparency = 1
		label.TextStrokeColor3 = color
		label.TextStrokeTransparency = 0
	elseif skin.strokeColor then
		label.TextStrokeColor3 = skin.strokeColor
		label.TextStrokeTransparency = 0
	end

	if skin.animation then
		animate(label, skin.animation)
	end
end

-- Returns a copy of `ids` sorted by catalog order (for the inventory grid)
function Skins.sortByOrder(ids: { string }): { string }
	local sorted = table.clone(ids)
	table.sort(sorted, function(a, b)
		local orderA = Skins.Catalog[a] and Skins.Catalog[a].order or 99
		local orderB = Skins.Catalog[b] and Skins.Catalog[b].order or 99
		return orderA < orderB
	end)
	return sorted
end

return Skins
