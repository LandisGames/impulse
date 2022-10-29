function impulse.Ops.EventManager.SequenceLoad(path)
	local fileData = file.Read(path, "DATA")
	local json = util.JSONToTable(fileData)

	if not json or not istable(json) then
		return false, "Corrupted sequence file"
	end

	if not json.Name or not json.Events or not json.FileName then
		return false, "Corrupted sequence file vital metadata"
	end

	impulse.Ops.EventManager.Sequences[json.Name] = json

	return true
end

function impulse.Ops.EventManager.SequenceSave(name)
	local sequence = impulse.Ops.EventManager.Sequences[name]
	file.Write("impulse/ops/eventmanager/"..sequence.FileName..".json", util.TableToJSON(sequence, true))
end

function impulse.Ops.EventManager.SequencePush(name)
	local sequence = impulse.Ops.EventManager.Sequences[name]
	local events = sequence.Events
	local eventCount = table.Count(events)

	print("[ops-em] Starting push of "..name..". (This might take a while)")

	net.Start("impulseOpsEMPushSequence")
	net.WriteString(name)
	net.WriteUInt(eventCount, 16)

	for v,k in pairs(events) do
		local edata = pon.encode(k)
		net.WriteUInt(#edata, 16)
		net.WriteData(edata, #edata)

		print("[ops-em] Packaged event "..v.."/"..eventCount.." ("..k.Type..")")
	end

	net.SendToServer()

	print("[ops-em] Push fully sent to server!")
end

function impulse.Ops.EventManager.GetVersionHash()
	return util.CRC(util.TableToJSON(impulse.Ops.EventManager.Config.Events))
end