impulse.Ops = impulse.Ops or {}
impulse.Ops.AutoMod = impulse.Ops.AutoMod or {}


function impulse.Ops.AutoMod.Ban(ply, reason, risk, details)
    local steamid = ply:SteamID64()

    for v,k in pairs(player.GetAll()) do
        if k:IsAdmin() then
            k:AddChatText(Color(0, 163, 118), "[AutoMod] "..steamid.." issued ban for suspected "..reason.." (risk score "..risk..")")
        end
    end

    if GExtension then
        GExtension:AddBan(ply:SteamID64(), 0, "AutoMod ban for suspected "..reason..". Appeal @ impulse-community.com for review.", "0", GExtension:CurrentTime(), function()
            GExtension:InitBans()
        end)
    end

    local embeds = {
        title = "AutoMod ban issued",
        description = "User was identified as high risk by the automated moderator.\n<@&"..impulse.Config.DiscordLeadModRoleID.."> please investigate and review.",
        url = "https://panel.impulse-community.com/index.php?t=admin_bans&id="..ply:SteamID64(),
        color = 7774976,
        fields = {
            {
                name = "User",
                value = "**"..ply:SteamName().."** ("..ply:SteamID64()..") ("..ply:Nick()..")"
            },
            {
                name = "Risk Score",
                value = risk or 0
            },
            {
                name = "Reason",
                value = reason
            },
            {
                name = "Details",
                value = "```"..string.sub(details, 1, 1000).."```"
            }
        }
    }

	if IsValid(ply) then
		ply:Kick("Automatic punishment issued")
	end

    opsDiscordLog("<@&"..impulse.Config.DiscordLeadModRoleID..">", embeds)
end

function meta:AutoModLogAdd(msg)
    self.AutoModLog = self.AutoModLog or {}

    table.insert(self.AutoModLog, "["..os.date("%H:%M:%S", os.time()).."] "..msg)
end

function meta:AutoModLogGet()
    local o = ""
    for v,k in pairs(self.AutoModLog or {}) do
        o = o.."\n"..k
    end

    return o
end