function meta:GetSkillXP(name)
	local skills = self.impulseSkills
	if not skills then return end

	if skills[name] then
		return skills[name]
	else
		return 0
	end
end

function meta:SetSkillXP(name, value)
	if not self.impulseSkills then return end
	if not impulse.Skills.Skills[name] then return end

	value = math.Round(value)

	self.impulseSkills[name] = value

	local data = util.TableToJSON(self.impulseSkills)

	if data then
		local query = mysql:Update("impulse_players")
		query:Update("skills", data)
		query:Where("steamid", self:SteamID())
		query:Execute()
	end

	self:NetworkSkill(name, value)
end

function meta:NetworkSkill(name, value)
	net.Start("impulseSkillUpdate")
	net.WriteUInt(impulse.Skills.Skills[name], 4)
	net.WriteUInt(value, 16)
	net.Send(self)
end

function meta:AddSkillXP(name, value)
	if not self.impulseSkills then return end

	local cur = self:GetSkillXP(name)
	local new = math.Round(math.Clamp(cur + value, 0, 4500))

	if cur != new then
		self:SetSkillXP(name, new)
		hook.Run("PlayerAddSkillXP", self, new, name)
	end
end