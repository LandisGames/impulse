local config = {
	trues = {
		["yes"] = true,
		["1"] = true,
		["true"] = true,
		["on"] = true
	},
	falses = {
		["no"] = true,
		["0"] = true,
		["false"] = true,
		["off"] = true
	},
	comments = {
		["#"] = true
	},
	strings = {
		[""] = true
	}
}

function IMLRead(data)
	local lines = string.Split(data, "\n")

	for v,k in pairs(lines) do
		local sub = string.Split(k, " ")

		if not sub[1] or not sub[2] then
			continue
		end
		
		return
	end
end