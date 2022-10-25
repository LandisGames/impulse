impulse.Signals = impulse.Signals or {}
impulse.Signals.Hooks = impulse.Signals.Hooks or {}

local YML = impulse.YML
local SIGNAL_SERVERID
local db

if YML.signals then
	SIGNAL_SERVERID = YML.signals.serverid or 1

	db = mysqloo.connect(YML.signals.ip, YML.signals.username, YML.signals.password, YML.signals.database, YML.signals.port or 3306)
	function db:onConnected(x)
		print("[signals-mysql] Signals database connected!")

		local q = db:query("CREATE TABLE IF NOT EXISTS impulse_signals (id int unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY, class varchar(128) NOT NULL, dest int unsigned NOT NULL, wait int unsigned NOT NULL, data longtext)")
		q:start()
	end

	function db:onConnectionFailed(x, err)
		print("[signals-mysql] Signals database connection failed! Error: "..err)
	end
end

function impulse.Signals.Send(class, data, to, delay)
	if not db then
		return print("[impulse] Trying to call Signals.Send with no signal database setup!")	
	end

	data = pon.encode(data)

	local query = db:prepare("INSERT INTO impulse_signals (`class`, `dest`, `wait`, `data`) VALUES(?, ?, ?, ?)")
	query:setString(1, class)
	query:setNumber(2, to or 0)
	query:setString(3, data)
	query:setNumber(4, delay and os.time() + delay or 0)
	query:start()
end

function impulse.Signals.ReadAll(onDone)
	local query = db:query("DELETE FROM `impulse_signals` WHERE wait <= "..os.time().." AND (dest = "..SIGNAL_SERVERID.." OR dest = 0) RETURNING *")
	query:start()

	function query:onSuccess(result)
		if type(result) == "table" and #result == 1 then
			onDone(result)
		else
			onDone({})
		end
	end
end

function impulse.Signals.Hook(class, func)
	impulse.Signals.Hooks[class] = func
end

if db then
	db:connect()

	if timer.Exists("impulseSignalsThink") then
		timer.Remove("impulseSignalsThink")
	end

	timer.Create("impulseSignalsThink", impulse.Config.SignalsUpdateTime or 5, 0, function()
		impulse.Signals.ReadAll(function(data)
			for v,k in pairs(data) do
				if impulse.Signals.Hooks[data.class] then
					impulse.Signals.Hooks[data.class](pon.decode(data.data))
				end
			end
		end)
	end)
end