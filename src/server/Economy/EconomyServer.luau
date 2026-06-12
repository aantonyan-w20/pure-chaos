--[[
	EconomyServer
	Creates the economy remotes in ReplicatedStorage and binds them to
	PlayerData and RollService. start() returns the small interface the
	game tables need: award a win, look up a player's equipped skin.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PlayerData = require(script.Parent.PlayerData)
local RollService = require(script.Parent.RollService)

local EconomyServer = {}

export type Economy = {
	awardWin: (Player) -> (),
	equippedSkin: (Player) -> string,
}

local function makeRemote(className: string, name: string)
	local remote = Instance.new(className)
	remote.Name = name
	remote.Parent = ReplicatedStorage
	return remote
end

function EconomyServer.start(): Economy
	local names = Config.EconomyRemotes
	local profileEvent = makeRemote("RemoteEvent", names.ProfileUpdated)
	local getProfile = makeRemote("RemoteFunction", names.GetProfile)
	local equipEvent = makeRemote("RemoteEvent", names.EquipSkin)
	local rollFunction = makeRemote("RemoteFunction", names.RequestRoll)

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
		awardWin = function(player: Player)
			PlayerData.addTacs(player, Config.TacsPerWin)
		end,
		equippedSkin = function(player: Player): string
			return PlayerData.equippedSkin(player)
		end,
	}
end

return EconomyServer
