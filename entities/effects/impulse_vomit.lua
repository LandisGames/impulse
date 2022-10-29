function EFFECT:Init(data)
	self.Player = data:GetEntity()

	if not IsValid(self.Player) then return end

	self.Length = CurTime() + 0.6
	self.Emitter = ParticleEmitter(self.Player:GetPos())

	sound.Play("npc/zombie/zombie_pain1.wav", self.Player:GetShootPos(), 100, 100)
end



local function CollideCallback(particle, pos, normal)
	util.Decal("beersplash", pos + normal, pos - normal)

	particle:SetStartSize(32)
	particle:SetEndSize(16)
end 


function EFFECT:Think()
	if not IsValid(self.Player) then
		return false
	end

	local pos = self.Player:GetShootPos();

	if self.Player == LocalPlayer() then
		pos = pos + Vector( 0, 0, -10 ) + self.Player:GetAimVector() * 5
	end

	local particle = self.Emitter:Add("effects/blood_core", pos)
	particle:SetVelocity(self.Player:GetAimVector() + ((VectorRand() * 0.2) * math.random(130, 360)))
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(128)
	particle:SetDieTime(2)
	particle:SetStartSize(math.Rand( 12, 16 ))
	particle:SetEndSize(math.Rand( 8, 12 ))
	particle:SetRoll(0)
	particle:SetRollDelta(0)
	particle:SetColor(100, 60, 0)
	particle:SetCollide(true)
	particle:SetBounce(0.3)
	particle:SetGravity(Vector(0, 0, -500))
	particle:SetCollideCallback(CollideCallback)

	if self.Length <= CurTime() then 
		self.Emitter:Finish() 
	end

	return self.Length > CurTime()
end

function EFFECT:Render()
end