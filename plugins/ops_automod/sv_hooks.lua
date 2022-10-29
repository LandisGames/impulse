function PLUGIN:PlayerDeath(victim, inflictor, attacker)
    if not IsValid(victim) or not IsValid(attacker) then
        return
    end

    local inflictor = (IsValid(attacker) and attacker.GetActiveWeapon) and attacker:GetActiveWeapon() or nil

    if not IsValid(inflictor) or not inflictor.IsWeapon or not inflictor:IsWeapon() then
        return
    end

    if attacker.AutoModKillCooldown and attacker.AutoModKillCooldown < CurTime() - impulse.Config.AutoModCooldown then
        attacker.AutoModRisk = 0
        attacker.AutoModLog = {}
        attacker.AutoModKillCooldown = nil
    end

    if attacker.AutoModKillCooldown and attacker.AutoModKillCooldown > CurTime() - 0.5 then
        return
    end

    attacker.AutoModKillCooldown = CurTime()

    if (attacker:Team() == victim:Team()) or (victim:IsCP() and attacker:IsCP()) then
        attacker.AutoModRisk = (attacker.AutoModRisk or 0) + 4.5
        attacker:AutoModLogAdd("User killed teammate "..victim:Nick())
    else
        attacker.AutoModRisk = (attacker.AutoModRisk or 0) + 0.6
        attacker:AutoModLogAdd("User killed "..victim:Nick())
    end

    local risk = attacker.AutoModRisk or 0
    if attacker:IsDonator() then -- donators and be trusted more
        risk = risk - 7
    end

    local adminCount = 0
    for v,k in pairs(player.GetAll()) do
        if k:IsAdmin() then
            adminCount = adminCount + 1
        end
    end

    if adminCount == 0 then -- no staff on will increase risk
        risk = risk * 1.2
    end

    if attacker:GetXP() < 600 then
        risk = risk * 1.2
    end

    if attacker:IsAdmin() then
        risk = 0
    end

    if risk >= impulse.Config.AutoModMaxRisk then
        impulse.Ops.AutoMod.Ban(attacker, "Mass RDM", tostring(math.Round(risk, 1)), attacker:AutoModLogGet())
    end
end