--[[
	VsBanner
	The big "username VS username" banner shown when a match starts.
	It fades out on its own after a couple of seconds, and hide()
	removes it immediately if the match ends early.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local VsBanner = {}

local currentGui: ScreenGui? = nil

local FADE_AFTER = 2.6
local FADE_TIME = 0.6

function VsBanner.hide()
	if currentGui then
		currentGui:Destroy()
		currentGui = nil
	end
end

function VsBanner.show(xName: string, oName: string)
	VsBanner.hide()

	local gui = Instance.new("ScreenGui")
	gui.Name = "VsBanner"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")
	currentGui = gui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0.16, 0)
	label.Position = UDim2.new(0, 0, 0.12, 0)
	label.BackgroundColor3 = Color3.new(0, 0, 0)
	label.BackgroundTransparency = 0.35
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.5
	label.Text = xName .. "   VS   " .. oName
	label.Parent = gui

	task.delay(FADE_AFTER, function()
		if label.Parent then
			TweenService:Create(label, TweenInfo.new(FADE_TIME), {
				TextTransparency = 1,
				TextStrokeTransparency = 1,
				BackgroundTransparency = 1,
			}):Play()
		end
	end)
end

return VsBanner
