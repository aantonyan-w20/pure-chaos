--[[
	Scenery
	Sprinkles trees, rocks, bushes, and flowers around an island.
	Uses one shared, seeded random generator so the park looks
	identical every server start.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PartBuilder = require(script.Parent.PartBuilder)

local Scenery = {}

local rng = Random.new(Config.SceneSeed)

local function makeTree(parent: Instance, x: number, z: number)
	local top = Config.IslandTop
	local height = rng:NextNumber(4.5, 6.5)
	PartBuilder.make(parent, {
		Name = "TreeTrunk",
		Size = Vector3.new(1, height, 1),
		Position = Vector3.new(x, top + height / 2, z),
		Color = Color3.fromRGB(86, 60, 38),
	})
	for _ = 1, rng:NextInteger(3, 4) do
		local clumpSize = rng:NextNumber(3, 5)
		local shade = rng:NextInteger(-20, 15)
		PartBuilder.make(parent, {
			Name = "TreeLeaves",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(clumpSize, clumpSize, clumpSize),
			Position = Vector3.new(
				x + rng:NextNumber(-1.4, 1.4),
				top + height + rng:NextNumber(0, 1.6),
				z + rng:NextNumber(-1.4, 1.4)
			),
			Color = Color3.fromRGB(58 + shade, 125 + shade, 21 + math.max(shade, 0)),
			Material = Enum.Material.Grass,
			CanCollide = false,
		})
	end
end

local function makeRock(parent: Instance, x: number, z: number)
	local size = rng:NextNumber(0.8, 2.2)
	PartBuilder.make(parent, {
		Name = "Rock",
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(size * 1.4, size, size),
		CFrame = CFrame.new(x, Config.IslandTop + size * 0.25, z)
			* CFrame.Angles(0, rng:NextNumber(0, math.pi), 0),
		Color = Color3.fromRGB(120, 122, 130),
		Material = Enum.Material.Rock,
	})
end

local function makeBush(parent: Instance, x: number, z: number)
	local size = rng:NextNumber(1.5, 2.6)
	PartBuilder.make(parent, {
		Name = "Bush",
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(size, size * 0.7, size),
		Position = Vector3.new(x, Config.IslandTop + size * 0.25, z),
		Color = Color3.fromRGB(64, 134, 36),
		Material = Enum.Material.Grass,
		CanCollide = false,
	})
end

local function makeFlower(parent: Instance, x: number, z: number)
	PartBuilder.make(parent, {
		Name = "FlowerStem",
		Size = Vector3.new(0.15, 0.6, 0.15),
		Position = Vector3.new(x, Config.IslandTop + 0.3, z),
		Color = Color3.fromRGB(60, 130, 40),
		Material = Enum.Material.Grass,
		CanCollide = false,
	})
	local petals = {
		Color3.fromRGB(235, 87, 87),
		Color3.fromRGB(242, 201, 76),
		Color3.fromRGB(187, 107, 217),
		Color3.fromRGB(255, 255, 255),
	}
	PartBuilder.make(parent, {
		Name = "FlowerHead",
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(0.45, 0.45, 0.45),
		Position = Vector3.new(x, Config.IslandTop + 0.65, z),
		Color = petals[rng:NextInteger(1, #petals)],
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})
end

local KEEP_CLEAR_RADIUS = 8

local function isTooCloseToKeepClear(x: number, z: number, keepClear: { Vector3 }?): boolean
	if not keepClear then
		return false
	end
	for _, point in ipairs(keepClear) do
		local dx = x - point.X
		local dz = z - point.Z
		if math.sqrt(dx * dx + dz * dz) < KEEP_CLEAR_RADIUS then
			return true
		end
	end
	return false
end

-- Scatters `count` decorations in a ring around (cx, cz), keeping the
-- island center clear for tables and spawn pads. Positions in `keepClear`
-- (e.g. portals) get an 8-stud no-decoration zone around them.
function Scenery.decorate(parent: Instance, cx: number, cz: number, diameter: number, count: number, keepClear: { Vector3 }?)
	local placed = 0
	local attempts = 0
	while placed < count and attempts < 200 do
		attempts += 1
		local angle = rng:NextNumber(0, 2 * math.pi)
		local radius = rng:NextNumber(diameter * 0.26, diameter * 0.42)
		local x = cx + math.cos(angle) * radius
		local z = cz + math.sin(angle) * radius
		if math.abs(x - cx) > 5 and math.abs(z - cz) > 5 and not isTooCloseToKeepClear(x, z, keepClear) then
			local roll = rng:NextInteger(1, 10)
			if roll <= 4 then
				makeTree(parent, x, z)
			elseif roll <= 6 then
				makeRock(parent, x, z)
			elseif roll <= 8 then
				makeBush(parent, x, z)
			else
				makeFlower(parent, x, z)
			end
			placed += 1
		end
	end
end

return Scenery
