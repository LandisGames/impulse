AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel(impulse.Config.InventoryStorageModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(false)

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(false)
	end
end

function ENT:OnTakeDamage(dmg) 
	return false
end

function ENT:CanPlayerUse(ply)
	if not self.impulseSaveKeyValue or not self.impulseSaveKeyValue["MasterDoor"] then
		return true
	end

	local door = ents.GetMapCreatedEntity(self.impulseSaveKeyValue["MasterDoor"])

	if not door:IsValid() or not door:IsDoor() then
		return true
	end

	if ply.OwnedDoors and ply.OwnedDoors[door] then
		return true
	else
		return false
	end
end

function ENT:Use(activator, caller)
	if activator:IsPlayer() and activator:Alive() then
		if activator:GetSyncVar(SYNC_ARRESTED, false) then 
			return activator:Notify("You cannot access your storage when detained.") 
		end

		if activator:IsCP() then
			return activator:Notify("You cannot access your storage as this team.")
		end

		if not self:CanPlayerUse(activator) then
			return activator:Notify("You do not have access to this storage chest.")
		end

		net.Start("impulseInvStorageOpen")
		net.Send(activator)

		hook.Run("PlayerOpenStorage", activator, self)

		activator.currentStorage = self
	end
end

