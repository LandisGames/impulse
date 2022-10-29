AddCSLuaFile("shared.lua") 
include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)  
	self:SetMoveType(SOLID_VPHYSICS)  
	self:SetSolid(SOLID_VPHYSICS)   
	self:SetUseType(SIMPLE_USE)
	self:GetPhysicsObject():Wake()
end

function ENT:Use(ply)
	if self.isDrink then
		ply:EmitSound("impulse/drink.wav")
	else
		ply:EmitSound("impulse/eat.wav")
	end
	
	ply:FeedHunger(self.food)
	self:Remove()
end