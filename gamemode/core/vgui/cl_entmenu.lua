local PANEL = {}

function PANEL:Init()
	self:SetSize(200, 600)
	self:Center()
	self:SetTitle("Entity Interaction")
	self:MakePopup()

	self.addY = 0
end

function PANEL:AddAction(icon, name, onClick)
	self.btn = vgui.Create("DImageButton", self)
	self.btn:SetSize(90, 90)
	self.btn:SetPos(55, 40 + self.addY)
	self.btn:SetImage(icon)

	function self.btn:Paint()
		if self:IsHovered() then
			self:SetColor(impulse.Config.MainColour)
		else
			self:SetColor(color_white)
		end
	end

	self.btn.DoClick = onClick

	self.iconLbl = vgui.Create("DLabel", self)
	self.iconLbl:SetText(name)
	self.iconLbl:SetFont("Impulse-Elements18")
	self.iconLbl:SizeToContents()
	self.iconLbl:SetPos(100-(self.iconLbl:GetWide()/2), self.addY+140)

	self.addY = self.addY + 125

	self.hasAction = true
end

function PANEL:SetRangeEnt(ent)
	self.rangeEnt = ent
end

function PANEL:SetDoor(door)
	local panel = self
	local doorOwners = door:GetSyncVar(SYNC_DOOR_OWNERS, nil) 
	local doorGroup = door:GetSyncVar(SYNC_DOOR_GROUP, nil)
	local doorBuyable = door:GetSyncVar(SYNC_DOOR_BUYABLE, true)
	local isDoorMaster = false
	if doorOwners and doorOwners[1] == LocalPlayer():EntIndex() then
		isDoorMaster = true
	end

	local customCanEditDoor = hook.Run("CanEditDoor", LocalPlayer(), door)

	if door:IsDoor() then
		if LocalPlayer():CanLockUnlockDoor(doorOwners, doorGroup) then
			self:AddAction("impulse/icons/padlock-2-256.png", "Unlock", function()
				net.Start("impulseDoorUnlock")
				net.SendToServer()

				panel:Remove()
			end)
			self:AddAction("impulse/icons/padlock-256.png", "Lock", function()
				net.Start("impulseDoorLock")
				net.SendToServer()

				panel:Remove()
			end)
		end

		if LocalPlayer():CanBuyDoor(doorOwners, doorBuyable) and (customCanEditDoor or customCanEditDoor == nil) then
			self:AddAction("impulse/icons/banknotes-256.png", "Buy", function()
				net.Start("impulseDoorBuy")
				net.SendToServer()

				panel:Remove()
			end)
		end

		if LocalPlayer():IsDoorOwner(doorOwners) and isDoorMaster and (customCanEditDoor or customCanEditDoor == nil) then
			self:AddAction("impulse/icons/group-256.png", "Permissions", function()
				doorOwners = door:GetSyncVar(SYNC_DOOR_OWNERS, nil) 

				local perm = DermaMenu()

				local addMenu, x = perm:AddSubMenu("Add")
				x:SetIcon("icon16/add.png")
				local removeMenu, x = perm:AddSubMenu("Remove")
				x:SetIcon("icon16/delete.png")

				local exclude = {}

				for v,k in pairs(doorOwners) do
					k = Entity(k)

					exclude[k] = true

					if not IsValid(k) or not k:IsPlayer() or k == LocalPlayer() then
						continue
					end

					local name = k:Nick()

					if k:GetFriendStatus() == "friend" then
						name = "(FRIEND) "..name
					end

					local x = removeMenu:AddOption(name, function()
						if IsValid(k) then
							net.Start("impulseDoorRemove")
							net.WriteEntity(k)
							net.SendToServer()
						else
							LocalPlayer():Notify("Player has disconnected.")
						end
					end)
					x:SetIcon("icon16/user_delete.png")
				end

				for v,k in pairs(player.GetAll()) do
					if exclude[k] or k == LocalPlayer() then 
						continue 
					end

					local name = k:Nick()

					if k:GetFriendStatus() == "friend" then
						name = "(FRIEND) "..name
					end

					local x = addMenu:AddOption(name, function()
						if IsValid(k) then
							net.Start("impulseDoorAdd")
							net.WriteEntity(k)
							net.SendToServer()
						else
							LocalPlayer():Notify("Player has disconnected.")
						end
					end)
					x:SetIcon("icon16/user_add.png")
				end

				perm:Open()
			end)
			self:AddAction("impulse/icons/banknotes-256.png", "Sell", function()
				net.Start("impulseDoorSell")
				net.SendToServer()

				panel:Remove()
			end)
		end
	end

	hook.Run("DoorMenuAddOptions", self, door, doorOwners, doorGroup, doorBuyable)

	if not self.hasAction then return self:Remove() end
end

function PANEL:SetPlayer(ply)
	if LocalPlayer():IsCP() and LocalPlayer():CanArrest(ply) and ply:GetSyncVar(SYNC_ARRESTED, false) then
		self:AddAction("impulse/icons/search-3-256.png", "Search Inventory", function()
			LocalPlayer():ConCommand("say /invsearch")

			self:Remove()
		end)

		self:AddAction("impulse/icons/padlock-2-256.png", "Unrestrain", function()
			net.Start("impulseUnRestrain")
			net.SendToServer()

			self:Remove()
		end)
	end

	hook.Add("PlayerMenuAddOptions", self, ply)

	if not self.hasAction then return self:Remove() end
end

function PANEL:SetContainer(ent)
	if ent:GetClass() == "impulse_container" and not ent:GetLoot() then
		if LocalPlayer():IsCP() then
			self:AddAction("impulse/icons/padlock-2-256.png", "Remove Padlock", function()
				impulse.MakeWorkbar(15, "Breaking padlock...", function()
					if not IsValid(ent) then return end

					net.Start("impulseInvContainerRemovePadlock")
					net.SendToServer()
				end, true)

				self:Remove()
			end)
		end
	end

	if not self.hasAction then return self:Remove() end
end

function PANEL:SetBody(ragdoll)
	hook.Run("RagdollMenuAddOptions", self, ragdoll)

	if not self.hasAction then return self:Remove() end
end

function PANEL:Think()
	if self.rangeEnt and IsValid(self.rangeEnt) then
		local dist = self.rangeEnt:GetPos():DistToSqr(LocalPlayer():GetPos())

		if dist > (200 ^ 2) then
			LocalPlayer():Notify("The target moved too far away.")
			self:Remove()
		end
	end
end


vgui.Register("impulseEntityMenu", PANEL, "DFrame")