--[[
	GameTable
	One complete playable table. When both chairs fill, it runs a
	best-of-three match: "Round 1" is announced, and each round is a
	normal game of tic-tac-toe. First player to two round wins takes
	the match — then the loser is sent back to spawn (their character
	dies) and the winner hops up out of their seat. Marks are drawn in
	the placing player's equipped skin, and the match winner earns Tacs.

	Misère tables (the mystery island) flip each round: making three in
	a row LOSES that round.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Board = require(script.Parent.Board)
local Furniture = require(script.Parent.Furniture)
local Logic = require(script.Parent.Logic)
local Match = require(script.Parent.Match)
local MatchWatcher = require(script.Parent.MatchWatcher)

local GameTable = {}

local RESET_DELAY = 4 -- seconds the finished board stays up before the next round

export type Economy = {
	awardWin: (Player) -> number,
	recordLoss: (Player) -> (),
	equippedSkin: (Player) -> string,
}

local function seatPlayer(seat: Seat): Player?
	local humanoid = seat.Occupant
	if humanoid then
		return Players:GetPlayerFromCharacter(humanoid.Parent)
	end
	return nil
end

function GameTable.create(
	parent: Instance,
	cx: number,
	cz: number,
	misere: boolean,
	matchEvent: RemoteEvent,
	economy: Economy
)
	local xSeat, oSeat = Furniture.build(parent, cx, cz)
	local board = Board.new(parent, cx, cz)
	local logic = Logic.new()
	local match = Match.new()

	local phase = "idle" -- "idle" until both chairs fill, then "playing"
	local players: { [string]: Player? } = { X = nil, O = nil }

	-- Sends an action (with optional payload) to both seated players
	local function fireBoth(action: string, payload: any?)
		for _, player in pairs(players) do
			if player and player.Parent then
				matchEvent:FireClient(player, action, payload)
			end
		end
	end

	local function announce(text: string)
		fireBoth("banner", text)
	end

	-- The symbol that WON the round (in misère, NOT making 3 in a row wins)
	local function roundWinner(result: string): string
		if misere then
			return (result == "X") and "O" or "X"
		end
		return result
	end

	-- Clears the board for the next round and announces it
	local function advance(message: string)
		task.wait(RESET_DELAY)
		board:clear()
		logic:reset()
		announce(message)
	end

	-- Match decided: reward the winner, send the loser to spawn, stand the winner up
	local function endMatch(winnerSymbol: string)
		phase = "idle"
		local winnerSeat = (winnerSymbol == "X") and xSeat or oSeat
		local loserSeat = (winnerSymbol == "X") and oSeat or xSeat
		local winnerHumanoid = winnerSeat.Occupant
		local loserHumanoid = loserSeat.Occupant
		local winnerPlayer = seatPlayer(winnerSeat)
		local loserPlayer = seatPlayer(loserSeat)

		local winnerName = (winnerPlayer and winnerPlayer.Name) or winnerSymbol
		if winnerPlayer then
			local streak = economy.awardWin(winnerPlayer)
			if streak >= 2 then
				announce(winnerName .. " wins! Winstreak " .. streak)
			else
				announce(winnerName .. " wins the match!")
			end
		else
			announce(winnerName .. " wins the match!")
		end
		if loserPlayer then
			economy.recordLoss(loserPlayer)
		end

		task.wait(RESET_DELAY)
		fireBoth("stop")
		if winnerHumanoid then
			winnerHumanoid.Sit = false
			winnerHumanoid.Jump = true
		end
		if loserHumanoid then
			loserHumanoid.Health = 0 -- respawns them at the hub spawn
		end
		board:clear()
		logic:reset()
		match:reset()
		players = { X = nil, O = nil }
	end

	local function finishRound(result: string, line: { number }?)
		if line then
			board:highlightLine(line, misere and Config.Colors.LoseCell or Config.Colors.WinCell)
		end

		if result == "TIE" then
			task.spawn(function()
				advance("Tie! Replay Round " .. match:roundNumber())
			end)
			return
		end

		local winnerSymbol = roundWinner(result)
		match:recordWin(winnerSymbol)
		if match:isOver() then
			task.spawn(function()
				endMatch(winnerSymbol)
			end)
		else
			task.spawn(function()
				advance("Round " .. match:roundNumber())
			end)
		end
	end

	-- Which symbol does this player control at THIS table?
	local function symbolForPlayer(player: Player): string?
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local seatPart = humanoid and humanoid.SeatPart
		if seatPart == xSeat then
			return "X"
		end
		if seatPart == oSeat then
			return "O"
		end
		return nil
	end

	local function onCellClicked(cellNumber: number, player: Player)
		if phase ~= "playing" or logic.gameOver then
			return
		end
		local symbol = symbolForPlayer(player)
		if symbol == nil or symbol ~= logic.currentTurn then
			return
		end
		if not logic:isCellEmpty(cellNumber) then
			return
		end

		board:drawMark(cellNumber, symbol, economy.equippedSkin(player))
		local result, line = logic:place(cellNumber, symbol)
		if result then
			finishRound(result, line)
		end
	end

	local function onBothSeated(xPlayer: Player, oPlayer: Player)
		phase = "playing"
		players = { X = xPlayer, O = oPlayer }
		match:reset()
		logic:reset()
		board:clear()
		fireBoth("start", {
			tableX = cx,
			tableZ = cz,
			boardY = Config.TableTopY,
			xName = xPlayer.Name,
			oName = oPlayer.Name,
		})
		announce("Round " .. match:roundNumber())
	end

	-- A player left mid-match (not our own end-of-match cleanup): abandon it
	local function onVacated()
		if phase ~= "playing" then
			return
		end
		phase = "idle"
		fireBoth("stop")
		board:clear()
		logic:reset()
		match:reset()
		players = { X = nil, O = nil }
	end

	MatchWatcher.watch(xSeat, oSeat, { onBothSeated = onBothSeated, onVacated = onVacated })
	board:connectCellClicks(onCellClicked)
end

return GameTable
