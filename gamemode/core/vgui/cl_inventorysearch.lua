local PANEL = {}

function PANEL:Init()
	self:SetSize(350, 500)
	self:Center()
	self:SetTitle("")
	self:ShowCloseButton(false)
	self:MakePopup()

	self.darkOverlay = Color(40, 40, 40, 160)

	self.scroll = vgui.Create("DScrollPanel", self)
	self.scroll:SetPos(0, 25)
	self.scroll:SetSize(350, 440)

	self.taking = {}
end

local bodyCol = Color(50, 50, 50, 210)
local red = Color(255, 0, 0)
function PANEL:SetInv(invdata)
	local panel = self

	for v,k in pairs(invdata) do
		local bg = self.scroll:Add("DPanel")
		bg:SetTall(38)
		bg:DockMargin(5, 3, 5, 3)
		bg:Dock(TOP)
		bg.ItemName = k.Name
		bg.ItemIllegal = k.Illegal or false
		bg.ItemClass = k.UniqueID

		function bg:Paint(w, h)
			surface.SetDrawColor(bodyCol)
			surface.DrawRect(0, 0, w, h)

			draw.SimpleText(self.ItemName, "Impulse-Elements18-Shadow", 10, 5, color_white)

			if self.ItemIllegal then
				draw.SimpleText("Contraband", "Impulse-Elements16-Shadow", 10, 22, red)	
			end

			return true
		end

		if bg.ItemIllegal then
			local takeBtn = vgui.Create("DCheckBox", bg)
			takeBtn:SetPos(300, 10)
			takeBtn:SetValue(0)
			takeBtn.ItemClass = k.UniqueID

			function takeBtn:OnChange(val)
				if val then
					table.insert(panel.taking, self.ItemClass)
				else
					table.RemoveByValue(panel.taking, self.ItemClass)
				end
			end
			
			local takeLbl = vgui.Create("DLabel", bg)
			takeLbl:SetPos(245, 10)
			takeLbl:SetText("Confiscate")
			takeLbl:SizeToContents()
		end
	end

	self.finish = vgui.Create("DButton", self)
	self.finish:SetPos(0, 470)
	self.finish:SetSize(350, 30)
	self.finish:SetText("Finish search")

	function self.finish:DoClick()
		net.Start("impulseInvDoSearchConfiscate")
		net.WriteUInt(#panel.taking, 8)
		for v,k in pairs(panel.taking) do
			local netid = impulse.Inventory.ClassToNetID(k)
			net.WriteUInt(netid, 10)
		end
		net.SendToServer()

		panel:Remove()
	end

	function self.finish:Think()
		local count = table.Count(panel.taking)

		if count > 0 then
			self:SetText("Finish search (confiscating "..count.." items)")
		else
			self:SetText("Finish search")
		end
	end
end

function PANEL:SetPlayer(ent)
	self:SetTitle(ent:Nick().."'s Inventory")
	self.rangeEnt = ent
end

function PANEL:Think()
	if self.rangeEnt and IsValid(self.rangeEnt) then
		local dist = self.rangeEnt:GetPos():DistToSqr(LocalPlayer():GetPos())

		if dist > (200 ^ 2) then
			LocalPlayer():Notify("The target moved too far away.")

			net.Start("impulseInvDoSearchConfiscate")
			net.WriteUInt(0, 8)
			net.SendToServer()

			self:Remove()
		end
	end
end


vgui.Register("impulseSearchMenu", PANEL, "DFrame")