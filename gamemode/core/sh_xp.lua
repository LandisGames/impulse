function meta:GetXP()
	return self:GetSyncVar(SYNC_XP, 0)
end

if SERVER then
	function meta:SetXP(amount)
		if not self.beenSetup or self.beenSetup == false then return end
		if not isnumber(amount) or amount < 0 or amount >= 1 / 0 then return end

		local query = mysql:Update("impulse_players")
		query:Update("xp", amount)
		query:Where("steamid", self:SteamID())
		query:Execute()

		return self:SetSyncVar(SYNC_XP, amount, true)
	end

	function meta:AddXP(amount)
		local setAmount = self:GetXP() + amount

		self:SetXP(setAmount)

		hook.Run("PlayerGetXP", self, amount)
	end

	function meta:GiveTimedXP()
		if self:IsDonator() then
			self:AddXP(impulse.Config.XPGetVIP)
			self:Notify("You have received "..impulse.Config.XPGetVIP.." XP for playing.")
		else
			self:AddXP(impulse.Config.XPGet)
			self:Notify("You have received "..impulse.Config.XPGet.." XP for playing.")
		end
	end
end