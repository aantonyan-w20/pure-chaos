--[[
	Banner
	On-screen match announcements for this player. Two kinds:
	  showVersus — the "name VS name" header at match start
	  showCenter — big centered text for "Round 1", "Tie!", "X wins!"
	Each message fades out on its own; hide() clears everything at once
	when a match ends.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local Banner = {}

local FADE_AFTER = 2.4
local FADE_TIME = 0.6

local gui: ScreenGui? = nil

local function ensureGui(): ScreenGui
	if not gui then
		local newGui = Instance.new("ScreenGui")
		newGui.Name = "Banners"
		newGui.ResetOnSpawn = false
		newGui.Parent = player:WaitForChild("PlayerGui")
		gui = newGui
	end
	return gui
end

-- Fades a label out after a beat, then removes it
local function scheduleFade(label: TextLabel)
	task.delay(FADE_AFTER, function()
		if not label.Parent then
			return
		end
		TweenService:Create(label, TweenInfo.new(FADE_TIME), {
			TextTransparency = 1,
			TextStrokeTransparency = 1,
			BackgroundTransparency = 1,
		}):Play()
		task.delay(FADE_TIME + 0.1, function()
			if label.Parent then
				label:Destroy()
			end
		end)
	end)
end

function Banner.hide()
	if gui then
		gui:Destroy()
		gui = nil
	end
end

function Banner.showVersus(xName: string, oName: string)
	local container = ensureGui()
	local existing = container:FindFirstChild("Versus")
	if existing then
		existing:Destroy()
	end

	local label = Instance.new("TextLabel")
	label.Name = "Versus"
	label.Size = UDim2.new(1, 0, 0.14, 0)
	label.Position = UDim2.new(0, 0, 0.1, 0)
	label.BackgroundColor3 = Color3.new(0, 0, 0)
	label.BackgroundTransparency = 0.35
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.5
	label.Text = xName .. "   VS   " .. oName
	label.Parent = container
	scheduleFade(label)
end

function Banner.showCenter(text: string)
	local container = ensureGui()
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.7, 0, 0.18, 0)
	label.Position = UDim2.new(0.15, 0, 0.4, 0)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = Color3.fromRGB(255, 225, 120)
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.TextStrokeTransparency = 0.3
	label.Text = text
	label.Parent = container
	scheduleFade(label)
end

return Banner
