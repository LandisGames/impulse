local PANEL = {}

local grey = Color(80, 80, 80, 220)
function PANEL:Init()
	self:SetPos(0, ScrH() - 115)
	self:SetSize(600, 110)
	self:CenterHorizontal()
	self:SetTitle("Snapshot Playback")

	self.slider = vgui.Create("DSlider", self)
	self.slider:SetPos(60, 70)
	self.slider:SetSize(480, 40)
	self.slider:SetSlideX(0)
	self.Length = 30
	self.CurTick = 0
	self.TotalTick = 5600
	self.StartTime = "3:45PM Jan 1st 2020"

	local panel = self

	function self.slider:Paint(w, h)
		draw.RoundedBox(0, 0, 20, w, 2, grey)
		draw.RoundedBox(0, 0, 20, self:GetSlideX() * self:GetWide(), 2, impulse.Config.MainColour)

		draw.SimpleText("0:00".."/"..panel.Length..":00", nil, 0, 25)
	end

	self.playPause = vgui.Create("DButton", self)
	self.playPause:SetPos(60, 30)
	self.playPause:SetSize(70, 30)
	self.playPause:SetText("Play")

	self.save = vgui.Create("DButton", self)
	self.save:SetPos(135, 30)
	self.save:SetSize(70, 30)
	self.save:SetText("Save")

	self.tick = vgui.Create("DButton", self)
	self.tick:SetPos(210, 30)
	self.tick:SetSize(70, 30)
	self.tick:SetText("Goto")

	--self.loader = vgui.Create("DProgress", self)
	--self.loader:SetSize(450, 30)
	--self.loader:SetFraction(0.66)
	--self.loader:Center()


end

function PANEL:PaintOver(w, h)
	if IsValid(self.loader) then
		draw.RoundedBox(0, 0, 0, w, h, grey)
		return
	end

	draw.SimpleText("Ticks: "..self.CurTick.."/"..self.TotalTick, nil, 420, 30)
	draw.SimpleText("Start time: "..self.StartTime, nil, 420, 42)
	draw.SimpleText("Size: ".."766.4".."kb", nil, 420, 54)
end

vgui.Register("impulseSnapshotPlayer", PANEL, "DFrame")