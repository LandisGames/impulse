function meta:GetZone()
	return self.impulseZone
end

function meta:GetZoneName()
	if self.impulseZone then
		return impulse.Config.Zones[self.impulseZone].name
	else
		return ""
	end
end

function meta:SetZone(id)
	if (self.impulseZone or -1) == id then return end
	self.impulseZone = id

	net.Start("impulseZoneUpdate")
	net.WriteUInt(id, 8)
	net.Send(self)

	hook.Run("PlayerZoneChanged", self, id)
end