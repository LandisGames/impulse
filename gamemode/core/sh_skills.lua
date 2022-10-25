impulse.Skills = impulse.Skills or {}
impulse.Skills.Skills = impulse.Skills.Skills or {}
impulse.Skills.NiceNames = impulse.Skills.NiceNames or {}
impulse.Skills.Data = impulse.Skills.Data or {}
local count = 0

function impulse.Skills.Define(name, niceName)
	count = count + 1
	impulse.Skills.Skills[name] = count
	impulse.Skills.NiceNames[name] = niceName
end

function impulse.Skills.GetNiceName(name)
	return impulse.Skills.NiceNames[name]
end

if CLIENT then
	function meta:GetSkillXP(name)
		local xp = impulse.Skills.Data[name]
		
		return xp or 0
	end

	function impulse.Skills.GetLevelXPRequirement(level)
		local req = 0

		for i = 1, level do
			req = req + (i * 100)
		end

		return math.Clamp(req, 0, 4500)
	end
end

function meta:GetSkillLevel(name)
	local xp = self:GetSkillXP(name)
	local req = 0

	for i = 1, 10 do
		if xp < req then
			return i - 1
		end

		req = req + (i * 100)
	end

	return 10
end

impulse.Skills.Define("craft", "Crafting")
--impulse.Skills.Define("medicine", "Medicine")
impulse.Skills.Define("strength", "Strength")
impulse.Skills.Define("lockpick", "Lockpicking")