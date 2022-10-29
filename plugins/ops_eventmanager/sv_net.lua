util.AddNetworkString("impulseOpsEMMenu")
util.AddNetworkString("impulseOpsEMPushSequence")
util.AddNetworkString("impulseOpsEMUpdateEvent")
util.AddNetworkString("impulseOpsEMPlaySequence")
util.AddNetworkString("impulseOpsEMStopSequence")
util.AddNetworkString("impulseOpsEMClientsideEvent")
util.AddNetworkString("impulseOpsEMIntroCookie")
util.AddNetworkString("impulseOpsEMPlayScene")
util.AddNetworkString("impulseOpsEMEntAnim")

net.Receive("impulseOpsEMPushSequence", function(len, ply)
	if (ply.nextOpsEMPush or 0) > CurTime() then return end
	ply.nextOpsEMPush = CurTime() + 1

	if not ply:IsEventAdmin() then
		return
	end

	local seqName = net.ReadString()
	local seqEventCount = net.ReadUInt(16)
	local events = {}

	print("[ops-em] Starting pull of "..seqName.." (by "..ply:SteamName().."). Total events: "..seqEventCount.."")

	for i=1, seqEventCount do
		local dataSize = net.ReadUInt(16)
		local eventData = pon.decode(net.ReadData(dataSize))

		table.insert(events, eventData)
		print("[ops-em] Got event "..i.."/"..seqEventCount.." ("..eventData.Type..")")
	end

	impulse.Ops.EventManager.Sequences[seqName] = events

	print("[ops-em] Finished pull of "..seqName..". Ready to play sequence!")

	if IsValid(ply) then
		ply:Notify("Push completed.")
	end
end)

net.Receive("impulseOpsEMPlaySequence", function(len, ply)
	if (ply.nextOpsEMPlay or 0) > CurTime() then return end
	ply.nextOpsEMPlay = CurTime() + 1

	if not ply:IsEventAdmin() then
		return
	end

	local seqName = net.ReadString()

	if not impulse.Ops.EventManager.Sequences[seqName] then
		return ply:Notify("Sequence does not exist on server (push first).")
	end

	if impulse.Ops.EventManager.GetSequence() == seqName then
		return ply:Notify("Sequence already playing.")
	end

	impulse.Ops.EventManager.PlaySequence(seqName)

	print("[ops-em] Playing sequence "..seqName.." (by "..ply:SteamName()..").")
	ply:Notify("Playing sequence "..seqName..".")
end)

net.Receive("impulseOpsEMStopSequence", function(len, ply)
	if (ply.nextOpsEMStop or 0) > CurTime() then return end
	ply.nextOpsEMStop = CurTime() + 1

	if not ply:IsEventAdmin() then
		return
	end

	local seqName = net.ReadString()

	if not impulse.Ops.EventManager.Sequences[seqName] then
		return ply:Notify("Sequence does not exist on server (push first).")
	end

	if impulse.Ops.EventManager.GetSequence() != seqName then
		return ply:Notify("Sequence not playing.")
	end

	impulse.Ops.EventManager.StopSequence(seqName)

	print("[ops-em] Stopping sequence "..seqName.." (by "..ply:SteamName()..").")
	ply:Notify("Stopped sequence "..seqName..".")
end)

net.Receive("impulseOpsEMIntroCookie", function(len, ply)
	if ply.usedIntroCookie or not impulse.Ops.EventManager.GetEventMode() then
		return
	end
	
	ply.usedIntroCookie = true

	ply:AllowScenePVSControl(true)

	timer.Simple(900, function()
		if IsValid(ply) then
			ply:AllowScenePVSControl(false)
		end
	end)
end)