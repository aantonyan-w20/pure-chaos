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

-- The RemoteEvent name the server and client camera agree on
Config.MatchEventName = "TableMatchEvent"

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
	Grass = Color3.fromRGB(86, 153, 56),
	Dirt = Color3.fromRGB(106, 74, 52),
	Stone = Color3.fromRGB(120, 122, 130),
	Ocean = Color3.fromRGB(52, 124, 212),
}

-- Derived values (computed once so nobody re-derives them slightly differently)
Config.CellStep = Config.CellSize + Config.CellGap
Config.BoardLength = 3 * Config.CellSize + 4 * Config.CellGap
Config.TableTopY = Config.IslandTop + 3

return Config
