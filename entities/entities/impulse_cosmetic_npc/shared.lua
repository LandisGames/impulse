ENT.Type = "anim"
ENT.PrintName = "Cosmetic NPC"
ENT.Author = "vin"
ENT.Category = "impulse"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.HUDName = "City Clerk"
ENT.HUDDesc = "You can change your appearance here."

function ENT:DoAnimation()
	for k,v in ipairs(self:GetSequenceList()) do
		if (v:lower():find("idle") and v != "idlenoise") then
			return self:ResetSequence(k)
		end
	end

	self:ResetSequence(4)
end