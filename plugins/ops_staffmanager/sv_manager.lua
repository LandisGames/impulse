impulse.Ops = impulse.Ops or {}
impulse.Ops.SM = impulse.Ops.SM or {}

util.AddNetworkString("impulseOpsSMOpen")

local function CalculateData(onDone)
	local data = {}
	data.Mods = {}
	data.All = {}

	local now = os.time()
	local monthAgo = now - 2592000 -- 1 month in seconds

	mysql:RawQuery("SELECT `id`, `mod`, UNIX_TIMESTAMP(`start`), `claimwait`, `closewait` FROM `impulse_reports`", function(result)
		for v,k in pairs(result) do
			if not data.Mods[k.mod] then
				data.Mods[k.mod] = {}
				data.Mods[k.mod].Total = 0
				data.Mods[k.mod].TotalWait = 0
				data.Mods[k.mod].TotalCloseWait = 0
				data.Mods[k.mod].Total30Days = 0
				data.Mods[k.mod].TotalWait30Days = 0
				data.Mods[k.mod].TotalCloseWait30Days = 0
			end

			data.Mods[k.mod].Total = data.Mods[k.mod].Total + 1
			data.Mods[k.mod].TotalWait = data.Mods[k.mod].TotalWait + k.claimwait
			data.Mods[k.mod].TotalCloseWait = data.Mods[k.mod].TotalCloseWait + k.closewait

			if k["UNIX_TIMESTAMP(`start`)"] > monthAgo then
				data.Mods[k.mod].Total30Days = data.Mods[k.mod].Total30Days + 1
				data.Mods[k.mod].TotalWait30Days = data.Mods[k.mod].TotalWait30Days + k.claimwait
				data.Mods[k.mod].TotalCloseWait30Days = data.Mods[k.mod].TotalCloseWait30Days + (k.closewait - k.claimwait)
			end
		end

		data.All.Total = 0
		data.All.TotalWait = 0
		data.All.TotalCloseWait = 0
		data.All.Total30Days = 0
		data.All.TotalWait30Days = 0
		data.All.TotalCloseWait30Days = 0

		for v,k in pairs(data.Mods) do
			data.All.Total = data.All.Total + k.Total
			data.All.TotalWait = data.All.TotalWait + k.TotalWait
			data.All.TotalCloseWait = data.All.TotalCloseWait + k.TotalCloseWait
			data.All.Total30Days = data.All.Total30Days + k.Total30Days
			data.All.TotalWait30Days = data.All.TotalWait30Days + k.TotalWait30Days
			data.All.TotalCloseWait30Days = data.All.TotalCloseWait30Days + k.TotalCloseWait30Days
		end

		onDone(data)
	end)
end

local NEXT_CHECK = NEXT_CHECK or 0
local CACHED_DATA = CACHED_DATA or {}
function impulse.Ops.SM.Open(ply)
	if NEXT_CHECK < CurTime() then
		CalculateData(function(data)
			if IsValid(ply) then
				local data = pon.encode(data)
				CACHED_DATA = data

				net.Start("impulseOpsSMOpen")
				net.WriteUInt(#data, 32)
				net.WriteData(data, #data)
				net.Send(ply)
			end
		end)

		NEXT_CHECK = CurTime() + 1200

		return
	end

	local data = CACHED_DATA

	net.Start("impulseOpsSMOpen")
	net.WriteUInt(#data, 32)
	net.WriteData(data, #data)
	net.Send(ply)
end