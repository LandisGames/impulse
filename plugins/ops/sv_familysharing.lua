function PLUGIN:PlayerAuthed(ply, sid)
	if not impulse.YML.apis.steam_key then
		return print("[ops] No apis.steam_key defined in config.yml! Can't check for familysharing!")
	end
	
	local s64id = util.SteamIDTo64(sid)
	
	http.Fetch(
	string.format("http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=%s&format=json&steamid=%s&appid_playing=4000",
		impulse.YML.apis.steam_key,
		s64id
	),

	function(body)
		local body = util.JSONToTable(body)

		if not body or not body.response or not body.response.lender_steamid then
			error(string.format("ops FamilySharing: Invalid Steam API response for %s | %s\n", ply:Nick(), ply:SteamID()))
			ply:Kick("Sorry, we do not allow private Steam accounts to connect. For more information goto support.impulse-community.com")
			return
		end

		local lender = body.response.lender_steamid
		if lender != "0" then -- if does not own gmod
			ply:Kick("Sorry, we do not allow Steam accounts that don't own the game fully. For more information goto support.impulse-community.com")
			return
		end
	end,

	function(code)
		ply:Kick("Sorry, we do not allow private Steam accounts to connect. For more information goto support.impulse-community.com")
	end
	)
end
