local reportCommand = {
    description = "Sends (or updates) a report to the game moderators.",
    requiresArg = true,
    onRun = function(ply, arg, rawText)
        impulse.Ops.ReportNew(ply, arg, rawText)
    end
}

impulse.RegisterChatCommand("/report", reportCommand)

local claimReportCommand = {
    description = "Claims a report for review.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        impulse.Ops.ReportClaim(ply, arg, rawText)
    end
}

impulse.RegisterChatCommand("/rc", claimReportCommand)

local closeReportCommand = {
    description = "Closes a report.",
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        impulse.Ops.ReportClose(ply, arg, rawText)
    end
}

impulse.RegisterChatCommand("/rcl", closeReportCommand)

local gotoReportCommand = {
    description = "Teleports yourself to the reportee of your claimed report.",
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        impulse.Ops.ReportGoto(ply, arg, rawText)
    end
}

impulse.RegisterChatCommand("/rgoto", gotoReportCommand)

local msgReportCommand = {
    description = "Messages the reporter of your claimed report.",
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        impulse.Ops.ReportMsg(ply, arg, rawText)
    end
}

impulse.RegisterChatCommand("/rmsg", msgReportCommand)