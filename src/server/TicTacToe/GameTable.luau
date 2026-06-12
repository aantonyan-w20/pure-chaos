--[[
	GameTable
	One complete playable tic-tac-toe table: builds the furniture and
	board, then wires player clicks through the rules in Logic.

	House rules enforced here:
	  1. Both chairs must be occupied before anyone can place a mark.
	  2. You must be sitting at THIS table to play.
	  3. Your chair decides your symbol (X or O), so you wait your turn.

	Pass misere = true for the mystery-island variant where making
	three in a row LOSES.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Board = require(script.Parent.Board)
local Furniture = require(script.Parent.Furniture)
local Logic = require(script.Parent.Logic)
local MatchWatcher = require(script.Parent.MatchWatcher)

local GameTable = {}

local RESET_DELAY = 4 -- seconds the final board stays visible
local HINT_SECONDS = 1.5

function GameTable.create(parent: Instance, cx: number, cz: number, misere: boolean, matchEvent: RemoteEvent)
	local xSeat, oSeat = Furniture.build(parent, cx, cz)
	local board = Board.new(parent, cx, cz)
	local logic = Logic.new()

	MatchWatcher.watch(xSeat, oSeat, matchEvent, {
		tableX = cx,
		tableZ = cz,
		boardY = Config.TableTopY,
	})

	local function turnText(): string
		local base = (logic.currentTurn == "X") and "X's turn (red)" or "O's turn (blue)"
		if misere then
			return "AVOID 3 in a row! " .. base
		end
		return base
	end

	-- Briefly flashes a rule reminder on the sign, then restores the turn text
	local hintShowing = false
	local function showHint(text: string)
		if logic.gameOver or hintShowing then
			return
		end
		hintShowing = true
		board:setStatus(text)
		task.delay(HINT_SECONDS, function()
			hintShowing = false
			if not logic.gameOver then
				board:setStatus(turnText())
			end
		end)
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

	local function resetAfterDelay()
		task.wait(RESET_DELAY)
		board:clear()
		logic:reset()
		board:setStatus(turnText())
	end

	local function finishGame(result: string, line: { number }?)
		if result == "TIE" then
			board:setStatus("It's a tie!")
		elseif misere then
			-- In misere, making three in a row LOSES
			local winner = (result == "X") and "O" or "X"
			board:setStatus(winner .. " wins! " .. result .. " made 3 in a row!")
			board:highlightLine(line, Config.Colors.LoseCell)
		else
			board:setStatus(result .. " wins!")
			board:highlightLine(line, Config.Colors.WinCell)
		end
		task.spawn(resetAfterDelay)
	end

	local function onCellClicked(cellNumber: number, player: Player)
		if logic.gameOver then
			return
		end

		if not (xSeat.Occupant and oSeat.Occupant) then
			showHint("Need a player in both chairs!")
			return
		end

		local symbol = symbolForPlayer(player)
		if symbol == nil then
			showHint("Sit in a chair to play!")
			return
		end

		if symbol ~= logic.currentTurn then
			showHint("Not your turn!")
			return
		end

		if not logic:isCellEmpty(cellNumber) then
			return
		end

		board:drawMark(cellNumber, symbol)
		local result, line = logic:place(cellNumber, symbol)
		if result then
			finishGame(result, line)
		else
			board:setStatus(turnText())
		end
	end

	board:connectCellClicks(onCellClicked)
	board:setStatus(turnText())
end

return GameTable
