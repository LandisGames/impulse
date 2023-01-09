util.AddNetworkString("opsUnderInvestigation")

hook.Add("iac.CheaterConvicted", "iacCheaterLog", function(steamid, code, caseInfo)
	for v,k in pairs(player.GetAll()) do
		if k:IsAdmin() then
			k:AddChatText(Color(255, 0, 0), "[IAC CONVICTION] "..steamid.." code: "..code)
		end
	end

	if not impulse.YML.apis.discord_iac_webhook then
		return
	end

	caseInfo = caseInfo or {}
	local evidence = ""
	for v,k in pairs(caseInfo) do
		if v == "detector" then
			continue
		end

		evidence = evidence.."**"..tostring(v).."**: `"..tostring(k).."`\n"
	end

    local embeds = {
        title = "IAC ban issued",
        description = "Evidence-based conviction.",
        url = "https://panel.impulse-community.com/index.php?t=admin_bans&id="..steamid,
        color = 16720932,
        fields = {
            {
                name = "User",
                value = steamid
            },
            {
                name = "Code",
                value = tostring(code)
            },
			{
				name = "Detector",
				value = caseInfo.detector or "Generic"
			},
            {
                name = "Evidence",
                value = string.sub(tostring(evidence), 1, 800)
            }
        }
    }

                    if reqwest then

                        if embeds then
                            embeds.timestamp = os.date("%Y-%m-%dT%H:%M:%S.000Z", os.time())
                            embeds.footer = {}
                            embeds.footer.text = "ops (GMT)"
                        end

                        reqwest({
                            method = "POST",
                            url = impulse.Config.ReqwestDiscordWebhookURL,
                            timeout = 30,
                            body = util.TableToJSON({ embeds = {embeds} }),
                            type = "application/json",
                            headers = { ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36" },
                            success = function(status, body, headers)
                                print("HTTP " .. status)
                                PrintTable(headers)
                                print(body)
                            end,
                            failed = function(err, errExt)
                                print("Error: " .. err .. " (" .. errExt .. ")")
                            end
                        })
                    else
                        opsDiscordLog(nil, embeds, impulse.YML.apis.discord_iac_webhook)
                    end
end)
