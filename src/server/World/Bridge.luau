--[[
	Bridge
	A flat plank bridge with railings connecting two islands.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PartBuilder = require(script.Parent.PartBuilder)

local Bridge = {}

function Bridge.build(parent: Instance, fromPos: Vector3, toPos: Vector3)
	-- The deck top sits 0.05 studs above the grass: if the two surfaces are
	-- at exactly the same height, they flicker (z-fight) where they overlap
	-- at the island edge.
	local deckY = Config.IslandTop - 0.45
	local distance = (toPos - fromPos).Magnitude
	local midpoint = (fromPos + toPos) / 2
	local deckCFrame = CFrame.lookAt(
		Vector3.new(midpoint.X, deckY, midpoint.Z),
		Vector3.new(toPos.X, deckY, toPos.Z)
	)

	PartBuilder.make(parent, {
		Name = "BridgeDeck",
		Size = Vector3.new(Config.BridgeWidth, 1, distance + 4),
		CFrame = deckCFrame,
		Material = Enum.Material.WoodPlanks,
		Color = Config.Colors.LightWood,
	})

	for _, side in ipairs({ -1, 1 }) do
		PartBuilder.make(parent, {
			Name = "BridgeRail",
			Size = Vector3.new(0.3, 1.3, distance + 4),
			CFrame = deckCFrame * CFrame.new(side * (Config.BridgeWidth / 2 - 0.15), 1.15, 0),
		})
	end
end

return Bridge
