-- helper funcs

local stringVars = {
	["#PlayerName"] = function() return LocalPlayer():Nick() end,
	["#PlayerSteamName"] = function() return LocalPlayer():SteamName() end
}

local function uiStringVarSwap(str)
	local out = str

	for v,k in pairs(stringVars) do
		out = string.Replace(out, v, k() or "Variable return error")
	end

	return out
end
-- config

impulse.Ops.EventManager.Config.CategoryIcons = {
	["hidden"] = "icon16/new.png",
	["music"] = "icon16/music.png",
	["effect"] = "icon16/wand.png",
	["sound"] = "icon16/sound.png",
	["ui"] = "icon16/monitor.png",
	["server"] = "icon16/server.png",
	["scene"] = "icon16/film.png",
	["npc"] = "icon16/user.png",
	["ent"] = "icon16/brick.png",
	["cookies"] = "icon16/database.png",
	["script"] = "icon16/script_code_red.png",
	["rtcamera"] = "icon16/camera.png",
	["loot"] = "icon16/briefcase.png",
	["prefabs"] = "icon16/plugin.png"
}

impulse.Ops.EventManager.Config.TagColours = {
	["purple"] = Color(177, 112, 212),
	["blue"] = Color(60, 140, 246),
	["green"] = Color(80, 207, 98),
	["yellow"] = Color(247, 206, 75),
	["orange"] = Color(246, 163, 71),
	["red"] = Color(246, 91, 85)
}

impulse.Ops.EventManager.Config.Events = {
	["empty"] = {
		Cat = "hidden",
		Prop = {},
		NeedUID = false,
		Clientside = false,
		Do = function() end
	},
	["screenshake"] = {
		Cat = "effect",
		Prop = {
			["pos"] = Vector(0, 0, 0),
			["amplitude"] = 5,
			["frequency"] = 5,
			["duration"] = 4,
			["radius"] = 10000 
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			util.ScreenShake(prop["pos"], prop["amplitude"], prop["frequency"], prop["duration"], prop["radius"])
		end
	},
	["timescale"] = {
		Cat = "effect",
		Prop = {
			["timescale"] = 1
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			game.SetTimeScale(prop["timescale"])
		end
	},
	["fog"] = {
		Cat = "effect",
		Prop = {
			["start"] = 10,
			["end"] = 10,
			["density"] = 1,
			["colour"] = Color(255, 255, 255)
		},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			hook.Add("SetupWorldFog", "opsEMFog", function()
				render.FogMode(MATERIAL_FOG_LINEAR)
				render.FogStart(prop["start"])
				render.FogEnd(prop["end"])
				render.FogMaxDensity(prop["density"])

				local col = prop["colour"]
				render.FogColor(col.r, col.g, col.b)

				return true
			end)

			hook.Add("SetupSkyboxFog", "opsEMFog", function(scale)
				render.FogMode(MATERIAL_FOG_LINEAR)
				render.FogStart(prop["start"] * scale)
				render.FogEnd(prop["end"] * scale)
				render.FogMaxDensity(prop["density"])

				local col = prop["colour"]
				render.FogColor(col.r, col.g, col.b)

				return true
			end)
		end
	},
	["killfog"] = {
		Cat = "effect",
		Prop = {},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			hook.Remove("SetupWorldFog", "opsEMFog")
			hook.Remove("SetupSkyboxFog", "opsEMFog")
		end
	},
	["explode"] = {
		Cat = "effect",
		Prop = {
			["pos"] = Vector(0, 0, 0),
			["magnitude"] = 200
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			local explodeEnt = ents.Create("env_explosion")
	        explodeEnt:SetPos(prop["pos"])
	        explodeEnt:Spawn()
	        explodeEnt:SetKeyValue("iMagnitude", prop["magnitude"])
	        explodeEnt:Fire("explode", "", 0)
		end
	},
	["explode_cinematic"] = {
		Cat = "effect",
		Prop = {
			["pos"] = Vector(0, 0, 0),
			["magnitude"] = 325,
			["debris"] = 9
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			local tempEnt = ents.Create("impulse_usable")
			tempEnt:SetModel("models/weapons/w_c4_planted.mdl")
			tempEnt:SetPos(prop["pos"])
			tempEnt:Spawn()

			timer.Simple(0.05, function()
				if IsValid(tempEnt) then
					impulse.MakeBigExplosion(tempEnt, prop["magnitude"], prop["debris"])
				end
			end)
		end
	},
	["particleffect"] = {
		Cat = "effect",
		Prop = {
			["pos"] = Vector(0, 0, 0),
			["ang"] = Vector(0, 0, 0),
			["name"] = "effect_name"
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			OPS_ENTS = OPS_ENTS or {}

		 	if OPS_ENTS[ui] and IsValid(OPS_ENTS[uid]) then
 				OPS_ENTS[uid]:Remove()
 			end

			OPS_ENTS[uid] = ents.Create("prop_physics")
			OPS_ENTS[uid]:SetModel("models/hunter/plates/plate.mdl")
			OPS_ENTS[uid]:SetColor(Color(0, 0, 0, 0))
			OPS_ENTS[uid]:SetRenderMode(RENDERMODE_TRANSCOLOR)
			--OPS_ENTS[uid]:SetNoDraw(true)
			OPS_ENTS[uid]:SetPos(prop["pos"])
			OPS_ENTS[uid]:SetAngles(Angle(prop["ang"].x, prop["ang"].y, prop["ang"].z))
			OPS_ENTS[uid]:Spawn()

			local phys = OPS_ENTS[uid]:GetPhysicsObject()

			if phys and phys:IsValid() then
				phys:EnableMotion(false)
			end

			ParticleEffectAttach(prop["name"], PATTACH_ABSORIGIN_FOLLOW, OPS_ENTS[uid], 0)
		end
	},
	["effect"] = {
		Cat = "effect",
		Prop = {
			["pos"] = Vector(0, 0, 0),
			["scale"] = 1,
			["name"] = "effect_name"
		},
		NeedUID = true,
		Clientside = true,
		Do = function(prop, uid)
			local ef = EffectData()
			ef:SetOrigin(prop["pos"])
			ef:SetScale(prop["scale"])

			util.Effect(prop["name"], ef, true, true)
		end
	},
	["makefire"] = {
		Cat = "effect",
		Prop = {
			["pos"] = Vector(0, 0, 0),
			["duration"] = 15
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			local explodeEnt = ents.Create("env_fire")
	        explodeEnt:SetPos(prop["pos"])
	        explodeEnt:Spawn()
	        explodeEnt:Fire("startfire", "", 0)

	        timer.Simple(prop["duration"], function()
	        	if IsValid(explodeEnt) then
	        		explodeEnt:Remove()
	        	end
	        end)
		end
	},
	["makeflare"] = {
		Cat = "effect",
		Prop = {
			["pos"] = Vector(0, 0, 0),
			["delay"] = 0,
			["life"] = 360
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			local ent = ents.Create("env_flare")
			ent:SetModel("models/props_junk/flare.mdl")
	        ent:SetPos(prop["pos"])
	        ent:SetKeyValue("spawnflags", 8) --start off
	        ent:Spawn()

	        timer.Simple(prop["delay"], function()
	        	if IsValid(ent) then
	        		ent:Fire("Start", prop["life"])
	        	end
	        end)
		end
	},
	["chat"] = {
		Cat = "ui",
		Prop = {
			["message"] = "Message"
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			for v,k in pairs(player.GetAll()) do
				k:SendChatClassMessage(14, prop["message"], Entity(0))
			end
		end
	},
	["cineintro"] = {
		Cat = "ui",
		Prop = {
			["title"] = "Event Name"
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			impulse.CinematicIntro(prop["title"])
		end
	},
	["screenfade"] = {
		Cat = "ui",
		Prop = {
			["flag"] = 1,
			["colour"] = Color(255, 255, 255),
			["fadetime"] = 2,
			["fadehold"] = 1
		},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			for v,k in pairs(player.GetAll()) do
				k:ScreenFade(prop["flag"], prop["colour"], prop["fadetime"], prop["fadehold"])
			end
		end
	},
	["hudoff"] = {
		Cat = "ui",
		Prop = {},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			impulse.hudEnabled = false
		end
	},
	["hudon"] = {
		Cat = "ui",
		Prop = {},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			impulse.hudEnabled = true
		end
	},
	["text"] = {
		Cat = "ui",
		Prop = {
			["message"] = "Sample Text",
			["pos_x"] = 0.5,
			["pos_y"] = 0.5,
			["message_fadein"] = 3,
			["message_fadeout"] = 3,
			["message_hold"] = 5,
			["message_colour"] = Color(255, 255, 255, 255),
			["message_align"] = TEXT_ALIGN_CENTER
		},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			local text = vgui.Create("impulseFadeText")
			text:Setup(uiStringVarSwap(prop["message"]), prop["pos_x"], prop["pos_y"], prop["message_fadein"], prop["message_fadeout"], prop["message_hold"], prop["message_colour"], prop["message_align"])
		end
	},
	["textarray"] = {
		Cat = "ui",
		Prop = {
			["message"] = "Item 1|Item 2|Item 3",
			["pos_x"] = 0.5,
			["pos_y"] = 0.5,
			["message_fadein"] = 3,
			["message_fadeout"] = 3,
			["message_hold"] = 5,
			["message_colour"] = Color(255, 255, 255, 255),
			["message_align"] = TEXT_ALIGN_CENTER,
			["array_ygap"] = 38,
			["array_delay"] = 1
		},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			local items = string.Split(prop["message"], "|")
			local c = 1
			local max = table.Count(items)
			local yAdd = prop["array_ygap"]

			timer.Create("impulseOpsEMTextArray"..math.random(1,100000), prop["array_delay"], max, function()
				local text = vgui.Create("impulseFadeText")
				text:Setup(uiStringVarSwap(items[c]), prop["pos_x"], prop["pos_y"] + (((c - 1) * yAdd) / ScrH()), prop["message_fadein"], prop["message_fadeout"], prop["message_hold"] + ((max - c) * prop["array_delay"]), prop["message_colour"], prop["message_align"])

				c = c + 1
			end)
		end
	},
	["spawnent"] = {
		Cat = "ent",
		Prop = {
			["model"] = "mdl here",
			["skin"] = 0,
			["pos"] = Vector(0, 0, 0),
			["ang"] = Vector(0, 0, 0),
			["ignite"] = false,
			["physics"] = false
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			OPS_ENTS = OPS_ENTS or {}

			if OPS_ENTS and OPS_ENTS[uid] and IsValid(OPS_ENTS[uid]) then
				OPS_ENTS[uid]:Remove()
			end

			local ent = ents.Create(prop["physics"] and "prop_physics" or "prop_dynamic")
			ent:SetModel(prop["model"])
			ent:SetSkin(prop["skin"])
			ent:SetPos(prop["pos"])
			ent:SetAngles(Angle(prop["ang"].x, prop["ang"].y, prop["ang"].z))
			ent:Spawn()
			ent:Activate()

			local phys = ent:GetPhysicsObject()

			if phys and phys:IsValid() and prop["physics"] then
				phys:EnableMotion(true)
			elseif phys and phys:IsValid() then
				phys:EnableMotion(false)
			end

			if prop["ignite"] then
				ent:Ignite(9999)
			end

			OPS_ENTS[uid] = ent
		end
	},
	["skinent"] = {
		Cat = "ent",
		Prop = {
			["newskin"] = 0
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			if OPS_ENTS and OPS_ENTS[uid] and IsValid(OPS_ENTS[uid]) then
				OPS_ENTS[uid]:SetSkin(prop["newskin"])
			end
		end
	},
	["bodygroupent"] = {
		Cat = "ent",
		Prop = {
			["bodygroups"] = ""
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			if OPS_ENTS and OPS_ENTS[uid] and IsValid(OPS_ENTS[uid]) then
				OPS_ENTS[uid]:SetBodyGroups(prop["bodygroups"])
			end
		end
	},
	["removeent"] = {
		Cat = "ent",
		Prop = {},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			if OPS_ENTS and OPS_ENTS[uid] and IsValid(OPS_ENTS[uid]) then
				OPS_ENTS[uid]:Remove()
			end
		end
	},
	["getplayer"] = {
		Cat = "ent",
		Prop = {
			["steamid"] = "steam_0:XXXX"
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			OPS_ENTS[uid] = player.GetBySteamID(prop["steamid"])
		end
	},
	["scaleent"] = {
		Cat = "ent",
		Prop = {
			["newscale"] = 2,
			["time"] = 0
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			if OPS_ENTS and OPS_ENTS[uid] and IsValid(OPS_ENTS[uid]) then
				OPS_ENTS[uid]:SetModelScale(prop["newscale"], prop["time"])
			end
		end
	},
	["animent"] = {
		Cat = "ent",
		Prop = {
			["sequence"] = "idle"
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			if OPS_ENTS and OPS_ENTS[uid] and IsValid(OPS_ENTS[uid]) then
				net.Start("impulseOpsEMEntAnim")
				net.WriteUInt(OPS_ENTS[uid]:EntIndex(), 16)
				net.WriteString(prop["sequence"])
				net.Broadcast()
			end
		end
	},
	["moveent"] = {
		Cat = "ent",
		Prop = {
			["end_pos"] = Vector(0, 0, 0),
			["speed"] = 100
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			if not OPS_ENTS or not OPS_ENTS[uid] or not IsValid(OPS_ENTS[uid]) then
				return
			end

			local e = OPS_ENTS[uid]

			if IsValid(e.loco) then
				--e.loco:Remove()
			end

			e.loco = ents.Create("func_movelinear")
			e.loco:SetPos(e:GetPos())
			e.loco:SetAngles(e:GetAngles())
			e.loco:Spawn()
			e.loco:SetMoveType(MOVETYPE_PUSH)
			e.loco.dad = e
			e:SetParent(e.loco)

			e.loco:CallOnRemove("removeLoco", function(ent)
				if IsValid(ent.dad) then
					ent.dad:Remove()
				end
			end)

			e:CallOnRemove("removeELoco", function(ent)
				if IsValid(ent.loco) then
					ent.loco:Remove()
				end
			end)

			e.loco:SetSaveValue("m_VecPosition1", tostring(e:GetPos()))
			e.loco:SetSaveValue("m_VecPosition2", tostring(prop["end_pos"]))

			e.loco:Fire("SetSpeed", prop["speed"])
			e.loco:Fire("Open")
		end
	},
	["movespeedent"] = {
		Cat = "ent",
		Prop = {
			["speed"] = 100
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			if OPS_ENTS and OPS_ENTS[uid] and IsValid(OPS_ENTS[uid]) and IsValid(OPS_ENTS[uid].loco) then
				OPS_ENTS[uid].loco:Fire("SetSpeed", prop["speed"])
			end
		end
	},
	["soundplay"] = {
		Cat = "sound",
		Prop = {
			["sound"] = "",
			["level"] = 75,
			["volume"] = 1,
			["cponly"] = false
		},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			if prop["cponly"] and not LocalPlayer():IsCP() then
				return
			end
			
			LocalPlayer():EmitSound(prop["sound"], prop["level"], nil, prop["volume"])
		end
	},
	["advsoundplay"] = {
		Cat = "sound",
		Prop = {
			["sound"] = "",
			["level"] = 75,
			["volume"] = 1,
			["volumetime"] = 0
		},
		NeedUID = true,
		Clientside = true,
		Do = function(prop, uid)
			OPS_SOUNDS = OPS_SOUNDS or {}

			if OPS_SOUNDS[uid] then
				OPS_SOUNDS[uid]:Stop()
				OPS_SOUNDS[uid] = nil
			end

			OPS_SOUNDS[uid] = CreateSound(LocalPlayer(), prop["sound"])
			OPS_SOUNDS[uid]:SetSoundLevel(prop["level"])
			OPS_SOUNDS[uid]:ChangeVolume(prop["volume"])
			OPS_SOUNDS[uid]:Play()
		end
	},
	["advsoundsetvolume"] = {
		Cat = "sound",
		Prop = {
			["newvolume"] = 1,
			["time"] = 0
		},
		NeedUID = true,
		Clientside = true,
		Do = function(prop, uid)
			if OPS_SOUNDS and OPS_SOUNDS[uid] and OPS_SOUNDS[uid] and OPS_SOUNDS[uid]:IsPlaying() then
				OPS_SOUNDS[uid]:ChangeVolume(prop["newvolume"], prop["time"])
			end
		end
	},
	["advsoundstop"] = {
		Cat = "sound",
		Prop = {},
		NeedUID = true,
		Clientside = true,
		Do = function(prop, uid)
			if OPS_SOUNDS and OPS_SOUNDS[uid] and OPS_SOUNDS[uid] and OPS_SOUNDS[uid]:IsPlaying() then
				OPS_SOUNDS[uid]:Stop()
				OPS_SOUNDS[uid] = nil
			end
		end
	},
	["emitsound"] = {
		Cat = "sound",
		Prop = {
			["sound"] = "",
			["pos"] = Vector(0, 0, 0),
			["volume"] = 1,
			["level"] = 75
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			local x = ents.Create("info_target")
			x:SetPos(prop["pos"])
			x:EmitSound(prop["sound"], prop["level"], nil, prop["volume"])
			x:Spawn()

			timer.Simple(1, function()
				x:Remove()
			end)
		end
	},
	["stopallsounds"] = {
		Cat = "sound",
		Prop = {},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			LocalPlayer():ConCommand("stopsound")
		end
	},
	["urlmusic_play"] = {
		Cat = "music",
		Prop = {
			["url"] = "this must be a .mp3",
			["volume"] = 1
		},
		NeedUID = true,
		Clientside = true,
		Do = function(prop, uid)
			local service = medialib.load("media").guessService(prop["url"])
			local mediaclip = service:load(prop["url"])

			OPS_MUSIC = OPS_MUSIC or {}

			if OPS_MUSIC[uid] then
				OPS_MUSIC[uid]:stop()
				OPS_MUSIC[uid] = nil
			end

			OPS_MUSIC[uid] = mediaclip

			mediaclip:play()
		end
	},
	["urlmusic_stop"] = {
		Cat = "music",
		Prop = {},
		NeedUID = true,
		Clientside = true,
		Do = function(prop, uid)
			if OPS_MUSIC and OPS_MUSIC[uid] then
				OPS_MUSIC[uid]:stop()
				OPS_MUSIC[uid] = nil
			end
		end
	},
	["urlmusic_setvolume"] = {
		Cat = "music",
		Prop = {
			["volume"] = 1
		},
		NeedUID = true,
		Clientside = true,
		Do = function(prop, uid)
			if OPS_MUSIC and OPS_MUSIC[uid] then
				OPS_MUSIC[uid]:setVolume(prop["volume"])
			end
		end
	},
	["changelevel"] = {
		Cat = "server",
		Prop = {
			["map"] = "gm_construct"
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			RunConsoleCommand("changelevel", prop["map"])
		end
	},
	["achievementgive"] = {
		Cat = "server",
		Prop = {
			["achievementid"] = ""
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			for v,k in pairs(player.GetAll()) do
				k:AchievementGive(prop["achievementid"])
			end
		end
	},
	["fire"] = {
		Cat = "server",
		Prop = {
			["pos"] = Vector(0, 0, 0),
			["class"] = "func_button",
			["arg"] = "Use"
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			for v,k in pairs(ents.GetAll()) do
				if k:GetClass() == prop["class"] and k:GetPos() == prop["pos"] then
					k:Fire(prop["arg"])
				end
			end
		end
	},
	["itemspawn"] = {
		Cat = "loot",
		Prop = {
			["itemclass"] = "item_name",
			["pos"] = Vector(0, 0, 0)
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			local x = impulse.Inventory.SpawnItem(prop["itemclass"], prop["pos"])
			x.IsRestrictedItem = true
		end
	},
	["ammobox_spawn"] = {
		Cat = "loot",
		Prop = {
			["pos"] = Vector(0, 0, 0),
			["ang"] = Vector(0, 0, 0),
			["physics"] = false
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			OPS_ENTS = OPS_ENTS or {}

			if OPS_ENTS and OPS_ENTS[uid] and IsValid(OPS_ENTS[uid]) then
				OPS_ENTS[uid]:Remove()
			end

			local ent = ents.Create("impulse_hl2rp_eventammobox")
			ent:SetPos(prop["pos"])
			ent:SetAngles(Angle(prop["ang"].x, prop["ang"].y, prop["ang"].z))
			ent:Spawn()
			ent:Activate()

			local phys = ent:GetPhysicsObject()

			if phys and phys:IsValid() and prop["physics"] then
				phys:EnableMotion(true)
			elseif phys and phys:IsValid() then
				phys:EnableMotion(false)
			end

			OPS_ENTS[uid] = ent
		end
	},
	["ammobox_remove"] = {
		Cat = "loot",
		Prop = {},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			OPS_ENTS = OPS_ENTS or {}

			if OPS_ENTS and OPS_ENTS[uid] and IsValid(OPS_ENTS[uid]) then
				OPS_ENTS[uid]:Remove()
			end
		end
	},
	["setcookie"] = {
		Cat = "cookies",
		Prop = {
			["name"] = "do_intro",
			["value"] = ""
		},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			cookie.Set("impulse_em_"..prop["name"], prop["value"])
		end
	},
	["npc_spawn"] = {
		Cat = "npc",
		Prop = {
			["class"] = "npc_combine_s",
			["weapon"] = "",
			["pos"] = Vector(0, 0, 0),
			["ang"] = Vector(0, 0, 0),
			["cpsarefriendly"] = false
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
 			OPS_NPCS = OPS_NPCS or {}

 			if OPS_NPCS[uid] and IsValid(OPS_NPCS[uid]) then
 				OPS_NPCS[uid]:Remove()
 			end

 			OPS_NPCS[uid] = ents.Create(prop["class"])
 			OPS_NPCS[uid]:SetPos(prop["pos"])
 			OPS_NPCS[uid]:SetAngles(Angle(prop["ang"].x, prop["ang"].y, prop["ang"].z))
			
			if prop["class"] != "npc_combinegunship" then
 				OPS_NPCS[uid]:SetKeyValue("spawnflags", OPS_NPCS[uid]:GetSpawnFlags() + SF_NPC_NO_WEAPON_DROP)
			end

 			OPS_NPCS[uid]:Spawn()
 			OPS_NPCS[uid]:Activate()

 			if prop["weapon"] != "" then
 				OPS_NPCS[uid]:Give(prop["weapon"])
 			end

 			local all = player.GetAll()

 			if prop["cpsarefriendly"] then
 				for v,k in pairs(all) do
 					if k:IsCP() then
 						OPS_NPCS[uid]:AddEntityRelationship(k, D_LI, 99)
 					end
 				end
 			end

 			for v,k in pairs(all) do
 				if k.GetMoveType(k) == MOVETYPE_NOCLIP then
 					OPS_NPCS[uid]:AddEntityRelationship(k, D_NU, 99)
 				end
 			end
		end
	},
	["npc_remove"] = {
		Cat = "npc",
		Prop = {},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
 			OPS_NPCS = OPS_NPCS or {}

 			if OPS_NPCS[uid] and IsValid(OPS_NPCS[uid]) then
 				OPS_NPCS[uid]:Remove()
 			end
		end
	},
	["npc_sethp"] = {
		Cat = "npc",
		Prop = {
			["health"] = 100
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
 			OPS_NPCS = OPS_NPCS or {}

 			if OPS_NPCS[uid] and IsValid(OPS_NPCS[uid]) then
 				OPS_NPCS[uid]:SetHealth(prop["health"])
 			end
		end
	},
	["npc_movetopos"] = {
		Cat = "npc",
		Prop = {
			["pos"] = Vector(0, 0, 0)
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
 			OPS_NPCS = OPS_NPCS or {}

 			if OPS_NPCS[uid] and IsValid(OPS_NPCS[uid]) then
 				OPS_NPCS[uid]:SetLastPosition(prop["pos"])
 				OPS_NPCS[uid]:SetSchedule(SCHED_FORCED_GO_RUN)
 			end
		end
	},
	["npc_movetotrack"] = {
		Cat = "npc",
		Prop = {
			["pos"] = Vector(0, 0, 0)
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
 			OPS_NPCS = OPS_NPCS or {}
 			OPS_TRACKS = OPS_TRACKS or {}

 			if OPS_NPCS[uid] and IsValid(OPS_NPCS[uid]) then
 				local npc = OPS_NPCS[uid]

 				if OPS_TRACKS[uid] and IsValid(OPS_TRACKS[uid]) then
 					OPS_TRACKS[uid]:Remove()
 				end

 				OPS_TRACKS[uid] = ents.Create("path_track")
 				OPS_TRACKS[uid]:SetName(uid.."Track5555")
 				OPS_TRACKS[uid]:SetPos(prop["pos"])

 				npc:Fire("flytospecifictrackviapath", uid.."Track5555")
 			end
		end
	},
	["dropship_spawn"] = {
		Cat = "npc",
		Prop = {
			["start_pos"] = Vector(0, 0, 0),
			["start_ang"] = Vector(0, 0, 0),
			["second_pos"] = Vector(0, 0, 0),
			["land_pos"] = Vector(0, 0, 0),
			["god"] = true,
			["soldier_smg"] = 3,
			["soldier_ar2"] = 2,
			["soldier_shotgun"] = 1,
			["soldier_elite"] = 0
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
 			OPS_NPCS = OPS_NPCS or {}

 			if OPS_NPCS[uid] and IsValid(OPS_NPCS[uid]) then
 				OPS_NPCS[uid]:Remove()
 			end

 			local secondPos = prop["second_pos"]

 			if secondPos.x == 0 and secondPos.y == 0 and secondPos.z == 0 then
 				secondPos = nil
 			end

 			OPS_NPCS[uid] = MakeDropship(uid, prop["start_pos"], Angle(prop["start_ang"].x, prop["start_ang"].y, prop["start_ang"].z), secondPos, prop["land_pos"], prop["god"], prop["soldier_smg"], prop["soldier_ar2"], prop["soldier_shotgun"], prop["soldier_elite"])
		end
	},
	["dropship_remove"] = {
		Cat = "npc",
		Prop = {},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
 			OPS_NPCS = OPS_NPCS or {}

 			if OPS_NPCS[uid] and IsValid(OPS_NPCS[uid]) then
 				OPS_NPCS[uid]:Remove()
 			end

 			if DROPSHIP_TROOPS[uid] then
 				for v,k in pairs(DROPSHIP_TROOPS[uid]) do
 					if IsValid(k) then
 						k:Remove()
 					end
 				end

 				DROPSHIP_TROOPS[uid] = nil
 			end
		end
	},
	["headcrabcanister"] = {
		Cat = "npc",
		Prop = {
			["pos"] = Vector(0, 0, 0),
			["ang"] = Vector(-20.139978, 28.500559, 0),
			["headcrabtype"] = 0,
			["count"] = 4,
			["speed"] = 3000,
			["time"] = 5,
			["damage"] = 50,
			["radius"] = 750,
			["duration"] = 30,
			["smoke"] = 0
 		},
 		NeedUID = true,
 		Clientside = false,
 		Do = function(prop, uid)
 			OPS_NPCS = OPS_NPCS or {}

 			if OPS_NPCS[uid] and IsValid(OPS_NPCS[uid]) then
 				OPS_NPCS[uid]:Remove()
 			end

 			OPS_NPCS[uid] = MakeHeadcrabCanister(
 				"models/props_combine/headcrabcannister01b.mdl",
 				prop["pos"],
 				Angle(prop["ang"].x, prop["ang"].y, prop["ang"].z),
 				nil,
 				nil,
 				nil,
 				nil,
 				prop["headcrabtype"],
 				prop["count"],
 				prop["speed"],
 				prop["time"],
 				nil,
 				prop["damage"],
 				prop["radius"],
 				prop["duration"],
 				nil,
 				prop["smoke"]
 			)

 			OPS_NPCS[uid]:Fire("FireCanister")
 		end
	},
	["thumper_spawn"] = {
		Cat = "npc",
		Prop = {
			["pos"] = Vector(0, 0, 0),
			["ang"] = Vector(0, 0, 0),
			["on"] = false,
			["isBig"] = false
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
 			OPS_NPCS = OPS_NPCS or {}

 			if OPS_NPCS[uid] and IsValid(OPS_NPCS[uid]) then
 				OPS_NPCS[uid]:Remove()
 			end

 			OPS_NPCS[uid] = ents.Create("prop_thumper")
 			OPS_NPCS[uid]:SetPos(prop["pos"])
 			OPS_NPCS[uid]:SetAngles(Angle(prop["ang"].x, prop["ang"].y, prop["ang"].z))

 			if prop["isBig"] then
 				OPS_NPCS[uid]:SetModel("models/props_combine/combinethumper001a.mdl")
 			end
 			
 			OPS_NPCS[uid]:Spawn()
 			OPS_NPCS[uid]:Activate()

 			if prop["on"] then
 				OPS_NPCS[uid]:Fire("Enable")
 			else
 				OPS_NPCS[uid]:Fire("Disable")
 			end

 			if prop["isBig"] then
 				OPS_NPCS[uid]:SetKeyValue("dustscale", 256)

 			else
 				OPS_NPCS[uid]:SetKeyValue("dustscale", 128)
 			end
		end
	},
	["thumper_setstate"] = {
		Cat = "npc",
		Prop = {
			["on"] = false
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
 			OPS_NPCS = OPS_NPCS or {}

 			if not OPS_NPCS[uid] or not IsValid(OPS_NPCS[uid]) then
 				return
 			end

 			if prop["on"] then
 				OPS_NPCS[uid]:Fire("Enable")
 			else
 				OPS_NPCS[uid]:Fire("Disable")
 			end
		end
	},
	["ai_disabled"] = {
		Cat = "npc",
		Prop = {
			["disabled"] = false
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			RunConsoleCommand("ai_disabled", (prop["disabled"] and "1" or "0"))
		end
	},
	["citycodeset"] = {
		Cat = "server",
		Prop = {
			["code"] = 1
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			impulse.Dispatch.SetCityCode(prop["code"])
			impulse.Dispatch.SetupCityCode(prop["code"])
		end
	},
	["voiceallowedset"] = {
		Cat = "server",
		Prop = {
			["allow_voice"] = true
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			if prop["allow_voice"] then
				hook.Remove("PlayerCanHearPlayersVoice", "opsEMBlockVoice")
			else
				hook.Add("PlayerCanHearPlayersVoice", "opsEMBlockVoice", function()
					return false, false
				end)
			end
		end
	},
	["createscene"] = {
		Cat = "scene",
		Prop = {
			["pos"] = Vector(0, 0, 0),
			["endpos"] = Vector(0, 0, 0),
			["ang"] = Vector(0, 0, 0),
			["endang"] = Vector(0, 0, 0),
			["posSpeed"] = 0.1,
			["posNoLerp"] = false,
			["fovNoLerp"] = false,
			["speed"] = 0.15,
			["fovFrom"] = 70,
			["fovTo"] = 70,
			["fovSpeed"] = 0.2,
			["text"] = "Optional text",
			["time"] = 6,
			["fadeIn"] = true,
			["fadeOut"] = true,
			["noHUDReEnable"] = false,
			["noHideProps"] = false,
			["hidePlayers"] = true
		},
		NeedUID = true,
		Clientside = true,
		Do = function(prop, uid)
			if not impulse.Ops.EventManager.Scenes then
				return
			end

			if prop["text"] == "" then
				prop["text"] = nil
			end

			prop["ang"] = Angle(prop["ang"].x, prop["ang"].y, prop["ang"].z)
			prop["endang"] = Angle(prop["endang"].x, prop["endang"].y, prop["endang"].z)
			
			impulse.Ops.EventManager.Scenes[uid] = {prop}
		end
	},
	["playscene"] = {
		Cat = "scene",
		Prop = {},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
			for v,k in pairs(player.GetAll()) do
				k:AllowScenePVSControl(true)
			end

			net.Start("impulseOpsEMPlayScene")
			net.WriteString(uid)
			net.Broadcast()
		end
	},
	["callhook_server"] = {
		Cat = "script",
		Prop = {
			["hook_name"] = ""
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			hook.Run(prop["hook_name"])
		end
	},
	["callhook_client"] = {
		Cat = "script",
		Prop = {
			["hook_name"] = ""
		},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			hook.Run(prop["hook_name"])
		end
	},
	["rtcamera_create"] = {
		Cat = "rtcamera",
		Prop = {
			["pos"] = Vector(0, 0, 0),
			["ang"] = Vector(0, 0, 0),
			["force_override"] = true
		},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
	 		OPS_RTCAMS = OPS_RTCAMS or {}

	 		if OPS_RTCAMS[uid] and IsValid(OPS_RTCAMS[uid]) then
	 			OPS_RTCAMS[uid]:Fire("SetOff")
	 			OPS_RTCAMS[uid]:Remove()
	 		end

	 		OPS_RTCAMS[uid] = ents.Create("point_camera")

	 		if prop["force_override"] then
	 			OPS_RTCAMS[uid]:SetKeyValue("GlobalOverride", 1)
	 		end

 			OPS_RTCAMS[uid]:SetPos(prop["pos"])
 			OPS_RTCAMS[uid]:SetAngles(Angle(prop["ang"].x, prop["ang"].y, prop["ang"].z))
 			OPS_RTCAMS[uid]:Spawn()
	 		OPS_RTCAMS[uid]:Activate()

	 		OPS_RTCAMS[uid]:Fire("SetOn")
		end
	},
	["rtcamera_remove"] = {
		Cat = "rtcamera",
		Prop = {},
		NeedUID = true,
		Clientside = false,
		Do = function(prop, uid)
	 		OPS_RTCAMS = OPS_RTCAMS or {}

	 		if OPS_RTCAMS[uid] and IsValid(OPS_RTCAMS[uid]) then
	 			OPS_RTCAMS[uid]:Fire("SetOff")
	 			OPS_RTCAMS[uid]:Remove()
	 		end
		end
	},
	["freezeplayers"] = {
		Cat = "server",
		Prop = {
			["freeze"] = true
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
	 		for v,k in pairs(player.GetAll()) do
	 			k:Freeze(prop["freeze"])
	 		end
		end
	},
	["lookat"] = {
		Cat = "server",
		Prop = {
			["pos"] = Vector(0, 0, 0),
			["speed"] = 1,
			["smooth"] = true
		},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			hook.Remove("Think", "opsEMSmoothLook")

			local t = prop["pos"]
			local o = LocalPlayer():GetShootPos()
			local oa = LocalPlayer():EyeAngles()
			local delta = (t - o):Angle()

			if prop["smooth"] then
				local x = 0
				hook.Add("Think", "opsEMSmoothLook", function()
					x = x + (FrameTime() * prop["speed"])
					local l = LerpAngle(x, oa, delta)

					LocalPlayer():SetEyeAngles(l)

					if x >= 1 then
						hook.Remove("Think", "opsEMSmoothLook")
					end
				end)
			else
				LocalPlayer():SetEyeAngles(delta)
			end
		end
	},
	["dnc_settime"] = {
		Cat = "server",
		Prop = {
			["time"] = 3600
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
	 		if DNCSetTime then
	 			DNCSetTime(prop["time"])
	 		end
		end
	},
	["colourcorrection"] = {
		Cat = "effect",
		Prop = {
			["brightness"] = 0,
			["contrast"] = 1,
			["colourlevel"] = 1,
			["mul_rgb"] = Color(0, 0, 0)
		},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			local fx = {
				["$pp_colour_addr"] = 0,
				["$pp_colour_addg"] = 0,
				["$pp_colour_addb"] = 0,
				["$pp_colour_brightness"] = prop["brightness"],
				["$pp_colour_contrast"] = prop["contrast"],
				["$pp_colour_colour"] = prop["colourlevel"],
				["$pp_colour_mulr"] = prop["mul_rgb"].r,
				["$pp_colour_mulg"] = prop["mul_rgb"].g,
				["$pp_colour_mulb"] = prop["mul_rgb"].b
			}

			hook.Add("RenderScreenspaceEffects", "opsEMSS", function()
				DrawColorModify(fx)
			end)
		end
	},
	["colourcorrection_kill"] = {
		Cat = "effect",
		Prop = {},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			hook.Remove("RenderScreenspaceEffects", "opsEMSS")
		end
	},
	["combinewaypoint"] = {
		Cat = "ui",
		Prop = {
			["message"] = "Waypoint message",
			["pos"] = Vector(0, 0, 0),
			["duration"] = 60,
			["iconid"] = 1,
			["colid"] = 1,
			["textcolid"] = 1
		},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			if LocalPlayer():IsCP() then
				impulse.AddCombineWaypoint(prop["message"], Vector(prop["pos"].x, prop["pos"].y, prop["pos"].z), prop["duration"], prop["iconid"], prop["colid"], prop["textcolid"])
			end
		end
	},
	["combinemessage"] = {
		Cat = "ui",
		Prop = {
			["message"] = "Message text here",
			["col"] = Color(255, 0, 0),
			["nosound"] = true
		},
		NeedUID = false,
		Clientside = true,
		Do = function(prop, uid)
			if LocalPlayer():IsCP() then
				impulse.AddCombineMessage(prop["message"], prop["col"], prop["nosound"])
			end
		end
	},
	["combineobjective"] = {
		Cat = "ui",
		Prop = {
			["message"] = "Message text here",
			["length"] = 20
		},
		NeedUID = false,
		Clientside = false,
		Do = function(prop, uid)
			local rf = RecipientFilter()

			rf:AddRecipientsByTeam(TEAM_CP)
			rf:AddRecipientsByTeam(TEAM_OTA)

			net.Start("impulseHL2RPObjectiveSendEvent")
			net.WriteString(prop["message"])
			net.WriteUInt(prop["length"], 8)
			net.Send(rf)
		end
	}
}
