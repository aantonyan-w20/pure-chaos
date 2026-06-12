--[[
	Logic
	Pure tic-tac-toe rules: whose turn it is, what's on the board, and
	whether anyone has three in a row. Knows NOTHING about Parts,
	chairs, or players — that keeps the rules easy to reason about
	(and easy to test) on their own.
]]

local Logic = {}
Logic.__index = Logic

local WINNING_LINES = {
	{ 1, 2, 3 },
	{ 4, 5, 6 },
	{ 7, 8, 9 },
	{ 1, 4, 7 },
	{ 2, 5, 8 },
	{ 3, 6, 9 },
	{ 1, 5, 9 },
	{ 3, 5, 7 },
}

export type Result = "X" | "O" | "TIE"

function Logic.new()
	local self = setmetatable({}, Logic)
	self.board = {} :: { [number]: string }
	self.currentTurn = "X"
	self.gameOver = false
	return self
end

function Logic:isCellEmpty(cellNumber: number): boolean
	return self.board[cellNumber] == nil
end

-- Returns "X" or "O" plus the winning line if someone made 3 in a row,
-- "TIE" if the board is full, or nil if the game should continue.
function Logic:evaluate(): (Result?, { number }?)
	for _, line in ipairs(WINNING_LINES) do
		local a, b, c = line[1], line[2], line[3]
		if self.board[a] and self.board[a] == self.board[b] and self.board[a] == self.board[c] then
			return self.board[a] :: Result, line
		end
	end
	for i = 1, 9 do
		if self.board[i] == nil then
			return nil, nil
		end
	end
	return "TIE", nil
end

-- Records a mark for `symbol`, then either ends the game or passes the
-- turn. Returns the same values as evaluate().
function Logic:place(cellNumber: number, symbol: string): (Result?, { number }?)
	self.board[cellNumber] = symbol

	local result, line = self:evaluate()
	if result then
		self.gameOver = true
	else
		self.currentTurn = (symbol == "X") and "O" or "X"
	end
	return result, line
end

function Logic:reset()
	table.clear(self.board)
	self.currentTurn = "X"
	self.gameOver = false
end

return Logic
