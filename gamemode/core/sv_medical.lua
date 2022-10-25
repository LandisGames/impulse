function meta:BreakLegs()
	self.BrokenLegsTime = CurTime() + impulse.Config.BrokenLegsHealTime -- reset heal time

	if self:HasBrokenLegs() then
		return
	end

	self:SetSyncVar(SYNC_BROKENLEGS, true, true)
	self.BrokenLegs = true

	self:EmitSound("impulse/bone"..math.random(1, 3)..".wav")
	self:Notify("You have broken your legs.")

	hook.Run("PlayerLegsBroken", self)
end

function meta:FixLegs()
	self:SetSyncVar(SYNC_BROKENLEGS, false, true)
	self.BrokenLegs = false
	self.BrokenLegsTime = nil
end