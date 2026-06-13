--[[
	Match
	Pure best-of-three scorekeeping for one table: how many rounds each
	symbol has won, what round number we're on, and whether the match is
	decided. Touches no Instances — only round wins go in, answers come
	out — so the rules stay easy to follow.

	roundNumber() = decisive rounds played so far + 1, so it naturally
	reads 1, then 2, then 3 (tie rounds don't count, so they replay under
	the same number).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Match = {}
Match.__index = Match

function Match.new()
	return setmetatable({ scores = { X = 0, O = 0 } }, Match)
end

function Match:roundNumber(): number
	return self.scores.X + self.scores.O + 1
end

function Match:recordWin(symbol: string)
	self.scores[symbol] += 1
end

function Match:isOver(): boolean
	local needed = Config.WinsNeededForMatch
	return self.scores.X >= needed or self.scores.O >= needed
end

function Match:reset()
	self.scores.X = 0
	self.scores.O = 0
end

return Match
