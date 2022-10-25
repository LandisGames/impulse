if SERVER then
	function meta:SetRPName(name, save)
		if save then
			local query = mysql:Update("impulse_players")
			query:Update("rpname", name)
			query:Where("steamid", self:SteamID())
			query:Execute(true)

			self.defaultRPName = name
		end

		hook.Run("PlayerRPNameChanged", self, self:Name(), name)

		self:SetSyncVar(SYNC_RPNAME, name, true)
	end

	function meta:GetSavedRPName()
		return self.defaultRPName
	end
end

local blacklistNames = {
	["ooc"] = true,
	["shared"] = true,
	["world"] = true,
	["world prop"] = true,
	["blocked"] = true,
	["admin"] = true,
	["server admin"] = true,
	["mod"] = true,
	["game moderator"] = true,
	["adolf hitler"] = true,
	["masked person"] = true,
	["masked player"] = true,
	["unknown"] = true,
	["nigger"] = true,
	["tyrone jenson"] = true
}

function impulse.CanUseName(name)
	if name:len() >= 24 then
		return false, "Name too long. (max. 24)" 
	end

	name = name:Trim()
	name = impulse.SafeString(name)

	if name:len() <= 6 then
		return false, "Name too short. (min. 6)"
	end

	if name == "" then
		return false, "No name was provided."
	end


	local numFound = string.match(name, "%d") -- no numerics

	if numFound then
		return false, "Name contains numbers."
	end
	
	if blacklistNames[name:lower()] then
		return false, "Blacklisted/reserved name."	
	end

	return true, name
end

meta.steamName = meta.steamName or meta.Name
function meta:SteamName()
	return self.steamName(self)
end

function meta:Name()
    return self:GetSyncVar(SYNC_RPNAME, self:SteamName())
end

function meta:KnownName()
	local custom = hook.Run("PlayerGetKnownName", self)
	return custom or self:GetSyncVar(SYNC_RPNAME, self:SteamName())
end

meta.GetName = meta.Name
meta.Nick = meta.Name
