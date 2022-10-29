local PANEL = {}

function PANEL:Init()
	self.model = vgui.Create("DModelPanel", self)
	self.model:SetPaintBackground(false)
	self:SetMouseInputEnabled(true)
	self:SetTall(64)

	self:SetCursor("hand")
end

function PANEL:SetItem(netitem, wide)
	local direct = self.ContainerType
	local item = impulse.Inventory.Items[(direct and netitem) or netitem.id]
	self.Item = item

	if not direct then
		self.IsEquipped = netitem.equipped or false
		self.IsRestricted = netitem.restricted or false
	end

	self.Weight = item.Weight or 0
	self.Count = 1

	local panel = self
	self.model:SetPos(0, 0)
	self.model:SetSize(64, 64)
	self.model:SetMouseInputEnabled(true)
	self.model:SetModel(item.Model)
	self.model:SetFOV(item.FOV or 35)

	if self.Item.ItemColour then
		self.model:SetColor(self.Item.ItemColour)
	end

	function self.model:LayoutEntity(ent)
		ent:SetAngles(Angle(0, 90, 0))

		if panel.Item.Material then
			ent:SetMaterial(panel.Item.Material)
		end

		if not item.NoCenter then
			self:SetLookAt(Vector(0, 0, 0))
		end

		if panel.Item.Skin then
			ent:SetSkin(panel.Item.Skin)
		end
	end

	function self.model:DoClick()
		panel:OnMousePressed()
	end

	function self.model:DoRightClick()
		panel:OnMousePressed(MOUSE_RIGHT)
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

	self.desc = vgui.Create("DLabel", self)
	self.desc:SetPos(65, 30)

	if self.Basic then
		self.desc:SetSize(270, 30)
	else
		self.desc:SetSize(wide - 530, 30)
	end

	if wide < 800 then -- small resolutions have trouble with 16
		self.desc:SetFont("Impulse-Elements14")
	else
		self.desc:SetFont("Impulse-Elements16")
	end

	self.desc:SetText(item.Desc or "")
	self.desc:SetContentAlignment(7)
	self.desc:SetWrap(true)

	self.count = vgui.Create("DLabel", self)

	if self.IsRestricted or self.Item.Illegal then
		self.count:SetPos(42, 28)
	else
		self.count:SetPos(42, 38)
	end

	self.count:SetText("")
	self.count:SetTextColor(impulse.Config.MainColour)
	self.count:SetFont("Impulse-Elements19-Shadow")
	self.count:SetSize(36, 20)

	function self.count:Think()
		if panel.Count > 1 and panel.Count != self.lastCount then
			self:SetText("x"..panel.Count)
			self.lastCount = panel.Count
			panel.Weight = panel.Count * panel.Item.Weight

			local wShift = 0

			if panel.Count > 99 then
				wShift = -16
			elseif panel.Count > 9 then
				wShift = -8
			end

			if panel.IsRestricted or panel.Item.Illegal then
				self:SetPos(42 + wShift, 28)
			else
				self:SetPos(42 + wShift, 38)
			end
		end
	end

	if self.Basic then return end
	local restrictedMat = "icon16/error.png"
	local illegalMat = "icon16/exclamation.png"

	if self.IsRestricted then
		self.tip = vgui.Create("DImageButton", self)
		self.tip:SetPos(43, 45)
		self.tip:SetSize(16, 16)
		self.tip:SetImage(restrictedMat)
	elseif self.Item.Illegal then
		self.tip = vgui.Create("DImageButton", self)
		self.tip:SetPos(43, 45)
		self.tip:SetSize(16, 16)
		self.tip:SetImage(illegalMat)
	end
end

function PANEL:OnMousePressed(keycode)
	if self.Disabled then
		return
	end

	if self.ContainerType or self.ContainerInv then
		local itemid

		if self.Type == 1 then
			itemid = self.InvID
		else
			itemid = impulse.Inventory.ClassToNetID(self.Item.UniqueID)
		end

		net.Start("impulseInvContainerDoMove")
		net.WriteUInt(itemid, 16)
		net.WriteUInt(self.Type, 4)
		net.SendToServer()

		return
	end

	if self.Basic then
		local invid = self.InvID
		local count = self.Count

		if keycode == MOUSE_RIGHT and count > 1 then
			local m = DermaMenu(self)
			local opt

			local function moveItems(panel)
				if not IsValid(self) then
					return
				end

				local amount = panel.Moving or 2

				if self.Count < amount then
					return
				end 

				net.Start("impulseInvDoMoveMass")
				net.WriteUInt(impulse.Inventory.ClassToNetID(self.Item.UniqueID), 10)
				net.WriteUInt(amount, 8)
				net.WriteUInt(self.Type, 4)
				net.SendToServer()
			end

			if count >= 2 then
				opt = m:AddOption("Move 2", moveItems)
				opt.Moving = 2
				opt:SetIcon("icon16/arrow_right.png")
			end
			if count >= 5 then
				opt = m:AddOption("Move 5", moveItems)
				opt.Moving = 5
				opt:SetIcon("icon16/arrow_right.png")
			end
			if count >= 10 then
				opt = m:AddOption("Move 10", moveItems)
				opt.Moving = 10
				opt:SetIcon("icon16/arrow_right.png")
			end
			if count >= 15 then
				opt = m:AddOption("Move 15", moveItems)
				opt.Moving = 15
				opt:SetIcon("icon16/arrow_right.png")
			end

			m:Open()

			return
		else
			net.Start("impulseInvDoMove")
			net.WriteUInt(invid, 16)
			net.WriteUInt(self.Type, 4)
			net.SendToServer()

			return
		end
	end

	local popup = DermaMenu(self)
	popup.Inv = self

	if self.Item.OnUse then
		local shouldUse = true

		if self.Item.ShouldTraceUse then
			local trace = {}
			trace.start = LocalPlayer():EyePos()
			trace.endpos = trace.start + LocalPlayer():GetAimVector() * 85
			trace.filter = LocalPlayer()

			local trEnt = util.TraceLine(trace).Entity
			shouldUse = false

			if trEnt and IsValid(trEnt) and self.Item.ShouldTraceUse(self.Item, LocalPlayer(), trEnt) then
				shouldUse = true
			end
		end
		
		if shouldUse then
			popup:AddOption(self.Item.UseName or "Use", function()
				if self.Item.ShouldTraceUse then
					local trace = {}
					trace.start = LocalPlayer():EyePos()
					trace.endpos = trace.start + LocalPlayer():GetAimVector() * 85
					trace.filter = LocalPlayer()

					local trEnt = util.TraceLine(trace).Entity

					if not trEnt or not IsValid(trEnt) or not self.Item.ShouldTraceUse(self.Item, LocalPlayer(), trEnt) then
						return
					end
				end
				if self.Item.UseWorkBarTime then
					local invid = self.InvID
					gui.EnableScreenClicker(false)

					if self.Item.UseWorkBarSound then
						surface.PlaySound(self.Item.UseWorkBarSound)
					end

					impulse.MakeWorkbar(self.Item.UseWorkBarTime, self.Item.UseWorkBarName or "Using...", function()
						net.Start("impulseInvDoUse")
						net.WriteUInt(invid, 16)
						net.SendToServer()
					end, self.Item.UseWorkBarFreeze or false)

					self.InvPanel:Remove()
				else
					net.Start("impulseInvDoUse")
					net.WriteUInt(self.InvID, 16)
					net.SendToServer()
				end
			end)
		end
	end

	if self.Item.OnEquip then
		if not self.Item.CanEquip or self.Item.CanEquip(self.Item, LocalPlayer()) then
			if not self.IsEquipped then
				popup:AddOption(self.Item.EquipName or "Equip", function()
					net.Start("impulseInvDoEquip")
					net.WriteUInt(self.InvID, 16)
					net.WriteBool(true)
					net.SendToServer()
				end)
			else
				popup:AddOption(self.Item.UnEquipName or "Un-Equip", function()
					net.Start("impulseInvDoEquip")
					net.WriteUInt(self.InvID, 16)
					net.WriteBool(false)
					net.SendToServer()
				end)
			end
		end
	end

	if (not self.IsRestricted and not self.Item.DropIfRestricted) then
		popup:AddOption("Drop", function()
			net.Start("impulseInvDoDrop")
			net.WriteUInt(self.InvID, 16)
			net.SendToServer()
		end)
	end

	function popup:Think()
		if not IsValid(self.Inv) then
			return self:Remove()
		end
	end

	popup:Open()
end

local bodyCol = Color(50, 50, 50, 210)
local restrictedCol = Color(255, 223, 0, 255)
local illegalCol = Color(255, 0, 0, 255)
local equippedCol =  Color(0, 220, 0, 140)
local restrictedMat =  Material("icon16/error.png")
local illegalMat = Material("icon16/exclamation.png")
function PANEL:Paint(w, h)
	surface.SetDrawColor(bodyCol)
	surface.DrawRect(0, 0, w, h)

	local item = self.Item
	if item then
		surface.SetTextColor(item.Colour or color_white)
		surface.SetFont("Impulse-Elements19-Shadow")
		surface.SetTextPos(65, 10)
		surface.DrawText(item.Name)

		draw.SimpleText(self.Weight.."kg", "Impulse-Elements16", w - 10, 10, color_white, TEXT_ALIGN_RIGHT)

		if self.Basic then return end

		if self.IsEquipped then -- if equipped
			surface.SetDrawColor(equippedCol)
			surface.DrawRect(0, 0, 5, h)
		end
	end
end

local disabledCol = Color(15, 15, 15, 210)
function PANEL:PaintOver(w, h)
	if self.Disabled then
		surface.SetDrawColor(disabledCol)
		surface.DrawRect(0, 0, w, h)
	end
end


vgui.Register("impulseInventoryItem", PANEL, "DPanel")