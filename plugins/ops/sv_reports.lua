impulse.Ops = impulse.Ops or {}
impulse.Ops.Reports = impulse.Ops.Reports or {}

local newReportCol = Color(173, 255, 47)
local claimedReportCol = Color(147, 112, 219)

file.CreateDir("impulse/ops")

util.AddNetworkString("opsNewReport")
util.AddNetworkString("opsReportMessage")
util.AddNetworkString("opsReportUpdate")
util.AddNetworkString("opsReportClaimed")
util.AddNetworkString("opsReportClosed")
util.AddNetworkString("opsReportAdminMessage")
util.AddNetworkString("opsReportSync")
util.AddNetworkString("opsReportDaleRepliedDo")
util.AddNetworkString("opsReportDaleReplied")
util.AddNetworkString("opsReportDaleClose")

function impulse.Ops.ReportNew(ply, arg, rawText)
	if ply.nextReport and ply.nextReport > CurTime() then
        return 
    end

    if string.len(rawText) > 600 then
        return ply:Notify("Your message is too big. (600 characters max.)")    
    end

    local reportId

    local hasActiveReport = false
    for id, data in pairs(impulse.Ops.Reports) do
        if data[1] == ply then
            hasActiveReport = true
            reportId = id
            break
        end
    end

    if hasActiveReport == false then
        reportId = nil

        for v,k in pairs(player.GetAll()) do
            if k:IsAdmin() then
                reportId = reportId or table.insert(impulse.Ops.Reports, {ply, rawText, nil, CurTime()})

                net.Start("opsNewReport")
                net.WriteEntity(ply)
                net.WriteUInt(reportId, 16)
                net.WriteString(rawText)
                net.Send(k)
            end
        end
        if reportId then
            net.Start("opsReportMessage")
            net.WriteUInt(reportId, 16)
            net.WriteUInt(1, 4)
            net.Send(ply)

            opsSlackLog(":warning: *[NEW REPORT]* [#"..reportId.."] ".. ply:SteamName().. " (".. ply:Name().. ") ("..ply:SteamID().."): ```"..rawText.."```")
            return
        else
            ply:Notify("Unfortunately, no game moderators are currently available to review your report. Please goto impulse-community.com and submit a ban request.")
            opsSlackLog(":exclamation: *A user is requesting help but no moderators are online!* Report: ```".. rawText.."```")
        end
    else
        if string.len(impulse.Ops.Reports[reportId][2]) > 3000 then
            return ply:Notify("Your report has too many characters. You may not send any more updates for this report.")    
        end

        local reportClaimant = impulse.Ops.Reports[reportId][3]

        for v,k in pairs(player.GetAll()) do
            if k:IsAdmin() then
                net.Start("opsReportUpdate")
                net.WriteEntity(ply)
                net.WriteUInt(reportId, 16)
                net.WriteString(rawText)
                net.Send(k)
            end
        end

        impulse.Ops.Reports[reportId][2] = impulse.Ops.Reports[reportId][2].." + "..rawText
        opsSlackLog(":speech_balloon: *[REPORT UPDATE]* [#"..reportId.."] ".. ply:SteamName().. " (".. ply:Name().. ") ("..ply:SteamID().."): ```".. rawText.."```")

        net.Start("opsReportMessage")
        net.WriteUInt(reportId, 16)
        net.WriteUInt(2, 4)
        net.Send(ply)
    end
    ply.nextReport = CurTime() + 2
end

function impulse.Ops.ReportClaim(ply, arg, rawText)
    local reportId = tonumber(arg[1])
    local targetReport = impulse.Ops.Reports[reportId]

    if targetReport then
        local reporter = targetReport[1]
        local reportMessage = targetReport[2]
        local reportClaimant = targetReport[3]
        local reportStartTime = targetReport[4]

        if targetReport[3] and IsValid(targetReport[3]) then
            return ply:AddChatText(newReportCol, "Report #"..reportId.." has already been claimed by "..targetReport[3]:SteamName())
        end

        if not IsValid(reporter) then
            return ply:AddChatText(newReportCol, "The player who submitted this report has left the game. Please close.")
        end

        local hasClaimedReport

        for id, data in pairs(impulse.Ops.Reports) do
            if data[3] and data[3] == ply then
                hasClaimedReport = id
                break
            end
        end

        if hasClaimedReport then
            return ply:AddChatText(newReportCol, "You already have a claimed report in progress. Current report #"..hasClaimedReport)
        end

        impulse.Ops.Reports[reportId] = {reporter, reportMessage, ply, reportStartTime, CurTime()}

        for v,k in pairs(player.GetAll()) do
            if k:IsAdmin() then
                net.Start("opsReportClaimed")
                net.WriteEntity(ply)
                net.WriteUInt(reportId, 16)
                net.Send(k)
            end
        end
        opsSlackLog(":passport_control: *[REPORT CLAIMED]* [#"..reportId.."] claimed by "..ply:SteamName().." ("..ply:SteamID()..")")

        net.Start("opsReportMessage")
        net.WriteUInt(reportId, 16)
        net.WriteUInt(3, 4)
        net.WriteEntity(ply)
        net.Send(reporter)
    else
        ply:AddChatText(claimedReportCol, "Report #"..arg[1].." does not exist.")
    end
end

function impulse.Ops.ReportClose(ply, arg, rawText)
   local reportId = arg[1]

    if reportId then
        reportId = tonumber(reportId)
    else
        for id, data in pairs(impulse.Ops.Reports) do
            if data[3] and data[3] == ply then
                reportId = id
                break
            end
        end
    end

    if not reportId then
        return ply:AddChatText(newReportCol, "You must claim a report or specify a report ID before closing it.")
    end

    local targetReport = impulse.Ops.Reports[reportId]

    if targetReport then
        local reporter = targetReport[1]
        local reportMessage = targetReport[2]
        local reportClaimant = targetReport[3]
        local isDc = false

        if not IsValid(reporter) then
            isDc = true
        end

        if reportClaimant and not isDc and IsValid(reportClaimant) then
        	local query = mysql:Insert("impulse_reports")
			query:Insert("reporter", reporter:SteamID())
			query:Insert("mod", reportClaimant:SteamID())
			query:Insert("message", string.sub(reportMessage, 1, 650))
			query:Insert("start", os.date("%Y-%m-%d %H:%M:%S", os.time()))
			query:Insert("claimwait", targetReport[5] - targetReport[4])
			query:Insert("closewait", CurTime() - targetReport[4])
			query:Execute(true)
        end

        impulse.Ops.Reports[reportId] = nil

        for v,k in pairs(player.GetAll()) do
        	if k:IsAdmin() then
		        net.Start("opsReportClosed")
		        net.WriteEntity(ply)
		        net.WriteUInt(reportId, 16)
		        net.Send(k)
		    end
	    end

        if not isDc then
            net.Start("opsReportMessage")
            net.WriteUInt(reportId, 16)
            net.WriteUInt(4, 4)
            net.WriteEntity(ply)
            net.Send(reporter)
        end

        if not IsValid(ply) or not ply:IsPlayer() then
            return
        end

        opsSlackLog(":no_entry: *[REPORT CLOSED]* [#"..reportId.."] closed by "..ply:SteamName().." ("..ply:SteamID()..")")
    else
        ply:AddChatText(claimedReportCol, "Report #"..reportId.." does not exist.")
    end
end

function impulse.Ops.ReportGoto(ply, arg, rawText)
    local reportId = arg[1]

    if reportId then
        reportId = tonumber(reportId)
    else
        for id, data in pairs(impulse.Ops.Reports) do
            if data[3] and data[3] == ply then
                reportId = id
                break
            end
        end
    end

    if not reportId then
        return ply:AddChatText(newReportCol, "You must claim a report to use this command.")
    end

    local targetReport = impulse.Ops.Reports[reportId]

    if targetReport then
        local reporter = targetReport[1]

        if not IsValid(reporter) then
            return ply:AddChatText(newReportCol, "The player who submitted this report has left the game. Please close.")
        end
        
        opsGoto(ply, reporter:GetPos())
        ply:Notify("You have teleported to "..reporter:Nick()..".")
    else
        ply:AddChatText(claimedReportCol, "Report #"..reportId.." does not exist.")
    end
end

function impulse.Ops.ReportMsg(ply, arg, rawText)
    local reportId

    for id, data in pairs(impulse.Ops.Reports) do
        if data[3] and data[3] == ply then
            reportId = id
            break
        end
    end

    if not reportId then
        return ply:AddChatText(newReportCol, "You must claim a report to use this command.")
    end

    local targetReport = impulse.Ops.Reports[reportId]
    if targetReport then
        local reporter = targetReport[1]

        if not IsValid(reporter) then
            return ply:AddChatText(newReportCol, "The player who submitted this report has left the game. Please close.")
        end

        net.Start("opsReportAdminMessage")
        net.WriteEntity(ply)
        net.WriteString(rawText)
        net.Send(reporter)

        ply:Notify("Reply sent to "..reporter:Nick()..".")
    end
end

hook.Add("PostSetupPlayer", "impulseOpsReportSync", function(ply)
    if not ply:IsAdmin() then
        return
    end

    if table.Count(impulse.Ops.Reports) < 1 then
        return
    end

    local reports = {}
    reports = table.Merge(reports, impulse.Ops.Reports)

    for v,k in pairs(reports) do
        impulse.Ops.Reports[4] = nil
        impulse.Ops.Reports[5] = nil -- clients dont need this
        impulse.Ops.Reports[6] = nil
    end

    net.Start("opsReportSync")
    net.WriteTable(reports)
    net.Send(ply)
end)

net.Receive("opsReportDaleRepliedDo", function(len, ply)
    if (ply.nextDaleDoReply or 0) > CurTime() then
        return
    end

    ply.nextDaleDoReply = CurTime() + 10

    for id, data in pairs(impulse.Ops.Reports) do
        if data[1] == ply then
            if data[6] then
                return
            end

            impulse.Ops.Reports[id][6] = true
            for v,k in pairs(player.GetAll()) do
                if k:IsAdmin() then
                    net.Start("opsReportDaleReplied")
                    net.WriteUInt(id, 8)
                    net.Send(k)
                end
            end
            
            break
        end
    end
end)

net.Receive("opsReportDaleClose", function(len, ply)
    if (ply.nextDaleClose or 0) > CurTime() then
        return
    end

    ply.nextDaleClose = CurTime() + 10

    for id, data in pairs(impulse.Ops.Reports) do
        if data[1] == ply then
            if not data[6] then
                return
            end

            impulse.Ops.ReportClose(Entity(0), {id})
            
            break
        end
    end
end)