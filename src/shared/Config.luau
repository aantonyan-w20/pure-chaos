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

-- Island layout (the mystery island is still a floating disc)
Config.IslandTop = 50 -- Y level of the platform surface and island tops
Config.GameIslandDiameter = 40

-- Furniture
Config.TableSize = 6

-- The misere island (3 in a row LOSES there). Parked far past the fog so it
-- can't be seen from the main island — you only reach it through the portal.
Config.MysteryIslandPosition = Vector3.new(1200, 0, 0)

-- Fixed seed so the park's trees and rocks land in the same spots every server
Config.SceneSeed = 7

-- The classic tables sit on one big platform in an evenly spaced grid
Config.PlatformTableColumns = 4
Config.PlatformTableRows = 3
Config.TableSpacing = 30 -- studs between neighboring tables
Config.PlatformMargin = 35 -- clear space from the outer tables to the platform edge
Config.PlatformThickness = 30 -- how deep the island block goes (its underside)

-- The hidden red button under the island grants these free rolls (once).
Config.SecretFreeRolls = { mega = 4, lucky = 4 }

-- Sandy stepped shore around the island so players who fall in can climb back up
Config.BeachWidth = 16 -- how far the shore reaches out from the island edge
Config.BeachSteps = 6 -- terraces from the waterline up to the island top
Config.BeachSegmentLength = 26 -- shorter = more (and more uneven-looking) segments
Config.BeachJitter = 0.4 -- random height wobble per segment, so it's not a clean line

-- Portal to the mystery island, parked near the platform's front edge
-- (clear of the table grid). The mystery one is derived below.
Config.HubPortalPosition = Vector3.new(0, 0, 55)

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
	ClaimFreeRoll = "ClaimFreeRoll", -- redeem a free roll earned from the secret button
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
	Grass = Color3.fromRGB(120, 200, 108), -- bright green island rim
	Dirt = Color3.fromRGB(106, 74, 52),
	Stone = Color3.fromRGB(120, 122, 130),
	Ocean = Color3.fromRGB(52, 124, 212),
	GroundBase = Color3.fromRGB(120, 202, 108), -- green shown until the ground image loads
	Sand = Color3.fromRGB(228, 209, 156), -- the shore around the island
}

-- Tiled ground: each island gets a round pad covering its whole top, wearing
-- the ground image as a tiling Texture. Upload the picture to Roblox (it gives
-- an rbxassetid) and paste it here; until then the ground is plain green.
Config.GroundTextureId = "rbxassetid://103043619626526" -- the green tile ground image
Config.GroundTextureTileStuds = 16 -- studs per repeat of the image
Config.TileCoverage = 1.0 -- 1 matches the island diameter exactly

-- Derived values (computed once so nobody re-derives them slightly differently)
Config.CellStep = Config.CellSize + Config.CellGap
Config.BoardLength = 3 * Config.CellSize + 4 * Config.CellGap
Config.TableTopY = Config.IslandTop + 3
Config.MysteryPortalPosition = Config.MysteryIslandPosition + Vector3.new(-13, 0, -13)
Config.PlatformWidth = (Config.PlatformTableColumns - 1) * Config.TableSpacing + 2 * Config.PlatformMargin
Config.PlatformDepth = (Config.PlatformTableRows - 1) * Config.TableSpacing + 2 * Config.PlatformMargin
-- Ocean surface sits a few studs below the tops so the platform and island
-- rise out of the sea like land (bigger gap = the land stands taller).
Config.WaterSurfaceY = Config.IslandTop - 8

return Config
