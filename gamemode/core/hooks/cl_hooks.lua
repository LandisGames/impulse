function GM:OnSchemaLoaded()
	if not impulse.MainMenu and not IsValid(impulse.MainMenu) then
		impulse.SplashScreen = vgui.Create("impulseSplash")

		if system.IsWindows() then
			system.FlashWindow()
		end
	end

	local dir = "impulse/menumsgs/"
	for v,k in ipairs(file.Find(dir.."*.dat", "DATA")) do
		local f = file.Read(dir..k, "DATA")
		local data = util.JSONToTable(f)

		if not data then
			print("[impulse] Error loading menu message "..v.."!")
			continue
		end

		impulse.MenuMessage.Data[data.type] = data
	end
end

if engine.ActiveGamemode() == "impulse" then -- debug fallback
	impulse.SplashScreen = vgui.Create("impulseSplash")
end

local lastServerData1
local lastServerData2
local nextCrashThink = 0
local nextCrashAnalysis
local crashAnalysisAttempts = 0

function GM:Think()
	if LocalPlayer():Team() != 0 and not vgui.CursorVisible() and not impulse_ActiveWorkbar then
		if not IsValid(impulse.MainMenu) or not impulse.MainMenu:IsVisible() then
			if input.IsKeyDown(KEY_F1) then
				local mainMenu = impulse.MainMenu or vgui.Create("impulseMainMenu")
				mainMenu:SetVisible(true)
				mainMenu:SetAlpha(0)
				mainMenu:AlphaTo(255, .3)
				mainMenu.popup = true

				hook.Run("DisplayMenuMessages", mainMenu)
			elseif input.IsKeyDown(KEY_F4) and not IsValid(impulse.playerMenu) and LocalPlayer():Alive() then
				impulse.playerMenu = vgui.Create("impulsePlayerMenu")
			elseif input.IsKeyDown(KEY_F2) and LocalPlayer():Alive() then
				local trace = {}
				trace.start = LocalPlayer():EyePos()
				trace.endpos = trace.start + LocalPlayer():GetAimVector() * 85
				trace.filter = LocalPlayer()

				local traceEnt = util.TraceLine(trace).Entity

				if (not impulse.entityMenu or not IsValid(impulse.entityMenu)) and IsValid(traceEnt) then
					if traceEnt:IsDoor() or traceEnt:IsPropDoor() then
						impulse.entityMenu = vgui.Create("impulseEntityMenu")
						impulse.entityMenu:SetDoor(traceEnt)
					elseif traceEnt:IsPlayer() then
						impulse.entityMenu = vgui.Create("impulseEntityMenu")
						impulse.entityMenu:SetRangeEnt(traceEnt)
						impulse.entityMenu:SetPlayer(traceEnt)
					elseif traceEnt:GetClass() == "impulse_container" then
						impulse.entityMenu = vgui.Create("impulseEntityMenu")
						impulse.entityMenu:SetRangeEnt(traceEnt)
						impulse.entityMenu:SetContainer(traceEnt)
					elseif traceEnt:GetClass() == "prop_ragdoll" then
						impulse.entityMenu = vgui.Create("impulseEntityMenu")
						impulse.entityMenu:SetRangeEnt(traceEnt)
						impulse.entityMenu:SetBody(traceEnt)
					end
				end
			elseif input.IsKeyDown(KEY_F6) and not IsValid(groupEditor) and not LocalPlayer():IsCP() then
				impulse.groupEditor = vgui.Create("impulseGroupEditor")
			end

			hook.Run("CheckMenuInput")
		end
	end

	if (nextLoopThink or 0) < CurTime() then
		for v,k in pairs(player.GetAll()) do
			local isArrested = k:GetSyncVar(SYNC_ARRESTED, false)

			if isArrested != (k.BoneArrested or false) then
				k:SetHandsBehindBack(isArrested)
				k.BoneArrested = isArrested
			end
		end

		nextLoopThink = CurTime() + 0.5
	end

	if not SERVER_DOWN and nextCrashAnalysis and nextCrashAnalysis < CurTime() then
		nextCrashAnalysis = CurTime() + 0.05

		local a, b = engine.ServerFrameTime()

		if crashAnalysisAttempts <= 15 then
			if a != (lastServerData1 or 0) or b != (lastServerData2 or 0) then
				nextCrashAnalysis = nil
				crashAnalysisAttempts = 0
				return
			end

			crashAnalysisAttempts = crashAnalysisAttempts + 1

			if crashAnalysisAttempts == 15 then
				nextCrashAnalysis = nil
				crashAnalysisAttempts = 0
				SERVER_DOWN = true
			end
		else
			nextCrashAnalysis = nil
			crashAnalysisAttempts = 0
		end

		lastServerData1 = a
		lastServerData2 = b
	end

	if (nextCrashThink or 0) < CurTime() then
		nextCrashThink = CurTime() + 0.66

		local a, b = engine.ServerFrameTime()

		if a == (lastServerData1 or 0) and b == (lastServerData2 or 0) then
			nextCrashAnalysis = CurTime()
		else
			SERVER_DOWN = false
			nextCrashAnalysis = nil
		end

		lastServerData1 = a
		lastServerData2 = b
	end
end

function GM:ScoreboardShow()
	if LocalPlayer():Team() == 0 then return end -- players who have not been loaded yet

    impulse_scoreboard = vgui.Create("impulseScoreboard")
end

function GM:ScoreboardHide()
	if LocalPlayer():Team() == 0 then return end -- players who have not been loaded yet
	
    impulse_scoreboard:Remove()
end

function GM:DefineSettings()
	impulse.DefineSetting("hud_vignette", {name="Vignette enabled", category="HUD", type="tickbox", default=true})
	impulse.DefineSetting("hud_iconcolours", {name="Icon colours enabled", category="HUD", type="tickbox", default=false})
	impulse.DefineSetting("view_thirdperson", {name="Thirdperson enabled", category="View", type="tickbox", default=false})
	impulse.DefineSetting("view_thirdperson_fov", {name="Thirdperson FOV", category="View", type="slider", default=90, minValue=60, maxValue=95})
	impulse.DefineSetting("perf_mcore", {name="Multi-core rendering enabled", category="Performance", type="tickbox", default=false, onChanged = function(newValue)
		RunConsoleCommand("gmod_mcore_test", tostring(tonumber(newValue)))

		if newValue == 1 then
			RunConsoleCommand("mat_queue_mode", "-1")
			RunConsoleCommand("cl_threaded_bone_setup", "1")
		else
			RunConsoleCommand("cl_threaded_bone_setup", "0")
		end
	end})
	impulse.DefineSetting("perf_dynlight", {name="Dynamic light rendering enabled", category="Performance", type="tickbox", default=true, onChanged = function(newValue)
		local v = 0
		if newValue == 1 then
			v = 1
		end

		RunConsoleCommand("r_shadows", v)
		RunConsoleCommand("r_dynamic", v)
	end})
	impulse.DefineSetting("perf_blur", {name="Blur enabled", category="Performance", type="tickbox", default=true})
	impulse.DefineSetting("inv_sortequippablesattop", {name="Sort equipped at top", category="Inventory", type="tickbox", default=true})
	impulse.DefineSetting("inv_sortweight", {name="Sort by weight", category="Inventory", type="dropdown", default="Inventory only", options={"Never", "Inventory only", "Containers only", "Always"}})
	impulse.DefineSetting("misc_vendorgreeting", {name="Vendor greeting sound enabled", category="Misc", type="tickbox", default=true})
	impulse.DefineSetting("chat_oocenabled", {name="OOC enabled", category="Chatbox", type="tickbox", default=true})
	impulse.DefineSetting("chat_pmpings", {name="PM and tag sound enabled", category="Chatbox", type="tickbox", default=true})
end

local loweredAngles = Angle(30, -30, -25)

function GM:CalcViewModelView(weapon, viewmodel, oldEyePos, oldEyeAng, eyePos, eyeAngles)
	if not IsValid(weapon) then return end

	local vm_origin, vm_angles = eyePos, eyeAngles

	do
		local lp = LocalPlayer()
		local raiseTarg = 0

		if !lp:IsWeaponRaised() then
			raiseTarg = 100
		end

		local frac = (lp.raiseFraction or 0) / 100
		local rot = weapon.LowerAngles or loweredAngles

		vm_angles:RotateAroundAxis(vm_angles:Up(), rot.p * frac)
		vm_angles:RotateAroundAxis(vm_angles:Forward(), rot.y * frac)
		vm_angles:RotateAroundAxis(vm_angles:Right(), rot.r * frac)

		lp.raiseFraction = Lerp(FrameTime() * 2, lp.raiseFraction or 0, raiseTarg)
	end

	--The original code of the hook.
	do
		local func = weapon.GetViewModelPosition
		if (func) then
			local pos, ang = func( weapon, eyePos*1, eyeAngles*1 )
			vm_origin = pos or vm_origin
			vm_angles = ang or vm_angles
		end

		func = weapon.CalcViewModelView
		if (func) then
			local pos, ang = func( weapon, viewModel, oldEyePos*1, oldEyeAngles*1, eyePos*1, eyeAngles*1 )
			vm_origin = pos or vm_origin
			vm_angles = ang or vm_angles
		end
	end

	return vm_origin, vm_angles
end

function GM:ShouldDrawLocalPlayer()
	if impulse.GetSetting("view_thirdperson") then
		return true
	end
end

function GM:CalcView(player, origin, angles, fov)
	local view

	if IsValid(impulse.splash) or (IsValid(impulse.MainMenu) and impulse.MainMenu:IsVisible() and not impulse.MainMenu.popup) then
		view = {
			origin = impulse.Config.MenuCamPos,
			angles = impulse.Config.MenuCamAng,
			fov = 70
		}
		return view
	end
	
	local ragdoll = player.Ragdoll

	if ragdoll and IsValid(ragdoll) then
		local eyes = ragdoll:GetAttachment(ragdoll:LookupAttachment("eyes"))
		if not eyes then return end

		view = {
			origin = eyes.Pos,
			angles = eyes.Ang,
			fov = 70
		}
		return view
	end

	if impulse.GetSetting("view_thirdperson") and player:GetViewEntity() == player then
		local angles = player:GetAimVector():Angle()
		local targetpos = Vector(0, 0, 60)

		if player:KeyDown(IN_DUCK) then
			if player:GetVelocity():Length() > 0 then
				targetpos.z = 50
			else
				targetpos.z = 40
			end
		end

		player:SetAngles(angles)

		local pos = targetpos

		local offset = Vector(5, 5, 5)

		offset.x = 75
		offset.y = 20
		offset.z = 5
		angles.yaw = angles.yaw + 3

		local t = {}

		t.start = player:GetPos() + pos
		t.endpos = t.start + angles:Forward() * -offset.x

		t.endpos = t.endpos + angles:Right() * offset.y
		t.endpos = t.endpos + angles:Up() * offset.z
		t.filter = function(ent)
			if ent == LocalPlayer() then
				return false
			end
			
			if ent.GetNoDraw(ent) then
				return false
			end

			return true
		end
		
		local tr = util.TraceLine(t)

		pos = tr.HitPos

		if (tr.Fraction < 1.0) then
			pos = pos + tr.HitNormal * 5
		end

		local fov = impulse.GetSetting("view_thirdperson_fov")
		local wep = player:GetActiveWeapon()

		if wep and IsValid(wep) and wep.GetIronsights and not wep.NoThirdpersonIronsights then
			fov = Lerp(FrameTime() * 15, wep.FOVMultiplier, wep:GetIronsights() and wep.IronsightsFOV or 1) * fov
		end

		local delta = player.EyePos(player) - origin

		return {
			origin = pos + delta,
			angles = angles,
			fov = fov
		}
	end
end

local blackandwhite = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

function GM:RenderScreenspaceEffects()
	if impulse.hudEnabled == false or (IsValid(impulse.MainMenu) and impulse.MainMenu:IsVisible()) then
		return
	end

	if LocalPlayer():Health() < 20 then
		DrawColorModify(blackandwhite)
	end
end

function GM:StartChat()
	net.Start("impulseChatState")
	net.WriteBool(true)
	net.SendToServer()
end

function GM:FinishChat()
	net.Start("impulseChatState")
	net.WriteBool(false)
	net.SendToServer()
end

function GM:OnContextMenuOpen()
	if LocalPlayer():Team() == 0 or not LocalPlayer():Alive() or impulse_ActiveWorkbar then return end
	if LocalPlayer():GetSyncVar(SYNC_ARRESTED, false) then return end

	local canUse = hook.Run("CanUseInventory", LocalPlayer())

	if canUse != nil and canUse == false then
		return
	end

	if not input.IsKeyDown(KEY_LALT) then
		impulse_inventory = vgui.Create("impulseInventory")
		gui.EnableScreenClicker(true)
	else
		if IsValid(g_ContextMenu) and not g_ContextMenu:IsVisible() then
			g_ContextMenu:Open()
			menubar.ParentTo(g_ContextMenu)

			hook.Call("ContextMenuOpened", self)
		end
	end
end

function GM:OnContextMenuClose()
	if IsValid(g_ContextMenu) then 
		g_ContextMenu:Close()
		hook.Call("ContextMenuClosed", self)
	end

	if IsValid(impulse_inventory) then
		impulse_inventory:Remove()
		gui.EnableScreenClicker(false)
	end
end

local blockedTabs = {
	["#spawnmenu.category.saves"] = true,
	["#spawnmenu.category.dupes"] = true,
	["#spawnmenu.category.postprocess"] = true
}

local blockNormalTabs = {
	["#spawnmenu.category.entities"] = true,
	["#spawnmenu.category.weapons"] = true,
	["#spawnmenu.category.npcs"] = true
}

function GM:PostReloadToolsMenu()
	local spawnMenu = g_SpawnMenu

	if spawnMenu then
		local tabs = spawnMenu.CreateMenu
		local closeMe = {}

		for v,k in pairs(tabs:GetItems()) do
			if blockedTabs[k.Name] then
				table.insert(closeMe, k.Tab)
			end

			if LocalPlayer() and LocalPlayer().IsAdmin and LocalPlayer().IsDonator then -- when u first load lp doesnt exist
				if blockNormalTabs[k.Name] and not LocalPlayer():IsAdmin() then
					table.insert(closeMe, k.Tab)
				end

				if k.Name == "#spawnmenu.category.vehicles" and not LocalPlayer():IsDonator() then
					table.insert(closeMe, k.Tab)
				end
			end
		end

		for v,k in pairs(closeMe) do
			tabs:CloseTab(k, true)
		end
	end
end

function GM:SpawnMenuOpen()
	if LocalPlayer():Team() == 0 or not LocalPlayer():Alive() then
		return false
	else
		return true
	end
end

function GM:DisplayMenuMessages(menu)
	menu.Messages = menu.Messages or {}

	for v,k in pairs(menu.Messages) do
		k:Remove()
	end

	hook.Run("CreateMenuMessages")

	local time = os.time()

	for v,k in pairs(impulse.MenuMessage.Data) do
		if k.expiry and k.expiry < time then
			impulse.MenuMessage.Remove(v)
			continue
		end

		menu.AddingMsgs = true
		local msg = vgui.Create("impulseMenuMessage", menu)
		local w = menu:GetWide() - 1100

		if w < 300 then
			msg:SetSize(520, 180)
			msg:SetPos(menu:GetWide() - 540, 390)
		else
			msg:SetSize(w, 120)
			msg:SetPos(520, 30)
		end

		msg:SetMessage(v)

		msg.OnClosed = function()
			impulse.MenuMessage.Remove(v)

			if IsValid(menu) then
				hook.Run("DisplayMenuMessages", menu)
			end

			surface.PlaySound("buttons/button14.wav")
		end

		table.insert(menu.Messages, msg)
		menu.AddingMsgs = false

		break
	end
end

function GM:OnAchievementAchieved() -- disable steam achievement chat messages
	return
end

function GM:PostProcessPermitted()
	return false
end

concommand.Add("impulse_togglethirdperson", function() -- ease of use command for binds
	impulse.SetSetting("view_thirdperson", (!impulse.GetSetting("view_thirdperson")))
end)

concommand.Add("impulse_reloadmenu", function()
	if IsValid(impulse.MainMenu) then
		impulse.MainMenu:Remove()
	end

	impulse.MainMenu = vgui.Create("impulseMainMenu")
end)