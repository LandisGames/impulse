include("shared.lua")

ENT.AutomaticFrameAdvance = true
function ENT:Initialize()
	self:DoAnimation()
end

function ENT:Think()
	if ((self.nextAnimCheck or 0) < CurTime()) then
		self:DoAnimation()
		self.nextAnimCheck = CurTime() + 25
	end

	self:SetNextClientThink(CurTime() + 0.25)

	return true
end