local PANEL = {}

function PANEL:Init()
	self:SetSize(350, 500)
	self:Center()
	self:MakePopup()

	self.darkOverlay = Color(40, 40, 40, 160)

	self.scroll = vgui.Create("DScrollPanel", self)
	self.scroll:SetPos(0, 25)
	self.scroll:SetSize(350, 440)

	self.taking = {}
end

local bodyCol = Color(50, 50, 50, 210)
local red = Color(255, 0, 0)
local green = Color(0, 255, 0)
local restrictedCol = Color(255, 223, 0, 255)
function PANEL:SetInv(invdata)
	local panel = self

	for v,k in pairs(invdata) do
		local r = k[2]
		local e = k[3]
		local itemid = k[4]
		k = k[1]
		local bg = self.scroll:Add("DPanel")
		bg:SetTall(38)
		bg:DockMargin(5, 3, 5, 3)
		bg:Dock(TOP)
		bg.ItemName = k.Name
		bg.ItemIllegal = k.Illegal or false
		bg.ItemClass = k.UniqueID
		bg.ItemRestrict = r
		bg.ItemEquipped = e
		bg.ItemID = itemid

		function bg:Paint(w, h)
			surface.SetDrawColor(bodyCol)
			surface.DrawRect(0, 0, w, h)

			draw.SimpleText(self.ItemName, "Impulse-Elements18-Shadow", 10, 5, color_white)
			draw.SimpleText(self.ItemClass.."  #"..self.ItemID, "Impulse-Elements16-Shadow", 10, 20, color_white)

			if self.ItemEquipped then
				draw.SimpleText("equipped", "Impulse-Elements16-Shadow", 180, 7, green)
			end

			if self.ItemRestrict then
				draw.SimpleText("restricted", "Impulse-Elements16-Shadow", 180, 22, restrictedCol)
			elseif self.ItemIllegal then
				draw.SimpleText("illegal", "Impulse-Elements16-Shadow", 180, 22, red)	
			end

			return true
		end


		local takeBtn = vgui.Create("DCheckBox", bg)
		takeBtn:SetPos(300, 10)
		takeBtn:SetValue(0)
		takeBtn.ItemClass = k.UniqueID

		function takeBtn:OnChange(val)
			if val then
				table.insert(panel.taking, bg.ItemID)
			else
				table.RemoveByValue(panel.taking, bg.ItemID)
			end
		end
			
		local takeLbl = vgui.Create("DLabel", bg)
		takeLbl:SetPos(258, 10)
		takeLbl:SetText("Remove")
		takeLbl:SizeToContents()
	end

	self.finish = vgui.Create("DButton", self)
	self.finish:SetPos(0, 470)
	self.finish:SetSize(350, 30)
	self.finish:SetText("Close")

	function self.finish:Think()
		local count = table.Count(panel.taking)

		if count > 0 then
			self:SetText("Close (removing "..count.." items)")
		else
			self:SetText("Close")
		end
	end

	function self.finish:DoClick()
		panel:Remove()

		if not IsValid(panel.ply) then
			LocalPlayer():Notify("Player left the server.")
		end

		local count = table.Count(panel.taking)

		if count > 0 then
			net.Start("impulseOpsRemoveInv")
			net.WriteUInt(panel.ply:EntIndex(), 8)
			net.WriteUInt(count, 16)
			for v,k in pairs(panel.taking) do
				net.WriteUInt(k, 16)
			end
			net.SendToServer()
		end
	end
end

function PANEL:SetPlayer(ent)
	self:SetTitle(ent:Nick().."'s Inventory")
	self.ply = ent
end

vgui.Register("impulseSearchMenuAdmin", PANEL, "DFrame")