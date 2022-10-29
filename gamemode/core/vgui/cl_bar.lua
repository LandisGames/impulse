local PANEL = {}

function PANEL:Init()
	self.Colour = Color(255,255,255,255)
	self.Progress = 0
	self.Label = ""
	self.TimeProgress = 0
end

function PANEL:SetColour(col)
	self.Colour = col
end

function PANEL:SetTime(seconds)
	self.Time = seconds
end

function PANEL:GetProgress()
	return self.Progress
end

function PANEL:SetProgress(val)
	self.Progress = val
end

function PANEL:SetLabel(text)
	self.Label = text
end

function PANEL:Think()
	if self.AutoReturn then
		self:SetProgress(math.Clamp(self.AutoReturn() or 0, 0, 100))
	end
end

local gradient = Material("vgui/gradient-d")

function PANEL:Paint(w,h)
	surface.SetDrawColor(30,30,30,155)
	surface.DrawRect(0, 0, w, h)
	surface.DrawOutlinedRect(0,0,w, h)

	surface.SetDrawColor(self.Colour)

	surface.DrawRect(1,1,w/100*self.Progress, h-1)


	surface.SetDrawColor(200,200,200, 90)
	surface.SetMaterial(gradient)
	surface.DrawTexturedRect(0,0,w,h)

	draw.SimpleText(self.Label, "Impulse-Elements18-Shadow", w/2, h/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("impulseDynamicBar", PANEL, "DPanel")
