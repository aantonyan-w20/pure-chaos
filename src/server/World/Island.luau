--[[
	Island
	Builds a floating island as a stack of cylinder discs: grass on
	top, then dirt, then narrowing rock down to a point.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PartBuilder = require(script.Parent.PartBuilder)

local Island = {}

function Island.build(parent: Instance, cx: number, cz: number, diameter: number)
	local top = Config.IslandTop

	local function disc(d: number, height: number, centerY: number, color: Color3, material: Enum.Material)
		PartBuilder.make(parent, {
			Name = "IslandLayer",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(height, d, d),
			CFrame = CFrame.new(cx, centerY, cz) * CFrame.Angles(0, 0, math.rad(90)),
			Color = color,
			Material = material,
		})
	end

	disc(diameter, 2, top - 1, Config.Colors.Grass, Enum.Material.Grass)
	disc(diameter * 0.8, 4, top - 4, Config.Colors.Dirt, Enum.Material.Ground)
	disc(diameter * 0.55, 5, top - 8.5, Color3.fromRGB(91, 93, 105), Enum.Material.Slate)
	disc(diameter * 0.3, 4, top - 13, Color3.fromRGB(91, 93, 105), Enum.Material.Rock)
	disc(diameter * 0.12, 3, top - 16.5, Color3.fromRGB(80, 82, 94), Enum.Material.Rock)
end

return Island
