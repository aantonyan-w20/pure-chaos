--[[
	TileFloor
	Covers each island's top with the ground image. A thin round pad the
	full island diameter carries a tiling Texture of the uploaded picture,
	so the textured ground reaches the island's round edge. Paste the
	image's id into Config.GroundTextureId (upload the picture to Roblox
	first); until then the ground is plain green.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PartBuilder = require(script.Parent.PartBuilder)

local TileFloor = {}

-- Adds the tiling ground texture to one face of `part`, if an image is set.
function TileFloor.applyTexture(part: BasePart, face: Enum.NormalId)
	if Config.GroundTextureId == "" then
		return
	end
	local texture = Instance.new("Texture")
	texture.Texture = Config.GroundTextureId
	texture.Face = face
	texture.StudsPerTileU = Config.GroundTextureTileStuds
	texture.StudsPerTileV = Config.GroundTextureTileStuds
	texture.Parent = part
end

function TileFloor.build(parent: Instance, cx: number, cz: number, diameter: number)
	local span = diameter * Config.TileCoverage

	-- A thin round pad matching the island disc, rotated so its flat circular
	-- cap faces straight up (same rotation the island layers use).
	local pad = PartBuilder.make(parent, {
		Name = "TileFloor",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.3, span, span),
		CFrame = CFrame.new(cx, Config.IslandTop + 0.05, cz) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Config.Colors.GroundBase,
		Material = Enum.Material.SmoothPlastic,
	})

	-- After that rotation the up-facing cap is the cylinder's +X (Right) face.
	TileFloor.applyTexture(pad, Enum.NormalId.Right)
end

return TileFloor
