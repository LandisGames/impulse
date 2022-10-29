local PANEL = {}

function PANEL:Init()
	self.IsMenuMessage = true
end

function PANEL:SetMessage(uid)
	self.Message = impulse.MenuMessage.Data[uid]
	self.Message.colour = ColorAlpha(self.Message.colour, 170)

	self.desc = vgui.Create("DLabel", self)
	self.desc:SetPos(50, 40)
	self.desc:SetSize(self:GetWide() - 60, self:GetTall() - 20)
	self.desc:SetFont(HIGH_RES("Impulse-Elements17-Shadow", "Impulse-Elements22-Shadow"))
	self.desc:SetWrap(true)
	self.desc:SetContentAlignment(7)
	self.desc:SetText(self.Message.message)

	self.close = vgui.Create("DImageButton", self)
	self.close:SetPos(self:GetWide() - 30, 4)
	self.close:SetSize(25, 25)
	self.close:SetImage("impulse/icons/x-mark-128.png")

	local panel = self
	function self.close:DoClick()
		panel:Remove()

		if panel.OnClosed then
			panel.OnClosed()
		end
	end

	if self.Message.url then
		self.url = vgui.Create("DLabel", self)
		self.url:SetPos(50, self:GetTall() - 20)
		self.url:SetTextColor(Color(0, 97, 175))
		self.url:SetFont(HIGH_RES("Impulse-Elements17-Shadow", "Impulse-Elements22-Shadow"))
		self.url:SetText(self.Message.urlText or "Find out more...")
		self.url:SetURL(self.Message.url)
		self.url:SetCursor("hand")
		self.url:SetMouseInputEnabled(true)
		self.url:SizeToContents()
		self.url.url = self.Message.url

		function self.url:DoClick()
			gui.OpenURL(self.url)
		end
	end
end

local gradient = Material("vgui/gradient-l")
local icon = Material("impulse/icons/warning-128.png")
local bodyCol = Color(30, 30, 30, 190)
function PANEL:Paint(w,h)
	surface.SetDrawColor(bodyCol)
	surface.DrawRect(0, 0, w, h)

	if self.Message then
		surface.SetDrawColor(self.Message.colour)
		surface.SetMaterial(gradient)
		surface.DrawTexturedRect(0, 0, w, 32)
		surface.SetDrawColor(ColorAlpha(self.Message.colour, 50))
		surface.DrawRect(0, 0, w, 32)

		draw.SimpleText(self.Message.title, HIGH_RES("Impulse-Elements22-Shadow", "Impulse-Elements23-Shadow"), 10, 16, nil, nil, TEXT_ALIGN_CENTER)

		surface.SetMaterial(icon)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRect(5, 38, 36, 36)
	end
end

vgui.Register("impulseMenuMessage", PANEL, "DPanel")