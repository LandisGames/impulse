function meta:SetMoney(amount)
	if not self.beenSetup or self.beenSetup == false then return end
	if not isnumber(amount) or amount < 0 or amount >= 1 / 0 then return end

	local query = mysql:Update("impulse_players")
	query:Update("money", amount)
	query:Where("steamid", self:SteamID())
	query:Execute()

	return self:SetLocalSyncVar(SYNC_MONEY, amount)
end

function meta:SetBankMoney(amount)
	if not self.beenSetup or self.beenSetup == false then return end
	if not isnumber(amount) or amount < 0 or amount >= 1 / 0 then return end

	local query = mysql:Update("impulse_players")
	query:Update("bankmoney", amount)
	query:Where("steamid", self:SteamID())
	query:Execute()

	return self:SetLocalSyncVar(SYNC_BANKMONEY, amount)
end

function meta:GiveBankMoney(amount)
	return self:SetBankMoney(self:GetBankMoney() + amount)
end

function meta:TakeBankMoney(amount)
	return self:SetBankMoney(self:GetBankMoney() - amount)
end

function meta:GiveMoney(amount)
	return self:SetMoney(self:GetMoney() + amount)
end

function meta:TakeMoney(amount)
	return self:SetMoney(self:GetMoney() - amount)
end

function impulse.SpawnMoney(pos, amount, dropper)
	local note = ents.Create("impulse_money")
	note:SetMoney(amount)
	note:SetPos(pos)
	note.Dropper = dropper or nil
	note:Spawn()

	return note
end