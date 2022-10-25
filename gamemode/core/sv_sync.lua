--- A fast entity based synchronous networking system
-- @module Sync

util.AddNetworkString("iSyncU")
util.AddNetworkString("iSyncUlcl")
util.AddNetworkString("iSyncR")
util.AddNetworkString("iSyncRvar")

local entMeta = FindMetaTable("Entity")

-- target is optional. Sync will take the player and sync their all SyncVars with all clients or the single target if provided.
function entMeta:Sync(target)
	local targetID = self:EntIndex()
	local syncUser = impulse.Sync.Data[targetID]

	for varID, syncData in pairs(syncUser) do
		local value = syncData[1]
		local syncRealm = syncData[2]
		local syncType = impulse.Sync.Vars[varID]
		local syncCondition = impulse.Sync.VarsConditional[varID]

		if target and syncCondition and not syncCondition(target) then
			return
		end
		
		if syncRealm == SYNC_TYPE_PUBLIC then
			if target then
				if value == nil then
					net.Start("iSyncRvar")
						net.WriteUInt(targetID, 16)
						net.WriteUInt(varID, SYNC_ID_BITS)
					net.Send(target)
				else
					net.Start("iSyncU")
						net.WriteUInt(targetID, 16)
						net.WriteUInt(varID, SYNC_ID_BITS)
						impulse.Sync.DoType(syncType, value)
					net.Send(target)
				end
			else
				local recipFilter = RecipientFilter()

				if syncCondition then
					for v,k in pairs(player.GetAll()) do
						if syncCondition(k) then
							recipFilter:AddPlayer(k)
						end
					end
				else
					recipFilter:AddAllPlayers()
				end

				if value == nil then
					net.Start("iSyncRvar")
						net.WriteUInt(targetID, 16)
						net.WriteUInt(varID, SYNC_ID_BITS)
					net.Send(recipFilter)
				else
					net.Start("iSyncU")
						net.WriteUInt(targetID, 16)
						net.WriteUInt(varID, SYNC_ID_BITS)
						impulse.Sync.DoType(syncType, value)
					net.Send(recipFilter)
				end
			end
		elseif target and target:IsPlayer() and target:EntIndex() == targetID then
			if value == nil then
				net.Start("iSyncRvar")
					net.WriteUInt(targetID, 16)
					net.WriteUInt(varID, SYNC_ID_BITS)
				net.Send(target)
			else
				net.Start("iSyncUlcl")
					net.WriteUInt(targetID, 8)
					net.WriteUInt(varID, SYNC_ID_BITS)
					impulse.Sync.DoType(syncType, value)
				net.Send(target)
			end
		end
	end
end

-- target is optional. SyncSingle will take the player and sync the SyncVar provided with all clients or the single target if provided.
function entMeta:SyncSingle(varID, target)
	local targetID = self:EntIndex()
	local syncUser = impulse.Sync.Data[targetID]
	local syncData = syncUser[varID]
	local value = syncData[1]
	local syncRealm = syncData[2]
	local syncType = impulse.Sync.Vars[varID]
	local syncCondition = impulse.Sync.VarsConditional[varID]

	if target and syncCondition and not syncCondition(target) then
		return
	end

	if syncRealm == SYNC_TYPE_PUBLIC then
		if target then
			if value == nil then
				net.Start("iSyncRvar")
					net.WriteUInt(targetID, 16)
					net.WriteUInt(varID, SYNC_ID_BITS)
				net.Send(target)
			else
				net.Start("iSyncU")
					net.WriteUInt(targetID, 16)
					net.WriteUInt(varID, SYNC_ID_BITS)
					impulse.Sync.DoType(syncType, value)
				net.Send(target)
			end
		else
			local recipFilter = RecipientFilter()

			if syncCondition then
				for v,k in pairs(player.GetAll()) do
					if syncCondition(k) then
						recipFilter:AddPlayer(k)
					end
				end
			else
				recipFilter:AddAllPlayers()
			end

			if value == nil then
				net.Start("iSyncRvar")
					net.WriteUInt(targetID, 16)
					net.WriteUInt(varID, SYNC_ID_BITS)
				net.Send(recipFilter)
			else
				net.Start("iSyncU")
					net.WriteUInt(targetID, 16)
					net.WriteUInt(varID, SYNC_ID_BITS)
					impulse.Sync.DoType(syncType, value)
				net.Send(recipFilter)
			end
		end
	elseif target and target:IsPlayer() and target:EntIndex() == targetID then
		if value == nil then
			net.Start("iSyncRvar")
				net.WriteUInt(targetID, 16)
				net.WriteUInt(varID, SYNC_ID_BITS)
			net.Send(target)
		else
			net.Start("iSyncUlcl")
				net.WriteUInt(targetID, 8)
				net.WriteUInt(varID, SYNC_ID_BITS)
				impulse.Sync.DoType(syncType, value)
			net.Send(target)
		end
	end
end

--- Removes all SyncVar's from an entity and update all players
-- @realm server
function entMeta:SyncRemove()
	local targetID = self:EntIndex()

	impulse.Sync.Data[targetID] = nil

	net.Start("iSyncR")
		net.WriteUInt(targetID, 16)
	net.Broadcast()	
end


--- Removes a specific SyncVar from an entity and update all players
-- @realm server
-- @int varID Sync variable
function entMeta:SyncRemoveVar(varID)
	local targetID = self:EntIndex()

	impulse.Sync.Data[targetID][varID] = nil

	net.Start("iSyncRvar")
		net.WriteUInt(targetID, 16)
		net.WriteUInt(varID, SYNC_ID_BITS)
	net.Broadcast()	
end

-- instantSync is optional. SetSyncVar will set the SyncVar however it will not update it with all clients unless instantSync is true.

--- Sets the Sync var on an entity
-- @realm server
-- @int varID Sync variable (EG: SYNC_MONEY)
-- @param value Value to set
-- @bool[opt=false] instantSync If we should network this to all players
-- @usage ply:SetSyncVar(SYNC_XP, 60, true) -- sets money to 60 and networks the new value to all players
function entMeta:SetSyncVar(varID, newValue, instantSync)
	local targetID = self:EntIndex()
	local targetData = impulse.Sync.Data[targetID]

	if not targetData then
		impulse.Sync.Data[targetID] = {}
		targetData = impulse.Sync.Data[targetID]
	elseif targetData[varID] and (type(newValue) != "table" and targetData[varID][1] == newValue) then
		return
	end

	targetData[varID] = {newValue, SYNC_TYPE_PUBLIC}

	if instantSync then
		self:SyncSingle(varID)
	end
end

-- SetLocalSyncVar will set a local (to the player) SyncVar that will not be communicated with any other players.

--- Sets the Sync var on an entity but only updates the player who it is being set on
-- @realm server
-- @int varID Sync variable (EG: SYNC_MONEY)
-- @param value Value to set
-- @usage ply:SetLocalSyncVar(SYNC_BANKMONEY, 600)
function meta:SetLocalSyncVar(varID, newValue)
	local targetID = self:EntIndex()
	local targetData = impulse.Sync.Data[targetID]
	targetData[varID] = {newValue, SYNC_TYPE_PRIVATE}

	self:SyncSingle(varID, self)
end

function entMeta:GetSyncVar(varID, fallback)
	local targetData = impulse.Sync.Data[self.EntIndex(self)]

	if targetData != nil then
		if targetData[varID] != nil then
			return targetData[varID][1]
		end
	end
	return fallback
end