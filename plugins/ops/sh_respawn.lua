local respawnCommand = {
    description = "Respawns the player specified.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local name = arg[1]
		local plyTarget = impulse.FindPlayer(name)

		if plyTarget then
			plyTarget:Spawn()
			plyTarget:Notify("You have been respawned by a game moderator.")
			ply:Notify(plyTarget:Name().." has been respawned.")
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
    end
}

impulse.RegisterChatCommand("/respawn", respawnCommand)