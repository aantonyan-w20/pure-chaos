--[[
	Main — Tic Tac Toe Park entry point
	The only Script on the server; everything else is a ModuleScript.
	Builds the whole park at startup: a hub island connected by
	bridges to four game islands (classic tic-tac-toe), plus a hidden
	mystery island (misere rules) reachable through a portal.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Bridge = require(script.Parent.World.Bridge)
local Environment = require(script.Parent.World.Environment)
local Island = require(script.Parent.World.Island)
local Portal = require(script.Parent.World.Portal)
local Scenery = require(script.Parent.World.Scenery)
local GameTable = require(script.Parent.TicTacToe.GameTable)

-- The "walkie-talkie" the server uses to tell each player's camera
-- script that a match started or ended.
local matchEvent = Instance.new("RemoteEvent")
matchEvent.Name = Config.MatchEventName
matchEvent.Parent = ReplicatedStorage

local worldFolder = Instance.new("Folder")
worldFolder.Name = "TicTacToePark"
worldFolder.Parent = workspace

local function makeSpawnPad()
	local spawnPad = Instance.new("SpawnLocation")
	spawnPad.Size = Vector3.new(10, 1, 10)
	spawnPad.Position = Vector3.new(0, Config.IslandTop + 0.5, 0)
	spawnPad.Anchored = true
	spawnPad.Color = Config.Colors.Grass
	spawnPad.Material = Enum.Material.Grass
	spawnPad.Duration = 0
	spawnPad.Parent = worldFolder
end

local function buildHub()
	Island.build(worldFolder, 0, 0, Config.HubDiameter)
	makeSpawnPad()
	Scenery.decorate(worldFolder, 0, 0, Config.HubDiameter, 14)
end

local function buildGameIslands()
	local islandSpots = {
		Vector3.new(Config.IslandDistance, 0, 0),
		Vector3.new(-Config.IslandDistance, 0, 0),
		Vector3.new(0, 0, Config.IslandDistance),
		Vector3.new(0, 0, -Config.IslandDistance),
	}

	for _, spot in ipairs(islandSpots) do
		Island.build(worldFolder, spot.X, spot.Z, Config.GameIslandDiameter)
		GameTable.create(worldFolder, spot.X, spot.Z, false, matchEvent)
		Scenery.decorate(worldFolder, spot.X, spot.Z, Config.GameIslandDiameter, 8)

		local direction = Vector3.new(spot.X, 0, spot.Z).Unit
		local bridgeStart = direction * (Config.HubDiameter / 2 - 1)
		local bridgeEnd = direction * (Config.IslandDistance - Config.GameIslandDiameter / 2 + 1)
		Bridge.build(worldFolder, bridgeStart, bridgeEnd)
	end
end

local function buildMysteryIsland()
	local mystery = Config.MysteryIslandPosition
	Island.build(worldFolder, mystery.X, mystery.Z, Config.GameIslandDiameter)
	GameTable.create(worldFolder, mystery.X, mystery.Z, true, matchEvent)
	Scenery.decorate(worldFolder, mystery.X, mystery.Z, Config.GameIslandDiameter, 8)

	-- Hub -> mystery island
	Portal.build(
		worldFolder,
		Vector3.new(15, 0, 15),
		Vector3.new(0, 0, 0),
		CFrame.lookAt(
			Vector3.new(mystery.X - 7, Config.IslandTop + 4, mystery.Z - 7),
			Vector3.new(mystery.X, Config.IslandTop + 4, mystery.Z)
		),
		Color3.fromRGB(125, 90, 255)
	)

	-- Mystery island -> back to the hub
	Portal.build(
		worldFolder,
		Vector3.new(mystery.X - 13, 0, mystery.Z - 13),
		mystery,
		CFrame.lookAt(
			Vector3.new(8, Config.IslandTop + 4, 8),
			Vector3.new(0, Config.IslandTop + 4, 0)
		),
		Color3.fromRGB(80, 220, 200)
	)
end

Environment.setup(worldFolder)
buildHub()
buildGameIslands()
buildMysteryIsland()

print("Tic Tac Toe Park is open! Red chair plays X, blue chair plays O.")
