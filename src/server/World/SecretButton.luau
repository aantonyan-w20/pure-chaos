--[[
	SecretButton
	A glowing red disc hidden under the island. Players who swim beneath
	the island can click it. Clicking calls the given handler (which
	grants the free rolls). The button itself knows nothing about the
	reward — it just reports clicks.
]]

local PartBuilder = require(script.Parent.PartBuilder)

local SecretButton = {}

function SecretButton.build(parent: Instance, position: Vector3, onClick: (Player) -> ())
	-- a big, bright, glowing red disc on the island's underside
	local button = PartBuilder.make(parent, {
		Name = "SecretButton",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.6, 5, 5),
		CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(255, 40, 40),
		Material = Enum.Material.Neon,
	})

	local click = Instance.new("ClickDetector")
	click.MaxActivationDistance = 32
	click.Parent = button
	click.MouseClick:Connect(onClick)
	return button
end

return SecretButton
