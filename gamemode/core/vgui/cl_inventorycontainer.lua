local PANEL = {}

local grey = Color(209, 209, 209)

function PANEL:Init()
	self:SetSize(700, 470)
	self:Center()
 	self:MakePopup()

 	--self:SetupItems()
 end

 function PANEL:SetupContainer()
	local lp = LocalPlayer()

	local trace = {}
	trace.start = lp:EyePos()
	trace.endpos = trace.start + lp:GetAimVector() * 120
	trace.filter = lp

	local tr = util.TraceLine(trace)

	if not tr.Entity or not IsValid(tr.Entity) or tr.Entity:GetClass() != "impulse_container" then
		return self:Remove()
	end

	self.container = tr.Entity
	self.isLoot = self.container:GetLoot()

	if self.container:GetLoot() then
		self:SetTitle("Loot Container")
	else
		self:SetTitle("Storage Container")
	end
end

function PANEL:OnRemove()
	net.Start("impulseInvContainerClose")
	net.SendToServer()
end

 function PANEL:PaintOver(w, h)
 	draw.SimpleText("You", "Impulse-Elements23-Shadow", 5, 30, grey)
 	if self.invWeight then
 		draw.SimpleText(self.invWeight.."kg/"..impulse.Config.InventoryMaxWeight.."kg", "Impulse-Elements18-Shadow", 345, 35, grey, TEXT_ALIGN_RIGHT)
 	end

 	draw.SimpleText("Container", "Impulse-Elements23-Shadow", w - 5, 30, grey, TEXT_ALIGN_RIGHT)
  	if self.storageWeight and self.container then
 		draw.SimpleText(self.storageWeight.."kg/"..self.container:GetCapacity().."kg", "Impulse-Elements18-Shadow", 355, 35, grey, TEXT_ALIGN_LEFT)
 	end
 end

 function PANEL:Think()
 	if self.container then
 		if not IsValid(self.container) or self.container:GetPos():DistToSqr(LocalPlayer():GetPos()) > (120 ^ 2) then
			return self:Remove()
		end
	
		if not LocalPlayer():Alive()  then
			return self:Remove()
		end

		if LocalPlayer():GetSyncVar(SYNC_ARRESTED, false) then
			return self:Remove()
		end
 	end
 end

 function PANEL:SetupItems(containerInv, invscroll, storescroll)
 	local w,h = self:GetSize()

 	if self.invScroll and IsValid(self.invScroll) then
 		self.invScroll:Remove()
 	end

  	if self.invStorageScroll and IsValid(self.invStorageScroll) then
 		self.invStorageScroll:Remove()
 	end

 	self.invScroll = vgui.Create("DScrollPanel", self)
 	self.invScroll:SetPos(0, 55)
 	self.invScroll:SetSize(346, h - 55)

 	self.invStorageScroll = vgui.Create("DScrollPanel", self)
 	self.invStorageScroll:SetPos(354, 55)
 	self.invStorageScroll:SetSize(346, h - 55)

 	self.items = {}
 	self.itemPanels = {}
  	self.itemsStorage = {}
 	self.itemPanelsStorage = {}
 	local invWeight = 0
 	local realInv = impulse.Inventory.Data[0][1]
 	local localInv = table.Copy(impulse.Inventory.Data[0][1]) or {}
	local storageWeight = 0
 	local reccurTemp = {}
   	local sortMethod = impulse.GetSetting("inv_sortweight", "Inventory only")
 	local invertSort = true

 	for v,k in pairs(localInv) do -- fix for fucking table.sort desyncing client/server itemids!!!!!!!
 		k.realKey = v

 		if sortMethod == "Always" or sortMethod == "Containers only" then
 			reccurTemp[k.id] = (reccurTemp[k.id] or 0) + (impulse.Inventory.Items[k.id].Weight or 0)
 			k.sortWeight = reccurTemp[k.id]
 		else
 			k.sortWeight = impulse.Inventory.Items[k.id].Name
 			invertSort = false
 		end
 	end

 	local reccurTemp = {}

 	for v,k in pairs(containerInv) do
 		k.realKey = v

 	 	if sortMethod == "Always" or sortMethod == "Containers only" then
 			k.sortWeight = (impulse.Inventory.Items[v].Weight or 0) * k.amount
 		else
 			k.sortWeight = impulse.Inventory.Items[v].Name
 			invertSort = false
 		end
 	end

 	if localInv and table.Count(localInv) > 0 then
	 	for v,k in SortedPairsByMemberValue(localInv, "sortWeight", invertSort) do
	 		local otherItem = self.items[k.id]
	 		local itemX = impulse.Inventory.Items[k.id]

	 		if itemX.CanStack and otherItem then
	 			otherItem.Count = (otherItem.Count or 1) + 1
	 		else
	 			local item = self.invScroll:Add("impulseInventoryItem")
	 			item:Dock(TOP)
	 			item:DockMargin(0, 0, 0, 5)
	 			item.Basic = true
	 			item.ContainerInv = true
	 			item.Type = 1
	 			item:SetItem(k, w)
	 			item.InvID = k.realKey
	 			item.InvPanel = self
	 			item.Disabled = self.isLoot

	 			self.items[k.id] = item
	 		end

	 		invWeight =  invWeight + (itemX.Weight or 0)
	 	end
	 else
		self.empty = self.invScroll:Add("DLabel", self)
		self.empty:SetContentAlignment(5)
		self.empty:Dock(TOP)
		self.empty:SetText("Empty")
		self.empty:SetFont("Impulse-Elements19-Shadow")
	end

	if table.Count(containerInv) > 0 then
	  	for v,k in SortedPairsByMemberValue(containerInv, "sortWeight", invertSort) do
	 		local itemX = impulse.Inventory.Items[k.realKey]

	 		local item = self.invStorageScroll:Add("impulseInventoryItem")
	 		item:Dock(TOP)
	 		item:DockMargin(0, 0, 0, 5)
	 		item.Basic = true
	 		item.ContainerType = true
	 		item.Type = 2
	 		item:SetItem(k.realKey, w)
	 		item.InvClass = k.realKey
	 		item.InvPanel = self
	 		item.Count = k.amount
	 		self.itemsStorage[k.realKey] = item

	 		storageWeight = storageWeight + ((itemX.Weight or 0) * k.amount)
	 	end
	 else
		self.empty = self.invStorageScroll:Add("DLabel", self)
		self.empty:SetContentAlignment(5)
		self.empty:Dock(TOP)
		self.empty:SetText("Empty")
		self.empty:SetFont("Impulse-Elements19-Shadow")
	end

	self.invWeight = invWeight
	self.storageWeight = storageWeight

	if invscroll then
		self.invScroll:GetVBar():AnimateTo(invscroll, 0)
		self.invStorageScroll:GetVBar():AnimateTo(storescroll, 0)
	end
 end

vgui.Register("impulseInventoryContainer", PANEL, "DFrame")
