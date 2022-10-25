--- Controls the business system which allows players to purchase items
-- @module Business

impulse.Business = impulse.Business or {}
impulse.Business.Data = impulse.Business.Data or {}
impulse.Business.DataRef = impulse.Business.DataRef or {}

local busID = 0

--- Renders a blur effect on a panel. Call this inside PANEL:Paint
-- @realm shared
-- @string name Buyable name
-- @param buyableData Buyable data
-- @see BuyableData
function impulse.Business.Define(name, buyableData)
	busID = busID + 1
	buyableData.key = name
    impulse.Business.Data[name] = buyableData
    impulse.Business.DataRef[busID] = name
end

--- Returns if a player can buy a buyable
-- @realm shared
-- @string name Buyable name
function meta:CanBuy(name)
	local buyable = impulse.Business.Data[name]

	if buyable.teams and not table.HasValue(buyable.teams, self:Team()) then
		return false
	end

	if buyable.classes and not table.HasValue(buyable.classes, self:GetTeamClass()) then
		return false
	end

	if buyable.customCheck and not buyable.customCheck(self) then
		return false
	end

	return true
end

--- Spawns a buyable as an entity
-- @realm server
-- @vector pos
-- @angle ang
-- @string buyable Buyable name
-- @entity owner Owner player
-- @internal
function impulse.SpawnBuyable(pos, ang, buyable, owner)
	local spawnedBuyable

	if buyable.bench then
		spawnedBuyable = impulse.Inventory.SpawnBench(buyable.bench, pos, ang)
	else
		spawnedBuyable = ents.Create(buyable.entity)

		if buyable.model then
			spawnedBuyable:SetModel(buyable.model)
		end

		spawnedBuyable:SetPos(pos)
		spawnedBuyable:Spawn()
	end

	if buyable.removeOnTeamSwitch then
		owner.BuyableTeamRemove = owner.BuyableTeamRemove or {}
		table.insert(owner.BuyableTeamRemove, spawnedBuyable)
	end

	if buyable.postSpawn then
		buyable.postSpawn(spawnedBuyable, owner)
	end

	spawnedBuyable.BuyableOwner = owner
	spawnedBuyable:CPPISetOwner(owner)
	spawnedBuyable.IsBuyable = true

	if buyable.refund then
		local class = "buy_"..buyable.key
		local sid = owner:SteamID()
		impulse.Refunds.Add(sid, class)

		spawnedBuyable:CallOnRemove("RefundDestroy", function(ent)
			impulse.Refunds.Remove(sid, class)
		end, class, sid)
	end

	return spawnedBuyable
end

--- A collection of data that defines how a buyable will behave
-- @realm shared
-- @string[opt] entity Entity class name
-- @string[opt] bench Bench class name
-- @string model Model
-- @string description Buyable description
-- @int price Price
-- @param[opt] teams A table of teams that can buy this buyable
-- @param[opt] classes A table of classes that can buy this buyable
-- @bool[opt=false] refund Should this buyable be refunded on server crashes
-- @int[opt=0] refundAdd The amount to add to the price in the event of a refund being issued
-- @bool[opt=false] removeOnTeamSwitch Should the buyable be removed on team switch
-- @func[opt] postSpawn Called after the buyable is spawned (ent, ply) arguments passed
-- @func[opt] customCheck Determines if the buyable can be spawned based on return value (ply) arguments passed
-- @table BuyableData
