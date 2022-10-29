if SERVER then
    util.AddNetworkString("opsGiveCombineBan")
end

local combineBanCommand = {
    description = "Gives the player a combine ban for the time specified (max of 1 week).",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local name = arg[1]
        local time = arg[2]
		local plyTarget = impulse.FindPlayer(name)

		if not time or not tonumber(time) then
			return ply:Notify("Please specific a valid time value in minutes.")
		end

		time = tonumber(time)
		time = time * 60
		time = math.Clamp(time, 0, 604800)

		if plyTarget and plyTarget.impulseData then
			local curT = os.time()
			local endT = curT + time

			plyTarget.impulseData.CombineBan = endT
			plyTarget:SaveData()

			if plyTarget:IsCP() then
				plyTarget:SetTeam(impulse.Config.DefaultTeam)
			end

			local howLong = string.NiceTime(time)

			ply:Notify("You have combine banned "..plyTarget:Nick().." for "..howLong..".")
			plyTarget:Notify("You have been banned from the combine faction for "..howLong.." by a game moderator ("..ply:SteamName()..").")

			net.Start("opsGiveCombineBan")
			net.WriteUInt(time, 16)
			net.Send(plyTarget)
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
    end
}

impulse.RegisterChatCommand("/combineban", combineBanCommand)

local combineUnBanCommand = {
    description = "Removes a combine ban from a player.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local name = arg[1]
		local plyTarget = impulse.FindPlayer(name)

		if plyTarget and plyTarget.impulseData then
			plyTarget.impulseData.CombineBan = nil
			plyTarget:SaveData()

			ply:Notify("You have removed "..plyTarget:Nick().."'s combine ban.")
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
    end
}

impulse.RegisterChatCommand("/uncombineban", combineUnBanCommand)