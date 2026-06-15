--[[
	EconomyServer
	Creates the economy remotes in ReplicatedStorage and binds them to
	PlayerData and RollService. start() returns the small interface the
	game tables need: award a win, look up a player's equipped skin.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PlayerData = require(script.Parent.PlayerData)
local RollService = require(script.Parent.RollService)

local EconomyServer = {}

export type Economy = {
	awardWin: (Player) -> number, -- pays the win + streak bonus, returns the new streak
	recordLoss: (Player) -> (),
	equippedSkin: (Player) -> string,
}

local function makeRemote(className: string, name: string)
	local remote = Instance.new(className)
	remote.Name = name
	remote.Parent = ReplicatedStorage
	return remote
end

-- Maps a Developer Product id to the roll it pays for. Built from Config
-- so there's one place to wire a product in.
local function productRolls(): { [number]: string }
	return { [Config.ProRollProductId] = "pro" }
end

-- Fulfills paid (Robux) rolls. Roblox may call this more than once for a
-- purchase until we return Granted, so we de-dupe by PurchaseId. The set
-- is in-memory: a server crash mid-purchase is the only case it misses,
-- and Roblox retries that on the player's next session.
local function makeReceiptProcessor(rollResultEvent: RemoteEvent)
	local handled: { [string]: boolean } = {}
	local rolls = productRolls()

	return function(receipt)
		local rollId = rolls[receipt.ProductId]
		if not rollId then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		if handled[receipt.PurchaseId] then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		local player = Players:GetPlayerByUserId(receipt.PlayerId)
		if not player then
			return Enum.ProductPurchaseDecision.NotProcessedYet -- retry when they're back
		end

		local outcome = RollService.fulfillProductRoll(player, rollId)
		handled[receipt.PurchaseId] = true
		rollResultEvent:FireClient(player, outcome)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

function EconomyServer.start(): Economy
	local names = Config.EconomyRemotes
	local profileEvent = makeRemote("RemoteEvent", names.ProfileUpdated)
	local getProfile = makeRemote("RemoteFunction", names.GetProfile)
	local equipEvent = makeRemote("RemoteEvent", names.EquipSkin)
	local rollFunction = makeRemote("RemoteFunction", names.RequestRoll)
	local rollResultEvent = makeRemote("RemoteEvent", names.RollResult)

	MarketplaceService.ProcessReceipt = makeReceiptProcessor(rollResultEvent)

	PlayerData.start(function(player)
		profileEvent:FireClient(player, PlayerData.snapshot(player))
	end)

	getProfile.OnServerInvoke = function(player)
		PlayerData.waitFor(player, 10)
		return PlayerData.snapshot(player)
	end

	equipEvent.OnServerEvent:Connect(function(player, skinId)
		if type(skinId) == "string" then
			PlayerData.equip(player, skinId)
		end
	end)

	rollFunction.OnServerInvoke = function(player, rollId)
		if type(rollId) ~= "string" then
			return { ok = false, reason = "BadRequest" }
		end
		return RollService.roll(player, rollId)
	end

	return {
		awardWin = function(player: Player): number
			return PlayerData.recordWin(player)
		end,
		recordLoss = function(player: Player)
			PlayerData.recordLoss(player)
		end,
		equippedSkin = function(player: Player): string
			return PlayerData.equippedSkin(player)
		end,
	}
end

return EconomyServer
