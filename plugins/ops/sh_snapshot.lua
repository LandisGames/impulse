impulse.Ops = impulse.Ops or {}
impulse.Ops.Snapshots = impulse.Ops.Snapshots or {}

local snapshotCommand = {
    description = "Plays the snapshot specified by the snapshot ID.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local id = arg[1]

        if not tonumber(id) then
        	return ply:Notify("ID must be a number.")
        end

        id = tonumber(id)

        if not impulse.Ops.Snapshots[id] then
        	return ply:Notify("Snapshot could not be found with that ID.")
        end

        ply:Notify("Downloading snapshot #"..id.."...")

        local snapshot = impulse.Ops.Snapshots[id]
        snapshot = pon.encode(snapshot)
		
		net.Start("opsSnapshot")
		net.WriteUInt(id, 16)
		net.WriteUInt(#snapshot, 32)
		net.WriteData(snapshot, #snapshot)
		net.Send(ply)
    end
}

impulse.RegisterChatCommand("/snapshot", snapshotCommand)