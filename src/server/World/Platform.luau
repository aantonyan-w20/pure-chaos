--[[
	Platform
	The single giant floating slab that the classic tic-tac-toe tables
	sit on. It is sized to fit the table grid (see Config) and wears the
	same tiling ground image as the mystery island, with its top surface
	at IslandTop so tables, chairs, and the portal line up.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PartBuilder = require(script.Parent.PartBuilder)
local TileFloor = require(script.Parent.TileFloor)

local Platform = {}

local THICKNESS = 6

function Platform.build(parent: Instance): Part
	local slab = PartBuilder.make(parent, {
		Name = "Platform",
		Size = Vector3.new(Config.PlatformWidth, THICKNESS, Config.PlatformDepth),
		Position = Vector3.new(0, Config.IslandTop - THICKNESS / 2, 0),
		Color = Config.Colors.GroundBase,
		Material = Enum.Material.SmoothPlastic,
	})
	TileFloor.applyTexture(slab, Enum.NormalId.Top)
	return slab
end

return Platform
