--[[
	MatchWatcher
	Watches a table's two chairs. The moment BOTH are occupied it
	tells both players' camera scripts "the match started" (side view,
	VS banner, glide to top-down). When either player stands up or
	leaves, it releases both cameras.
]]

local Players = game:GetService("Players")

local MatchWatcher = {}

local function playerInSeat(seat: Seat): Player?
	local occupant = seat.Occupant -- the sitting character's Humanoid
	if occupant then
		return Players:GetPlayerFromCharacter(occupant.Parent)
	end
	return nil
end

function MatchWatcher.watch(xSeat: Seat, oSeat: Seat, matchEvent: RemoteEvent, tableInfo: { [string]: any })
	local matchPlayers = nil

	local function onOccupantChanged()
		local xPlayer = playerInSeat(xSeat)
		local oPlayer = playerInSeat(oSeat)

		if xPlayer and oPlayer and not matchPlayers then
			-- both chairs just filled: the match begins!
			matchPlayers = { xPlayer, oPlayer }
			local info = {
				tableX = tableInfo.tableX,
				tableZ = tableInfo.tableZ,
				boardY = tableInfo.boardY,
				xName = xPlayer.Name,
				oName = oPlayer.Name,
			}
			matchEvent:FireClient(xPlayer, "start", info)
			matchEvent:FireClient(oPlayer, "start", info)
		elseif matchPlayers and (not xPlayer or not oPlayer) then
			-- someone stood up or left: release both cameras
			for _, player in ipairs(matchPlayers) do
				if player.Parent then
					matchEvent:FireClient(player, "stop")
				end
			end
			matchPlayers = nil
		end
	end

	xSeat:GetPropertyChangedSignal("Occupant"):Connect(onOccupantChanged)
	oSeat:GetPropertyChangedSignal("Occupant"):Connect(onOccupantChanged)
end

return MatchWatcher
