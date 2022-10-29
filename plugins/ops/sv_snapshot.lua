util.AddNetworkString("opsSnapshot")

hook.Add("PlayerDeath", "opsDeathSnapshot", function(victim, attacker, inflictor)
	if not victim:IsPlayer() or not inflictor:IsPlayer() then
		return
	end

	local snapshot = {}

	snapshot.Victim = victim
	snapshot.VictimID = victim:SteamID()
	snapshot.VictimNick = victim:Nick()
	snapshot.VictimPos = victim:GetPos()
	snapshot.VictimLastPos = victim.LastKnownPos or snapshot.VictimPos
	snapshot.VictimAng = victim:GetAngles()
	snapshot.VictimEyeAng = victim:EyeAngles()
	snapshot.VictimModel = victim:GetModel()
	snapshot.VictimHitGroup = victim:LastHitGroup()
	snapshot.VictimBodygroups = {}

	for v,k in pairs(victim:GetBodyGroups()) do
		snapshot.VictimBodygroups[k.id] = victim:GetBodygroup(k.id)
	end

	snapshot.Inflictor = inflictor
	snapshot.InflictorID = inflictor:SteamID()
	snapshot.InflictorNick = inflictor:Nick()
	snapshot.InflictorPos = inflictor:GetPos()
	snapshot.InflictorLastPos = inflictor.LastKnownPos or snapshot.InflictorPos
	snapshot.InflictorAng = inflictor:GetAngles()
	snapshot.InflictorEyePos = inflictor:EyePos()
	snapshot.InflictorEyeAng = inflictor:EyeAngles()
	snapshot.InflictorModel = inflictor:GetModel()
	snapshot.InflictorHealth = inflictor:Health()
	snapshot.InflictorBodygroups = {}

	for v,k in pairs(inflictor:GetBodyGroups()) do
		snapshot.InflictorBodygroups[k.id] = inflictor:GetBodygroup(k.id)
	end

	if attacker:IsPlayer() then
		snapshot.AttackerClass = IsValid(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon():GetClass() or 'unknown'
	else
		snapshot.AttackerClass = "non player ent"
	end

	local snapshotsCount = #impulse.Ops.Snapshots + 1
	impulse.Ops.Snapshots[snapshotsCount] = snapshot

	victim.LastSnapshotID = snapshotsCount
	inflictor.LastSnapshotID = snapshotsCount

	hook.Run("PlayerDeathPostSnapshot", victim, attacker, inflictor)
end)