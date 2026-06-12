--[[
	Environment
	Sets the stage: clears the Studio template leftovers, dials in the
	sky and fog, and lays the ocean far below the islands.
]]

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PartBuilder = require(script.Parent.PartBuilder)

local Environment = {}

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

local function makeOcean(parent: Instance)
	PartBuilder.make(parent, {
		Name = "Ocean",
		Size = Vector3.new(2048, 1, 2048),
		Position = Vector3.new(0, -15, 0),
		CanCollide = false,
		Color = Config.Colors.Ocean,
		Material = Enum.Material.SmoothPlastic,
	}).Reflectance = 0.12
end

function Environment.setup(parent: Instance)
	clearTemplateLeftovers()
	setUpLighting()
	makeOcean(parent)
end

return Environment
