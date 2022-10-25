function meta:GetMoney()
	return self:GetSyncVar(SYNC_MONEY, 0)
end

function meta:GetBankMoney()
	return self:GetSyncVar(SYNC_BANKMONEY, 0)
end

function meta:CanAfford(amount)
	return self:GetMoney() >= amount
end

function meta:CanAffordBank(amount)
	return self:GetBankMoney() >= amount
end