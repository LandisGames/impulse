local red = Color(255, 0, 0, 255)
local green = Color(0, 240, 0, 255)
local col = Color(255,255,255,120)
local dotToggleTime = 0
local hitgroups = {
	[HITGROUP_GENERIC] = "generic",
	[HITGROUP_HEAD] = "head",
	[HITGROUP_CHEST] = "chest",
	[HITGROUP_STOMACH] = "stomach",
	[HITGROUP_LEFTARM] = "leftarm",
	[HITGROUP_RIGHTARM] = "rightarm",
	[HITGROUP_LEFTLEG] = "leftleg",
	[HITGROUP_RIGHTLEG] = "rightleg",
	[HITGROUP_GEAR] = "belt"
}

hook.Add("HUDPaint", "impulseOpsHUD", function()
	if not impulse.hudEnabled then return end

	if LocalPlayer():IsAdmin() and LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP then
		local onDuty = impulse.GetSetting("admin_onduty") or false

		if onDuty then
			draw.SimpleText("OBSERVER MODE", "Impulse-Elements19-Shadow", 20, 10, col)
		else
			draw.SimpleText("OBSERVER MODE (OFF DUTY! YOU WILL NOT VIEW INBOUND REPORTS!)", "Impulse-Elements19-Shadow", 20, 10, red)
		end

		local staffOn = 0

		for v,k in pairs(player.GetAll()) do
			if k:IsAdmin() then
				staffOn = staffOn + 1
			end
		end

		draw.SimpleText(staffOn.." STAFF ONLINE", "Impulse-Elements18-Shadow", ScrW() * .5, 10, col, TEXT_ALIGN_CENTER)

		if OPS_LIGHT then
			draw.SimpleText("LIGHT ON", "Impulse-Elements18-Shadow", ScrW() * .5, 30, col, TEXT_ALIGN_CENTER)
		end

		draw.SimpleText("TOTAL REPORTS: " ..#impulse.Ops.Reports, "Impulse-Elements16-Shadow", 20, 30, col)

		local totalClaimed = 0
		for v,k in pairs(impulse.Ops.Reports) do
			if k[3] then
				totalClaimed = totalClaimed + 1

				if k[3] == LocalPlayer() then
					if IsValid(k[1]) then
						draw.SimpleText("REPORTEE: "..k[1]:SteamName().." ("..k[1]:Name()..")", "Impulse-Elements16-Shadow", 20, 80, green)
					else
						draw.SimpleText("REPORTEE IS INVALID! CLOSE THIS REPORT.", "Impulse-Elements16-Shadow", 20, 80, green)
					end
				end
			end
		end

		draw.SimpleText("CLAIMED REPORTS: " ..totalClaimed, "Impulse-Elements16-Shadow", 20, 50, col)

		if LocalPlayer():IsAdmin() and impulse.GetSetting("admin_esp") then
			draw.SimpleText("ENTCOUNT: "..#ents.GetAll(), "Impulse-Elements16-Shadow", 20, 100, col)
			draw.SimpleText("PLAYERCOUNT: "..#player.GetAll(), "Impulse-Elements16-Shadow", 20, 120, col)

			if impulse.Dispatch then
				local ccode = impulse.Dispatch.CityCodes[impulse.Dispatch.GetCityCode()]
				draw.SimpleText("CITYCODE: "..ccode[1], "Impulse-Elements16-Shadow", 20, 140, ccode[2])
			end

			local y = 160

			for v,k in pairs(impulse.Teams.Data) do
				draw.SimpleText(team.GetName(v)..": "..#team.GetPlayers(v), "Impulse-Elements16-Shadow", 20, y, col)
				y = y + 20
			end

			for v,k in pairs(player.GetAll()) do
				if k ==  LocalPlayer() then continue end
				
				local pos = (k:GetPos() + k:OBBCenter()):ToScreen()
				local col = team.GetColor(k:Team())


				if k:IsAdmin() and k:GetMoveType() == MOVETYPE_NOCLIP and k:GetNoDraw() then
					draw.SimpleText("** In Observer Mode **", "Impulse-Elements18-Shadow", pos.x, pos.y, Color(255, 0, 0), TEXT_ALIGN_CENTER)
				else
					draw.SimpleText(k:Name(), "Impulse-Elements18-Shadow", pos.x, pos.y, col, TEXT_ALIGN_CENTER)
				end

				draw.SimpleText(k:SteamName(), "Impulse-Elements16-Shadow", pos.x, pos.y + 15, impulse.Config.InteractColour, TEXT_ALIGN_CENTER)
			end
		end

		if CUR_SNAPSHOT then
			local snapData = impulse.Ops.Snapshots[CUR_SNAPSHOT]
			impulse.Ops.Snapshots[CUR_SNAPSHOT].VictimNeatName = impulse.Ops.Snapshots[CUR_SNAPSHOT].VictimNeatName or ((IsValid(snapData.Victim) and snapData.Victim:IsPlayer()) and (snapData.VictimNick.." ("..snapData.Victim:SteamName()..")") or snapData.VictimID)
			impulse.Ops.Snapshots[CUR_SNAPSHOT].InflictorNeatName = impulse.Ops.Snapshots[CUR_SNAPSHOT].InflictorNeatName or ((IsValid(snapData.Inflictor) and snapData.Inflictor:IsPlayer()) and (snapData.InflictorNick.." ("..snapData.Inflictor:SteamName()..")") or snapData.InflictorID)

			draw.SimpleText("VIEWING SNAPSHOT #"..CUR_SNAPSHOT.." (CLOSE WITH F2)", "Impulse-Elements16-Shadow", 250, 100, col)
			draw.SimpleText("VICTIM: "..snapData.VictimNeatName.." ["..snapData.VictimID.."]", "Impulse-Elements16-Shadow", 250, 120, Color(255, 0, 0))
			draw.SimpleText("ATTACKER: "..snapData.InflictorNeatName.." ["..snapData.InflictorID.."]", "Impulse-Elements16-Shadow", 250, 140, Color(0, 255, 0))

			for v,k in pairs(impulse.Ops.SnapshotEnts) do
				local pos = (k:GetPos() + k:OBBCenter()):ToScreen()
				local col = k:GetColor()

				draw.SimpleText(k.IsVictim and snapData.VictimNeatName or snapData.InflictorNeatName, "Impulse-Elements18-Shadow", pos.x, pos.y, col, TEXT_ALIGN_CENTER)

				if not k.IsVictim then
					draw.SimpleText("WEP: "..snapData.AttackerClass, "Impulse-Elements18-Shadow", pos.x, pos.y + 20, col, TEXT_ALIGN_CENTER)
					draw.SimpleText("HP: "..snapData.InflictorHealth, "Impulse-Elements18-Shadow", pos.x, pos.y + 40, col, TEXT_ALIGN_CENTER)
				else
					draw.SimpleText("HITGROUP: "..hitgroups[snapData.VictimHitGroup], "Impulse-Elements18-Shadow", pos.x, pos.y + 20, col, TEXT_ALIGN_CENTER)
				end
			end
		end

		if impulse.Ops.EventManager and impulse.Ops.EventManager.GetEventMode() and impulse.Ops.EventManager.GetSequence() then
			local symb = "•"

			if dotToggleTime < CurTime() then
				symb = ""

				if dotToggleTime + 1 < CurTime() then
					dotToggleTime = CurTime() + 1
				end
			end

			draw.SimpleText(symb.." LIVE (CURRENT SEQUENCE: "..impulse.Ops.EventManager.GetSequence()..")", "Impulse-Elements18-Shadow", ScrW() - 20, 20, red, TEXT_ALIGN_RIGHT)
		end
	end
end)