function PLUGIN:PlayerShouldGetHungry(ply)
	if ply:IsAdmin() and ply:GetMoveType() == MOVETYPE_NOCLIP then
		return false
	end
end