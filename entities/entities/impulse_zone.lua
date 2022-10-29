if SERVER then
	ENT.Base = "base_brush"
	ENT.Type = "brush"
	ENT.IsZoneTrigger =  true

	-- Updates the bounds of this collision box
	function ENT:SetBounds(min, max)
	    self:DrawShadow(false)
		self:SetNotSolid(true)
	    self:SetSolid(SOLID_BBOX)
	    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	    self:SetCollisionBounds(min, max)
	    self:SetTrigger(true)
	    self:SetMoveType(MOVETYPE_NONE)
	end

	-- Run when any entity starts touching our trigger
	function ENT:StartTouch(ent)
	    if not ent:IsPlayer() then
	        return
	    end

	    ent:SetZone(self.Zone)
	end

	function ENT:Touch()
		return
	end

	function ENT:EndTouch()
		return
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_NEVER
	end
end