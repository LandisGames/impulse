local PANEL = {}

function PANEL:Init()
	self:SetAlpha(0)
	self:SetPos(0, 0)
	self:SetSize(ScrW(), ScrH())
end

function PANEL:Setup(text, x, y, fadein, fadeout, hold, col, align)
	self:AlphaTo(255, fadein or 3, 0, function() self:AlphaTo(0, fadeout or 3, hold or 5, function() self:Remove() end) end)
	self.text = text
	self.pX = x or 0.5
	self.pY = y or 0.5
	self.col = col or color_white
	self.align = self.align or TEXT_ALIGN_CENTER
end

function PANEL:Paint(w,h)
	if self.text then
		draw.DrawText(self.text, "Impulse-Elements36", w * self.pX, h * self.pY, self.col, self.align)
	end
end

vgui.Register("impulseFadeText", PANEL, "DPanel")
