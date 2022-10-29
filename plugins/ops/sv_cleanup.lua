impulse.Ops = impulse.Ops or {}

function impulse.Ops.CleanupPlayer(ply)
	for v,k in ipairs(ents.GetAll()) do
		local owner = k:CPPIGetOwner()

		if owner == ply then
			if not k.IsBuyable then
				k:Remove()
			end
		end
	end
end

function impulse.Ops.CleanupAll()
	for v,k in ipairs(ents.GetAll()) do
		local owner = k:CPPIGetOwner()

		if owner and not k.IsBuyable then
			k:Remove()
		end
	end
end

function impulse.Ops.ClearDecals()
	for v,k in pairs(player.GetAll()) do
		k:ConCommand("r_cleardecals")
	end
end