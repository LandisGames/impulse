local managerCommand = {
    description = "Opens the staff manager tool.",
    leadAdminOnly = true,
    onRun = function(ply)
    	impulse.Ops.SM.Open(ply)
    end
}

impulse.RegisterChatCommand("/staffmanager", managerCommand)