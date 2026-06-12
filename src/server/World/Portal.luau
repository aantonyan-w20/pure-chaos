--[[
	Portal
	A stone arch with a glowing surface that teleports any player who
	touches it. A short per-player cooldown stops the destination
	portal from instantly bouncing them back.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PartBuilder = require(script.Parent.PartBuilder)

local Portal = {}

-- Shared across every portal so two portals can't ping-pong a player
local cooldown: { [Player]: boolean } = {}

local function buildArch(parent: Instance, baseCFrame: CFrame, radius: number, pillarHeight: number)
	for _, side in ipairs({ -1, 1 }) do
		PartBuilder.make(parent, {
			Name = "PortalPillar",
			Size = Vector3.new(1.2, pillarHeight, 1.2),
			CFrame = baseCFrame * CFrame.new(side * radius, pillarHeight / 2, 0),
			Color = Config.Colors.Stone,
			Material = Enum.Material.Slate,
		})
	end

	local segments = 7
	for i = 0, segments - 1 do
		local angle = math.rad(180 / segments * (i + 0.5))
		PartBuilder.make(parent, {
			Name = "PortalArch",
			Size = Vector3.new(1.6, 1, 1.2),
			CFrame = baseCFrame
				* CFrame.new(math.cos(angle) * radius, pillarHeight + math.sin(angle) * radius, 0)
				* CFrame.Angles(0, 0, angle + math.rad(90)),
			Color = Config.Colors.Stone,
			Material = Enum.Material.Slate,
		})
	end
end

-- A floating text sign hovering above the arch
local function buildSign(parent: Instance, baseCFrame: CFrame, archTop: number, text: string)
	local signPart = PartBuilder.make(parent, {
		Name = "PortalSign",
		Size = Vector3.new(1, 1, 1),
		CFrame = baseCFrame * CFrame.new(0, archTop + 1.5, 0),
		Transparency = 1,
		CanCollide = false,
	})

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 320, 0, 60)
	billboard.MaxDistance = 80
	billboard.Parent = signPart

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.5
	label.Text = text
	label.Parent = billboard
end

local function teleportOnTouch(glow: Part, destinationCFrame: CFrame)
	glow.Touched:Connect(function(hit)
		local character = hit.Parent
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local player = humanoid and Players:GetPlayerFromCharacter(character)
		if player and not cooldown[player] then
			cooldown[player] = true
			character:PivotTo(destinationCFrame)
			task.delay(2, function()
				cooldown[player] = nil
			end)
		end
	end)
end

function Portal.build(
	parent: Instance,
	basePos: Vector3,
	faceTarget: Vector3,
	destinationCFrame: CFrame,
	glowColor: Color3,
	labelText: string?
)
	local baseCFrame = CFrame.lookAt(
		Vector3.new(basePos.X, Config.IslandTop, basePos.Z),
		Vector3.new(faceTarget.X, Config.IslandTop, faceTarget.Z)
	)
	local radius = 3.2
	local pillarHeight = 5

	buildArch(parent, baseCFrame, radius, pillarHeight)
	if labelText then
		buildSign(parent, baseCFrame, pillarHeight + radius, labelText)
	end

	local glow = PartBuilder.make(parent, {
		Name = "PortalGlow",
		Size = Vector3.new(radius * 2 - 0.8, pillarHeight + radius - 0.8, 0.4),
		CFrame = baseCFrame * CFrame.new(0, (pillarHeight + radius) / 2 - 0.2, 0),
		Color = glowColor,
		Material = Enum.Material.Neon,
		Transparency = 0.35,
		CanCollide = false,
	})
	teleportOnTouch(glow, destinationCFrame)
end

return Portal
