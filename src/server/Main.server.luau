--[[
	Main — Tic Tac Toe Park entry point
	The only Script on the server; everything else is a ModuleScript.
	Builds the park at startup: one giant platform holding all the
	classic tic-tac-toe tables in an evenly spaced grid, plus a separate
	mystery island (misere rules) reachable through a portal.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Beach = require(script.Parent.World.Beach)
local Environment = require(script.Parent.World.Environment)
local Island = require(script.Parent.World.Island)
local Platform = require(script.Parent.World.Platform)
local Portal = require(script.Parent.World.Portal)
local Scenery = require(script.Parent.World.Scenery)
local TileFloor = require(script.Parent.World.TileFloor)
local EconomyServer = require(script.Parent.Economy.EconomyServer)
local GameTable = require(script.Parent.TicTacToe.GameTable)

-- The "walkie-talkie" the server uses to tell each player's camera
-- script that a match started or ended.
local matchEvent = Instance.new("RemoteEvent")
matchEvent.Name = Config.MatchEventName
matchEvent.Parent = ReplicatedStorage

-- Tacs, skins, and rolls: profiles, remotes, and the win-reward hook
local economy = EconomyServer.start()

local worldFolder = Instance.new("Folder")
worldFolder.Name = "TicTacToePark"
worldFolder.Parent = workspace

local function makeSpawnPad()
	local spawnPad = Instance.new("SpawnLocation")
	spawnPad.Size = Vector3.new(10, 1, 10)
	-- sit just above the platform floor and wear the ground image so it blends
	spawnPad.Position = Vector3.new(0, Config.IslandTop - 0.2, 0)
	spawnPad.Anchored = true
	spawnPad.Color = Config.Colors.GroundBase
	spawnPad.Material = Enum.Material.SmoothPlastic
	spawnPad.Duration = 0
	spawnPad.Parent = worldFolder
	TileFloor.applyTexture(spawnPad, Enum.NormalId.Top)
end

-- Lays the classic tables out in a centered grid on the platform.
local function buildTables()
	local cols = Config.PlatformTableColumns
	local rows = Config.PlatformTableRows
	for row = 0, rows - 1 do
		for col = 0, cols - 1 do
			local x = (col - (cols - 1) / 2) * Config.TableSpacing
			local z = (row - (rows - 1) / 2) * Config.TableSpacing
			GameTable.create(worldFolder, x, z, false, matchEvent, economy)
		end
	end
end

local function buildPlatform()
	Platform.build(worldFolder)
	Beach.build(worldFolder)
	makeSpawnPad()
	-- A red landmark tree near spawn
	Scenery.placeTree(worldFolder, Config.SpawnTreePosition, Config.Colors.RedLeaves)
	buildTables()
end

local function buildMysteryIsland()
	local mystery = Config.MysteryIslandPosition
	Island.build(worldFolder, mystery.X, mystery.Z, Config.GameIslandDiameter)
	TileFloor.build(worldFolder, mystery.X, mystery.Z, Config.GameIslandDiameter)
	GameTable.create(worldFolder, mystery.X, mystery.Z, true, matchEvent, economy)
	Scenery.decorate(
		worldFolder,
		mystery.X,
		mystery.Z,
		Config.GameIslandDiameter,
		8,
		{ Config.MysteryPortalPosition }
	)

	-- Platform -> mystery island
	Portal.build(
		worldFolder,
		Config.HubPortalPosition,
		Vector3.new(0, 0, 0),
		CFrame.lookAt(
			Vector3.new(mystery.X - 7, Config.IslandTop + 4, mystery.Z - 7),
			Vector3.new(mystery.X, Config.IslandTop + 4, mystery.Z)
		),
		Color3.fromRGB(125, 90, 255),
		"Avoid 3 in a row"
	)

	-- Mystery island -> back to the platform
	Portal.build(
		worldFolder,
		Config.MysteryPortalPosition,
		mystery,
		CFrame.lookAt(
			Vector3.new(8, Config.IslandTop + 4, 8),
			Vector3.new(0, Config.IslandTop + 4, 0)
		),
		Color3.fromRGB(80, 220, 200)
	)
end

Environment.setup()
buildPlatform()
buildMysteryIsland()

print("Tic Tac Toe Park is open! Red chair plays X, blue chair plays O.")
