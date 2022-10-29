impulse.Ops.ST = impulse.Ops.ST or {}

util.AddNetworkString("impulseOpsSTOpenTool")
util.AddNetworkString("impulseOpsSTDoRefund")
util.AddNetworkString("impulseOpsSTGetRefund")
util.AddNetworkString("impulseOpsSTDoOOCEnabled")
util.AddNetworkString("impulseOpsSTDoTeamLocked")
util.AddNetworkString("impulseOpsSTDoGroupRemove")

local function isSupport(ply)
    if not ply:IsSuperAdmin() then
        if ply:GetUserGroup() != "communitymanager" then
            return false
        end
    end

    return true
end

local lockedTeams = lockedTeams or {}

net.Receive("impulseOpsSTDoOOCEnabled", function(len, ply)
    if not isSupport(ply) then
        return
    end

    local enabled = net.ReadBool()

    impulse.OOCClosed = !enabled

    ply:Notify("OOC enabled set to "..(enabled and "true" or "false")..".")
end)

net.Receive("impulseOpsSTDoGroupRemove", function(len, ply)
    if not isSupport(ply) then
        return
    end

    local name = net.ReadString()
    local groupData = impulse.Group.Groups[name]

	if not groupData or not groupData.ID then
        impulse.Group.DBRemoveByName(name)
        ply:Notify("No loaded group found, however, we have attempted to remove it from the database.")
		return
	end
	
	for v,k in pairs(groupData.Members) do
		local targEnt = player.GetBySteamID(v)

		if IsValid(targEnt) then
			targEnt:SetSyncVar(SYNC_GROUP_NAME, nil, true)
			targEnt:SetSyncVar(SYNC_GROUP_RANK, nil, true)
			targEnt:Notify("You were removed from the "..name.." group as it has been removed by the staff team for violations of the RP group rules.")
		end
	end

	impulse.Group.DBRemove(groupData.ID)
	impulse.Group.DBRemovePlayerMass(groupData.ID)
	impulse.Group.Groups[name] = nil

    ply:Notify("The "..name.." group has been removed.")
end)

net.Receive("impulseOpsSTDoTeamLocked", function(len, ply)
    if not isSupport(ply) then
        return
    end

    local teamid = net.ReadUInt(8)
    local locked = net.ReadBool()

    if teamid == impulse.Config.DefaultTeam then
        return ply:Notify("You can't lock the default team.")
    end

    lockedTeams[teamid] = locked

    ply:Notify("Team "..teamid.." has been "..(locked and "locked" or "unlocked")..".")
end)

net.Receive("impulseOpsSTDoRefund", function(len, ply)
    if not isSupport(ply) then
        return
    end

    local s64 = net.ReadString()
    local len = net.ReadUInt(32)
    local items = pon.decode(net.ReadData(len))
    local steamid = util.SteamIDFrom64(s64)

    local query = mysql:Select("impulse_players")
    query:Select("id")
    query:Where("steamid", steamid)
    query:Callback(function(result)
        if not IsValid(ply) then
            return
        end

        if not type(result) == "table" or #result == 0 then
            return ply:Notify("This Steam account has not joined the server yet or the SteamID is invalid.")
        end

        local impulseID = result[1].id
        local refundData = {}

        for v,k in pairs(items) do
            if not impulse.Inventory.ItemsRef[v] then
                continue
            end

            refundData[v] = k
        end

        impulse.Data.Write("SupportRefund_"..s64, refundData)

        ply:Notify("Issued support refund for user "..s64..".")
    end)

    query:Execute()
end)

function impulse.Ops.ST.Open(ply)
	net.Start("impulseOpsSTOpenTool")
	net.Send(ply)
end

function PLUGIN:PostInventorySetup(ply)
    impulse.Data.Read("SupportRefund_"..ply:SteamID64(), function(refundData)
        if not IsValid(ply) then
            return
        end
        
        for v,k in pairs(refundData) do
            if not impulse.Inventory.ItemsRef[v] then
                continue
            end
            
            for i=1,k do
               ply:GiveInventoryItem(v, INV_STORAGE) -- refund to storage 
            end
        end

        impulse.Data.Remove("SupportRefund_"..ply:SteamID64())

        local data = pon.encode(refundData)

        net.Start("impulseOpsSTGetRefund")
        net.WriteUInt(#data, 32)
        net.WriteData(data, #data)
        net.Send(ply)
    end)
end

function PLUGIN:CanPlayerChangeTeam(ply, newTeam)
    if lockedTeams[newTeam] then
        if SERVER then
            ply:Notify("Team temporarily locked.")
        end
        return false
    end
end