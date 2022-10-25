--- Functions to control a player's animations, based heavily on nutscript's Anim system
-- @module Anim

-- this animation system is HEAVILY based on nutscripts system with partial recodes or changes to suit impulse.
-- i claim no credit for this
-- check out NS at https://github.com/rebel1324/NutScript/

impulse.Anim = impulse.Anim or {}
impulse.Anim.citizen_male = {
	normal = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED}
	},
	pistol = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_RANGE_ATTACK_PISTOL},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_ATTACK_PISTOL_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_RELOAD_PISTOL
	},
	smg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	ar2 = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	shotgun = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
	},
	grenade = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_RIFLE_STIMULATED},
		attack = ACT_RANGE_ATTACK_THROW
	},
	melee = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_MELEE},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
		attack = ACT_MELEE_ATTACK_SWING
	},
	glide = ACT_GLIDE,
	vehicle = {
		["prop_vehicle_prisoner_pod"] = {"podpose", Vector(-3, 0, 0)},
		["prop_vehicle_jeep"] = {ACT_BUSY_SIT_CHAIR, Vector(14, 0, -14)},
		["prop_vehicle_airboat"] = {ACT_BUSY_SIT_CHAIR, Vector(8, 0, -20)},
		chair = {ACT_BUSY_SIT_CHAIR, Vector(1, 0, -23)}
	},
}

impulse.Anim.citizen_female = {
	normal = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED}
	},
	pistol = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_PISTOL},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_PISTOL},
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_RELOAD_PISTOL
	},
	smg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	ar2 = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	shotgun = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
	},
	grenade = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_PISTOL},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_PISTOL},
		attack = ACT_RANGE_ATTACK_THROW
	},
	melee = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
		attack = ACT_MELEE_ATTACK_SWING
	},
	glide = ACT_GLIDE,
	vehicle = impulse.Anim.citizen_male.vehicle
}
impulse.Anim.metrocop = {
	normal = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN}
	},
	pistol = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW},
		[ACT_MP_WALK] = {ACT_WALK_PISTOL, ACT_WALK_AIM_PISTOL},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN_PISTOL, ACT_RUN_AIM_PISTOL},
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_GESTURE_RELOAD_PISTOL
	},
	smg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	ar2 = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	shotgun = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	grenade = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_MELEE},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_ANGRY},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
		attack = ACT_COMBINE_THROW_GRENADE
	},
	melee = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_MELEE},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_ANGRY},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
		attack = ACT_MELEE_ATTACK_SWING_GESTURE
	},
	glide = ACT_GLIDE,
	vehicle = {
		chair = {ACT_COVER_PISTOL_LOW, Vector(5, 0, -5)},
		["prop_vehicle_airboat"] = {ACT_COVER_PISTOL_LOW, Vector(10, 0, 0)},
		["prop_vehicle_jeep"] = {ACT_COVER_PISTOL_LOW, Vector(18, -2, 4)},
		["prop_vehicle_prisoner_pod"] = {ACT_IDLE, Vector(-4, -0.5, 0)}
	}
}
impulse.Anim.overwatch = {
	normal = {
		[ACT_MP_STAND_IDLE] = {"idle_unarmed", "idle_unarmed"},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {"walkunarmed_all", "walkunarmed_all"},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	pistol = {
		[ACT_MP_STAND_IDLE] = {"idle_unarmed", ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {"walkunarmed_all", ACT_WALK_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	smg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	ar2 = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	shotgun = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SHOTGUN},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_SHOTGUN},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_SHOTGUN}
	},
	grenade = {
		[ACT_MP_STAND_IDLE] = {"idle_unarmed", ACT_IDLE_ANGRY},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {"walkunarmed_all", ACT_WALK_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	melee = {
		[ACT_MP_STAND_IDLE] = {"idle_unarmed", ACT_IDLE_ANGRY},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {"walkunarmed_all", ACT_WALK_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE},
		attack = ACT_MELEE_ATTACK_SWING_GESTURE
	},
	glide = ACT_GLIDE,
	vehicle = {
		chair = {ACT_CROUCHIDLE, Vector(5, 0, -5)},
		["prop_vehicle_airboat"] = {ACT_CROUCHIDLE, Vector(10, 0, 0)},
		["prop_vehicle_jeep"] = {ACT_CROUCHIDLE, Vector(18, -2, 4)},
		["prop_vehicle_prisoner_pod"] = {"idle_unarmed", Vector(-4, -0.5, 0)}
	}
}
impulse.Anim.vort = {
	normal = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN}
	},
	pistol = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN}
	},
	smg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN}
	},
	ar2 = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN}
	},
	shotgun = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN}
	},
	grenade = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN}
	},
	melee = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, "sweep_idle"},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, "walk_all_holdbroom"},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdbroom"},
		[ACT_MP_RUN] = {ACT_RUN, "walk_all_holdbroom"}
	},
	glide = ACT_GLIDE
}
impulse.Anim.player = {
	normal = {
		[ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE,
		[ACT_MP_CROUCH_IDLE] = ACT_HL2MP_IDLE_CROUCH,
		[ACT_MP_WALK] = ACT_HL2MP_WALK,
		[ACT_MP_RUN] = ACT_HL2MP_RUN
	},
	passive = {
		[ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE_PASSIVE,
		[ACT_MP_WALK] = ACT_HL2MP_WALK_PASSIVE,
		[ACT_MP_CROUCHWALK] = ACT_HL2MP_WALK_CROUCH_PASSIVE,
		[ACT_MP_RUN] = ACT_HL2MP_RUN_PASSIVE
	}
}
impulse.Anim.zombie = {
	normal = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_RUN] = {ACT_WALK, ACT_WALK},
		attack = ACT_MELEE_ATTACK1
	},
	grenade = {
		[ACT_MP_STAND_IDLE] = {"idle_grenade", "idle_grenade"},
		[ACT_MP_CROUCH_IDLE] = {"idle_grenade", "idle_grenade"},
		[ACT_MP_WALK] = {"walk_all_grenade", "walk_all_grenade"},
		[ACT_MP_CROUCHWALK] = {"walk_all_grenade", "walk_all_grenade"},
		[ACT_MP_RUN] = {"run_all_grenade", "run_all_grenade"},
		attack = ACT_MELEE_ATTACK1
	}
}
impulse.Anim.zombie.melee = impulse.Anim.zombie.normal

impulse.Anim.fastZombie = {
	[ACT_MP_STAND_IDLE] = ACT_HL2MP_WALK_ZOMBIE,
	[ACT_MP_CROUCH_IDLE] = ACT_HL2MP_IDLE_CROUCH_ZOMBIE,
	[ACT_MP_CROUCHWALK] = ACT_HL2MP_WALK_CROUCH_ZOMBIE_05,
	[ACT_MP_WALK] = ACT_HL2MP_WALK_ZOMBIE_06,
	[ACT_MP_RUN] = ACT_HL2MP_RUN_ZOMBIE_FAST
}

--- A collection of default animation classes
-- @realm shared
-- @field citizen_male
-- @field citizen_female
-- @field metrocop
-- @field overwatch
-- @field vort
-- @field player
-- @field zombie
-- @field fastZombie
-- @table DefaultAnimClasses


local translations = translations or {}

--- Sets the animation class of a specific model
-- @realm shared
-- @string model The model to set
-- @string class The animation class
-- @see DefaultAnimClasses
function impulse.Anim.SetModelClass(model, class)
	if not impulse.Anim[class] then
		error("'"..tostring(class).."' is not a valid animation class!")
	end
	
	translations[model:lower()] = class
end

-- Micro-optimization since the get class function gets called a lot.
local stringLower = string.lower
local stringFind = string.find

--- Gets the animation class of a specific model
-- @realm shared
-- @string model The model
-- @treturn string Animation class
function impulse.Anim.GetModelClass(model)
	model = stringLower(model)
	local class = translations[model]

	class = class or "player"
	
	return class
end

impulse.Anim.SetModelClass("models/police.mdl", "metrocop")
impulse.Anim.SetModelClass("models/dpfilms/metropolice/hdpolice.mdl", "metrocop")
impulse.Anim.SetModelClass("models/dpfilms/metropolice/civil_medic.mdl", "metrocop")
impulse.Anim.SetModelClass("models/dpfilms/metropolice/hl2beta_police.mdl", "metrocop")
impulse.Anim.SetModelClass("models/dpfilms/metropolice/retrocop.mdl", "metrocop")
impulse.Anim.SetModelClass("models/dpfilms/metropolice/elite_police.mdl", "metrocop")
impulse.Anim.SetModelClass("models/dpfilms/metropolice/policetrench.mdl", "metrocop")
impulse.Anim.SetModelClass("models/dpfilms/metropolice/hl2concept.mdl", "metrocop")
impulse.Anim.SetModelClass("models/combine_super_soldier.mdl", "overwatch")
impulse.Anim.SetModelClass("models/combine_soldier_prisonGuard.mdl", "overwatch")
impulse.Anim.SetModelClass("models/combine_soldier.mdl", "overwatch")
impulse.Anim.SetModelClass("models/vortigaunt.mdl", "vort")
impulse.Anim.SetModelClass("models/vortigaunt_blue.mdl", "vort")
impulse.Anim.SetModelClass("models/vortigaunt_doctor.mdl", "vort")
impulse.Anim.SetModelClass("models/vortigaunt_slave.mdl", "vort")
impulse.Anim.SetModelClass("models/vortiblue1.mdl", "vort")
impulse.Anim.SetModelClass("models/dpfilms/metropolice/police_fragger.mdl", "metrocop")
impulse.Anim.SetModelClass("models/dpfilms/metropolice/zombie_police.mdl", "zombie")
impulse.Anim.SetModelClass("models/zombie/classic.mdl", "zombie")
impulse.Anim.SetModelClass("models/zombie/zombie_soldier.mdl", "zombie")

--impulse.Anim.SetModelClass("models/breen.mdl", "player")
--impulse.Anim.SetModelClass("models/nicrobe/gallahan.mdl", "player")

hook.Run("LoadAnimationClasses")

local ALWAYS_RAISED = {}
ALWAYS_RAISED["weapon_physgun"] = true
ALWAYS_RAISED["gmod_tool"] = true

do
	--- Plays an animation sequence on a player
	-- @realm server
    -- @string sequence The sequence name
    -- @func[opt] callback Called when the animation is completed
    -- @int[opt] time How long until we force the sequence to stop
    -- @bool[opt=false] noFreeze If the player should not freeze when the sequence is playing
	function meta:ForceSequence(sequence, callback, time, noFreeze)
		hook.Run("OnPlayerEnterSequence", self, sequence, callback, time, noFreeze)

		if not sequence then
			net.Start("impulseSeqSet")
			net.WriteEntity(self)
			net.WriteBool(true)
			net.WriteUInt(0, 16)
			net.Broadcast()
			--return netstream.Start(nil, "seqSet", self)
		end

		local sequence = self:LookupSequence(sequence)

		if sequence and sequence > 0 then
			time = time or self:SequenceDuration(sequence)

			self.impulseSeqCallback = callback
			self.impulseForceSeq = sequence

			if not noFreeze then
				self:SetMoveType(MOVETYPE_NONE)
			end

			if time > 0 then
				timer.Create("impulseSeq"..self:EntIndex(), time, 1, function()
					if IsValid(self) then
						self:leaveSequence()
					end
				end)
			end

			net.Start("impulseSeqSet")
			net.WriteEntity(self)
			net.WriteBool(false)
			net.WriteUInt(sequence, 16)
			net.Broadcast()

			return time
		end

		return false
	end

	function meta:leaveSequence()
		hook.Run("OnPlayerLeaveSequence", self)

		net.Start("impulseSeqSet")
		net.WriteEntity(self)
		net.WriteBool(true)
		net.WriteUInt(0, 16)
		net.Broadcast()

		self:SetMoveType(MOVETYPE_WALK)
		self.impulseForceSeq = nil

		if self.impulseSeqCallback then
			self:impulseSeqCallback()
		end
	end

	function meta:IsWeaponRaised()
		local weapon = self.GetActiveWeapon(self)

		if IsValid(weapon) then
			if weapon.IsAlwaysRaised or ALWAYS_RAISED[weapon.GetClass(weapon)] then
				return true
			elseif weapon.IsAlwaysLowered then
				return false
			end
		end

		return self.GetSyncVar(self, SYNC_WEPRAISED, false)
	end

	if SERVER then
		util.AddNetworkString("impulseSeqSet")
		
		function meta:SetWeaponRaised(state)
			self:SetSyncVar(SYNC_WEPRAISED, state, true)

			local weapon = self:GetActiveWeapon()

			if IsValid(weapon) then
				weapon:SetNextPrimaryFire(CurTime() + 1)
				weapon:SetNextSecondaryFire(CurTime() + 1)

				if weapon.OnLowered then
					weapon.OnLowered(weapon)
				end
			end
		end

		function meta:ToggleWeaponRaised()
			self:SetWeaponRaised(!self:IsWeaponRaised())
		end
	end

	if CLIENT then
		net.Receive("impulseSeqSet", function()
			local ent = net.ReadEntity()
			local reset = net.ReadBool()
			local sequence = net.ReadUInt(16)

			if IsValid(ent) then
				if reset then
					ent.impulseForceSeq = nil
					return
				end

				ent:SetCycle(0)
				ent:SetPlaybackRate(1)
				ent.impulseForceSeq = sequence
			end
		end)
	end
end

HOLDTYPE_TRANSLATOR = {}
HOLDTYPE_TRANSLATOR[""] = "normal"
HOLDTYPE_TRANSLATOR["physgun"] = "smg"
HOLDTYPE_TRANSLATOR["crossbow"] = "shotgun"
HOLDTYPE_TRANSLATOR["rpg"] = "shotgun"
HOLDTYPE_TRANSLATOR["slam"] = "normal"
HOLDTYPE_TRANSLATOR["grenade"] = "grenade"
HOLDTYPE_TRANSLATOR["fist"] = "normal"
HOLDTYPE_TRANSLATOR["melee2"] = "melee"
HOLDTYPE_TRANSLATOR["passive"] = "normal"
HOLDTYPE_TRANSLATOR["knife"] = "melee"
HOLDTYPE_TRANSLATOR["duel"] = "pistol"
HOLDTYPE_TRANSLATOR["camera"] = "smg"
HOLDTYPE_TRANSLATOR["magic"] = "normal"
HOLDTYPE_TRANSLATOR["revolver"] = "pistol"

PLAYER_HOLDTYPE_TRANSLATOR = {}
PLAYER_HOLDTYPE_TRANSLATOR[""] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["fist"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["pistol"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["grenade"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["melee"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["slam"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["melee2"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["passive"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["knife"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["duel"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["bugbait"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["pistol"] = "normal"
PLAYER_HOLDTYPE_TRANSLATOR["revolver"] = "normal"

local getModelClass = impulse.Anim.GetModelClass
local IsValid = IsValid
local string  = string
local type = type

local PLAYER_HOLDTYPE_TRANSLATOR = PLAYER_HOLDTYPE_TRANSLATOR
local HOLDTYPE_TRANSLATOR = HOLDTYPE_TRANSLATOR

function GM:TranslateActivity(ply, act)
	local model = string.lower(ply.GetModel(ply))
	local class = getModelClass(model) or "player"
	local weapon = ply.GetActiveWeapon(ply)

	if class == "player" then
		if IsValid(weapon) and not ply.IsWeaponRaised(ply) and ply.OnGround(ply) then
			local holdType = IsValid(weapon) and (weapon.HoldType or weapon.GetHoldType(weapon)) or "normal"
			if not ply.IsWeaponRaised(ply) and ply.OnGround(ply) then
				holdType = PLAYER_HOLDTYPE_TRANSLATOR[holdType] or "passive"
			end

			local animTree = impulse.Anim.player[holdType]

			if animTree and animTree[act] then
				if type(animTree[act]) == "string" then
					ply.CalcSeqOverride = ply.LookupSequence(ply, animTree[act])
					return
				else
					return animTree[act]
				end
			end
		end
		return self.BaseClass.TranslateActivity(self.BaseClass, ply, act)
	end

	local animTree = impulse.Anim[class]

	if animTree then
		local subClass = "normal"
		if ply.InVehicle(ply) then
			local vehicle = ply.GetVehicle(ply)
			local class = vehicle:IsChair() and "chair" or vehicle:GetClass()

			if animTree.vehicle and animTree.vehicle[class] then
				local act = animTree.vehicle[class][1]
				local fixvec = animTree.vehicle[class][2]

				if fixvec then
					ply:SetLocalPos(fixvec)
				end

				if type(act) == "string" then
					ply.CalcSeqOverride = ply.LookupSequence(ply, act)

					return
				else
					return act
				end
			else
				act = animTree.normal[ACT_MP_CROUCH_IDLE][1]

				if type(act) == "string" then
					ply.CalcSeqOverride = ply:LookupSequence(act)
				end
				return
			end
		elseif ply.OnGround(ply) then
			ply.ManipulateBonePosition(ply, 0, vector_origin)

			if IsValid(weapon) then
				subClass = weapon.HoldType or weapon.GetHoldType(weapon)
				subClass = HOLDTYPE_TRANSLATOR[subClass] or subClass
			end

			if animTree[subClass] and animTree[subClass][act] then
				local act2 = animTree[subClass][act][ply:IsWeaponRaised() and 2 or 1]

				if type(act2) == "string" then
					ply.CalcSeqOverride = ply.LookupSequence(ply, act2)
					return
				end
				return act2
			end
		elseif animTree.glide then
			return animTree.glide
		end
	end
end

local vectorAngle = FindMetaTable("Vector").Angle
local normalizeAngle = math.NormalizeAngle

function GM:CalcMainActivity(ply, velocity)
	local eyeAngles = ply.EyeAngles(ply)
	local yaw = vectorAngle(velocity)[2]
	local normalized = normalizeAngle(yaw - eyeAngles[2])

	ply.SetPoseParameter(ply, "move_yaw", normalized)

	if CLIENT then
		ply.SetIK(ply, false)
	end

	local oldSeqOverride = ply.CalcSeqOverride
	local seqIdeal, seqOverride = self.BaseClass.CalcMainActivity(self.BaseClass, ply, velocity)

	return seqIdeal, ply.impulseForceSeq or oldSeqOverride or ply.CalcSeqOverride
end

function GM:DoAnimationEvent(ply, event, data)
	local model = ply:GetModel():lower()
	local class = impulse.Anim.GetModelClass(model)

	if class == "player" then
		return self.BaseClass:DoAnimationEvent(ply, event, data)
	else
		local weapon = ply:GetActiveWeapon()

		if IsValid(weapon) then
			local holdType = weapon.HoldType or weapon:GetHoldType()
			holdType = HOLDTYPE_TRANSLATOR[holdType] or holdType

			local animation = impulse.Anim[class][holdType]

			if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
				ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.attack or ACT_GESTURE_RANGE_ATTACK_SMG1, true)
				return ACT_VM_PRIMARYATTACK
			elseif event == PLAYERANIMEVENT_ATTACK_SECONDARY then
				ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.attack or ACT_GESTURE_RANGE_ATTACK_SMG1, true)
				return ACT_VM_SECONDARYATTACK
			elseif event == PLAYERANIMEVENT_RELOAD then
				ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.reload or ACT_GESTURE_RELOAD_SMG1, true)
				return ACT_INVALID
			elseif event == PLAYERANIMEVENT_JUMP then
				ply.m_bJumping = true
				ply.m_bFirstJumpFrame = true
				ply.m_flJumpStartTime = CurTime()
				ply:AnimRestartMainSequence()
				return ACT_INVALID
			elseif event == PLAYERANIMEVENT_CANCEL_RELOAD then
				ply:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)
				return ACT_INVALID
			end
		end
	end
	return ACT_INVALID
end