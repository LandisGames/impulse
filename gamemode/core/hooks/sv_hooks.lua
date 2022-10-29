local isValid = IsValid
local mathAbs = math.abs

function GM:PlayerInitialSpawn(ply)
	local isNew = true

	ply:SetCanZoom(false)

	-- sync players with all other clients/ents
	impulse.Sync.Data[ply:EntIndex()] = {}
	for v,k in pairs(impulse.Sync.Data) do
		local ent = Entity(v)
		if IsValid(ent) then
			ent:Sync(ply)
		end
	end

	local query = mysql:Select("impulse_players")
	query:Select("id")
	query:Select("rpname")
	query:Select("group")
	query:Select("rpgroup")
	query:Select("rpgrouprank")
	query:Select("xp")
	query:Select("money")
	query:Select("bankmoney")
	query:Select("model")
	query:Select("skin")
	query:Select("data")
	query:Select("skills")
	query:Select("ammo")
	query:Select("firstjoin")
	query:Where("steamid", ply:SteamID())
	query:Callback(function(result)
		if IsValid(ply) and type(result) == "table" and #result > 0 then -- if player exists in db
			isNew = false
			impulse.SetupPlayer(ply, result[1])
		elseif IsValid(ply) then
			ply:Freeze(true)
		end

		if IsValid(ply) then
			net.Start("impulseJoinData")
			net.WriteBool(isNew)
			net.Send(ply)

			net.Start("impulseGetButtons")
			net.WriteUInt(table.Count(impulse.ActiveButtons), 16)

			for v,k in pairs(impulse.ActiveButtons) do
				net.WriteUInt(v, 16)
				net.WriteUInt(k, 16)
			end

			net.Send(ply)
		end
	end)
	query:Execute()

	timer.Create(ply:UserID().."impulseXP", impulse.Config.XPTime, 0, function()
		if not ply:IsAFK() then
			ply:GiveTimedXP()
		end
	end)

	timer.Create(ply:UserID().."impulseOOCLimit", 1800, 0, function()
		if IsValid(ply) then
			if ply:IsDonator() then
				ply.OOCLimit = impulse.Config.OOCLimitVIP
			else
				ply.OOCLimit = impulse.Config.OOCLimit
			end

			net.Start("impulseUpdateOOCLimit")
			net.WriteUInt(1800, 16)
			net.WriteBool(true)
			net.Send(ply)
		end
	end)

	timer.Create(ply:UserID().."impulseFullLoad", 0.5, 0, function()
		if IsValid(ply) and ply:GetModel() != "player/default.mdl" then
			hook.Run("PlayerInitialSpawnLoaded", ply)
			timer.Remove(ply:UserID().."impulseFullLoad")
		end
	end)

	ply.AFKTimer = CurTime() + 720 -- initial afk time :)
end

function GM:PlayerInitialSpawnLoaded(ply) -- called once player is full loaded
	local jailTime = impulse.Arrest.DCRemember[ply:SteamID()]

	if ply.ammoToGive then
		for v,k in pairs(ply.ammoToGive) do
			if game.GetAmmoID(v) != -1 then
				ply:GiveAmmo(k, v)
			end
		end

		ply.ammoToGive = nil
	end

	if jailTime then
		ply:Arrest()
		ply:Jail(jailTime)
		impulse.Arrest.DCRemember[ply:SteamID()] = nil
	end

	local s64 = ply:SteamID64()

	if GExtension and GExtension.Warnings[s64] then
		local bans = GExtension:GetBans(s64)
		local warns = GExtension.Warnings[s64]

		net.Start("opsGetRecord")
		net.WriteUInt(table.Count(warns), 8)
		net.WriteUInt(table.Count(bans), 8)
		net.Send(ply)
	end
end

function GM:PlayerSpawn(ply)
	local cellID = ply.InJail

	if ply.InJail then
		local pos = impulse.Config.PrisonCells[cellID]
		ply:SetPos(impulse.FindEmptyPos(pos, {self}, 150, 30, Vector(16, 16, 64)))
		ply:SetEyeAngles(impulse.Config.PrisonAngle)
		ply:Arrest()

		return
	end

	local killSilent = ply.IsKillSilent

	if killSilent then
		ply.IsKillSilent = false

		for v,k in pairs(ply.TempWeapons) do
			local wep = ply:Give(k.wep)
			wep:SetClip1(k.clip)
		end

		for v,k in pairs(ply.TempAmmo) do
			ply:SetAmmo(k, v)
		end

		if ply.TempSelected then
			ply:SelectWeapon(ply.TempSelected)
			ply:SetWeaponRaised(ply.TempSelectedRaised)
		end

		return
	end
	
	if ply:GetSyncVar(SYNC_ARRESTED, false) == true then
		ply:SetSyncVar(SYNC_ARRESTED, false, true)
	end

	if ply:HasBrokenLegs() then
		ply:FixLegs()
	end

	if ply.beenSetup then
		ply:SetTeam(impulse.Config.DefaultTeam)

		if ply.HasDied then
			ply:SetHunger(70)
		else
			ply:SetHunger(100)
		end
	end

	ply.ArrestedWeapons = nil

	ply.SpawnProtection = true
	ply:SetJumpPower(160)

	timer.Simple(10, function()
		if IsValid(ply) then
			ply.SpawnProtection = false
		end
	end)

	hook.Run("PlayerLoadout", ply)
end

function GM:PlayerDisconnected(ply)
	local userID = ply:UserID()
	local steamID = ply:SteamID()
	local entIndex = ply:EntIndex()
	local arrested = ply:GetSyncVar(SYNC_ARRESTED, false)

	ply:SyncRemove()

	local dragger = ply.ArrestedDragger
	if IsValid(dragger) then
		impulse.Arrest.Dragged[ply] = nil
		dragger.ArrestedDragging = nil
	end

	timer.Remove(userID.."impulseXP")
	timer.Remove(userID.."impulseOOCLimit")
	if timer.Exists(userID.."impulseFullLoad") then
		timer.Remove(userID.."impulseFullLoad")
	end

	local jailCell = ply.InJail

	if jailCell then
		timer.Remove(userID.."impulsePrison")
		local duration = impulse.Arrest.Prison[jailCell][entIndex].duration
		impulse.Arrest.Prison[jailCell][entIndex] = nil
		impulse.Arrest.DCRemember[steamID] = duration
	elseif ply.BeingJailed then
		impulse.Arrest.DCRemember[steamID] = ply.BeingJailed
	elseif arrested then
		impulse.Arrest.DCRemember[steamID] = impulse.Config.MaxJailTime
	end

	if ply.CanHear then
		for v,k in ipairs(player.GetAll()) do
			if not k.CanHear then continue end

			k.CanHear[ply] = nil
		end
	end

	if ply.impulseID then
		impulse.Inventory.Data[ply.impulseID] = nil

		if not ply:IsCP() then
			local query = mysql:Update("impulse_players")
			query:Update("ammo", util.TableToJSON(ply:GetAmmo()))
			query:Where("steamid", steamID)
			query:Execute()
		end
	end

	if ply.OwnedDoors then
		for door,k in pairs(ply.OwnedDoors) do
			if IsValid(door) then
				if door:GetDoorMaster() == ply then
					local noUnlock = door.NoDCUnlock or false
					ply:RemoveDoorMaster(door, noUnlock)
				else
					ply:RemoveDoorUser(door)
				end
			end
		end
	end

	if ply.InvSearching and IsValid(ply.InvSearching) then
		ply.InvSearching:Freeze(false)
	end

	for v,k in pairs(ents.FindByClass("impulse_item")) do
		if k.ItemOwner and k.ItemOwner == ply then
			k.RemoveIn = CurTime() + impulse.Config.InventoryItemDeSpawnTime
		end
	end

	impulse.Refunds.RemoveAll(steamID)
end

function GM:PlayerLoadout(ply)
	ply:SetRunSpeed(impulse.Config.JogSpeed)
	ply:SetWalkSpeed(impulse.Config.WalkSpeed)

	return true
end

function impulse.SetupPlayer(ply, dbData)
	local totalCount = player.GetCount()
	local donorCount = 0

	for v,k in pairs(player.GetAll()) do
		if k:IsDonator() then
			donorCount = donorCount + 1
		end
	end

	local userCount = totalCount - donorCount

	if (not ply:IsDonator() and userCount >= (impulse.Config.UserSlots or 9999)) then
		ply:Kick("The server is currently at full user capacity. Donate at panel.impulse-community.com to access additional donator slots")
		return
	end

	ply:SetSyncVar(SYNC_RPNAME, dbData.rpname, true)
	ply:SetSyncVar(SYNC_XP, dbData.xp, true)

	ply:SetLocalSyncVar(SYNC_MONEY, dbData.money)
	ply:SetLocalSyncVar(SYNC_BANKMONEY, dbData.bankmoney)

	local data = util.JSONToTable(dbData.data)

	ply.impulseData = data
	ply.impulseID = dbData.id

	if ply.impulseData and ply.impulseData.Achievements then
		local count = table.Count(ply.impulseData.Achievements)

		if count > 0 then
			net.Start("impulseAchievementSync")
			net.WriteUInt(count, 8)

			for v,k in pairs(ply.impulseData.Achievements) do
				net.WriteString(v)
				net.WriteUInt(k, 32)
			end

			net.Send(ply)
		end

		ply:CalculateAchievementPoints()
	end

	local skills = util.JSONToTable(dbData.skills) or {}

	ply.impulseSkills = skills

	for v,k in pairs(ply.impulseSkills) do
		local xp = ply:GetSkillXP(v)
		ply:NetworkSkill(v, xp)
	end

	local query = mysql:Update("impulse_players")
	query:Update("ammo", "{}")
	query:Where("steamid", ply:SteamID())
	query:Execute()

	if ammo then
		local ammo = util.JSONToTable(dbData.ammo) or {}
		local give = {}

		for v,k in pairs(ammo) do
			local ammoName = game.GetAmmoName(v)

			if impulse.Config.SaveableAmmo[ammoName] then
				give[ammoName] = k
			end
		end
	end

	ply.ammoToGive = give or {}

	if not GExtension and (dbData.group and dbData.group != "user") then
		ply:SetUserGroup(dbData.group)
	end

	ply.impulseFirstJoin = dbData.firstjoin

	ply.defaultModel = dbData.model
	ply.defaultSkin = dbData.skin
	ply.defaultRPName = dbData.rpname
	ply:UpdateDefaultModelSkin()
	
	ply:SetFOV(90, 0)
	ply:SetTeam(impulse.Config.DefaultTeam)
	ply:AllowFlashlight(true)

	local id = ply.impulseID
	impulse.Inventory.Data[id] = {}
	impulse.Inventory.Data[id][1] = {} -- inv
	impulse.Inventory.Data[id][2] = {} -- storage

	ply.InventoryWeight = 0
	ply.InventoryWeightStorage = 0
	ply.InventoryRegister = {}
	ply.InventoryStorageRegister = {}
	ply.InventoryEquipGroups = {}

	hook.Run("PreEarlyInventorySetup", ply)

	local query = mysql:Select("impulse_inventory")
	query:Select("id")
	query:Select("uniqueid")
	query:Select("ownerid")
	query:Select("storagetype")
	query:Where("ownerid", dbData.id)
	query:Callback(function(result)
		if IsValid(ply) and type(result) == "table" and #result > 0 then
			local userid = ply.impulseID
			local userInv = impulse.Inventory.Data[userid]

			for v,k in pairs(result) do
				local netid = impulse.Inventory.ClassToNetID(k.uniqueid)
				if not netid then continue end -- when items are removed from a live server we will remove them manually in the db, if an item is broken auto doing this would break peoples items

				local storetype = k.storagetype

				if not userInv[storetype] then
					userInv[storetype] = {}
				end
				
				ply:GiveInventoryItem(k.uniqueid, k.storagetype, false, true)
			end
		end

		if IsValid(ply) then
			ply.beenInvSetup = true
			hook.Run("PostInventorySetup", ply)
		end
	end)

	query:Execute()

	ply:SetupWhitelists()

	local rankCol = impulse.Config.RankColours[ply:GetUserGroup()]

	if rankCol then
		ply:SetWeaponColor(Vector(rankCol.r / 255, rankCol.g / 255, rankCol.b / 255))
	end

	local query = mysql:Select("impulse_refunds")
	query:Select("item")
	query:Where("steamid", ply:SteamID())
	query:Callback(function(result)
		if IsValid(ply) and type(result) == "table" and #result > 0 then
			local sid = ply:SteamID()
			local money = 0
			local names = {}

			for v,k in pairs(result) do
				if string.sub(k.item, 1, 4) == "buy_" then
					local class = string.sub(k.item, 5)
					local buyable = impulse.Business.Data[class]

					impulse.Refunds.Remove(sid, k.item)

					if not buyable then
						continue
					end

					names[class] = (names[class] or 0) + 1
					money = money + (buyable.price or 0) + (buyable.refundAdd or 0)
				end
			end

			if money == 0 then
				return
			end

			ply:GiveBankMoney(money)
			
			net.Start("impulseGetRefund")
			net.WriteUInt(table.Count(names), 8)
			net.WriteUInt(money, 16)

			for v,k in pairs(names) do
				net.WriteString(v)
				net.WriteUInt(k, 8)
			end

			net.Send(ply)
		end
	end)

	query:Execute()

	if dbData.rpgroup then
		ply:GroupLoad(dbData.rpgroup, dbData.rpgrouprank or nil)
	end

	ply.beenSetup = true
	hook.Run("PostSetupPlayer", ply)
end

function GM:PostSetupPlayer(ply)
	ply.impulseData.Achievements = ply.impulseData.Achievements or {}

	for v,k in pairs(impulse.Config.Achievements) do
		ply:AchievementCheck(v)
	end
end

function GM:ShowHelp()
	return
end

local talkCol = Color(255, 255, 100)
local infoCol = Color(135, 206, 250)
local strTrim = string.Trim
function GM:PlayerSay(ply, text, teamChat, newChat)
	if not ply.beenSetup then return "" end -- keep out players who are not setup yet
	if teamChat == true then return "" end -- disabled team chat

	text = strTrim(text, " ")

	hook.Run("iPostPlayerSay", ply, text)

	if string.StartWith(text, "/") then
		local args = string.Explode(" ", text)
		local command = impulse.chatCommands[string.lower(args[1])]
		if command then
			if command.cooldown and command.lastRan then
				if command.lastRan + command.cooldown > CurTime() then
					return ""
				end
			end

			if command.adminOnly == true and ply:IsAdmin() == false then
				ply:Notify("You must be an admin to use this command.")
				return ""
			end

			if command.leadAdminOnly == true and not ply:IsLeadAdmin() then
				ply:Notify("You must be a lead admin to use this command.")
				return ""
			end

			if command.superAdminOnly == true and ply:IsSuperAdmin() == false then
				ply:Notify("You must be a super admin to use this command.")
				return ""
			end

			if command.requiresArg and (not args[2] or string.Trim(args[2]) == "") then return "" end
			if command.requiresAlive and not ply:Alive() then return "" end

			text = string.sub(text, string.len(args[1]) + 2)

			table.remove(args, 1)
			command.onRun(ply, args, text)
		else
			ply:Notify("The command "..args[1].." does not exist.")
		end
	elseif ply:Alive() then
		text = hook.Run("ProcessICChatMessage", ply, text) or text
		text = hook.Run("ChatClassMessageSend", 1, text, ply) or text

		for v,k in pairs(player.GetAll()) do
			if (ply:GetPos() - k:GetPos()):LengthSqr() <= (impulse.Config.TalkDistance ^ 2) then
				k:SendChatClassMessage(1, text, ply)
			end
		end

		hook.Run("PostChatClassMessageSend", 1, text, ply)
	end

	return ""
end

local function canHearCheck(listener) -- based on darkrps voice chat optomization this is called every 0.5 seconds in the think hook
	if not IsValid(listener) then return end

	listener.CanHear = listener.CanHear or {}
	local listPos = listener:GetShootPos()
	local voiceDistance = impulse.Config.VoiceDistance ^ 2

	for _,speaker in ipairs(player.GetAll()) do
		listener.CanHear[speaker] = (listPos:DistToSqr(speaker:GetShootPos()) < voiceDistance)
		hook.Run("PlayerCanHearCheck", listener, speaker)
	end
end

function GM:PlayerCanHearPlayersVoice(listener, speaker)
	if not speaker:Alive() then return false end

	local canHear = listener.CanHear and listener.CanHear[speaker]
	return canHear, true
end

function GM:UpdatePlayerSync(ply)
	for v,k in pairs(impulse.Sync.Data) do
		local ent = Entity(v)

		if IsValid(ent) then
			for id,conditional in pairs(impulse.Sync.VarsConditional) do
				if ent:GetSyncVar(id) and conditional(ply) then
					ent:SyncSingle(id, ply)
				end
			end
		end
	end
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)
	local vel = ply:GetVelocity()

	local ragCount = #ents.FindByClass("prop_ragdoll")

	if ragCount > 32 then
		print("[impulse] Avoiding ragdoll body spawn for performance reasons... (rag count: "..ragCount..")")
		return
	end

	local ragdoll = ents.Create("prop_ragdoll")
	ragdoll:SetModel(ply:GetModel())
	ragdoll:SetPos(ply:GetPos())
	ragdoll:SetSkin(ply:GetSkin())
	ragdoll.DeadPlayer = ply
	ragdoll.Killer = attacker
	ragdoll.DmgInfo = dmginfo

	if ply.LastFall and ply.LastFall > CurTime() - 0.5 then
		ragdoll.FallDeath = true
	end

	if IsValid(attacker) and attacker:IsPlayer() then
		local wep = attacker:GetActiveWeapon()

		if IsValid(wep) then
			ragdoll.DmgWep = wep:GetClass()
		end	
	end

	ragdoll.CanConstrain = false
	ragdoll.NoCarry = true

	for v,k in pairs(ply:GetBodyGroups()) do
		ragdoll:SetBodygroup(k.id, ply:GetBodygroup(k.id))
	end

	hook.Run("PlayerRagdollPreSpawn", ragdoll, ply, attacker)

	ragdoll:Spawn()
	ragdoll:SetCollisionGroup(COLLISION_GROUP_WORLD)

	local velocity = ply:GetVelocity()

	for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		local physObj = ragdoll:GetPhysicsObjectNum(i)

		if IsValid(physObj) then
			physObj:SetVelocity(velocity)

			local index = ragdoll:TranslatePhysBoneToBone(i)

			if index then
				local pos, ang = ply:GetBonePosition(index)

				physObj:SetPos(pos)
				physObj:SetAngles(ang)
			end
		end
	end

	timer.Simple(impulse.Config.BodyDeSpawnTime, function()
		if ragdoll and IsValid(ragdoll) then
			ragdoll:Fire("FadeAndRemove", 7)

			timer.Simple(10, function() -- i have a feeling FadeAndRemove won't work with every ragdoll or something
				if IsValid(ragdoll) then
					ragdoll:Remove() -- just in case
				end
			end)
		end
	end)

	timer.Simple(0.1, function()
		if IsValid(ragdoll) and IsValid(ply) then
			net.Start("impulseRagdollLink")
			net.WriteEntity(ragdoll)
			net.Send(ply)
		end
	end)

	return true
end

function GM:PlayerDeath(ply, killer)
	local wait = impulse.Config.RespawnTime

	if ply:IsDonator() then
		wait = impulse.Config.RespawnTimeDonator
	end

	ply.respawnWait = CurTime() + wait

	local money = ply:GetMoney()

	if money > 0 then
		ply:SetMoney(0)
		impulse.SpawnMoney(ply:GetPos(), money)
	end

	if not ply.beenInvSetup then -- people that havent made char or are not loaded in
		return
	end

	ply:UnEquipInventory()

	local inv = ply:GetInventory()
	local restorePoint = {}
	local pos = ply.LocalToWorld(ply, ply:OBBCenter())
	local dropped = 0

	for v,k in pairs(inv) do
		local itemclass = impulse.Inventory.ClassToNetID(k.class)
		local item = impulse.Inventory.Items[itemclass]

		if not k.restricted then
			table.insert(restorePoint, k.class)
		end

		if item.DropOnDeath and not k.restricted then
			local ent = impulse.Inventory.SpawnItem(k.class, pos)
			ent.ItemClip = k.clip

			dropped = dropped + 1

			if dropped > 4 then
				break
			end
		end
	end

	hook.Run("PlayerDropDeathItems", ply, killer, pos, dropped, inv)

	ply:ClearInventory(1)
	ply.InventoryRestorePoint = restorePoint
	ply.HasDied = true
end

function GM:PlayerSilentDeath(ply)
	ply.IsKillSilent = true
	ply.TempWeapons = {}

	for v,k in pairs(ply:GetWeapons()) do
		ply.TempWeapons[v] = {wep = k:GetClass(), clip = k:Clip1()}
	end

	ply.TempAmmo = ply:GetAmmo()

	local wep = ply:GetActiveWeapon()

	if wep and IsValid(wep) then
		ply.TempSelected = wep:GetClass()
		ply.TempSelectedRaised = ply:IsWeaponRaised()
	end
end

function GM:PlayerDeathThink(ply)
	if not ply.respawnWait then
		ply:Spawn()
		return true
	end

	if ply.respawnWait < CurTime() then
		ply:Spawn()
	end

	return true
end

function GM:PlayerDeathSound()
	return true
end

function GM:CanPlayerSuicide()
	return false
end

function GM:OnPlayerChangedTeam(ply) -- get rid of it logging team changes to console
	if ply.BuyableTeamRemove then
		for v,k in pairs(ply.BuyableTeamRemove) do
			if k and IsValid(k) and k.BuyableOwner == ply then
				k:Remove()
			end
		end
	end
end

function GM:SetupPlayerVisibility(ply)
	if ply.extraPVS then
		AddOriginToPVS(ply.extraPVS)
	end

	if ply.extraPVS2 then
		AddOriginToPVS(ply.extraPVS2)
	end
end

function GM:KeyPress(ply, key)
	if ply:IsAFK() then
		ply:UnMakeAFK()	
	end

	ply.AFKTimer = CurTime() + impulse.Config.AFKTime

	if key == IN_RELOAD then
		timer.Create("impulseRaiseWait"..ply:SteamID(), 1, 1, function()
			if IsValid(ply) then
				ply:ToggleWeaponRaised()
			end
		end)
	elseif key == IN_USE and not ply:InVehicle() then
		local trace = {}
		trace.start = ply:GetShootPos()
		trace.endpos = trace.start + ply:GetAimVector() * 96
		trace.filter = ply

		local entity = util.TraceLine(trace).Entity

		if IsValid(entity) and entity:IsPlayer() then
			if ply:CanArrest(entity) then
				if not entity.ArrestedDragger then
					ply:DragPlayer(entity)
				else
					entity:StopDrag()
				end
			end
		end
	end
end

function GM:PlayerUse(ply, entity)
	if (ply.useNext or 0) > CurTime() then return false end
	ply.useNext = CurTime() + 0.3

	local btnKey = entity.ButtonCheck

	if btnKey and impulse.Config.Buttons[btnKey] then
		local btnData = impulse.Config.Buttons[btnKey]

		if btnData.customCheck and not btnData.customCheck(ply, entity) then
			ply.useNext = CurTime() + 1
			return false
		end

		if btnData.doorgroup then
			local teamDoorGroups = ply.DoorGroups

			if not teamDoorGroups or not table.HasValue(teamDoorGroups, btnData.doorgroup) then
				ply.useNext = CurTime() + 1
				ply:Notify("You don't have access to use this button.")
				return false
			end
		end
	end
end

function GM:KeyRelease(ply, key)
	if key == IN_RELOAD then
		timer.Remove("impulseRaiseWait"..ply:SteamID())
	end
end

impulse.ActiveButtons = {}
local function LoadButtons()
	for a,button in pairs(ents.FindByClass("func_button")) do
		if button.ButtonCheck then
			button.ButtonCheck = nil
		end
	end

	if not impulse.Config.Button then
		return
	end
	
	for a,button in pairs(ents.FindByClass("func_button")) do
		if button.ButtonCheck then
			continue
		end
		
		for v,k in pairs(impulse.Config.Buttons) do
			if k.pos:DistToSqr(button:GetPos()) < (9 ^ 2) then -- getpos client/server innaccuracy
				button.ButtonCheck = v
				impulse.ActiveButtons[button:EntIndex()] = v

				if k.init then
					k.init(button)
				end
			end
		end
	end
end

function GM:InitPostEntity()
	impulse.Doors.Load()

	for v,k in pairs(ents.GetAll()) do
		if k.impulseSaveEnt or k.IsZoneTrigger then
			k:Remove()
		end
	end

	if impulse.Config.LoadScript then
		impulse.Config.LoadScript()
	end

	if impulse.Config.Zones then
		for v,k in pairs(impulse.Config.Zones) do
			local zone = ents.Create("impulse_zone")
			zone:SetBounds(k.pos1, k.pos2)
			zone.Zone = v
		end
	end

	if impulse.Config.BlacklistEnts then
		for v,k in pairs(ents.GetAll()) do
			if impulse.Config.BlacklistEnts[k:GetClass()] then
	            k:Remove()
	        end
	    end
	end

	LoadSaveEnts()
	LoadButtons()

	hook.Run("PostInitPostEntity")
end

LoadButtons()

function GM:PostCleanupMap()
	hook.Run("InitPostEntity")
end

function GM:GetFallDamage(ply, speed)
	ply.LastFall = CurTime()

	local dmg = speed * 0.05

	if speed > 780 then
		dmg = dmg + 75
	end

	local shouldBreakLegs = hook.Run("PlayerShouldBreakLegs", ply, dmg)

	if shouldBreakLegs != nil and shouldBreakLegs == false then
		return dmg
	end

	local strength = ply:GetSkillLevel("strength")
	local r = math.random(0, 20 + (strength * 2))

	if r <= 20 and dmg < ply:Health() then
		ply:BreakLegs()
	end

	return dmg
end

local lastAFKScan
local curTime = CurTime
function GM:Think()
	local ctime = curTime()
	local allPlayers = player.GetAll()

	for v,k in pairs(allPlayers) do
		if not k.nextHungerUpdate then k.nextHungerUpdate = ctime + impulse.Config.HungerTime end

		if k:Alive() then
			if k.nextHungerUpdate < ctime then
				local shouldTakeHunger = hook.Run("PlayerShouldGetHungry", k)

				if shouldTakeHunger == nil or shouldTakeHunger then
					k:FeedHunger(-1)
				end

				if k:GetSyncVar(SYNC_HUNGER, 100) < 1 then
					if k:Health() > 10 then
						k:TakeDamage(1, k, k)
					end
					k.nextHungerUpdate = ctime + 1
				else
					k.nextHungerUpdate = ctime + impulse.Config.HungerTime
				end
			end

			if (k.nextHungerHeal or 0) < ctime then
				local hunger = k:GetSyncVar(SYNC_HUNGER, 10)

				if hunger >= 90 and k:Health() < 75 then
					k:SetHealth(math.Clamp(k:Health() + 1, 0, 75))
					k.nextHungerHeal = ctime + impulse.Config.HungerHealTime
				else
					k.nextHungerHeal = ctime + 2
				end
			end
		end

		if not k.nextHearUpdate or k.nextHearUpdate < CurTime() then -- optimized version of canhear hook based upon darkrp
			canHearCheck(k)
			k.nextHearUpdate = ctime + 0.65
		end
	end

	for v,k in pairs(impulse.Arrest.Dragged) do
		if not IsValid(v) then
			impulse.Arrest.Dragged[v] = nil
			continue
		end

		local dragger = v.ArrestedDragger

		if IsValid(dragger) then
			if (dragger:GetPos() - v:GetPos()):LengthSqr() >= (175 ^ 2) then
				v:StopDrag()
			end
		else
			v:StopDrag()
		end
	end

	if (lastAFKScan or 0) < ctime then
		lastAFKScan = ctime + 2

		for v,k in pairs(allPlayers) do
			if k.AFKTimer and k.AFKTimer < ctime and not impulse.Arrest.Dragged[k] and not k:IsAFK() then
				k:MakeAFK()
			end

			k.LastKnownPos = k.GetPos(k)

			if k.BrokenLegs and k.BrokenLegsTime < ctime and k:Alive() then
				k:FixLegs()
				k:Notify("Your broken legs have healed naturally.")
			end
		end
	end
end

function GM:DatabaseConnectionFailed(errorText)
	SetGlobalString("impulse_fatalerror", "Failed to connect to database. See server console for error.")
	print("[impulse] [SERIOUS FAULT] DB connection failure... Attempting reconnection...")

	timer.Simple(0.66, function()
		mysql:Connect(impulse.DB.ip, impulse.DB.username, impulse.DB.password, impulse.DB.database, impulse.DB.port)
	end)
end

function GM:PlayerCanPickupWeapon(ply)
	if ply:GetSyncVar(SYNC_ARRESTED, false) then
		return false
	end

	return true
end

local exploitRagBlock = {
	["models/dpfilms/metropolice/zombie_police.mdl"] = true,
	["models/dpfilms/metropolice/playermodels/pm_zombie_police.mdl"] = true,
	["models/zombie/zmanims.mdl"] = true
}

function GM:PlayerSpawnRagdoll(ply, model)
	if exploitRagBlock[model] then
		return false
	end

	return ply:IsLeadAdmin()
end

function GM:PlayerSpawnSENT(ply)
	return ply:IsSuperAdmin()
end

function GM:PlayerSpawnSWEP(ply)
	return ply:IsSuperAdmin()
end

function GM:PlayerGiveSWEP(ply)
	return ply:IsSuperAdmin()
end

function GM:PlayerSpawnEffect(ply)
	return ply:IsAdmin()
end

function GM:PlayerSpawnNPC(ply)
	return ply:IsSuperAdmin() or (ply:IsAdmin() and impulse.Ops.EventManager.GetEventMode())
end

function GM:PlayerSpawnProp(ply, model)
	if not ply:Alive() or not ply.beenSetup or ply:GetSyncVar(SYNC_ARRESTED, false) then
		return false
	end

	if ply:IsAdmin() then
		return true
	end

	local limit
	local price

	if ply:IsDonator() then
		limit = impulse.Config.PropLimitDonator
		price = impulse.Config.PropPriceDonator
	else
		limit = impulse.Config.PropLimit
		price = impulse.Config.PropPrice
	end

	if ply:GetPropCount(true) >= limit then
		ply:Notify("You have reached your prop limit.")
		return false
	end

	if ply:CanAfford(price) then
		ply:TakeMoney(price)
		ply:Notify("You have purchased a prop for "..impulse.Config.CurrencyPrefix..price..".")
	else
		ply:Notify("You need "..impulse.Config.CurrencyPrefix..price.." to spawn this prop.")
		return false
	end

	return true
end

function GM:PlayerSpawnedProp(ply, model, ent)
	ply:AddPropCount(ent)
end

function GM:PlayerSpawnVehicle(ply, model)
	if ply:GetSyncVar(SYNC_ARRESTED, false) then
		return false
	end

	if ply:IsDonator() and (model:find("chair") or model:find("seat") or model:find("pod")) then
		local count = 0
		ply.SpawnedVehicles = ply.SpawnedVehicles or {}

		for v,k in pairs(ply.SpawnedVehicles) do
			if k and IsValid(k) then
				count = count + 1
			else
				ply.SpawnedVehicles[v] = nil
			end
		end

		if count >= impulse.Config.ChairsLimit then
			ply:Notify("You have spawned the maximum amount of chairs.")
			return false
		end

		return true
	else
		return ply:IsSuperAdmin()
	end
end

function GM:PlayerSpawnedVehicle(ply, ent)
	ply.SpawnedVehicles = ply.SpawnedVehicles or {}
	table.insert(ply.SpawnedVehicles, ent)
end

function GM:CanDrive()
	return false
end

local whitelistProp = {
	["remover"] = true,
	["collision"] = true
}

function GM:CanProperty(ply, prop)
	if whitelistProp[prop] then
		return true
	end

	if ply:IsAdmin() and (prop == "ignite" or prop == "extinguish") then
		return true
	end

	return false
end

local bannedTools = {
	["duplicator"] = true,
	["physprop"] = true,
	["dynamite"] = true,
	["eyeposer"] = true,
	["faceposer"] = true,
	["fingerposer"] = true,
	["inflator"] = true,
	["trails"] = true,
	["paint"] = true,
	["wire_explosive"] = true,
	["wire_simple_explosive"] = true,
	["wire_turret"] = true,
	["wire_user"] = true,
	["wire_pod"] = true,
	["wire_magnet"] = true,
	["wire_teleporter"] = true,
	["wire_trail"] = true,
	["wire_trigger"] = true,
	["wire_detonators"] = true,
	["wire_detonator"] = true,
	["wire_field_device"] = true,
	["wire_hsranger"] = true,
	["wire_hsholoemitter"] = true,
	["wire_eyepod"] = true,
	["wire_spu"] = true,
	["wnpc"] = true
}

local dupeBannedTools = {
	["weld"] = true,
	["weld_ez"] = true,
	["spawner"] = true,
	["duplicator"] = true,
	["adv_duplicator"] = true
}

local donatorTools = {
	["wire_expression2"] = true,
	["wire_egp"] = true,
	["wire_soundemitter"] = true
}

local adminWorldRemoveWhitelist = {
	["impulse_item"] = true,
	["impulse_money"] = true,
	["impulse_letter"] = true,
	["prop_ragdoll"] = true,
	["prop_physics"] = true
}

function GM:CanTool(ply, tr, tool)
	if not ply:IsAdmin() and tool == "spawner" then
		return false
	end

	if bannedTools[tool] then
		return false
	end

	if donatorTools[tool] and not ply:IsDonator() then
		ply:Notify("This tool is restricted to donators only.")
		return false
	end

    local ent = tr.Entity

    if IsValid(ent) then
        if ent.onlyremover then
            if tool == "remover" then
                return ply:IsAdmin() or ply:IsSuperAdmin()
            else
                return false
            end
        end

        if ent.nodupe and dupeBannedTools[tool] then
            return false
        end

       	if tool == "remover" and ply:IsAdmin() and not ply:IsSuperAdmin() then
    		local owner = ent:CPPIGetOwner()

    		if not owner and not adminWorldRemoveWhitelist[ent:GetClass()] then
    			ply:Notify("You can not remove this entity.")
    			return false
    		end
    	end

    	if string.sub(ent:GetClass(), 1, 8) == "impulse_" then
    		if tool != "remover" and not ply:IsSuperAdmin() then
    			return false
    		end
    	end
	end

	return true
end

local bannedDupeEnts = {
	["gmod_wire_explosive"] = true,
	["gmod_wire_simple_explosive"] = true,
	["gmod_wire_turret"] = true,
	["gmod_wire_user"] = true,
	["gmod_wire_realmagnet"] = true,
	["gmod_wire_teleporter"] = true,
	["gmod_wire_thruster"] = true,
	["gmod_wire_trail"] = true,
	["gmod_wire_trigger"] = true,
	["gmod_wire_trigger_entity"] = true,
	["gmod_wire_rtcam"] = true,
	["gmod_wire_detonator"] = true,
	["gmod_wire_hsranger"] = true,
	["gmod_wire_hsholoemitter"] = true,
	["gmod_wire_eyepod"] = true,
	["gmod_wire_spu"] = true
}

local donatorDupeEnts = {
	["gmod_wire_expression2"] = true,
	["prop_vehicle_prisoner_pod"] = true,
	["gmod_wire_soundemitter"] = true,
	["gmod_wire_epg"] = true
}

local whitelistDupeEnts = {
	["gmod_wheel"] = true,
	["gmod_lamp"] = true,
	["gmod_emitter"] = true,
	["gmod_button"] = true,
	["prop_dynamic"] = true,
	["prop_physics"] = true,
	["gmod_light"] = true,
	["prop_door_rotating"] = true -- door tool
}

function GM:ADVDupeIsAllowed(ply, class, entclass) -- adv dupe 2 can be easily exploited, this fixes it. you must have the impulse version of AD2 for this to work
	if bannedDupeEnts[class] then
		return false
	end

	if donatorDupeEnts[class] then
		if ply:IsDonator() then
			return true
		else
			ply:Notify("This entity is restricted to donators only.")
			return false
		end
	end

	if whitelistDupeEnts[class] or string.sub(class, 1, 9) == "gmod_wire" then
		return true
	end

	return false
end

function GM:SetupMove(ply, mvData)
	if isValid(ply.ArrestedDragging) then
		mvData:SetMaxClientSpeed(impulse.Config.WalkSpeed - 30)
	end
end

function GM:CanPlayerEnterVehicle(ply, veh)
	if ply:GetSyncVar(SYNC_ARRESTED, false) or ply.ArrestedDragging then
		return false
	end

	return true
end

function GM:CanExitVehicle(veh, ply)
	if ply:GetSyncVar(SYNC_ARRESTED, false) then
		return false
	end

	return true
end

function GM:PlayerSetHandsModel(ply, hands)
	local handModel = impulse.Teams.Data[ply:Team()].handModel

	if handModel then
		hands:SetModel(handModel)
		return
	end

	local simplemodel = player_manager.TranslateToPlayerModelName(ply:GetModel())
	local info = player_manager.TranslatePlayerHands(simplemodel)

	if info then
		hands:SetModel(info.model)
		hands:SetSkin(info.skin)
		hands:SetBodyGroups(info.body)
	end
end

function GM:PlayerSpray()
	return true
end

function GM:PlayerShouldTakeDamage(ply, attacker)
	if ply:Team() == 0 then
		return false
	end
	
	if ply.SpawnProtection and attacker:IsPlayer() then
		return false
	end

	if attacker and IsValid(attacker) and attacker:IsPlayer() and attacker != Entity(0) and attacker != ply then
		if (ply.NextStorage or 0) < CurTime() then
			ply.NextStorage = CurTime() + 60
		end

		attacker.NextStorage = CurTime() + 180
	end

	return true
end

function GM:LongswordCalculateMeleeDamage(ply, damage, ent)
	local skill = ply:GetSkillLevel("strength")
	local dmg = damage * (1 + (skill * .059))
	local override = hook.Run("CalculateMeleeDamage", ply, dmg, ent)

	return override or dmg
end

function GM:LongswordMeleeHit(ply)
	if ply.StrengthUp and ply.StrengthUp > 5 then
		ply:AddSkillXP("strength", math.random(1, 6))
		ply.StrengthUp = 0
		return
	end

	ply.StrengthUp = (ply.StrengthUp or 0) + 1
end

function GM:LongswordHitEntity(ply, ent)
	-- if tree then vood ect.
end
