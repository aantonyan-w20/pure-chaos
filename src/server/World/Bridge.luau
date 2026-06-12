--[[
	Bridge
	A flat plank bridge with railings connecting two islands.
	Bridges can cross each other, which needs two tricks:
	  yOffset  — nudges the deck height, because two decks (or a deck
	             and the grass) at exactly the same height flicker
	             (z-fight) where they overlap
	  railGaps — offsets from the deck center where the railing leaves
	             an opening, so players can walk through where another
	             bridge joins instead of being fenced out
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PartBuilder = require(script.Parent.PartBuilder)

local Bridge = {}

-- An opening wide enough for a crossing bridge's deck plus a little margin
local RAIL_GAP_WIDTH = Config.BridgeWidth + 2

export type Options = {
	yOffset: number?,
	railGaps: { number }?,
}

-- Turns gap positions into the {start, finish} spans the railing
-- should actually cover along the deck.
local function railIntervals(length: number, gaps: { number }): { { number } }
	local sorted = table.clone(gaps)
	table.sort(sorted)

	local intervals = {}
	local cursor = -length / 2
	for _, gapCenter in ipairs(sorted) do
		local gapStart = gapCenter - RAIL_GAP_WIDTH / 2
		if gapStart > cursor then
			table.insert(intervals, { cursor, gapStart })
		end
		cursor = math.max(cursor, gapCenter + RAIL_GAP_WIDTH / 2)
	end
	if cursor < length / 2 then
		table.insert(intervals, { cursor, length / 2 })
	end
	return intervals
end

function Bridge.build(parent: Instance, fromPos: Vector3, toPos: Vector3, options: Options?)
	local yOffset = (options and options.yOffset) or 0
	local railGaps = (options and options.railGaps) or {}

	-- Base deck top sits 0.05 studs above the grass (see yOffset note above)
	local deckY = Config.IslandTop - 0.45 + yOffset
	local distance = (toPos - fromPos).Magnitude
	local length = distance + 4
	local midpoint = (fromPos + toPos) / 2
	local deckCFrame = CFrame.lookAt(
		Vector3.new(midpoint.X, deckY, midpoint.Z),
		Vector3.new(toPos.X, deckY, toPos.Z)
	)

	PartBuilder.make(parent, {
		Name = "BridgeDeck",
		Size = Vector3.new(Config.BridgeWidth, 1, length),
		CFrame = deckCFrame,
		Material = Enum.Material.WoodPlanks,
		Color = Config.Colors.LightWood,
	})

	for _, side in ipairs({ -1, 1 }) do
		for _, interval in ipairs(railIntervals(length, railGaps)) do
			local railLength = interval[2] - interval[1]
			local railCenter = (interval[1] + interval[2]) / 2
			PartBuilder.make(parent, {
				Name = "BridgeRail",
				Size = Vector3.new(0.3, 1.3, railLength),
				CFrame = deckCFrame
					* CFrame.new(side * (Config.BridgeWidth / 2 - 0.15), 1.15, railCenter),
			})
		end
	end
end

return Bridge
