local PANEL = {}

function PANEL:Init()
	self:Receiver("impulseInv")
end

local outlineCol = Color(10, 10, 10, 255)
local darkCol = Color(30, 30, 30, 190)
local fullCol = Color(139, 0, 0, 15)

function PANEL:Paint(w,h)
	--surface.SetMaterial(gradient)
	surface.SetDrawColor(darkCol)
	surface.DrawRect(0, 0, w, h)
	--surface.DrawTexturedRect(1, 1, w - 1, h - 1)

	if self.Unusable then
		surface.SetDrawColor(fullCol)
		surface.DrawRect(0, 0, w, h)
	end

	surface.SetDrawColor(outlineCol)
	surface.DrawOutlinedRect(0, 0, w, h)
end

function PANEL:OnMousePressed()

end

vgui.Register("impulseInventoryCard", PANEL, "DPanel")