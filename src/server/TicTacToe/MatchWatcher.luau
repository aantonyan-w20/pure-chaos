--[[
	MatchWatcher
	Watches a table's two chairs and reports the transitions GameTable
	cares about: onBothSeated (the moment both chairs fill) and
	onVacated (a player stands up or leaves while seated). It only
	reports — GameTable decides what a match start or a walkout means.
]]

local Players = game:GetService("Players")

local MatchWatcher = {}

export type Handlers = {
	onBothSeated: (Player, Player) -> (),
	onVacated: () -> (),
}

local function playerInSeat(seat: Seat): Player?
	local occupant = seat.Occupant -- the sitting character's Humanoid
	if occupant then
		return Players:GetPlayerFromCharacter(occupant.Parent)
	end
	return nil
end

function MatchWatcher.watch(xSeat: Seat, oSeat: Seat, handlers: Handlers)
	local bothSeated = false

	local function onOccupantChanged()
		local xPlayer = playerInSeat(xSeat)
		local oPlayer = playerInSeat(oSeat)

		if xPlayer and oPlayer and not bothSeated then
			bothSeated = true
			handlers.onBothSeated(xPlayer, oPlayer)
		elseif bothSeated and (not xPlayer or not oPlayer) then
			bothSeated = false
			handlers.onVacated()
		end
	end

	xSeat:GetPropertyChangedSignal("Occupant"):Connect(onOccupantChanged)
	oSeat:GetPropertyChangedSignal("Occupant"):Connect(onOccupantChanged)
end

return MatchWatcher
