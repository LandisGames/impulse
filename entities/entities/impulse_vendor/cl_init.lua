include("shared.lua")

ENT.AutomaticFrameAdvance = true
function ENT:Initialize()
	self:DoAnimation(self:GetIdleSequence())
end

function ENT:Think()
	if ((self.nextAnimCheck or 0) < CurTime()) then
		self:DoAnimation(self:GetIdleSequence())
		self.nextAnimCheck = CurTime() + 25
	end

	local vendor = self:GetVendor()

	if vendor != self.curVendor and impulse.Vendor.Data[vendor] then
		self.Vendor = impulse.Vendor.Data[vendor]
		self.HUDName = self.Vendor.Name
		self.HUDDesc = self.Vendor.Desc

		self.curVendor = vendor
	end

	self:SetNextClientThink(CurTime() + 0.25)

	return true
end