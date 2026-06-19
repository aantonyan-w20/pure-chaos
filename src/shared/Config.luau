--[[
	Config
	Every tunable number and color for Tic Tac Toe Park lives here.
	Change a value once and every system (world building, game logic,
	cameras) picks it up. No other file should hard-code these.
]]

local Config = {}

-- Board geometry
Config.CellSize = 1.2
Config.CellGap = 0.25
Config.BoardHeight = 0.2
Config.GridWallHeight = 0.4

-- Island layout
Config.IslandTop = 50 -- Y level of every island's grass surface
Config.HubDiameter = 50
Config.GameIslandDiameter = 40
Config.IslandDistance = 75 -- hub center to each game island center
Config.BridgeWidth = 6

-- Furniture
Config.TableSize = 6

-- The far-away island with the misere table (3 in a row LOSES there)
Config.MysteryIslandPosition = Vector3.new(300, 0, 300)

-- Fixed seed so the park's trees and rocks land in the same spots every server
Config.SceneSeed = 7

-- Portal locations (the mystery one is derived below)
Config.HubPortalPosition = Vector3.new(15, 0, 15)

-- A red landmark tree just off the spawn pad's north edge
Config.SpawnTreePosition = Vector3.new(0, 0, -7)

-- The RemoteEvent name the server and client camera agree on
Config.MatchEventName = "TableMatchEvent"

-- Economy
Config.TacsPerWin = 15
Config.ProRollGamepassId = 0 -- paste the real gamepass id from the Creator Hub here
Config.ProRollRobuxPrice = 39 -- display only; the actual price is set on the Creator Hub

Config.EconomyRemotes = {
	ProfileUpdated = "ProfileUpdated",
	GetProfile = "GetProfile",
	EquipSkin = "EquipSkin",
	RequestRoll = "RequestRoll",
}

Config.Colors = {
	X = Color3.fromRGB(226, 75, 74),
	O = Color3.fromRGB(55, 138, 221),
	EmptyCell = Color3.fromRGB(245, 240, 225),
	WinCell = Color3.fromRGB(99, 153, 34),
	LoseCell = Color3.fromRGB(170, 55, 55),
	Wood = Color3.fromRGB(74, 50, 34),
	LightWood = Color3.fromRGB(124, 92, 62),
	XChair = Color3.fromRGB(168, 82, 72), -- reddish backrest = X chair
	OChair = Color3.fromRGB(82, 106, 160), -- bluish backrest = O chair
	RedLeaves = Color3.fromRGB(200, 45, 45), -- the red spawn-landmark tree
	Grass = Color3.fromRGB(120, 200, 108), -- bright green rim that blends with the tiles
	Dirt = Color3.fromRGB(106, 74, 52),
	Stone = Color3.fromRGB(120, 122, 130),
	Ocean = Color3.fromRGB(52, 124, 212),
	-- The two-tone tiled ground (a green checkerboard) and its grid lines
	TileLight = Color3.fromRGB(170, 232, 140),
	TileDark = Color3.fromRGB(120, 202, 108),
	TileLine = Color3.fromRGB(96, 170, 92),
}

-- Tiled ground: each island gets a square checkerboard pad on top. The pad
-- stays inside the round island (0.7 of the diameter keeps its corners in).
Config.TileWorldSize = 2.8 -- roughly how many studs wide one tile is
Config.TileCoverage = 0.7

-- Derived values (computed once so nobody re-derives them slightly differently)
Config.CellStep = Config.CellSize + Config.CellGap
Config.BoardLength = 3 * Config.CellSize + 4 * Config.CellGap
Config.TableTopY = Config.IslandTop + 3
Config.MysteryPortalPosition = Config.MysteryIslandPosition + Vector3.new(-13, 0, -13)

return Config
