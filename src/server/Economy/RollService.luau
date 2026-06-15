--[[
	RollService
	Validates and performs skin rolls. The server is authoritative: it
	throws the weighted dice and adds the prize to the player's profile.

	Two entry points:
	  roll              — Tacs rolls; charges Tacs, then grants (called
	                      synchronously from the RequestRoll remote)
	  fulfillProductRoll — paid (Developer Product) rolls; the Robux
	                      charge already happened in ProcessReceipt, so
	                      this just grants the prize
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rolls = require(ReplicatedStorage.Shared.Rolls)
local PlayerData = require(script.Parent.PlayerData)

local RollService = {}

local rng = Random.new()

local function grant(player: Player, roll)
	local skinId = Rolls.pick(roll, rng)
	local isNew = PlayerData.giveSkin(player, skinId)
	return { ok = true, rollId = roll.id, skinId = skinId, isNew = isNew }
end

-- A Tacs roll requested from the shop. Paid rolls don't come through
-- here — they go through the Robux purchase flow instead.
function RollService.roll(player: Player, rollId: string)
	local roll = Rolls.byId(rollId)
	if not roll then
		return { ok = false, reason = "BadRequest" }
	end
	if roll.requiresProduct then
		return { ok = false, reason = "UseProduct" }
	end
	if not PlayerData.spendTacs(player, roll.costTacs) then
		return { ok = false, reason = "NotEnoughTacs" }
	end
	return grant(player, roll)
end

-- Called by ProcessReceipt once the Robux purchase has gone through.
function RollService.fulfillProductRoll(player: Player, rollId: string)
	local roll = Rolls.byId(rollId)
	if not roll then
		return { ok = false, reason = "BadRequest" }
	end
	return grant(player, roll)
end

return RollService
