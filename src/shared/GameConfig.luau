--[[
	GameConfig
	Shared settings used by both the server and the client.
	Change values here and both sides stay in sync.
]]

local GameConfig = {
	GameName = "Our Game",

	-- Coin settings
	CoinCount = 10, -- how many coins exist in the world at once
	CoinValue = 1, -- coins awarded per pickup
	CoinRespawnSeconds = 5, -- delay before a collected coin reappears
	CoinSpawnRadius = 100, -- coins spawn within this distance of the map center
}

return GameConfig
