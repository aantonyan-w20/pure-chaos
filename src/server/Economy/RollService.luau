--[[
	RollService
	Validates and performs skin rolls. The server is authoritative:
	it checks the price (Tacs or gamepass), throws the weighted dice,
	and adds the prize to the player's profile. The client only ever
	receives the outcome.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Rolls = require(ReplicatedStorage.Shared.Rolls)
local PlayerData = require(script.Parent.PlayerData)

local RollService = {}

local rng = Random.new()
local ownsProPass: { [Player]: boolean } = {}

-- Picks the prize (X/O skin or chair, per roll.kind), gives it, and
-- refunds Tacs if it's a duplicate.
local function grantItem(player: Player, roll)
	local id = Rolls.pick(roll, rng)
	local isNew
	if roll.kind == "chair" then
		isNew = PlayerData.giveChair(player, id)
	else
		isNew = PlayerData.giveSkin(player, id)
	end
	local refund = 0
	if not isNew then
		refund = Config.DuplicateRefund
		PlayerData.addTacs(player, refund)
	end
	return { ok = true, skinId = id, kind = roll.kind or "mark", isNew = isNew, refund = refund }
end

local function checkGamepass(player: Player): (boolean, string?)
	if ownsProPass[player] then
		return true, nil
	end
	local passId = Config.ProRollGamepassId
	if passId == 0 then
		return false, "GamepassNotConfigured"
	end
	local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, passId)
	if ok and owns then
		ownsProPass[player] = true
		return true, nil
	end
	return false, "NeedGamepass"
end

-- Returns {ok = true, skinId, isNew} or {ok = false, reason}
function RollService.roll(player: Player, rollId: string)
	local roll = Rolls.byId(rollId)
	if not roll then
		return { ok = false, reason = "BadRequest" }
	end

	if roll.requiresGamepass then
		local owns, reason = checkGamepass(player)
		if not owns then
			return { ok = false, reason = reason }
		end
	elseif not PlayerData.spendTacs(player, roll.costTacs) then
		return { ok = false, reason = "NotEnoughTacs" }
	end

	return grantItem(player, roll)
end

-- Claims one of the player's free rolls (earned from the secret button).
function RollService.freeRoll(player: Player, rollId: string)
	local roll = Rolls.byId(rollId)
	if not roll then
		return { ok = false, reason = "BadRequest" }
	end
	if not PlayerData.useFreeRoll(player, rollId) then
		return { ok = false, reason = "NoFreeRolls" }
	end
	return grantItem(player, roll)
end

-- A purchase made mid-game unlocks the Pro Roll immediately
-- (UserOwnsGamePassAsync caches its answer, so we track it ourselves)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
	if purchased and passId == Config.ProRollGamepassId then
		ownsProPass[player] = true
	end
end)

Players.PlayerRemoving:Connect(function(player)
	ownsProPass[player] = nil
end)

return RollService
