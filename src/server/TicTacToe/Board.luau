--[[
	Board
	The physical 3x3 board on a table top: nine clickable cells, the
	grid walls between them, and the X/O marks drawn on cells (styled
	by the placing player's equipped skin). Holds no game rules —
	Logic owns those.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Skins = require(ReplicatedStorage.Shared.Skins)
local PartBuilder = require(script.Parent.Parent.World.PartBuilder)

local Board = {}
Board.__index = Board

local function buildCells(parent: Instance, cx: number, cz: number): { Part }
	local cells = {}
	for i = 1, 9 do
		local row = math.floor((i - 1) / 3)
		local col = (i - 1) % 3
		local part = PartBuilder.make(parent, {
			Name = "Cell" .. i,
			Size = Vector3.new(Config.CellSize, Config.BoardHeight, Config.CellSize),
			Position = Vector3.new(
				cx + (col - 1) * Config.CellStep,
				Config.TableTopY + Config.BoardHeight / 2,
				cz + (row - 1) * Config.CellStep
			),
			Color = Config.Colors.EmptyCell,
			Material = Enum.Material.SmoothPlastic,
		})
		local clicker = Instance.new("ClickDetector")
		clicker.MaxActivationDistance = 30
		clicker.Parent = part
		cells[i] = part
	end
	return cells
end

-- The grid frame, oversized so every seam is sealed
local function buildGridWalls(parent: Instance, cx: number, cz: number)
	local wallY = Config.TableTopY + Config.GridWallHeight / 2
	for i = 0, 3 do
		local linePos = -1.5 * Config.CellStep + i * Config.CellStep
		PartBuilder.make(parent, {
			Name = "GridWallV",
			Size = Vector3.new(Config.CellGap + 0.08, Config.GridWallHeight, Config.BoardLength + 0.08),
			Position = Vector3.new(cx + linePos, wallY, cz),
		})
		PartBuilder.make(parent, {
			Name = "GridWallH",
			Size = Vector3.new(Config.BoardLength + 0.08, Config.GridWallHeight, Config.CellGap + 0.08),
			Position = Vector3.new(cx, wallY, cz + linePos),
		})
	end
end

function Board.new(parent: Instance, cx: number, cz: number)
	local self = setmetatable({}, Board)
	self.cells = buildCells(parent, cx, cz)
	buildGridWalls(parent, cx, cz)
	return self
end

-- Wires every cell's ClickDetector to `callback(cellNumber, player)`.
function Board:connectCellClicks(callback: (number, Player) -> ())
	for i, cell in ipairs(self.cells) do
		local clicker = cell:FindFirstChildOfClass("ClickDetector")
		clicker.MouseClick:Connect(function(player)
			callback(i, player)
		end)
	end
end

function Board:drawMark(cellNumber: number, symbol: string, skinId: string?)
	local cell = self.cells[cellNumber]

	local gui = Instance.new("SurfaceGui")
	gui.Name = "Mark"
	gui.Face = Enum.NormalId.Top
	gui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	gui.CanvasSize = Vector2.new(100, 100)
	gui.Parent = cell

	-- parent first: skin animations stop when the label leaves the tree
	local label = Instance.new("TextLabel")
	label.Parent = gui
	Skins.apply(label, skinId or "Classic", symbol)
end

function Board:highlightLine(line: { number }, color: Color3)
	for _, index in ipairs(line) do
		self.cells[index].Color = color
	end
end

-- Wipes every mark and highlight, ready for a fresh game.
function Board:clear()
	for _, cell in ipairs(self.cells) do
		cell.Color = Config.Colors.EmptyCell
		local mark = cell:FindFirstChild("Mark")
		if mark then
			mark:Destroy()
		end
	end
end

return Board
