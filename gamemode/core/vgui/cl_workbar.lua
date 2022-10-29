local PANEL = {}

function PANEL:Init()
	self:SetSize(500, 50)
	self:Center()
	self.Progress = 0
	self.Text = ""

	impulse_ActiveWorkbar = true
end

function PANEL:SetEndTime(endtime)
	self.EndTime = endtime
	self.StartTime = CurTime()
end

function PANEL:SetText(text)
	self.Text = text
end

function PANEL:Think()
	if not self.EndTime then return end
	local timeDist = self.EndTime - CurTime()
	self.Progress = math.Clamp(((self.StartTime - CurTime()) / (self.StartTime - self.EndTime)), 0, 1)

	if self.Progress == 1 then
		impulse_ActiveWorkbar = false
		self:Remove()

		local endFunc = self.OnEnd
		if endFunc then
			endFunc()
		end
	end
end

local bgCol = impulse.Config.MainColour
local outlineCol = Color(50, 50, 50, 255)
local bodyCol = Color(30, 30, 30, 100)
function PANEL:Paint(w, h)
	impulse.blur(self, 10, 20, 255)
	surface.SetDrawColor(bodyCol)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(impulse.Config.MainColour)
	surface.DrawRect(5, 5, (w - 10) * self.Progress, h - 10)

	surface.SetDrawColor(outlineCol)
	surface.DrawOutlinedRect(0, 0, w, h)

	draw.SimpleText(self.Text, "Impulse-Elements20-Shadow", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("impulseWorkbar", PANEL, "DPanel")