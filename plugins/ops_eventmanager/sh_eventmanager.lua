function impulse.Ops.EventManager.GetEventMode()
    return GetGlobalBool("opsEventMode", false)
end

function impulse.Ops.EventManager.GetSequence()
	local val = GetGlobalString("opsEventSequence", "")

	if val == "" then
		return
	end

    return val
end

function impulse.Ops.EventManager.SetEventMode(val)
	return SetGlobalBool("opsEventMode", val)
end

function impulse.Ops.EventManager.SetSequence(val)
	return SetGlobalString("opsEventSequence", val)
end

function impulse.Ops.EventManager.GetCurEvents()
	return impulse_OpsEM_CurEvents
end

function meta:IsEventAdmin()
	return self:IsSuperAdmin() or (self:IsAdmin() and impulse.Ops.EventManager.GetEventMode())
end

if SERVER then
	concommand.Add("impulse_ops_eventmode", function(ply, cmd, args)
		if not IsValid(ply) or ply:IsSuperAdmin() then
			if args[1] == "1" then
				impulse.Ops.EventManager.SetEventMode(true)
				print("[ops-em] Event mode ON")
			else
				impulse.Ops.EventManager.SetEventMode(false)
				print("[ops-em] Event mode OFF")
			end
		end
	end)
end