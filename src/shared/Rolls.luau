--[[
	Rolls
	The catalog of rolls and the weighted dice throw. Each roll has a
	`kind`: "mark" rolls give X/O skins, "chair" rolls give chair skins
	(absent kind means "mark"). Weights are relative chances — they don't
	have to sum to 100; each real chance is weight / (sum of weights).
	The client only uses this for display; the server does the rolling.
]]

local Rolls = {}

Rolls.Catalog = {
	{
		id = "mega",
		name = "Mega Roll",
		costTacs = 100,
		items = {
			{ skin = "Rainbow", weight = 1 },
			{ skin = "Red", weight = 60 },
			{ skin = "ShinyGreen", weight = 10 },
			{ skin = "Cursive", weight = 29 },
		},
	},
	{
		id = "lucky",
		name = "Lucky Roll",
		costTacs = 50,
		items = {
			{ skin = "Blue", weight = 20 },
			{ skin = "Tiny", weight = 5 },
			{ skin = "Pink", weight = 40 },
			{ skin = "Yellow", weight = 40 },
		},
	},
	{
		id = "pro",
		name = "Pro Roll",
		requiresGamepass = true,
		items = {
			{ skin = "ColorShift", weight = 10 },
			{ skin = "Invisible", weight = 40 },
			{ skin = "Soccer", weight = 50 },
		},
	},
	{
		id = "chairBasic",
		name = "Chair Roll",
		kind = "chair",
		costTacs = 60,
		items = {
			{ skin = "GreenChair", weight = 30 },
			{ skin = "YellowChair", weight = 30 },
			{ skin = "TinyChair", weight = 10 },
			{ skin = "GlitchChair", weight = 5 },
		},
	},
	{
		id = "chairElite",
		name = "Elite Chair Roll",
		kind = "chair",
		costTacs = 120,
		items = {
			{ skin = "HumongousChair", weight = 30 },
			{ skin = "InvisibleChair", weight = 20 },
			{ skin = "RainbowChair", weight = 5 },
			{ skin = "MythicChair", weight = 1 },
		},
	},
}

function Rolls.byId(rollId: string)
	for _, roll in ipairs(Rolls.Catalog) do
		if roll.id == rollId then
			return roll
		end
	end
	return nil
end

-- Picks one skin id from the roll, each item weighted by its `weight`
function Rolls.pick(roll, rng: Random): string
	local total = 0
	for _, item in ipairs(roll.items) do
		total += item.weight
	end

	local ticket = rng:NextNumber(0, total)
	for _, item in ipairs(roll.items) do
		ticket -= item.weight
		if ticket <= 0 then
			return item.skin
		end
	end
	return roll.items[#roll.items].skin
end

return Rolls
