ENT.Base			= "base_gmodentity" 
ENT.Type			= "anim"
ENT.PrintName		= "Bench"
ENT.Author			= "vin"
ENT.Purpose			= ""
ENT.Instructions	= "Press E"
ENT.Category 		= "impulse"

ENT.Spawnable = false
ENT.AdminOnly = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "BenchType")
end