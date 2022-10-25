concommand.Add("impulse_debug_pos", function(ply)
	local pos = ply:GetPos()

	local output = "Vector("..pos.x..", "..pos.y..", "..pos.z..")"
	chat.AddText(output)

	SetClipboardText(output)
end)

concommand.Add("impulse_debug_eyepos", function(ply)
	local pos = ply:EyePos()

	local output = "Vector("..pos.x..", "..pos.y..", "..pos.z..")"
	chat.AddText(output)

	SetClipboardText(output)
end)

concommand.Add("impulse_debug_ang", function(ply)
	local pos = ply:EyeAngles()

	local output = "Angle("..pos.p..", "..pos.y..", "..pos.r..")"
	chat.AddText(output)

	SetClipboardText(output)
end)

concommand.Add("impulse_debug_ent_ang", function(ply)
	local traceEnt = LocalPlayer():GetEyeTrace().Entity

	if not traceEnt or not IsValid(traceEnt) then
		return chat.AddText("You must be looking at an entity.")
	end

	local pos = traceEnt:GetAngles()
	local output = "Angle("..pos.p..", "..pos.y..", "..pos.r..")"
	chat.AddText(traceEnt)
	chat.AddText(output)
	SetClipboardText(output)
end)

concommand.Add("impulse_debug_ent_pos", function(ply)
	local traceEnt = LocalPlayer():GetEyeTrace().Entity

	if not traceEnt or not IsValid(traceEnt) then
		return chat.AddText("You must be looking at an entity.")
	end

	local pos = traceEnt:GetPos()
	local output = "Vector("..pos.x..", "..pos.y..", "..pos.z..")"
	chat.AddText(traceEnt)
	chat.AddText(output)
	SetClipboardText(output)
end)

concommand.Add("impulse_debug_hudtoggle", function(ply)
	impulse_DevHud = !impulse_DevHud
end)

concommand.Add("impulse_debug_iconeditor", function(ply)
	if ply:IsSuperAdmin() or ply:IsDeveloper() then
		vgui.Create("impulseIconEditor")
	end
end)

concommand.Add("impulse_debug_wtl", function(ply)
	local traceEnt = LocalPlayer():GetEyeTrace().Entity

	if not traceEnt or not IsValid(traceEnt) then
		return chat.AddText("You must be looking at an entity.")
	end

	if impulse_DebugTargPos then
		local pos = traceEnt:WorldToLocal(impulse_DebugTargPos)
		local ang = traceEnt:WorldToLocalAngles(impulse_DebugTargAng)

		chat.AddText("Base entity selected. World-To-Local output below and in console:")

		local output = "Vector("..pos.x..", "..pos.y..", "..pos.z..")"
		chat.AddText(output)

		local output = "Angle("..ang.p..", "..ang.y..", "..ang.r..")"
		chat.AddText(output)
		
		impulse_DebugTargAng = nil
		impulse_DebugTargPos = nil
		return
	end

	impulse_DebugTargPos = traceEnt:GetPos()
	impulse_DebugTargAng = traceEnt:GetAngles()
	chat.AddText("Target entity selected as "..tostring(traceEnt)..". Please run the command looking at the child entity for output.")
end)

concommand.Add("impulse_debug_dump", function(ply, cmd, arg)
	if arg[1] and arg[1] == "help" then
		print("Available memory targets: (does not include sub-targets)")

		for v,k in pairs(impulse) do
			if v and istable(k) and isstring(v) then
				print(v)
			end	
		end

		return
	end
	
	if string.Trim(arg[1] or "", " ") == "" then
		return print("Please provide a memory target. (type 'impulse_debug_dump help' for a list of targets)")
	end

	local route = string.Split(arg[1], ".")
	local c

	for v,k in pairs(route) do
		c = (c or impulse)[k]

		if not c or type(c) != "table" then
			return print("Memory target invalid. (must be a path in the impulse.X data structure)")
		end
	end

	local output = c

	print("Start dump for table "..arg[1])
	PrintTable(output)
	print("End dump for table "..arg[1])
end)