AddCSLuaFile()

ENT.Type = "anim"
ENT.Category = "impulse"
ENT.Spawnable = false


if SERVER then
	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)  
		self:SetMoveType(SOLID_VPHYSICS)  
		self:SetSolid(SOLID_VPHYSICS)   
		self:SetUseType(SIMPLE_USE)

    	local physObj = self:GetPhysicsObject()
    	self.nodupe = true

    	if IsValid(physObj) then
			physObj:Wake()
		end
	end

	function ENT:Use(activator)
	end
end

	