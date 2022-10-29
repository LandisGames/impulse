local PANEL = {}

function PANEL:Init()
	self:SetAlpha(0)
	self:SetSize(520, 120)
	self:CenterHorizontal()
	self:CenterVertical(0.85)
	self:MoveToFront()

	self:AlphaTo(255, 3, 0, function() self:AlphaTo(0, 3, 4, function() self:Remove() end) end)
	surface.PlaySound("buttons/blip1.wav")
end

function PANEL:SetAchivement(event)
	self.Achievement = impulse.Config.Achievements[event]

	local desc = vgui.Create("DLabel", self)
	desc:SetPos(120, 60)
	desc:SetSize(400, 60)
	desc:SetFont("Impulse-Elements18-Shadow")
	desc:SetContentAlignment(7)
	desc:SetWrap(true)
	desc:SetText(self.Achievement.Desc)
end

local topCol = Color(30, 30, 30, 200)
function PANEL:Paint(w,h)
	impulse.blur(self, 10, 20, 255)
	draw.RoundedBox(0, 0, 0, w, h, topCol)

	draw.SimpleText("Achievement Unlocked", "Impulse-Elements27-Shadow", 120, 10, impulse.Config.MainColour)
	draw.SimpleText(self.Achievement.Name, "Impulse-Elements22-Shadow", 120, 40)

	surface.SetDrawColor(color_white)
	surface.SetMaterial(self.Achievement.Icon)
	surface.DrawTexturedRect(10, 10, 100, 100)
end

vgui.Register("impulseAchievementNotify", PANEL, "DPanel")
