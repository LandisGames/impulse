local PANEL = {}

function PANEL:Init()
	self:Receiver("impulseInv", self.OnDrop)
	self:SetMouseInputEnabled(false)
	self:SetSize(140, 140)
	self:Hide()
end

function PANEL:SetItem(panel)
	self.Item = panel
	self:SetPos(gui.MouseX() + 6, gui.MouseY() - self:GetTall() - 6)

	self.ItemName = panel.Item.Name
	self.ItemColour = panel.Item.Colour or impulse.Config.MainColour
	self.ItemDesc = panel.Item.Desc or ""
	self.ItemRarity = 1
	self.ItemIsIllegal = panel.Item.Illegal or false
	self.ItemIsEquipped = panel.Item.Equipable or false
	self.ItemIsRestricted = panel.Item.Restricted or false

	surface.SetFont("Impulse-Elements18-Shadow")
	local nameSize = surface.GetTextSize(self.ItemName)

	surface.SetFont("Impulse-Elements16-Shadow")
	local descSize = surface.GetTextSize(self.ItemDesc)

	local wide
	if descSize > nameSize and nameSize < 200 then
		wide = math.Clamp(descSize, 140, 200)
	else
		wide = math.Clamp(nameSize, 140, 340)
	end

	local extraTall = 0
	if descSize > 773 then
		extraTall = 70
	end

	local extraMarkup = ""

	if self.ItemIsIllegal then
		extraMarkup = "<colour=255, 0, 0, 255>This item is contraband</colour>\n"
	end

	if self.ItemIsEquipped then
		extraMarkup = extraMarkup.."<colour=0, 200, 0, 255>This item is equipped</colour>\n"
	end

	if self.ItemIsRestricted then
		extraMarkup = extraMarkup.."<colour=255, 223, 0, 255>This item is restricted</colour>\n"
	end

	self.ItemDescMarkup = markup.Parse("<font=Impulse-Elements16-Shadow>"..extraMarkup.."<colour=255, 255, 255, 255>"..self.ItemDesc.."</colour></font>", wide)

	self:SetSize(wide + 20, 140 + extraTall)
	self:Show()
end

function PANEL:Think()
	self:SetPos(gui.MouseX() + 6, gui.MouseY() - self:GetTall() - 2)

	if self.Item and IsValid(self.Item) and self.Item.model:IsHovered() then
		self:MoveToFront()
	else
		self:Remove()
	end
end

local gradient = Material("vgui/gradient-r")
local outlineCol = Color(10, 10, 10, 255)
local darkCol = Color(80, 80, 80, 100)
local fullCol = Color(139, 0, 0, 15)

function PANEL:Paint(w,h)
	impulse.blur(self, 10, 20, 255)
	surface.SetDrawColor(darkCol)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(outlineCol)
	surface.DrawOutlinedRect(0, 0, w, h)

	surface.SetFont("Impulse-Elements18-Shadow")
	surface.SetTextColor(self.ItemColour)
	surface.SetTextPos(10, 10)
	surface.DrawText(self.ItemName)

	self.ItemDescMarkup:Draw(10, 30)
end

vgui.Register("impulseInventoryHover", PANEL, "DPanel")