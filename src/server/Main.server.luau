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
	-- keep-clear: no trees/rocks blocking the portal to the mystery island
	Scenery.decorate(worldFolder, 0, 0, Config.HubDiameter, 14, { Config.HubPortalPosition })
end

local function buildIslandWithTable(cx: number, cz: number)
	Island.build(worldFolder, cx, cz, Config.GameIslandDiameter)
	GameTable.create(worldFolder, cx, cz, false, matchEvent, economy)
	Scenery.decorate(worldFolder, cx, cz, Config.GameIslandDiameter, 8)
end

local function buildGameIslands()
	local islandSpots = {
		Vector3.new(Config.IslandDistance, 0, 0),
		Vector3.new(-Config.IslandDistance, 0, 0),
		Vector3.new(0, 0, Config.IslandDistance),
		Vector3.new(0, 0, -Config.IslandDistance),
	}

	for _, spot in ipairs(islandSpots) do
		buildIslandWithTable(spot.X, spot.Z)

		local direction = Vector3.new(spot.X, 0, spot.Z).Unit
		local bridgeStart = direction * (Config.HubDiameter / 2 - 1)
		local bridgeEnd = direction * (Config.IslandDistance - Config.GameIslandDiameter / 2 + 1)
		-- railing opening in the middle, where the cross bridge joins
		Bridge.build(worldFolder, bridgeStart, bridgeEnd, { railGaps = { 0 } })

		-- A cross bridge through this bridge's midpoint, running sideways
		-- to two extra islands that line up with the neighboring islands.
		local junction = (bridgeStart + bridgeEnd) / 2
		local sideways = Vector3.new(-direction.Z, 0, direction.X)
		local reach = bridgeEnd.Magnitude

		-- The four cross bridges meet each other at the four corners.
		-- Crossing decks must not share the same height (they'd flicker),
		-- so Z-running decks sit 0.1 low and X-running decks 0.2 low.
		-- Railing openings: the main-bridge junction (0) and both corners.
		local corner = junction.Magnitude
		Bridge.build(worldFolder, junction - sideways * reach, junction + sideways * reach, {
			yOffset = (direction.X ~= 0) and -0.1 or -0.2,
			railGaps = { -corner, 0, corner },
		})

		-- The two new tic-tac-toe islands at the ends of the cross bridge
		for _, side in ipairs({ -1, 1 }) do
			local center = junction + sideways * side * Config.IslandDistance
			buildIslandWithTable(center.X, center.Z)
		end
	end
end

local function buildMysteryIsland()
	local mystery = Config.MysteryIslandPosition
	Island.build(worldFolder, mystery.X, mystery.Z, Config.GameIslandDiameter)
	GameTable.create(worldFolder, mystery.X, mystery.Z, true, matchEvent, economy)
	Scenery.decorate(
		worldFolder,
		mystery.X,
		mystery.Z,
		Config.GameIslandDiameter,
		8,
		{ Config.MysteryPortalPosition }
	)

	-- Hub -> mystery island
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

	-- Mystery island -> back to the hub
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

Environment.setup(worldFolder)
buildHub()
buildGameIslands()
buildMysteryIsland()

print("Tic Tac Toe Park is open! Red chair plays X, blue chair plays O.")
