--[[
	MatchCamera
	The SERVER decides when a match starts (both chairs at a table
	occupied) and fires the match event to both players. This script
	listens and runs the show on this player's screen:
	  1) camera cuts to a side view of the table
	  2) the "username VS username" banner appears
	  3) camera glides up to a locked top-down view of the board
	When either player stands up, the server says "stop" and the
	normal character camera comes back.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local VsBanner = require(script.Parent.VsBanner)

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- created by the server at startup
local matchEvent = ReplicatedStorage:WaitForChild(Config.MatchEventName)

local GLIDE_DELAY = 2.8 -- let the side view + banner breathe first
local GLIDE_TIME = 1.2

local matchActive = false

local function releaseCamera()
	matchActive = false
	VsBanner.hide()
	camera.CameraType = Enum.CameraType.Custom
end

local function glideToTopDown(boardCenter: Vector3)
	local topDown = CFrame.lookAt(
		boardCenter + Vector3.new(0, 8, 0),
		boardCenter,
		Vector3.new(0, 0, 1)
	)
	TweenService:Create(
		camera,
		TweenInfo.new(GLIDE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{ CFrame = topDown }
	):Play()
end

local function startMatch(info: { [string]: any })
	matchActive = true
	local boardCenter = Vector3.new(info.tableX, info.boardY + 0.4, info.tableZ)

	-- 1) cinematic side view of the table
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.lookAt(boardCenter + Vector3.new(10, 4, 0), boardCenter)

	-- 2) the big VS banner: X player's username vs O player's username
	VsBanner.show(info.xName, info.oName)

	-- 3) glide up to a straight-down view of the board
	task.delay(GLIDE_DELAY, function()
		if matchActive then
			glideToTopDown(boardCenter)
		end
	end)
end

matchEvent.OnClientEvent:Connect(function(action, info)
	if action == "start" then
		startMatch(info)
	elseif action == "stop" then
		releaseCamera()
	end
end)

-- safety net: if our character respawns, give the camera back
player.CharacterAdded:Connect(releaseCamera)
