concommand.Add("impulse_setgroup", function(ply, cmd, args)
	if ply != NULL or IsValid(ply) then
		return
	end
	
	local steamid = args[1]
	local group = args[2]

	if not steamid or not group then
		return print("[impulse] SteamID or group name not provided.")
	end

	local targ = player.GetBySteamID(steamid)

	if IsValid(targ) then
		targ:SetUserGroup(group)
	end

	local query = mysql:Update("impulse_players")
	query:Update("group", group)
	query:Where("steamid", steamid)
	query:Execute()

	print("[impulse] Set '"..steamid.."'' to group '"..group.."'.")
end)