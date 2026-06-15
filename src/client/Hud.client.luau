--[[
	Hud — client HUD entry point
	Builds the Tacs counter (bottom left) and the Inventory and Rolls
	buttons (middle left), then keeps them in sync with the server's
	profile updates. Opening one panel closes the other so they never
	overlap.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local TacsBox = require(script.Parent.Ui.TacsBox)
local InventoryPanel = require(script.Parent.Ui.InventoryPanel)
local RollShop = require(script.Parent.Ui.RollShop)

local player = Players.LocalPlayer

local names = Config.EconomyRemotes
local profileEvent = ReplicatedStorage:WaitForChild(names.ProfileUpdated)
local getProfile = ReplicatedStorage:WaitForChild(names.GetProfile)
local equipEvent = ReplicatedStorage:WaitForChild(names.EquipSkin)
local rollFunction = ReplicatedStorage:WaitForChild(names.RequestRoll)
local rollResultEvent = ReplicatedStorage:WaitForChild(names.RollResult)

local gui = Instance.new("ScreenGui")
gui.Name = "Hud"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local tacsBox = TacsBox.create(gui)

local inventory, shop
inventory = InventoryPanel.create(gui, function(skinId)
	equipEvent:FireServer(skinId)
end, function()
	shop.close()
end)
shop = RollShop.create(gui, function(rollId)
	return rollFunction:InvokeServer(rollId)
end, function()
	MarketplaceService:PromptProductPurchase(player, Config.ProRollProductId)
end, rollResultEvent, function()
	inventory.close()
end)

local function applyProfile(profile)
	if not profile then
		return
	end
	tacsBox.set(profile.tacs)
	inventory.update(profile)
end

profileEvent.OnClientEvent:Connect(applyProfile)
applyProfile(getProfile:InvokeServer())
