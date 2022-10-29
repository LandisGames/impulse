local PANEL = {}

function PANEL:Init()
	self:SetAlpha(0)
	self:SetSize(300, 30)
	self:AlphaTo(255, 3, 0, function() self:AlphaTo(0, 3, 4, function() self:Remove() end) end)
end

function PANEL:Think()
	if self.Zone != LocalPlayer():GetZoneName() then
		self.Zone = LocalPlayer():GetZoneName()
	end

	if not LocalPlayer():Alive() then
		return self:Remove()
	end

	if not impulse.hudEnabled then
		return self:Remove()
	end

	local x = hook.Run("ShouldDrawHUDBox")
	if x != nil and x == false then
		return self:Remove()
	end

	if impulse.chatBox and IsValid(impulse.chatBox.chatLog) and impulse.chatBox.chatLog.active then
		return self:Remove()
	end
end

function PANEL:Paint(w,h)
	if self.Zone then
		draw.DrawText(self.Zone, "Impulse-Elements23-Italic", 0, 0, color_white, TEXT_ALIGN_LEFT)
	end
end

vgui.Register("impulseZoneLabel", PANEL, "DPanel")
