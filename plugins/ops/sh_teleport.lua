if SERVER then
	function opsGoto(ply, pos)
		ply:ExitVehicle()
		if not ply:Alive() then ply:Spawn() end

		ply:SetPos(impulse.FindEmptyPos(pos, {ply}, 600, 30, Vector(16, 16, 64)))
	end

	function opsBring(ply, target)
		local hasPhysgun = false
		local wep = target:GetActiveWeapon()

		if not target:IsBot() and wep and IsValid(wep) and wep:GetClass() == "weapon_physgun" and target:KeyDown(IN_ATTACK) then
			target:ConCommand("-attack")
			target:GetActiveWeapon():Remove()
			hasPhysgun = true
		end

		if hasPhysgun then
			timer.Simple(0.5, function() 
				if IsValid(target) and target:Alive() then
					target:Give("weapon_physgun")
					target:SelectWeapon("weapon_physgun")
				end
			end)
		end

		target.lastPos = target:GetPos()
		opsGoto(target, ply:GetPos())
	end
end

local gotoCommand = {
    description = "Teleports yourself to the player specified.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local name = arg[1]
		local plyTarget = impulse.FindPlayer(name)

		if plyTarget and ply != plyTarget then
			opsGoto(ply, plyTarget:GetPos())
			ply:Notify("You have teleported to "..plyTarget:Name().."'s position.")
		elseif string.sub(name, 1, 1) == "#" then
			local id = string.sub(name, 2)

			if not tonumber(id) then
				return ply:Notify("Invalid entity ID: "..id)
			end

			id = tonumber(id)

			local ent = Entity(id)

			if not IsValid(ent) then
				return ply:Notify("Entity "..id.." does not exist.")
			end

			opsGoto(ply, ent:GetPos())
			ply:Notify("You have teleported to Entity "..id.."'s position.")
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
    end
}

impulse.RegisterChatCommand("/goto", gotoCommand)

local zoneGotoCommand = {
	description = "Teleports yourself to the zone specified.",
	requiresArg = true,
	adminOnly = true,
	onRun = function(ply, arg, rawText)
        local name = string.lower(arg[1])
		local zoneTarget

		for v,k in pairs(impulse.Config.Zones) do
			if string.find(string.lower(k.name), name, 1, true) ~= nil then
            	zoneTarget = k
        	end
		end

		if zoneTarget then
			opsGoto(ply, LerpVector(0.5, zoneTarget.pos1, zoneTarget.pos2))
			ply:Notify("You have teleported to "..zoneTarget.name..".")
		else
			return ply:Notify("Could not find zone: "..tostring(name))
		end
    end
}

impulse.RegisterChatCommand("/zgoto", zoneGotoCommand)

local bringCommand = {
    description = "Teleports the player specified to your location.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local name = arg[1]
		local plyTarget = impulse.FindPlayer(name)

		if plyTarget and ply != plyTarget then
			if not plyTarget:Alive() then
				plyTarget:Spawn()
				plyTarget:Notify("You have been respawned by a game moderator.")
				ply:Notify("Target was dead, automatically respawned.")
			end

			opsBring(ply, plyTarget)
			ply:Notify(plyTarget:Name().." has been brought to your position.")
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
    end
}

impulse.RegisterChatCommand("/bring", bringCommand)

local returnCommand = {
    description = "Returns the player specified to their last location.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local name = arg[1]
		local plyTarget = impulse.FindPlayer(name)

		if plyTarget and ply != plyTarget then
			if plyTarget.lastPos then
				if not plyTarget:Alive() then
					return ply:Notify("Player is dead.")
				end
				
				opsGoto(plyTarget, plyTarget.lastPos)
				plyTarget.lastPos = nil
				ply:Notify(plyTarget:Name().." has been returned.")
			else
				return ply:Notify("No old position to return the player to.")
			end
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
    end
}

impulse.RegisterChatCommand("/return", returnCommand)