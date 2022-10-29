local PANEL = {}

local grey = Color(209, 209, 209)

function PANEL:Init()
	self:SetSize(700, 470)
	self:Center()
	self:SetTitle("Storage")
 	self:MakePopup()

 	self:SetupItems()
 end

 function PANEL:PaintOver(w, h)
 	draw.SimpleText("You", "Impulse-Elements23-Shadow", 5, 30, grey)
 	if self.invWeight then
 		draw.SimpleText(self.invWeight.."kg/"..impulse.Config.InventoryMaxWeight.."kg", "Impulse-Elements18-Shadow", 345, 35, grey, TEXT_ALIGN_RIGHT)
 	end

 	draw.SimpleText("Storage", "Impulse-Elements23-Shadow", w - 5, 30, grey, TEXT_ALIGN_RIGHT)
  	if self.storageWeight then
 		draw.SimpleText(self.storageWeight.."kg/"..LocalPlayer():GetMaxInventoryStorage().."kg", "Impulse-Elements18-Shadow", 355, 35, grey, TEXT_ALIGN_LEFT)
 	end
 end

 function PANEL:SetupItems(invscroll, storescroll)
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
  	local realInvStorage = impulse.Inventory.Data[0][2]
 	local localInvStorage = table.Copy(impulse.Inventory.Data[0][2]) or {}
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

 	for v,k in pairs(localInvStorage) do
 		k.realKey = v

 		if sortMethod == "Always" or sortMethod == "Containers only" then
 			reccurTemp[k.id] = (reccurTemp[k.id] or 0) + (impulse.Inventory.Items[k.id].Weight or 0)
 			k.sortWeight = reccurTemp[k.id]
 		else
 			k.sortWeight = impulse.Inventory.Items[k.id].Name
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
	 			item.Type = 1
	 			item:SetItem(k, w)
	 			item.InvID = k.realKey
	 			item.InvPanel = self
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

	if localInvStorage and table.Count(localInvStorage) > 0 then
	  	for v,k in SortedPairsByMemberValue(localInvStorage, "sortWeight", invertSort) do
	 		local otherItem = self.itemsStorage[k.id]
	 		local itemX = impulse.Inventory.Items[k.id]

	 		if itemX.CanStack and otherItem then
	 			otherItem.Count = (otherItem.Count or 1) + 1
	 		else
	 			local item = self.invStorageScroll:Add("impulseInventoryItem")
	 			item:Dock(TOP)
	 			item:DockMargin(0, 0, 0, 5)
	 			item.Basic = true
	 			item.Type = 2
	 			item:SetItem(k, w)
	 			item.InvID = k.realKey
	 			item.InvPanel = self
	 			self.itemsStorage[k.id] = item
	 		end

	 		storageWeight =  storageWeight + (itemX.Weight or 0)
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

vgui.Register("impulseInventoryStorage", PANEL, "DFrame")
