include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()
	if self.IsSetup then return end
	local class = self:GetBenchType()

	if class then
		local bench = impulse.Inventory.Benches[class]

		if bench then
			self.HUDName = bench.Name
			self.HUDDesc = bench.Desc
			self.IsSetup = true
		end
	end
end