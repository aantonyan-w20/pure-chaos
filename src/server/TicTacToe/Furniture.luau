--[[
	Furniture
	The wooden table and its two assigned chairs. One chair always
	plays X (red backrest), the other always plays O (blue backrest),
	so players can pick a side before they sit.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local PartBuilder = require(script.Parent.Parent.World.PartBuilder)

local Furniture = {}

local CHAIR_LEG_OFFSETS = {
	Vector3.new(-0.8, 0, -0.8),
	Vector3.new(0.8, 0, -0.8),
	Vector3.new(-0.8, 0, 0.8),
	Vector3.new(0.8, 0, 0.8),
}

local function buildTable(parent: Instance, cx: number, cz: number)
	local tableSize = Config.TableSize
	PartBuilder.make(parent, {
		Name = "TableTop",
		Size = Vector3.new(tableSize, 0.3, tableSize),
		Position = Vector3.new(cx, Config.TableTopY - 0.15, cz),
		Color = Config.Colors.LightWood,
	})

	local legInset = tableSize / 2 - 0.5
	local legHeight = 3 - 0.3
	for _, offset in ipairs({
		Vector3.new(-legInset, 0, -legInset),
		Vector3.new(legInset, 0, -legInset),
		Vector3.new(-legInset, 0, legInset),
		Vector3.new(legInset, 0, legInset),
	}) do
		PartBuilder.make(parent, {
			Name = "TableLeg",
			Size = Vector3.new(0.4, legHeight, 0.4),
			Position = Vector3.new(cx, Config.IslandTop + legHeight / 2, cz) + offset,
		})
	end
end

local function buildChair(parent: Instance, chairPos: Vector3, cx: number, cz: number, symbol: string): Seat
	local seat = Instance.new("Seat")
	seat.Name = "GameChair"
	seat.Size = Vector3.new(2, 0.3, 2)
	seat.CFrame = CFrame.lookAt(chairPos, Vector3.new(cx, chairPos.Y, cz))
	seat.Anchored = true
	seat.Color = Config.Colors.LightWood
	seat.Material = Enum.Material.Wood
	seat:SetAttribute("TableX", cx)
	seat:SetAttribute("TableZ", cz)
	seat:SetAttribute("BoardY", Config.TableTopY)
	seat:SetAttribute("Symbol", symbol)
	seat.Parent = parent

	-- Back and legs are parented to the seat (so ChairSkins can find them)
	-- and tagged with their base size (so scaling skins can restore it).
	local back = PartBuilder.make(seat, {
		Name = "ChairBack",
		Size = Vector3.new(2, 2.2, 0.3),
		CFrame = seat.CFrame * CFrame.new(0, 1.1, 0.85),
		Color = (symbol == "X") and Config.Colors.XChair or Config.Colors.OChair,
	})
	back:SetAttribute("BaseSize", back.Size)

	local seatHeight = chairPos.Y - Config.IslandTop - 0.15
	for _, legOffset in ipairs(CHAIR_LEG_OFFSETS) do
		local leg = PartBuilder.make(seat, {
			Name = "ChairLeg",
			Size = Vector3.new(0.3, seatHeight, 0.3),
			CFrame = seat.CFrame
				* CFrame.new(legOffset.X, 0, legOffset.Z)
				* CFrame.new(0, -seatHeight / 2, 0),
			Color = Config.Colors.LightWood,
		})
		leg:SetAttribute("BaseSize", leg.Size)
	end
	return seat
end

-- Builds the table and both chairs; returns the X seat and the O seat.
function Furniture.build(parent: Instance, cx: number, cz: number): (Seat, Seat)
	buildTable(parent, cx, cz)

	local chairDistance = Config.TableSize / 2 + 1.2
	local chairY = Config.IslandTop + 1.65
	local xSeat = buildChair(parent, Vector3.new(cx, chairY, cz - chairDistance), cx, cz, "X")
	local oSeat = buildChair(parent, Vector3.new(cx, chairY, cz + chairDistance), cx, cz, "O")
	return xSeat, oSeat
end

return Furniture
