AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Money"
ENT.Category = "impulse"
ENT.Spawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "ItemID")
end

if SERVER then
	function ENT:Initialize()
		self:PhysicsInit(SOLID_VPHYSICS)  
		self:SetMoveType(SOLID_VPHYSICS)  
		self:SetSolid(SOLID_VPHYSICS)   
		self:SetUseType(SIMPLE_USE)

    	local physObj = self:GetPhysicsObject()
    	self.nodupe = true

    	if IsValid(physObj) then
			physObj:Wake()
		end

		self.UseDelay = CurTime() + 1
	end

	function ENT:SetItem(itemclass, owner)
		local item = impulse.Inventory.Items[itemclass]
		self:SetItemID(itemclass)
		self:SetModel(item.DropModel or item.Model)
		self:SetSkin(item.Skin or 0)
		self.Item = item

		if item.Material then
			self:SetMaterial(item.Material)
		end

		if item.ItemColour then
			self:SetColor(item.ItemColour)
		end

		if owner and IsValid(owner) then
			self.ItemOwner = owner
		end

		if item.Mass and IsValid(self:GetPhysicsObject()) then
			self:GetPhysicsObject():SetMass(item.Mass)
		end
	end

	function ENT:Use(activator)
		if self.UseDelay > CurTime() then
			return
		end

		if activator:IsPlayer() then
			if self.Item.Illegal and activator:IsCP() then
				activator.ConfiscatingItem = self
				net.Start("impulseConfiscateCheck")
				net.WriteEntity(self)
				net.Send(activator)				
			elseif activator:CanHoldItem(self.Item.UniqueID) then
				if self.BannedUser and self.BannedUser == activator then
					return activator:Notify("You are not allowed to pick up this item.")
				end

				if not activator:Alive() or activator:GetSyncVar(SYNC_ARRESTED, false) then
					return activator:Notify("You are not allowed to pick up items while arrested.")
				end

				local canUse = hook.Run("CanUseInventory", activator)

				if canUse != nil and canUse == false then
					return
				end

				self:Remove()

				if self.ItemClip then
					activator:GiveInventoryItem(self.Item.UniqueID, nil, nil, nil, nil, self.ItemClip) -- kinda messy ik
				else
					activator:GiveInventoryItem(self.Item.UniqueID, nil, self.IsRestrictedItem or false)
				end
				
				--activator:Notify("You have picked up a "..self.Item.Name..".") grammatical problems + not really needed

				hook.Run("PlayerPickupItem", activator, self.Item.UniqueID)
			else
				activator:Notify("This item is too heavy to pick up.")
			end
		end
	end

	function ENT:Think()
		if self.RemoveIn and CurTime() > self.RemoveIn then
			self:Remove()
		end
		self:NextThink(CurTime() + 5)
	end

	function ENT:OnRemove()
		local owner = self.ItemOwner

		if owner and IsValid(owner) and owner.DroppedItems then
			owner.DroppedItemsC = math.Clamp((owner.DroppedItemsC or 0) - 1, 0, impulse.Config.DroppedItemsLimit)
			owner.DroppedItems[self.DropIndex] = nil
		end
	end
else
	function ENT:Think()
		local itemid = self:GetItemID()

		if itemid and itemid != (self.lastItemID or -1) then
			local item = impulse.Inventory.Items[itemid]
			
			if item then
				self.HUDName = item.Name or "Unknown Item"
				self.HUDDesc = item.Desc or ""
				self.lastItemID = itemid
			end
		end
	end
end

	