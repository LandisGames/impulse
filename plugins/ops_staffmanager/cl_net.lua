net.Receive("impulseOpsSMOpen", function()
	local len = net.ReadUInt(32)
	local stats = pon.decode(net.ReadData(len))

	local m = vgui.Create("impulseStaffManager")
	m:SetupStats(stats)
end)