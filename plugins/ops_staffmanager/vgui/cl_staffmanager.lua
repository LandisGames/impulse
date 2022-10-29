local PANEL = {}

function PANEL:Init()
	self:SetSize(900, 810)
	self:Center()
	self:SetTitle("ops staff manager")
	self:MakePopup()
end

function PANEL:SetupStats(stats)
	local complete = 0

	for v,k in pairs(stats.Mods) do
		steamworks.RequestPlayerInfo(util.SteamIDTo64(v), function(name)
			stats.Mods[v].Name = name
			complete = complete + 1

			if complete >= table.Count(stats.Mods) and IsValid(self) then
				self:Setup(stats)
			end
		end)
	end
end

function PANEL:AddSheet(name, icon)
	local sheet = vgui.Create("DPanel", self.sheet)
	sheet.Paint = function() end
	sheet:DockMargin(5, 5, 5, 5)
	sheet:Dock(FILL)

	self.sheet:AddSheet(name, sheet, icon)

	return sheet
end

function PANEL:Setup(stats)
	self.Stats = stats

	self.sheet = vgui.Create("DColumnSheet", self)
	self.sheet:Dock(FILL)

	self.sheet.Navigation:SetWidth(300)

	local all = self:AddSheet("Everyone", "icon16/group.png")
	local x

	for v,k in pairs(stats.Mods) do
		if k.Total30Days > 0 then
			x = self:AddSheet(k.Name.." - "..v, "icon16/user.png")
			self:SetupPlayer(x, k, v)
		end
	end

	for v,k in pairs(stats.Mods) do
		if k.Total30Days == 0 then
			x = self:AddSheet(k.Name.." - "..v, "icon16/user_red.png")
			self:SetupPlayer(x, k, v)
		end
	end

	self:SetupPlayer(all, stats.All)
end

function PANEL:SetupPlayer(panel, stats, sid)
	local lbl = vgui.Create("DLabel", panel)
	lbl:SetFont("Impulse-CharacterInfo-NO")
	lbl:SetText(stats.Name or "Everyone")
	lbl:SizeToContents()
	lbl:Dock(TOP)

	if stats.Name then
		local btn = vgui.Create("DButton", panel)
		btn:SetText("Copy SteamID")
		btn:SizeToContents()
		btn:Dock(TOP)
		btn:SetWide(200)

		function btn:DoClick()
			LocalPlayer():Notify("Copied SteamID.")
			return SetClipboardText(sid)
		end

		local rating = 0
		local explain = ""

		local rScore = stats.Total30Days / 70
		rScore = math.Clamp(rScore, 0, 12)

		rating = rating + rScore
		explain = explain.."Reports Completed: +"..rScore.."\n"

		if stats.Total30Days > 40 then
			rating = rating + 2
			explain = explain.."Basic Completion Threshold Pass: +2\n"
		else
			rating = rating - 1.5
			explain = explain.."Basic Completion Threshold Fail: -1.5\n"
		end

		local tScore = (stats.TotalWait30Days / stats.Total30Days)
		tScore = 300 - tScore
		tScore = tScore * 0.01
		tScore = math.Clamp(tScore, 0, 3)
		explain = explain.."Response Time: +"..tScore.."\n"

		if tScore > 2 then
			rating = rating + 1
			explain = explain.."Basic Response Threshold Bonus: +1\n"
		elseif tScore < 1 then
			rating = rating - 0.5
			explain = explain.."Basic Response Threshold Fail: -0.5\n"
		else
			explain = explain.."Basic Response Threshold Pass: +0\n"
		end

		rating = rating + tScore

		local iScore = stats.TotalCloseWait30Days / stats.Total30Days
		if iScore < 30 then
			rating = rating - 1
			explain = explain.."Basic Investigation Threshold Fail (too fast): -1\n"
		elseif iScore > 210 then
			rating = rating - 0.8
			explain = explain.."Basic Investigation Threshold Fail (too slow): -0.8\n"
		else
			explain = explain.."Basic Investigation Threshold Pass: +0\n"
		end

		rating = math.Round(rating, 2)
		rating = math.Clamp(rating, 0, 15)

		if sid == "STEAM_0:1:95921723" then
			explain = explain.."Being vin: +1000000"
			rating = 100000000000
		end

		if stats.Total30Days == 0 then
			rating = 0
		end

		local lbl = vgui.Create("DLabel", panel)
		lbl:SetFont("Impulse-Elements18-Shadow")
		lbl:SetText("Perfomance Rating: "..rating)
		lbl:SizeToContents()
		lbl:Dock(TOP)

		if rating > 1000 then
			lbl:SetTextColor(Color(255, 110, 199))
		elseif rating > 7 then
			lbl:SetTextColor(Color(0, 255, 0))
		elseif rating > 4.5 then
			lbl:SetTextColor(Color(255, 255, 0))
		elseif rating > 3 then
			lbl:SetTextColor(Color(255, 69, 0))
		else
			lbl:SetTextColor(Color(255, 0, 0))
		end

		local lbl = vgui.Create("DLabel", panel)
		lbl:SetFont("Impulse-Elements14")
		lbl:SetText(explain)
		lbl:SizeToContents()
		lbl:Dock(TOP)
	end

	local lbl = vgui.Create("DLabel", panel)
	lbl:SetFont("Impulse-Elements22-Shadow")
	lbl:SetText("\nLast 30 Days")
	lbl:SizeToContents()
	lbl:Dock(TOP)

	local lbl = vgui.Create("DLabel", panel)
	lbl:SetFont("Impulse-Elements18-Shadow")
	lbl:SetText("Reports Completed: "..stats.Total30Days)
	lbl:SizeToContents()
	lbl:Dock(TOP)

	local lbl = vgui.Create("DLabel", panel)
	lbl:SetFont("Impulse-Elements18-Shadow")
	lbl:SetText("Average Response Time: "..math.floor(stats.TotalWait30Days / stats.Total30Days))
	lbl:SizeToContents()
	lbl:Dock(TOP)

	local lbl = vgui.Create("DLabel", panel)
	lbl:SetFont("Impulse-Elements18-Shadow")
	lbl:SetText("Average Investigation Time: "..math.floor(stats.TotalCloseWait30Days / stats.Total30Days))
	lbl:SizeToContents()
	lbl:Dock(TOP)

	local lbl = vgui.Create("DLabel", panel)
	lbl:SetFont("Impulse-Elements22-Shadow")
	lbl:SetText("\nAll Time")
	lbl:SizeToContents()
	lbl:Dock(TOP)

	local lbl = vgui.Create("DLabel", panel)
	lbl:SetFont("Impulse-Elements18-Shadow")
	lbl:SetText("Reports Completed: "..stats.Total)
	lbl:SizeToContents()
	lbl:Dock(TOP)

	local lbl = vgui.Create("DLabel", panel)
	lbl:SetFont("Impulse-Elements18-Shadow")
	lbl:SetText("Average Response Time: "..math.floor(stats.TotalWait / stats.Total))
	lbl:SizeToContents()
	lbl:Dock(TOP)

	local lbl = vgui.Create("DLabel", panel)
	lbl:SetFont("Impulse-Elements18-Shadow")
	lbl:SetText("Average Investigation Time: "..math.floor(stats.TotalCloseWait / stats.Total))
	lbl:SizeToContents()
	lbl:Dock(TOP)
end

function PANEL:PaintOver()
	if not self.Stats then
		draw.SimpleText("Grabbing data from Steam... (this gets stuck if Steam goes down)", "Impulse-Elements18-Shadow", 50, 50)
	end
end

vgui.Register("impulseStaffManager", PANEL, "DFrame")