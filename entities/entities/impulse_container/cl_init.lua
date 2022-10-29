include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()
	if not self.LootSet and self:GetLoot() then
		self.HUDName = "Lootable Container"
		self.HUDDesc = "Press E to loot this container."

		self.LootSet = true
	end

	self:SetNextClientThink(CurTime() + 0.25)

	return true
end