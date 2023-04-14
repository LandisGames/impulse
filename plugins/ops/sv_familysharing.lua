function PLUGIN:PlayerAuthed(ply, sid)
	if impulse.YML.apis.steam_key then
		print("[ops] IsPlayingSharedGame is deprecated. apis.steam_key is not needed.")
	end
	
	local s64id = util.SteamIDTo64(sid)
	local o64id = ply:OwnerSteamID64()
	
	if o64id == s64id then return end
	
	ply:Kick("Sorry, we do not allow Steam accounts that don't own the game fully. For more information goto support.impulse-community.com")
end
