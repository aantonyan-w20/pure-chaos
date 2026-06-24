--[[
	PlayerData
	Each player's profile: Tacs balance, owned X/O skins, and which
	skin is equipped. Loads from a DataStore on join and saves on
	leave. If the store is unreachable (e.g. Studio without API access)
	the session still works — it just won't save.
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local PlayerData = {}

local STORE_NAME = "PlayerProfiles_v1"
local DEFAULT_SKIN = "Classic"

local profiles = {}
local notifyChanged = nil

local store = nil
pcall(function()
	store = DataStoreService:GetDataStore(STORE_NAME)
end)

local function notify(player: Player)
	if notifyChanged and profiles[player] then
		notifyChanged(player)
	end
end

local function ownedList(profile): { string }
	local list = {}
	for skinId in pairs(profile.ownedSet) do
		table.insert(list, skinId)
	end
	table.sort(list)
	return list
end

local function load(player: Player)
	local profile = {
		tacs = 0,
		ownedSet = { [DEFAULT_SKIN] = true },
		equipped = DEFAULT_SKIN,
		freeRolls = {}, -- rollId -> count of claimable free rolls
		secretClaimed = false, -- has this player used the hidden button?
		canSave = false,
	}
	if store then
		local ok, saved = pcall(store.GetAsync, store, "u_" .. player.UserId)
		if ok then
			-- only allow saving when the read worked, so a failed read can
			-- never overwrite a good profile with defaults
			profile.canSave = true
			if saved then
				profile.tacs = saved.tacs or 0
				profile.secretClaimed = saved.secretClaimed or false
				for rollId, count in pairs(saved.freeRolls or {}) do
					profile.freeRolls[rollId] = count
				end
				for _, skinId in ipairs(saved.owned or {}) do
					profile.ownedSet[skinId] = true
				end
				if saved.equipped and profile.ownedSet[saved.equipped] then
					profile.equipped = saved.equipped
				end
			end
		end
	end
	profiles[player] = profile
	notify(player)
end

local function save(player: Player)
	local profile = profiles[player]
	if not (profile and profile.canSave and store) then
		return
	end
	pcall(store.SetAsync, store, "u_" .. player.UserId, {
		tacs = profile.tacs,
		owned = ownedList(profile),
		equipped = profile.equipped,
		freeRolls = profile.freeRolls,
		secretClaimed = profile.secretClaimed,
	})
end

-- onChanged fires after a profile loads and after every change, so the
-- caller can push fresh snapshots to the client.
function PlayerData.start(onChanged: (Player) -> ())
	notifyChanged = onChanged
	Players.PlayerAdded:Connect(load)
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(load, player)
	end
	Players.PlayerRemoving:Connect(function(player)
		save(player)
		profiles[player] = nil
	end)
	game:BindToClose(function()
		for _, player in ipairs(Players:GetPlayers()) do
			save(player)
		end
	end)
end

function PlayerData.waitFor(player: Player, timeout: number)
	local deadline = os.clock() + timeout
	while not profiles[player] and os.clock() < deadline do
		task.wait(0.1)
	end
	return profiles[player]
end

function PlayerData.snapshot(player: Player)
	local profile = profiles[player]
	if not profile then
		return nil
	end
	local freeRolls = {}
	for rollId, count in pairs(profile.freeRolls) do
		freeRolls[rollId] = count
	end
	return {
		tacs = profile.tacs,
		equipped = profile.equipped,
		owned = ownedList(profile),
		freeRolls = freeRolls,
	}
end

function PlayerData.addTacs(player: Player, amount: number)
	local profile = profiles[player]
	if profile then
		profile.tacs += amount
		notify(player)
	end
end

function PlayerData.spendTacs(player: Player, amount: number): boolean
	local profile = profiles[player]
	if profile and profile.tacs >= amount then
		profile.tacs -= amount
		notify(player)
		return true
	end
	return false
end

-- Returns true when the skin wasn't owned yet
function PlayerData.giveSkin(player: Player, skinId: string): boolean
	local profile = profiles[player]
	if not profile then
		return false
	end
	local isNew = not profile.ownedSet[skinId]
	profile.ownedSet[skinId] = true
	notify(player)
	return isNew
end

function PlayerData.equip(player: Player, skinId: string)
	local profile = profiles[player]
	if profile and profile.ownedSet[skinId] then
		profile.equipped = skinId
		notify(player)
	end
end

function PlayerData.equippedSkin(player: Player): string
	local profile = profiles[player]
	return (profile and profile.equipped) or DEFAULT_SKIN
end

-- The hidden button's one-time reward. Returns true the first time only.
function PlayerData.grantSecretReward(player: Player): boolean
	local profile = profiles[player]
	if not profile or profile.secretClaimed then
		return false
	end
	profile.secretClaimed = true
	for rollId, count in pairs(Config.SecretFreeRolls) do
		profile.freeRolls[rollId] = (profile.freeRolls[rollId] or 0) + count
	end
	notify(player)
	return true
end

-- Spends one free roll of the given type, if the player has any.
function PlayerData.useFreeRoll(player: Player, rollId: string): boolean
	local profile = profiles[player]
	if profile and (profile.freeRolls[rollId] or 0) > 0 then
		profile.freeRolls[rollId] -= 1
		notify(player)
		return true
	end
	return false
end

return PlayerData
