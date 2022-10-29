ENT.Base			= "base_gmodentity" 
ENT.Type			= "anim"
ENT.PrintName		= "Container"
ENT.Author			= "vin"
ENT.Purpose			= ""
ENT.Instructions	= "Press E"
ENT.Category 		= "impulse"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.HUDName = "Storage Container"
ENT.HUDDesc = "Allows a small amount of items to be stored in a physical container."

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Loot")
	self:NetworkVar("Int", 0, "Capacity")
end