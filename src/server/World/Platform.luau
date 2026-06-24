--[[
	Platform
	The single giant island the classic tic-tac-toe tables sit on. A
	thick land block: its tiled top is at IslandTop (so tables, chairs,
	and the portal line up) and its dirt sides drop well below the water
	surface, so it rises out of the sea like one big island.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PartBuilder = require(script.Parent.PartBuilder)
local TileFloor = require(script.Parent.TileFloor)

local Platform = {}

local THICKNESS = 30 -- deep land base; reaches well under the waterline

function Platform.build(parent: Instance): Part
	local slab = PartBuilder.make(parent, {
		Name = "Platform",
		Size = Vector3.new(Config.PlatformWidth, THICKNESS, Config.PlatformDepth),
		Position = Vector3.new(0, Config.IslandTop - THICKNESS / 2, 0),
		Color = Config.Colors.Dirt,
		Material = Enum.Material.Ground,
	})
	TileFloor.applyTexture(slab, Enum.NormalId.Top)
	return slab
end

return Platform
