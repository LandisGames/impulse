local PANEL = {}

function PANEL:Init()
	self:SetSize(640, 500)
	self:Center()
	self:SetTitle("Achievements (you have "..LocalPlayer():GetSyncVar(SYNC_TROPHYPOINTS, 0).." achievement points)")
	self:MakePopup()

	local panel = self

	self.scroll = vgui.Create("DScrollPanel", self)
	self.scroll:Dock(FILL)

	self.unlocked = vgui.Create("DCollapsibleCategory", self.scroll)
	self.unlocked:SetLabel("Unlocked achievements")
	self.unlocked:Dock(TOP)

	self.unlockedLayout = vgui.Create("DListLayout")
	self.unlockedLayout:Dock(FILL)
	self.unlocked:SetContents(self.unlockedLayout)

	self.locked = vgui.Create("DCollapsibleCategory", self.scroll)
	self.locked:SetLabel("Locked achievements")
	self.locked:Dock(TOP)

	self.lockedLayout = vgui.Create("DListLayout")
	self.lockedLayout:Dock(FILL)
	self.locked:SetContents(self.lockedLayout)

	for v,k in pairs(impulse.Config.Achievements) do
		local t = self.lockedLayout
		local unlocked = false
		local sub = "Locked"

		if impulse.Achievements[v] then
			t = self.unlockedLayout
			unlocked = true

			sub = "Unlocked on "..os.date("%d/%m/%Y", impulse.Achievements[v])
		end

		local ach = t:Add("DPanel")
		ach:SetTall(100)

		local activeCol = Color(55, 55, 55, 150)
		local disabledCol = Color(15, 15, 15, 190)
		function ach:Paint(w, h)
			draw.RoundedBox(0, 0, 0, w, h, activeCol)
			draw.SimpleText(k.Name, "Impulse-Elements22-Shadow", 110, 20)

			draw.SimpleText(sub, "Impulse-Elements16-Shadow", 110, 40)

			surface.SetDrawColor(color_white)
			surface.SetMaterial(k.Icon)
			surface.DrawTexturedRect(10, 10, 82, 84)

			if not unlocked then
				draw.RoundedBox(0, 0, 0, w, h, disabledCol)
			end
		end

		local desc = vgui.Create("DLabel", ach)
		desc:SetPos(110, 55)
		desc:SetSize(400, 40)
		desc:SetFont("Impulse-Elements18-Shadow")
		desc:SetContentAlignment(7)
		desc:SetWrap(true)
		desc:SetText(k.Desc)

		ach:Dock(TOP)
	end
end


vgui.Register("impulseAchievements", PANEL, "DFrame")