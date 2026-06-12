--[[
	PartBuilder
	The one place that turns a property table into an anchored Part.
	All world geometry goes through here so defaults (anchored, wood,
	named) stay consistent everywhere.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local PartBuilder = {}

function PartBuilder.make(parent: Instance, props: { [string]: any }): Part
	local part = Instance.new("Part")
	part.Anchored = true
	part.Color = props.Color or Config.Colors.Wood
	part.Material = props.Material or Enum.Material.Wood
	if props.Shape then
		part.Shape = props.Shape
	end
	part.Size = props.Size
	if props.CFrame then
		part.CFrame = props.CFrame
	else
		part.Position = props.Position
	end
	if props.Transparency then
		part.Transparency = props.Transparency
	end
	if props.CanCollide ~= nil then
		part.CanCollide = props.CanCollide
	end
	part.Name = props.Name or "Part"
	part.Parent = parent
	return part
end

return PartBuilder
