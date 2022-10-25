impulse.Data = impulse.Data or {}

function meta:GetData()
	return self.impulseData or {}
end

function meta:SaveData()	
	local query = mysql:Update("impulse_players")
	query:Update("data", util.TableToJSON(self.impulseData))
	query:Where("steamid", self:SteamID())
	query:Execute()
end

function impulse.Data.Write(name, data)
	local query = mysql:Select("impulse_data")
	query:Select("id")
	query:Where("name", name)
	query:Callback(function(result) -- somewhat annoying that we cant do a conditional query or smthing but whatever
		if type(result) == "table" and #result > 0 then
			local followUp = mysql:Update("impulse_data")
			followUp:Update("data", pon.encode(data))
			followUp:Where("name", name)
			followUp:Execute()
		else
			local followUp = mysql:Insert("impulse_data")
			followUp:Insert("name", name)
			followUp:Insert("data", pon.encode(data))
			followUp:Execute()
		end
	end)

	query:Execute()
end

function impulse.Data.Remove(name, limit)
	local query = mysql:Delete("impulse_data")
	query:Where("name", name)

	if limit then
		query:Limit(limit)
	end

	query:Execute()
end

function impulse.Data.Read(name, onDone, fallback)
	local query = mysql:Select("impulse_data")
	query:Select("data")
	query:Where("name", name)
	query:Callback(function(result)
		if type(result) == "table" and #result > 0 then
			onDone(pon.decode(result[1].data))
		elseif fallback then
			fallback()
		end
	end)

	query:Execute()
end