AddCSLuaFile( "shared.lua" ) 
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props_c17/paper01.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )  
	self:SetMoveType(SOLID_VPHYSICS)  
	self:SetSolid( SOLID_VPHYSICS )   
	self:SetUseType( SIMPLE_USE )
	self:GetPhysicsObject():Wake()

	self.KillTime = CurTime() + 1000
end

function ENT:Use(ply)
	net.Start("impulseReadNote")
	net.WriteString(self.letterText)
	net.Send(ply)
end

function ENT:SetText(text)
	self.letterText = text
end

function ENT:SetPlayerOwner(ply)
	self.playerOwner = ply

	ply.letterCount = (ply.letterCount or 0) + 1
end

function ENT:OnRemove()
	if IsValid(self.playerOwner) and self.playerOwner:IsPlayer() then
		self.playerOwner.letterCount = self.playerOwner.letterCount - 1
	end
end

function ENT:Think()
	if self.KillTime < CurTime() then
		self:Remove()
	end
	self:NextThink(CurTime() + 5)
end