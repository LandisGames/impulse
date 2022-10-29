function PLUGIN:PlayerSpawnedNPC(ply, npc)
	npc:SetSpawnEffect(false)
	npc:SetKeyValue("spawnflags", npc:GetSpawnFlags() + SF_NPC_NO_WEAPON_DROP)

	if ply:GetMoveType() == MOVETYPE_NOCLIP and ply:IsAdmin() then
 		for v,k in pairs(player.GetAll()) do
 			if k.IsAdmin(k) and k.GetMoveType(k) == MOVETYPE_NOCLIP then
 				npc:AddEntityRelationship(k, D_NU, 99)
 			end
 		end
	end
end