--[[TFA SND - Sound Metadata Library]]
--[[RootTable]]
TFA_SND = TFA_SND or {}
--[[SubTables]]
TFA_SND.WAV = TFA_SND.WAV or {}

--[[Helper Functions]]
function TFA_SND.Path(path, gamedir)
	if not gamedir then
		path = "sound/" .. path
		gamedir = "GAME"
	end

	return path, gamedir
end

local function pack(...)
	return {
		n = select("#", ...),
...
	}
end

function TFA_SND.FileAccessor(p, d, fn)
	local path, gamedir = TFA_SND.Path(p, d)
	local f = file.Open(path, "rb", gamedir)
	if not f then return -1 end --Return -1 on invalid files
	local ret = pack(fn(f))
	f:Close()

	return unpack(ret)
end

function TFA_SND.f_IsWAV(f)
	f:Seek(8)

	return f:Read(4) == "WAVE"
end

function TFA_SND.f_IsMP3(f)
	f:Seek(0)
	local s = f:Read(3)

	return s == "ID3" or s == "TAG"
end

function TFA_SND.IsWAV(path, gamedir)
	return TFA_SND.FileAccessor(path, gamedir, TFA_SND.f_IsWAV)
end

function TFA_SND.IsMP3(path, gamedir)
	return TFA_SND.FileAccessor(path, gamedir, TFA_SND.f_IsMP3)
end

--[[WAV Functions]]
function TFA_SND.WAV.f_Channels(f)
	f:Seek(22)
	local bytes = {}

	for i = 1, 2 do
		bytes[i] = f:ReadByte(1)
	end

	local num = bit.lshift(bytes[2], 8) + bit.lshift(bytes[1], 0)

	return num
end

function TFA_SND.WAV.f_SampleDepth(f)
	f:Seek(34)
	local bytes = {}

	for i = 1, 2 do
		bytes[i] = f:ReadByte(1)
	end

	local num = bit.lshift(bytes[2], 8) + bit.lshift(bytes[1], 0)

	return num
end

function TFA_SND.WAV.f_SampleRate(f)
	f:Seek(24)
	local bytes = {}

	for i = 1, 4 do
		bytes[i] = f:ReadByte(1)
	end

	local num = bit.lshift(bytes[4], 24) + bit.lshift(bytes[3], 16) + bit.lshift(bytes[2], 8) + bit.lshift(bytes[1], 0)

	return num
end

function TFA_SND.WAV.f_Duration(f)
	return (f:Size() - 44) / (TFA_SND.WAV.f_SampleDepth(f) / 8 * TFA_SND.WAV.f_SampleRate(f) * TFA_SND.WAV.f_Channels(f))
end

function TFA_SND.WAV.Channels(path, gamedir)
	return TFA_SND.FileAccessor(path, gamedir, TFA_SND.WAV.f_Channels)
end

function TFA_SND.WAV.SampleDepth(path, gamedir)
	return TFA_SND.FileAccessor(path, gamedir, TFA_SND.WAV.f_SampleDepth)
end

function TFA_SND.WAV.SampleRate(path, gamedir)
	return TFA_SND.FileAccessor(path, gamedir, TFA_SND.WAV.f_SampleRate)
end

function TFA_SND.WAV.Duration(path, gamedir)
	return TFA_SND.FileAccessor(path, gamedir, TFA_SND.WAV.f_Duration)
end

if system.IsLinux() then
	SoundDurationOld = SoundDurationOld or SoundDuration

	SoundDuration = function(str)
		local path, gamedir = TFA_SND.Path(str)
		local f = file.Open(path, "rb", gamedir)
		if not f then return 0 end --Return nil on invalid files
		local ret

		if TFA_SND.f_IsWAV(f) then
			ret = TFA_SND.WAV.f_Duration(f)
		else
			ret = SoundDurationOld(str)
		end

		f:Close()

		return ret
	end
end