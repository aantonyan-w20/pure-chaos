--[[
	GameTable
	One complete playable tic-tac-toe table: builds the furniture and
	board, then wires player clicks through the rules in Logic.

	House rules enforced (silently — an invalid click just does nothing):
	  1. Both chairs must be occupied before anyone can place a mark.
	  2. You must be sitting at THIS table to play.
	  3. Your chair decides your symbol (X or O), so you wait your turn.

	Pass misere = true for the mystery-island variant where making
	three in a row LOSES (the line is highlighted red instead of green).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Board = require(script.Parent.Board)
local Furniture = require(script.Parent.Furniture)
local Logic = require(script.Parent.Logic)
local MatchWatcher = require(script.Parent.MatchWatcher)

local GameTable = {}

local RESET_DELAY = 4 -- seconds the final board stays visible

function GameTable.create(parent: Instance, cx: number, cz: number, misere: boolean, matchEvent: RemoteEvent)
	local xSeat, oSeat = Furniture.build(parent, cx, cz)
	local board = Board.new(parent, cx, cz)
	local logic = Logic.new()

	MatchWatcher.watch(xSeat, oSeat, matchEvent, {
		tableX = cx,
		tableZ = cz,
		boardY = Config.TableTopY,
	})

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

	local function resetAfterDelay()
		task.wait(RESET_DELAY)
		board:clear()
		logic:reset()
	end

	local function finishGame(result: string, line: { number }?)
		if line then
			-- In misere, making three in a row LOSES, so the line shows red
			local color = misere and Config.Colors.LoseCell or Config.Colors.WinCell
			board:highlightLine(line, color)
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

		board:drawMark(cellNumber, symbol)
		local result, line = logic:place(cellNumber, symbol)
		if result then
			finishGame(result, line)
		end
	end

	board:connectCellClicks(onCellClicked)
end

return GameTable
