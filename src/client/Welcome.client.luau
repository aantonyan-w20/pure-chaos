--[[
	Welcome
	Runs on each player's own machine. Shows a short welcome
	message when they join the game.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local player = Players.LocalPlayer

-- Wait a moment so the chat system is ready, then greet the player
task.delay(2, function()
	pcall(function()
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = ("Welcome to %s, %s! Touch the gold coins to collect them."):format(
				GameConfig.GameName,
				player.DisplayName
			),
			Color = Color3.fromRGB(255, 200, 40),
		})
	end)
end)
