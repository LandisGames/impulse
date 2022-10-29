local unArrestCommand = {
    description = "Un arrests the player specified.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local name = arg[1]
		local plyTarget = impulse.FindPlayer(name)

		if plyTarget then
			plyTarget:UnArrest()
			plyTarget:Notify("You have been un-arrested by a game moderator.")
			ply:Notify(plyTarget:Name().." has been un-arrested.")

			if plyTarget.InJail then
				impulse.Arrest.Prison[plyTarget.InJail][plyTarget:EntIndex()] = nil
				plyTarget.InJail = nil
				timer.Remove(plyTarget:UserID().."impulsePrison")
				plyTarget:StopDrag()
				plyTarget:Spawn()
			end
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
    end
}

impulse.RegisterChatCommand("/unarrest", unArrestCommand)

local setTeamCommand = {
    description = "Sets the team of the player specified. Teams are refrenced with their team ID number.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local name = arg[1]
        local teamID = arg[2]
		local plyTarget = impulse.FindPlayer(name)

		if not tonumber(teamID) then
			return ply:Notify("Team ID should be a number.")
		end

		teamID = tonumber(teamID)

		if plyTarget then
			if teamID and impulse.Teams.Data[teamID] then
				local teamName = team.GetName(teamID)
				plyTarget:SetTeam(teamID)
				plyTarget:Notify("Your team has been set to "..teamName.." by a game moderator.")
				ply:Notify(plyTarget:Name().." has been set to "..teamName..".")
			else
				ply:Notify("Invalid team ID. They are in F4 menu order!")
			end
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
    end
}

impulse.RegisterChatCommand("/setteam", setTeamCommand)

local forceUnlockCommand = {
    description = "Unlocks the door you are looking at.",
    adminOnly = true,
    onRun = function(ply, arg, rawText)
		local door = ply:GetEyeTrace().Entity

		if not door or not IsValid(door) or not door:IsDoor() then
			return ply:Notify("You are not looking at a door.")
		end

		door:DoorUnlock()
		ply:Notify("Door unlocked.")
    end
}

impulse.RegisterChatCommand("/forceunlock", forceUnlockCommand)

local forceLockCommand = {
    description = "Locks the door you are looking at.",
    adminOnly = true,
    onRun = function(ply, arg, rawText)
		local door = ply:GetEyeTrace().Entity

		if not door or not IsValid(door) or not door:IsDoor() then
			return ply:Notify("You are not looking at a door.")
		end

		door:DoorLock()
		ply:Notify("Door locked.")
    end
}

impulse.RegisterChatCommand("/forcelock", forceLockCommand)

local removeDoorCommand = {
    description = "Removed a bugged door spawned with the door tool.",
    adminOnly = true,
    onRun = function(ply, arg, rawText)
		local door = ply:GetEyeTrace().Entity

		if not door or not IsValid(door) or (not door:IsDoor() and not door:IsPropDoor()) then
			return ply:Notify("You are not looking at a door.")
		end

		if door:MapCreationID() != -1 then
			return ply:Notify("This is a map door, you can not remove it.")
		end

		door:Remove()
		ply:Notify("Door removed.")
    end
}

impulse.RegisterChatCommand("/removebuggeddoor", removeDoorCommand)

local sellDoorCommand = {
    description = "Sells the door you are looking at.",
    adminOnly = true,
    onRun = function(ply, arg, rawText)
		local door = ply:GetEyeTrace().Entity

		if not door or not IsValid(door) or not door:IsDoor() then
			return ply:Notify("You are not looking at a door.")
		end

		local owners = door:GetSyncVar(SYNC_DOOR_OWNERS, nil)

		if not owners then
			return ply:Notify("No door owners to remove.")
		end

		ply:RemoveDoorMaster(door)
		ply:Notify("Door sold.")
    end
}

impulse.RegisterChatCommand("/forceselldoor", sellDoorCommand)