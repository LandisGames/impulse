ENT.Type = "anim"
ENT.PrintName = "Vendor Base"
ENT.Author = "vin"
ENT.Category = "impulse"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.HUDName = "Unset Vendor"
ENT.HUDDesc = "This vendor has no VendorType set. Use the key/value save system to set 'vendor' to the string ID of the vendor. Then reload me."

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Vendor")
	self:NetworkVar("String", 1, "IdleSequence")
end

function ENT:DoAnimation(custom)
	if custom and custom != "" then
		return self:ResetSequence(custom)
	end

	for k,v in ipairs(self:GetSequenceList()) do
		if (v:lower():find("idle") and v != "idlenoise") then
			return self:ResetSequence(k)
		end
	end

	self:ResetSequence(4)
end