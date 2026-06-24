--[[
	Beach
	A stepped sand shore around the rectangular island so players who
	fall in the water can climb back up. Each side is a run of short
	terraces rising from just above the waterline to the island top;
	each terrace is split into segments whose heights are jittered, so
	the sand looks uneven instead of one clean line.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PartBuilder = require(script.Parent.PartBuilder)

local Beach = {}

local rng = Random.new(Config.SceneSeed)

-- The four island edges: outward normal `n`, along-edge axis `a`, and the
-- island half-sizes in each of those directions.
local function sides(): { { n: Vector3, a: Vector3, halfN: number, halfA: number } }
	local halfW = Config.PlatformWidth / 2
	local halfD = Config.PlatformDepth / 2
	return {
		{ n = Vector3.new(1, 0, 0), a = Vector3.new(0, 0, 1), halfN = halfW, halfA = halfD },
		{ n = Vector3.new(-1, 0, 0), a = Vector3.new(0, 0, 1), halfN = halfW, halfA = halfD },
		{ n = Vector3.new(0, 0, 1), a = Vector3.new(1, 0, 0), halfN = halfD, halfA = halfW },
		{ n = Vector3.new(0, 0, -1), a = Vector3.new(1, 0, 0), halfN = halfD, halfA = halfW },
	}
end

-- One terrace segment: a tall sand block reaching from below the water up to `top`.
local function segment(parent: Instance, center: Vector3, size: Vector3, top: number)
	local height = top - (Config.WaterSurfaceY - 15)
	PartBuilder.make(parent, {
		Name = "BeachSand",
		Size = Vector3.new(size.X, height, size.Z),
		Position = Vector3.new(center.X, top - height / 2, center.Z),
		Color = Config.Colors.Sand,
		Material = Enum.Material.Sand,
	})
end

local function buildSide(parent: Instance, side)
	local steps = Config.BeachSteps
	local baseY = Config.WaterSurfaceY - 1 -- lowest terrace starts at the waterline
	local stepH = (Config.IslandTop - baseY) / steps
	local stepW = Config.BeachWidth / steps
	local lengthA = 2 * side.halfA + 2 * Config.BeachWidth -- overlap the corners
	local segCount = math.ceil(lengthA / Config.BeachSegmentLength)
	local segLen = lengthA / segCount
	local nAbs = Vector3.new(math.abs(side.n.X), 0, math.abs(side.n.Z))
	local aAbs = Vector3.new(math.abs(side.a.X), 0, math.abs(side.a.Z))

	for i = 0, steps - 1 do
		-- innermost terrace (highest) hugs the island edge; outer ones step down
		local terraceTop = baseY + (i + 1) * stepH
		local centerN = side.halfN + (steps - 1 - i) * stepW + stepW / 2
		for s = 0, segCount - 1 do
			local alongPos = -lengthA / 2 + (s + 0.5) * segLen
			local center = side.n * centerN + side.a * alongPos
			local size = nAbs * (stepW + 0.3) + aAbs * (segLen + 0.3)
			local top = terraceTop + rng:NextNumber(-Config.BeachJitter, Config.BeachJitter)
			segment(parent, center, size, top)
		end
	end
end

function Beach.build(parent: Instance)
	for _, side in ipairs(sides()) do
		buildSide(parent, side)
	end
end

return Beach
