--[[
	Environment
	Sets the stage: clears the Studio template leftovers, dials in the
	sky and fog, and fills a real Terrain-water sea around the island so
	it clearly reads as water (gentle waves, no mirror reflection).
]]

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Environment = {}

local WATER_EXTENT = 1200 -- how far the sea spreads out around the main island
local MYSTERY_SEA_EXTENT = 800 -- a smaller sea around the far-off mystery island
local WATER_DEPTH = 30 -- deep enough to sit under the island's base

local function clearTemplateLeftovers()
	local baseplate = workspace:FindFirstChild("Baseplate")
	if baseplate then
		baseplate:Destroy()
	end
	for _, item in ipairs(workspace:GetChildren()) do
		if item:IsA("SpawnLocation") then
			item:Destroy()
		end
	end
end

local function setUpLighting()
	Lighting.ClockTime = 13
	Lighting.Brightness = 2.5

	local oldAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if oldAtmosphere then
		oldAtmosphere:Destroy()
	end

	Lighting.FogColor = Color3.fromRGB(140, 180, 235)
	Lighting.FogStart = 150
	Lighting.FogEnd = 650
end

local function fillSea(terrain: Terrain, x: number, z: number, extent: number)
	local center = Vector3.new(x, Config.WaterSurfaceY - WATER_DEPTH / 2, z)
	terrain:FillBlock(CFrame.new(center), Vector3.new(extent, WATER_DEPTH, extent), Enum.Material.Water)
end

local function makeOcean()
	local terrain = workspace.Terrain
	terrain:Clear()

	-- Real water look: visible blue, gentle waves, and no mirror reflection
	terrain.WaterColor = Config.Colors.Ocean
	terrain.WaterTransparency = 0.25
	terrain.WaterReflectance = 0
	terrain.WaterWaveSize = 0.15
	terrain.WaterWaveSpeed = 12

	fillSea(terrain, 0, 0, WATER_EXTENT)
	-- its own patch of sea around the far-off mystery island
	local mystery = Config.MysteryIslandPosition
	fillSea(terrain, mystery.X, mystery.Z, MYSTERY_SEA_EXTENT)
end

function Environment.setup()
	clearTemplateLeftovers()
	setUpLighting()
	makeOcean()
end

return Environment
