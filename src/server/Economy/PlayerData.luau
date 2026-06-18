--[[
	PlayerData
	Each player's profile: Tacs balance, owned X/O skins, equipped skin,
	and current win streak. Loads from a DataStore on join and saves on
	leave. If the store is unreachable (e.g. Studio without API access)
	the session still works — it just won't save.
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Policy = require(script.Parent.Policy)

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
		streak = 0, -- consecutive match wins; resets on a loss
		-- whether Roblox policy bars this player from paid random items
		-- (the Pro Roll); session-only, not saved. Defaults to restricted.
		paidRandomRestricted = true,
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
				profile.streak = saved.streak or 0
				for _, skinId in ipairs(saved.owned or {}) do
					profile.ownedSet[skinId] = true
				end
				if saved.equipped and profile.ownedSet[saved.equipped] then
					profile.equipped = saved.equipped
				end
			end
		end
	end
	profile.paidRandomRestricted = Policy.isPaidRandomRestricted(player)
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
		streak = profile.streak,
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
	return {
		tacs = profile.tacs,
		equipped = profile.equipped,
		owned = ownedList(profile),
		streak = profile.streak,
		paidRandomRestricted = profile.paidRandomRestricted,
	}
end

function PlayerData.addTacs(player: Player, amount: number)
	local profile = profiles[player]
	if profile then
		profile.tacs += amount
		notify(player)
	end
end

-- Records a match win: extends the streak, pays the base reward plus
-- the streak bonus, and returns the new streak length.
function PlayerData.recordWin(player: Player): number
	local profile = profiles[player]
	if not profile then
		return 0
	end
	profile.streak += 1
	local bonus = math.max(0, profile.streak - 1) * Config.WinStreakBonus
	profile.tacs += Config.TacsPerWin + bonus
	notify(player)
	return profile.streak
end

function PlayerData.recordLoss(player: Player)
	local profile = profiles[player]
	if profile and profile.streak ~= 0 then
		profile.streak = 0
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

return PlayerData
