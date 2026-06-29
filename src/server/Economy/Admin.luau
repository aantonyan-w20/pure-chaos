--[[
	Admin
	Developer perks. An admin (anyone testing in Studio, the experience
	owner, or a UserId listed in Config.Admins) gets a big Tacs balance on
	join plus on-screen dev buttons (driven by the AdminPanel remote):
	  Unlock All   unlock every X/O skin and chair
	  +100k Tacs   add Tacs
	Chat commands /give and /unlockall also work where the legacy chat is
	enabled. Regular players in the live game are unaffected.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local Skins = require(ReplicatedStorage.Shared.Skins)
local ChairSkins = require(ReplicatedStorage.Shared.ChairSkins)
local PlayerData = require(script.Parent.PlayerData)

local Admin = {}

local function isAdmin(player: Player): boolean
	if RunService:IsStudio() then
		return true -- only developers run the game in Studio
	end
	if game.CreatorType == Enum.CreatorType.User and player.UserId == game.CreatorId then
		return true
	end
	for _, userId in ipairs(Config.Admins) do
		if userId == player.UserId then
			return true
		end
	end
	return false
end

local function unlockAll(player: Player)
	for skinId in pairs(Skins.Catalog) do
		PlayerData.giveSkin(player, skinId)
	end
	for chairId in pairs(ChairSkins.Catalog) do
		PlayerData.giveChair(player, chairId)
	end
end

local function onChatted(player: Player, message: string)
	local command, arg = message:lower():match("^(/%a+)%s*(%S*)")
	if command == "/give" then
		PlayerData.addTacs(player, tonumber(arg) or 100000)
	elseif command == "/unlockall" then
		unlockAll(player)
	end
end

local function runAction(player: Player, action: string)
	if action == "unlockall" then
		unlockAll(player)
	elseif action == "give" then
		PlayerData.addTacs(player, 100000)
	end
end

local function setup(player: Player, panelRemote: RemoteEvent)
	if not isAdmin(player) then
		return
	end
	task.spawn(function()
		if PlayerData.waitFor(player, 15) then
			PlayerData.ensureTacs(player, Config.AdminTacs)
		end
		panelRemote:FireClient(player) -- tell the client to show the dev buttons
	end)
	player.Chatted:Connect(function(message)
		onChatted(player, message)
	end)
end

function Admin.start()
	local panelRemote = Instance.new("RemoteEvent")
	panelRemote.Name = Config.EconomyRemotes.AdminPanel
	panelRemote.Parent = ReplicatedStorage

	panelRemote.OnServerEvent:Connect(function(player, action)
		if isAdmin(player) and type(action) == "string" then
			runAction(player, action)
		end
	end)

	Players.PlayerAdded:Connect(function(player)
		setup(player, panelRemote)
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		setup(player, panelRemote)
	end
end

return Admin
