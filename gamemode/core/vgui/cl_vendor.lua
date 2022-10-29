local PANEL = {}

function PANEL:Init()
	self:SetSize(780, 700)
	self:Center()
	self:SetTitle("")
	self:MakePopup()
end

function PANEL:SetupVendor()
	local lp = LocalPlayer()

	local trace = {}
	trace.start = lp:EyePos()
	trace.endpos = trace.start + lp:GetAimVector() * 120
	trace.filter = lp

	local tr = util.TraceLine(trace)

	if not tr.Entity or not IsValid(tr.Entity) or tr.Entity:GetClass() != "impulse_vendor" then
		return self:Remove()
	end

	local npc = tr.Entity
	local vendorType = npc:GetVendor()

	if not vendorType then
		return print("[impulse] Vendor has no VendorType set!")
	end

	if not impulse.Vendor.Data[vendorType] then
		return print("[impulse] "..vendorType.." invalid.")
	end

	self.NPC = npc
	self.Vendor = impulse.Vendor.Data[vendorType]

	if self.Vendor.Talk and impulse.GetSetting("misc_vendorgreeting", true) then
		surface.PlaySound(impulse.GetRandomAmbientVO(self.Vendor.Gender))
	end

	local vNameLbl = vgui.Create("DLabel", self)
	vNameLbl:SetText(self.Vendor.Name)
	vNameLbl:SetFont("Impulse-Elements27-Shadow")
	vNameLbl:SetPos(10, 33)
	vNameLbl:SizeToContents()

	if vNameLbl:GetWide() >= 330 then
		vNameLbl:SetFont("Impulse-Elements20A-Shadow")
		vNameLbl:SizeToContents()
	end

	local vDescLbl = vgui.Create("DLabel", self)
	vDescLbl:SetText(self.Vendor.Desc)
	vDescLbl:SetFont("Impulse-Elements14-Shadow")
	vDescLbl:SetPos(10, 58)
	vDescLbl:SetSize(300, 20)

	local yNameLbl = vgui.Create("DLabel", self)
	yNameLbl:SetText("You")
	yNameLbl:SetFont("Impulse-Elements27-Shadow")
	yNameLbl:SetPos(450, 33)
	yNameLbl:SizeToContents()

	local yDescLbl = vgui.Create("DLabel", self)
	yDescLbl:SetText("You have "..LocalPlayer():GetMoney().." "..impulse.Config.CurrencyName)
	yDescLbl:SetFont("Impulse-Elements17-Shadow")
	yDescLbl:SetPos(450, 58)
	yDescLbl:SetSize(300, 20)
	yDescLbl.lastMoney = LocalPlayer():GetMoney()

	function yDescLbl:Think()
		if self.lastMoney != LocalPlayer():GetMoney() then
			self.lastMoney = LocalPlayer():GetMoney()
			self:SetText("You have "..LocalPlayer():GetMoney().." "..impulse.Config.CurrencyName)
		end
	end

	local w, h = self:GetSize()
	local empty = true

	self.vendorScroll = vgui.Create("DScrollPanel", self)
	self.vendorScroll:SetPos(0, 83)
	self.vendorScroll:SetSize(340, h - 83)

	for v,k in pairs(self.Vendor.Sell) do
		if not k.CanBuy or k.CanBuy(LocalPlayer()) then
			local itemid = impulse.Inventory.ClassToNetID(v)

			if not itemid then
				print("[impulse] "..v.." is invalid!")
				continue
			end

			local item = impulse.Inventory.Items[itemid]

			if not item then
				print("[impulse] Failed to resolve ItemID "..itemid.."! (Class "..v..")!")
				continue
			end

			local vendorItem = self.vendorScroll:Add("impulseVendorItem")
			vendorItem:SetItem(item, k)
			vendorItem.Parent = self
			vendorItem:Dock(TOP)
		end

		empty = false
	end

	for v,k in pairs(self.Vendor.Sell) do
		if k.CanBuy and not k.CanBuy(LocalPlayer()) then
			local itemid = impulse.Inventory.ClassToNetID(v)

			if not itemid then
				print("[impulse] "..v.." is invalid!")
				continue
			end

			local item = impulse.Inventory.Items[itemid]

			if not item then
				print("[impulse] Failed to resolve ItemID "..itemid.."! (Class "..v..")!")
				continue
			end

			local vendorItem = self.vendorScroll:Add("impulseVendorItem")
			vendorItem:SetItem(item, k)
			vendorItem.Parent = self
			vendorItem:Dock(TOP)
		end

		empty = false
	end

	if empty then
		local emptyLbl = vgui.Create("DLabel", self.vendorScroll)
		emptyLbl:SetText("Nothing to buy")
		emptyLbl:SetFont("Impulse-Elements18-Shadow")
		emptyLbl:SizeToContents()
		emptyLbl:Dock(TOP)
		emptyLbl:DockMargin(0, 20, 0, 0)
		emptyLbl:SetContentAlignment(5)
	end

	empty = true

	self.youScroll = vgui.Create("DScrollPanel", self)
	self.youScroll:SetPos(440, 83)
	self.youScroll:SetSize(340, h - 83)

	for v,k in pairs(impulse.Inventory.Data[0][1]) do
		if k.restricted then
			continue	
		end

		local item = impulse.Inventory.Items[k.id]
		local class = item.UniqueID

		if self.Vendor.Buy and self.Vendor.Buy[class] then
			local vendorItem = self.youScroll:Add("impulseVendorItem")
			vendorItem.Selling = true
			vendorItem.ItemID = v
			vendorItem:SetItem(item, self.Vendor.Buy[class])
			vendorItem.Parent = self
			vendorItem:Dock(TOP)

			empty = false
		end
	end

	if empty then
		local emptyLbl = vgui.Create("DLabel", self.youScroll)
		emptyLbl:SetText("Nothing to sell")
		emptyLbl:SetFont("Impulse-Elements18-Shadow")
		emptyLbl:SizeToContents()
		emptyLbl:Dock(TOP)
		emptyLbl:DockMargin(0, 20, 0, 0)
		emptyLbl:SetContentAlignment(5)
	end
end

local headerDark = Color(20, 20, 20, 180)
local listDark = Color(0, 0, 0, 28)
function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "Frame", self, w, h)

	surface.SetDrawColor(headerDark)
	surface.DrawRect(0, 25, 340, 58)
	surface.DrawRect(440, 25, 340, 58)

	surface.SetDrawColor(listDark)
	surface.DrawRect(0, 83, 340, h)
	surface.DrawRect(440, 83, 340, h)
end

vgui.Register("impulseVendorMenu", PANEL, "DFrame")