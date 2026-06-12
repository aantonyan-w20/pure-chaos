--[[
	CoinSpawner
	Spawns spinning coins around the map. When a player touches one,
	they earn coins on the leaderboard and the coin respawns elsewhere
	after a short delay.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local random = Random.new()

local function randomPosition(): Vector3
	local radius = GameConfig.CoinSpawnRadius
	return Vector3.new(
		random:NextNumber(-radius, radius),
		3,
		random:NextNumber(-radius, radius)
	)
end

local function awardCoin(otherPart: BasePart)
	local character = otherPart.Parent
	local player = character and Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	local coins = leaderstats and leaderstats:FindFirstChild("Coins")
	if coins and coins:IsA("IntValue") then
		coins.Value += GameConfig.CoinValue
	end
end

local function spawnCoin()
	local coin = Instance.new("Part")
	coin.Name = "Coin"
	coin.Shape = Enum.PartType.Cylinder
	coin.Size = Vector3.new(0.4, 3, 3)
	coin.Color = Color3.fromRGB(255, 200, 40)
	coin.Material = Enum.Material.Metal
	coin.Anchored = true
	coin.CanCollide = false
	coin.Position = randomPosition()
	coin.Orientation = Vector3.new(0, 0, 90)

	local collected = false
	coin.Touched:Connect(function(otherPart)
		if collected then
			return
		end
		local character = otherPart.Parent
		if not (character and Players:GetPlayerFromCharacter(character)) then
			return
		end

		collected = true
		awardCoin(otherPart)
		coin:Destroy()

		task.delay(GameConfig.CoinRespawnSeconds, spawnCoin)
	end)

	-- Slow spin so coins are easy to spot
	task.spawn(function()
		while coin.Parent do
			coin.CFrame = coin.CFrame * CFrame.Angles(math.rad(2), 0, 0)
			task.wait(0.03)
		end
	end)

	coin.Parent = workspace
end

for _ = 1, GameConfig.CoinCount do
	spawnCoin()
end
