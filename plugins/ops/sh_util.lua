if SERVER then
    util.AddNetworkString("opsGiveWarn")
    util.AddNetworkString("opsGetRecord")
end


local setHealthCommand = {
    description = "Sets health of the specified player.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local targ = impulse.FindPlayer(arg[1])
        local hp = arg[2]

        if not hp or not tonumber(hp) then
            return
        end

        if not ply:IsLeadAdmin() then
            hp = math.Clamp(hp, 1, 100)
        end


        if targ and IsValid(targ) then
            targ:SetHealth(hp)
            ply:Notify("You have set "..targ:Nick().."'s health to "..hp..".")

            if targ == ply then
                for v,k in pairs(player.GetAll()) do
                    if k:IsLeadAdmin() then
                        k:AddChatText(Color(135, 206, 235), "[ops] Moderator "..ply:SteamName().." set their health to "..hp..".")
                    end
                end
            end
        else
            return ply:Notify("Could not find player: "..tostring(arg[1]))
        end
    end
}

impulse.RegisterChatCommand("/sethp", setHealthCommand)

local kickCommand = {
    description = "Kicks the specified player from the server.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local name = arg[1]
        local plyTarget = impulse.FindPlayer(name)

        local reason = ""

        for v,k in pairs(arg) do
            if v != 1 then
                reason = reason.." "..k
            end
        end

        reason = string.Trim(reason)

        if reason == "" then reason = nil end

        if plyTarget and ply != plyTarget then
            ply:Notify("You have kicked "..plyTarget:Name().." from the server.")
            plyTarget:Kick(reason or "Kicked by a game moderator.")
        else
            return ply:Notify("Could not find player: "..tostring(name))
        end
    end
}

impulse.RegisterChatCommand("/kick", kickCommand)


if GExtension then
    local banCommand = {
        description = "Bans the specified player from the server. (time in minutes)",
        requiresArg = true,
        adminOnly = true,
        onRun = function(ply, arg, rawText)
            local name = arg[1]
            local plyTarget = impulse.FindPlayer(name)

            local time = arg[2]

            if not time or not tonumber(time) then
                return ply:Notify("No time value supplied.")
            end

            time = tonumber(time)

            if time < 0 then
                return ply:Notify("Negative time values are not allowed.")
            end

            local reason = ""

            for v,k in pairs(arg) do
                if v > 2 then
                    reason = reason.." "..k
                end
            end

            reason = string.Trim(reason)

            if plyTarget and ply != plyTarget then
                if ply:GE_CanBan(plyTarget:SteamID64(), time) then
                    if plyTarget:IsSuperAdmin() then
                        return ply:Notify("You can not ban this user.")
                    end
                    
                    plyTarget:GE_Ban(time, reason, ply:SteamID64())
                    ply:Notify("You have banned "..plyTarget:SteamName().." for "..time.." minutes.")

                    local steamid = plyTarget:SteamID64()
                    local embeds = {
                        title = "Manual ban issued",
                        description = "User was banned by a staff member.",
                        url = "https://panel.impulse-community.com/index.php?t=admin_bans&id="..steamid,
                        color = 8801791,
                        fields = {
                            {
                                name = "User",
                                value = "**"..plyTarget:SteamName().."** ("..steamid..") ("..plyTarget:Nick()..")"
                            },
                            {
                                name = "Moderator",
                                value = "**"..ply:SteamName().."** ("..ply:SteamID64()..")"
                            },
                            {
                                name = "Reason",
                                value = reason
                            },
                            {
                                name = "Length",
                                value = string.NiceTime(time * 60).." ("..time.." minutes)"
                            }
                        }
                    }
                    
                    opsDiscordLog(nil, embeds)
                else
                    ply:Notify("This user can not be banned.")
                end
            else
                return ply:Notify("Could not find player: "..tostring(name))
            end
        end
    }

    impulse.RegisterChatCommand("/ban", banCommand)

    local warnCommand = {
        description = "Warns the specified player (reason is required).",
        requiresArg = true,
        adminOnly = true,
        onRun = function(ply, arg, rawText)
            local name = arg[1]
            local plyTarget = impulse.FindPlayer(name)
            local reason = ""

            for v,k in pairs(arg) do
                if v > 1 then
                    reason = reason.." "..k
                end
            end

            reason = string.Trim(reason)

            if reason == "" then
                return ply:Notify("No reason provided.")
            end

            if plyTarget and ply != plyTarget then
                if not ply:GE_HasPermission("warnings_add") then 
                    return ply:Notify("You don't have permission do this.")
                end
                
                GExtension:Warn(plyTarget:SteamID64(), reason, ply:SteamID64())
                ply:Notify("You have warned "..plyTarget:SteamName().." for "..reason..".")

                net.Start("opsGiveWarn")
                net.WriteString(reason)
                net.Send(plyTarget)

            	local steamid = plyTarget:SteamID64()
                local embeds = {
                    title = "Warning issued",
                    description = "User was warned by a staff member.",
                    url = "https://panel.impulse-community.com/index.php?t=admin_warnings&id="..steamid,
                    color = 16774400,
                    fields = {
                        {
                            name = "User",
                            value = "**"..plyTarget:SteamName().."** ("..steamid..") ("..plyTarget:Nick()..")"
                        },
                        {
                            name = "Moderator",
                            value = "**"..ply:SteamName().."** ("..ply:SteamID64()..")"
                        },
                        {
                            name = "Reason",
                            value = reason
                        }
                    }
                }
                
                opsDiscordLog(nil, embeds)
            else
                return ply:Notify("Could not find player: "..tostring(name))
            end
        end
    }

    impulse.RegisterChatCommand("/warn", warnCommand)
end