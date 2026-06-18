--[[
	Policy
	Thin wrapper over Roblox's PolicyService. Tells us whether a player
	is allowed to buy paid random items (the Pro Roll). Some players are
	restricted by age or region, and we must not offer loot-box-style
	purchases to them.

	If the policy can't be read, we default to RESTRICTED — the safe,
	conservative choice Roblox recommends.
]]

local PolicyService = game:GetService("PolicyService")

local Policy = {}

function Policy.isPaidRandomRestricted(player: Player): boolean
	local ok, info = pcall(function()
		return PolicyService:GetPolicyInfoForPlayerAsync(player)
	end)
	if ok and info ~= nil then
		return info.ArePaidRandomItemsRestricted == true
	end
	return true
end

return Policy
