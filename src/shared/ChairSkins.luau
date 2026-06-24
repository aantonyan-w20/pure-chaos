--[[
	ChairSkins
	The catalog of chair skins and the code that paints one onto a game
	chair (the Seat plus its ChairBack and ChairLeg parts). Applied
	server-side when a player sits, and reset to the "Wood" look when the
	seat empties. Effects: recolor, transparency, size scaling, looping
	animations, and decorative add-ons. The client requires it too, just
	for the catalog (names/colors) — it never calls apply().
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local ChairSkins = {}

local rng = Random.new()

ChairSkins.Catalog = {
	Wood = { order = 1, name = "Wood Chair" },
	GreenChair = { order = 2, name = "Green Chair", color = Color3.fromRGB(60, 190, 70) },
	YellowChair = { order = 3, name = "Yellow Chair", color = Color3.fromRGB(240, 210, 50) },
	TinyChair = { order = 4, name = "Tiny Chair", scale = 0.45 },
	GlitchChair = { order = 5, name = "Glitch Chair", animation = "glitch" },
	InvisibleChair = { order = 6, name = "Invisible Chair", transparency = 1 },
	RainbowChair = { order = 7, name = "Rainbow Chair", animation = "rainbow" },
	HumongousChair = { order = 8, name = "Humongous Chair", scale = 2.4 },
	MythicChair = { order = 9, name = "Mythic Chair", color = Color3.fromRGB(235, 200, 90), decor = true },
}

local function symbolColor(symbol: string?): Color3
	return (symbol == "X") and Config.Colors.XChair or Config.Colors.OChair
end

local function chairParts(seat: Seat): ({ BasePart }, { BasePart })
	local backs, legs = {}, {}
	for _, part in ipairs(seat:GetChildren()) do
		if part:IsA("BasePart") and part.Name == "ChairBack" then
			table.insert(backs, part)
		elseif part:IsA("BasePart") and part.Name == "ChairLeg" then
			table.insert(legs, part)
		end
	end
	return backs, legs
end

local function paintAll(seat: Seat, color: Color3, transparency: number)
	local backs, legs = chairParts(seat)
	seat.Color, seat.Transparency = color, transparency
	for _, part in ipairs(backs) do
		part.Color, part.Transparency = color, transparency
	end
	for _, part in ipairs(legs) do
		part.Color, part.Transparency = color, transparency
	end
end

local function sizeBack(back: BasePart, seat: Seat, scale: number)
	local base = back:GetAttribute("BaseSize") :: Vector3
	back.Size = Vector3.new(base.X * scale, base.Y * scale, base.Z)
	back.CFrame = seat.CFrame * CFrame.new(0, back.Size.Y / 2, 0.85) -- bottom stays at the seat
end

local function sizeLeg(leg: BasePart, scale: number)
	local base = leg:GetAttribute("BaseSize") :: Vector3
	leg.Size = Vector3.new(base.X * scale, base.Y, base.Z * scale) -- thicken in place, keep height
end

local function buildDecor(seat: Seat)
	local folder = Instance.new("Folder")
	folder.Name = "ChairDecor"
	local base = seat.CFrame
	local function deco(size: Vector3, cf: CFrame, color: Color3, material: Enum.Material, shape: Enum.PartType?)
		local part = Instance.new("Part")
		part.Anchored, part.CanCollide = true, false
		part.Size, part.CFrame, part.Color, part.Material = size, cf, color, material
		if shape then
			part.Shape = shape
		end
		part.Parent = folder
	end

	for _, side in ipairs({ -1, 1 }) do
		-- angel wings
		deco(Vector3.new(0.2, 1.8, 2.6), base * CFrame.new(side * 1.3, 2.7, 0.9) * CFrame.Angles(0, 0, math.rad(side * 25)), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic)
		-- demon horns
		deco(Vector3.new(0.9, 0.3, 0.3), base * CFrame.new(side * 0.5, 3.2, 0.85) * CFrame.Angles(0, 0, math.rad(90 - side * 25)), Color3.fromRGB(120, 20, 20), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
	end
	local colors = { Color3.fromRGB(255, 90, 90), Color3.fromRGB(90, 160, 255), Color3.fromRGB(120, 255, 120), Color3.fromRGB(255, 230, 90) }
	for i = 1, 4 do
		deco(Vector3.new(0.6, 0.6, 0.6), base * CFrame.new(rng:NextNumber(-1.8, 1.8), 0.6 + i * 0.6, rng:NextNumber(-1, 1.5)), colors[i], Enum.Material.Neon, Enum.PartType.Ball)
	end
	folder.Parent = seat
end

local function animate(seat: Seat, kind: string, token: number)
	task.spawn(function()
		local t = 0
		while seat.Parent and seat:GetAttribute("ChairToken") == token do
			if kind == "rainbow" then
				paintAll(seat, Color3.fromHSV((t * 0.25) % 1, 1, 1), 0)
			else -- glitch
				local flick = (rng:NextNumber(0, 1) < 0.3) and 0.6 or 0
				paintAll(seat, Color3.fromRGB(rng:NextInteger(40, 255), rng:NextInteger(40, 255), rng:NextInteger(40, 255)), flick)
			end
			t += task.wait(0.08)
		end
	end)
end

-- Paints `skinId` onto the seat. Bumping the token stops any running
-- animation from a previous skin, so this also serves as the reset.
function ChairSkins.apply(seat: Seat, skinId: string)
	local skin = ChairSkins.Catalog[skinId] or ChairSkins.Catalog.Wood
	local token = (seat:GetAttribute("ChairToken") or 0) + 1
	seat:SetAttribute("ChairToken", token)
	local decor = seat:FindFirstChild("ChairDecor")
	if decor then
		decor:Destroy()
	end

	local symbol = seat:GetAttribute("Symbol")
	local scale = skin.scale or 1
	local transparency = skin.transparency or 0
	local backs, legs = chairParts(seat)

	seat.Color, seat.Transparency = skin.color or Config.Colors.LightWood, transparency
	for _, back in ipairs(backs) do
		sizeBack(back, seat, scale)
		back.Color, back.Transparency = skin.color or symbolColor(symbol), transparency
	end
	for _, leg in ipairs(legs) do
		sizeLeg(leg, scale)
		leg.Color, leg.Transparency = skin.color or Config.Colors.LightWood, transparency
	end

	if skin.decor then
		buildDecor(seat)
	end
	if skin.animation then
		animate(seat, skin.animation, token)
	end
end

function ChairSkins.previewColor(skinId: string): Color3
	local skin = ChairSkins.Catalog[skinId]
	return (skin and skin.color) or Config.Colors.LightWood
end

function ChairSkins.sortByOrder(ids: { string }): { string }
	local sorted = table.clone(ids)
	table.sort(sorted, function(a, b)
		local oa = ChairSkins.Catalog[a] and ChairSkins.Catalog[a].order or 99
		local ob = ChairSkins.Catalog[b] and ChairSkins.Catalog[b].order or 99
		return oa < ob
	end)
	return sorted
end

return ChairSkins
