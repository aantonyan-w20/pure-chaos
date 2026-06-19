--[[
	TileFloor
	Lays the green tiled ground on top of an island: a round pad the full
	island diameter whose top face is a SurfaceGui checkerboard of two
	greens with thin grid lines — the look of small tiles, built with no
	uploaded image. Because the pad is a cylinder, the SurfaceGui is
	clipped to its circle, so the tiles cover the whole round island top.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PartBuilder = require(script.Parent.PartBuilder)

local TileFloor = {}

local RESOLUTION = 1200 -- SurfaceGui canvas size in pixels (square)
local MAX_DISTANCE = 250 -- far-off islands stop drawing their tiles

local function addTile(surface: SurfaceGui, index: number, isLight: boolean)
	local cell = Instance.new("Frame")
	cell.LayoutOrder = index
	cell.BorderSizePixel = 0
	cell.BackgroundColor3 = isLight and Config.Colors.TileLight or Config.Colors.TileDark

	local stroke = Instance.new("UIStroke")
	stroke.Color = Config.Colors.TileLine
	stroke.Thickness = 1
	stroke.Transparency = 0.45
	stroke.Parent = cell

	cell.Parent = surface
end

local function buildCheckerboard(surface: SurfaceGui, tiles: number)
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.fromOffset(RESOLUTION / tiles, RESOLUTION / tiles)
	grid.CellPadding = UDim2.fromOffset(0, 0)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = surface

	for i = 1, tiles * tiles do
		local row = math.floor((i - 1) / tiles)
		local col = (i - 1) % tiles
		addTile(surface, i, (row + col) % 2 == 0)
	end
end

function TileFloor.build(parent: Instance, cx: number, cz: number, diameter: number)
	local span = diameter * Config.TileCoverage
	local tiles = math.max(4, math.floor(span / Config.TileWorldSize + 0.5))

	-- A thin round pad matching the island disc, rotated so its flat circular
	-- cap faces straight up (same rotation the island layers use).
	local pad = PartBuilder.make(parent, {
		Name = "TileFloor",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.3, span, span),
		CFrame = CFrame.new(cx, Config.IslandTop + 0.05, cz) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Config.Colors.TileDark,
		Material = Enum.Material.SmoothPlastic,
	})

	-- After that rotation the up-facing cap is the cylinder's +X (Right) face;
	-- a SurfaceGui there is clipped to the circle, giving a round tiled top.
	local surface = Instance.new("SurfaceGui")
	surface.Name = "Tiles"
	surface.Face = Enum.NormalId.Right
	surface.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	surface.CanvasSize = Vector2.new(RESOLUTION, RESOLUTION)
	surface.LightInfluence = 1 -- shaded by sun/shadows so it reads as real ground
	surface.MaxDistance = MAX_DISTANCE
	surface.Parent = pad

	buildCheckerboard(surface, tiles)
end

return TileFloor
