local PANEL = {}

function PANEL:Init()
	self.model = vgui.Create("DModelPanel", self)
	self.model:SetPaintBackground(false)
	self:SetMouseInputEnabled(true)
	self:SetTall(74)

	self:SetCursor("hand")
end

function PANEL:SetItem(item, sellData)
	self.Item = item
	self.SellData = sellData

	local panel = self

	self.model:SetPos(0, 0)
	self.model:SetSize(74, 74)
	self.model:SetMouseInputEnabled(true)
	self.model:SetModel(item.Model)
	self.model:SetFOV(item.FOV or 35)

	function self.model:LayoutEntity(ent)
		ent:SetAngles(Angle(0, 90, 0))

		if panel.Item.Material then
			ent:SetMaterial(panel.Item.Material)
		end

		if not item.NoCenter then
			self:SetLookAt(Vector(0, 0, 0))
		end

		if item.Skin then
			ent:SetSkin(item.Skin)
		end
	end

	function self.model:DoClick()
		panel:OnMousePressed()
	end

	local camPos = self.model.Entity:GetPos()
	camPos:Add(Vector(0, 25, 25))

	local min, max = self.model.Entity:GetRenderBounds()

	if item.CamPos then
		self.model:SetCamPos(item.CamPos)
	else
		self.model:SetCamPos(camPos -  Vector(10, 0, 16))
	end

	self.model:SetLookAt((max + min) / 2)
end

function PANEL:Think()
	if self.ItemID then
		local inv = impulse.Inventory.Data[0][1]

		if not inv[self.ItemID] then
			self:Remove()
		end
	end
end

function PANEL:OnMousePressed()
	if self.Selling then
		net.Start("impulseVendorSell")
		net.WriteUInt(self.ItemID, 16)
		net.SendToServer()
	else
		net.Start("impulseVendorBuy")
		net.WriteString(self.Item.UniqueID)
		net.SendToServer()
	end
end

local activeCol = Color(35, 35, 35, 88)
local hoverCol = Color(120, 120, 120, 88)
local disabledCol = Color(15, 15, 15, 150)
local grey = Color(170, 170, 170, 150)

function PANEL:Paint(w, h)
	local col = activeCol
	local cost = self.SellData.Cost
	local max = self.SellData.Max
	local hasItem, amount = LocalPlayer():HasInventoryItem(impulse.Inventory.ClassToNetID(self.Item.UniqueID))
	local disabled = false
	local maxed = false

	if (cost and cost > LocalPlayer():GetMoney()) or (self.SellData.CanBuy and self.SellData.CanBuy(LocalPlayer()) == false) then
		col = disabledCol
		disabled = true
	end

	if max and hasItem and amount >= max then
		col = disabledCol
		disabled = true
		maxed = true
	end

	surface.SetDrawColor(col)
	surface.DrawRect(0, 0, w, h)

	if self:IsHovered() then
		if disabled then
			surface.SetDrawColor(disabledCol)
		else
			surface.SetDrawColor(hoverCol)
		end

		surface.DrawRect(0, 0, w, h)
	end

	draw.SimpleText(self.Item.Name, "Impulse-Elements18-Shadow", 80, 10, (disabled and grey) or color_white)

	local desc = ""

	if cost then
		desc = cost.." "..impulse.Config.CurrencyName
	else
		desc = "Free"
	end

	if self.SellData.Desc then
		desc = desc.." ("..self.SellData.Desc..")"
	end

	draw.SimpleText(desc, "Impulse-Elements17-Shadow", 80, 30, grey)

	if max then
		draw.SimpleText((amount or 0).."/"..max.." (max limit)", "Impulse-Elements17-Shadow", 80, 45, grey)
	end
end

vgui.Register("impulseVendorItem", PANEL, "DPanel")