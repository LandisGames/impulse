local PANEL = {}

local newReportCol = Color(173, 255, 47)
local claimedReportCol = Color(147, 112, 219)

function PANEL:Init()
	self:SetSize(480, 410)
	self:Center()
	self:SetTitle("ops reports")
	gui.EnableScreenClicker(true)
	self:SetPopupStayAtBack(true)

	local panel = self

	self.status = vgui.Create("DLabel", self)
	self.status:SetTall(50)
	self.status:Dock(TOP)

	function self.status:Paint()
		draw.SimpleText(panel.Status, "Impulse-Elements24-Shadow", 5, 5, panel.StatusCol)
		draw.SimpleText("Report queue:", "Impulse-Elements16", 5, 30, color_white)

		return true
	end

	function self.status:Think()
		local reports = impulse.Ops.Reports
		local cCount = 0
		local ucCount = 0

		for v,k in pairs(reports) do
			if k[3] and IsValid(k[3]) then
				cCount = cCount + 1

				if k[3] == LocalPlayer() then
					panel.Status = "Processing report #"..v.."..."
					panel.StatusCol = claimedReportCol
					return
				end
			else
				ucCount = ucCount + 1
			end
		end

		if ucCount > 0 then
			panel.Status = ucCount.." report(s) awaiting claim and "..cCount.." in processing..."
			panel.StatusCol = Color(255, 255, 0)
		else
			panel.Status = "No reports waiting."
			panel.StatusCol = Color(0, 255, 0)
		end
	end

	self:ReloadReports()
end

function PANEL:OnClose()
	gui.EnableScreenClicker(false)
end

function PANEL:ReloadReports()
	if IsValid(self.scroll) then
		self.scroll:Remove()
	end

	self.scroll = vgui.Create("DScrollPanel", self)
	self.scroll:Dock(FILL)

	for v,k in pairs(impulse.Ops.Reports or {}) do
		local report = self.scroll:Add("DPanel")
		report:SetTall(55)
		report:Dock(TOP)
		report.id = v
		report.data = k

		local id = report.id
		local data = k

		if not report.data[3] then
			local claimBtn =  vgui.Create("DButton", report)
			claimBtn:SetPos(300, 0)
			claimBtn:SetSize(40, 23)
			claimBtn:SetText("Claim")
			claimBtn:SetColor(Color(0, 255, 0))

			function claimBtn:DoClick()
				LocalPlayer():ConCommand("say /rc "..id)
			end
		else
			local replyBtn = vgui.Create("DButton", report)
			replyBtn:SetPos(300, 0)
			replyBtn:SetSize(40, 23)
			replyBtn:SetText("Reply")

			function replyBtn:DoClick()
				local reporteeName = "disconnected"

				if IsValid(report.data[1]) then
					reporteeName = report.data[1]:SteamName()
				end 

				local i = Derma_StringRequest("ops report reply to "..reporteeName, "Message to send:", nil, function(msg)
					net.Start("impulseChatMessage")
					net.WriteString("/rmsg "..msg)
					net.SendToServer()
				end, nil, "Send")

				local textEntry = i:GetChild(4):GetChildren()[2]
				local quickReplies = vgui.Create("DComboBox", i)
				quickReplies:SetPos(10, 90)
				quickReplies:SetSize(145, 20)
				quickReplies:SetValue("Quick replies")
				quickReplies:SetPopupStayAtBack(false)

				for v,k in pairs(impulse.Config.ModQuickReplies) do
					quickReplies:AddChoice(k)
				end

				function quickReplies:OnSelect()
					textEntry:SetValue(self:GetValue())
				end
			end
		end

		local viewBtn = vgui.Create("DButton", report)
		viewBtn:SetPos(340, 0)
		viewBtn:SetSize(40, 23)
		viewBtn:SetText("View")

		function viewBtn:DoClick()
			Derma_Message(string.Replace(data[2], "+", "\n").."\n                                                    ", "ops report #"..id.." message", "Close")
		end

		local gotoBtn = vgui.Create("DButton", report)
		gotoBtn:SetPos(380, 0)
		gotoBtn:SetSize(40, 23)
		gotoBtn:SetText("Goto")

		function gotoBtn:DoClick()
			LocalPlayer():ConCommand("say /rgoto")
		end

		local cardBtn = vgui.Create("DButton", report)
		cardBtn:SetPos(260, 0)
		cardBtn:SetSize(40, 23)
		cardBtn:SetText("Card")

		function cardBtn:DoClick()
			local ent = report.data[1]
			local badges = {}

			if not ent or not IsValid(ent) or not ent:IsPlayer() then
				return LocalPlayer():Notify("User left the game.")
			end

			for v,k in pairs(impulse.Badges) do
				if k[3](ent) then
					badges[v] = k
				end 	
			end

			impulse_infoCard = vgui.Create("impulsePlayerInfoCard")
			impulse_infoCard:SetPlayer(ent, badges)
		end

		local ownsReport = true
		if not report.data[3] or not IsValid(report.data[3]) or report.data[3] != LocalPlayer() then
			gotoBtn:SetDisabled(true)
			ownsReport = false
		end

		local closeBtn =  vgui.Create("DButton", report)
		closeBtn:SetPos(420, 0)
		closeBtn:SetSize(40, 23)
		closeBtn:SetText("Close")
		closeBtn:SetColor(Color(255, 0, 0))

		function closeBtn:DoClick()
			local ownsReport = true
			if not report.data[3] or not IsValid(report.data[3]) or report.data[3] != LocalPlayer() then
				ownsReport = false
			end

			if ownsReport then
				LocalPlayer():ConCommand("say /rcl")
			else
				Derma_Query("You are closing a report you have not claimed!\nDo not close reports that others are working on.","impulse", "I'm sure", function()
					LocalPlayer():ConCommand("say /rcl "..id)
				end, "Take me back!")
			end
		end

		function report:Paint(w, h)
			surface.SetDrawColor(Color(70, 70, 70))
			surface.DrawRect(0, 0, w, h)

			draw.SimpleText("#"..self.id, "Impulse-Elements16", 3, 4, color_white)

			if self.data[3] then
				local claimerName = "disconnected, close me!"
				local col = Color(255, 255, 0)

				if IsValid(self.data[3]) then
					claimerName = self.data[3]:SteamName()

					if self.data[3] == LocalPlayer() then
						col = claimedReportCol
					end
				end

				draw.SimpleText("Claimed by: "..claimerName, "Impulse-Elements16", 25, 4, col)
			else
				if self.data[4] then
					draw.SimpleText("Unclaimed (Dale replied)", "Impulse-Elements17", 25, 3, newReportCol)
				else
					draw.SimpleText("Unclaimed", "Impulse-Elements17", 25, 3, newReportCol)
				end
			end

			local reporteeName = "disconnected"
			if IsValid(self.data[1]) then
				reporteeName = self.data[1]:SteamName().." ("..self.data[1]:Nick()..")"
			end 

			draw.SimpleText("Submitted by: "..reporteeName, "Impulse-Elements16", 25, 19, color_white)
			draw.SimpleText("Message: "..self.data[2], "Impulse-Elements16", 3, 36, color_white)

			return true
		end
	end
end


local wait = 0
hook.Add("Think", "impulseReportMenuFastOpen", function()
	if (wait > CurTime()) then return end

	if input.IsKeyDown(KEY_F3) then
		if impulse_reportMenu and IsValid(impulse_reportMenu) then
			local alpha = impulse.GetSetting("admin_reportalpha", 130)

			if not impulse_reportMenu.changing then
				impulse_reportMenu.changing = true

				if impulse_reportMenu.hiding then
					gui.EnableScreenClicker(true)
					impulse_reportMenu:AlphaTo(255, 0.5, 0, function()
						if not IsValid(impulse_reportMenu) then return end
						impulse_reportMenu.changing = false
						impulse_reportMenu.hiding = false
					end)
				else
					gui.EnableScreenClicker(false)
					impulse_reportMenu:AlphaTo(alpha, 0.5, 0, function()
						if not IsValid(impulse_reportMenu) then return end
						impulse_reportMenu.changing = false
						impulse_reportMenu.hiding = true
					end)
				end
			end
		elseif LocalPlayer():IsAdmin() then
			impulse_reportMenu = vgui.Create("impulseReportMenu")
			wait = CurTime() + 1
		end

		if not LocalPlayer():IsAdmin() and not vgui.CursorVisible() then
			if not impulse_userReportMenu or not IsValid(impulse_userReportMenu) then
				impulse_userReportMenu = vgui.Create("impulseUserReportMenu")
			end
		end
	end

	if input.IsKeyDown(KEY_F2) and CUR_SNAPSHOT then
		impulse.Ops.ClearSnapshot()
		LocalPlayer():Notify("Snapshot closed.")
	end
end)

vgui.Register("impulseReportMenu", PANEL, "DFrame")