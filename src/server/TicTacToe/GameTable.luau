--[[
	GameTable
	One complete playable tic-tac-toe table: builds the furniture and
	board, then wires player clicks through the rules in Logic. Marks
	are drawn in the placing player's equipped skin, and the winner
	earns Tacs through the economy interface.

	House rules enforced (silently — an invalid click just does nothing):
	  1. Both chairs must be occupied before anyone can place a mark.
	  2. You must be sitting at THIS table to play.
	  3. Your chair decides your symbol (X or O), so you wait your turn.

	Pass misere = true for the mystery-island variant where making
	three in a row LOSES (the line is highlighted red instead of green).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local ChairSkins = require(ReplicatedStorage.Shared.ChairSkins)
local Board = require(script.Parent.Board)
local Furniture = require(script.Parent.Furniture)
local Logic = require(script.Parent.Logic)
local MatchWatcher = require(script.Parent.MatchWatcher)

local GameTable = {}

local RESET_DELAY = 4 -- seconds the final board stays visible

export type Economy = {
	awardWin: (Player) -> (),
	equippedSkin: (Player) -> string,
	equippedChair: (Player) -> string,
}

-- Paints the sitter's equipped chair onto the seat, and the default
-- "Wood" look when it empties.
local function watchChairSkin(seat: Seat, economy: Economy)
	seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		local occupant = seat.Occupant
		local player = occupant and Players:GetPlayerFromCharacter(occupant.Parent)
		ChairSkins.apply(seat, (player and economy.equippedChair(player)) or "Wood")
	end)
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

	MatchWatcher.watch(xSeat, oSeat, matchEvent, {
		tableX = cx,
		tableZ = cz,
		boardY = Config.TableTopY,
	})

	watchChairSkin(xSeat, economy)
	watchChairSkin(oSeat, economy)

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

	local function awardWinner(result: string)
		local winnerSymbol = result
		if misere then
			-- making three in a row LOSES, so the other player won
			winnerSymbol = (result == "X") and "O" or "X"
		end
		local seat = (winnerSymbol == "X") and xSeat or oSeat
		local humanoid = seat.Occupant
		local player = humanoid and Players:GetPlayerFromCharacter(humanoid.Parent)
		if player then
			economy.awardWin(player)
		end
	end

	local function resetAfterDelay()
		task.wait(RESET_DELAY)
		board:clear()
		logic:reset()
	end

	local function finishGame(result: string, line: { number }?)
		if line then
			local color = misere and Config.Colors.LoseCell or Config.Colors.WinCell
			board:highlightLine(line, color)
		end
		if result ~= "TIE" then
			awardWinner(result)
		end
		task.spawn(resetAfterDelay)
	end

	local function onCellClicked(cellNumber: number, player: Player)
		if logic.gameOver then
			return
		end
		if not (xSeat.Occupant and oSeat.Occupant) then
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
			finishGame(result, line)
		end
	end

	board:connectCellClicks(onCellClicked)
end

return GameTable
