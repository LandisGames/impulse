impulse.Refunds = impulse.Refunds or {}

local timeoutTime = 86400 -- 24 hours (86400)

function impulse.Refunds.Clean()
	local query = mysql:Delete("impulse_refunds")
	query:WhereLTE("date", math.floor(os.time()) - timeoutTime)
	query:Execute()
end

function impulse.Refunds.Remove(steamid, item)
	local query = mysql:Delete("impulse_refunds")
	query:Where("steamid", steamid)
	query:Where("item", item)
	query:Limit(1)
	query:Execute()
end

function impulse.Refunds.RemoveAll(steamid)
	local query = mysql:Delete("impulse_refunds")
	query:Where("steamid", steamid)
	query:Execute()
end

function impulse.Refunds.Add(steamid, item)
	local query = mysql:Insert("impulse_refunds")
	query:Insert("steamid", steamid)
	query:Insert("item", item)
	query:Insert("date", math.floor(os.time()))
	query:Execute()
end

if not timer.Exists("impulseRefundCleaner") then
	timer.Create("impulseRefundCleaner", 120, 0, function()
		impulse.Refunds.Clean()
	end)
end