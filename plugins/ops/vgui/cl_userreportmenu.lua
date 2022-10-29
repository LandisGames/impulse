local PANEL = {}

function PANEL:Init()
	self:SetSize(605, 470)
	self:Center()
	self:SetTitle("Reports")
	self:MakePopup()

	self:SetupUI()
end

function PANEL:AddLog(message, isMe, timestamp)
	local entry = self.log:Add("DPanel")
	entry:SetTall(35)
	entry:Dock(TOP)

	local gap = 300
	if isMe then
		entry:DockMargin(0, 0, gap, 8)
	else
		entry:DockMargin(gap, 0, 0, 8)
	end

	-- Encode message into markup
	local msg = "<font=Impulse-Elements16-Shadow>"

	for k, v in ipairs(message) do
		if type(v) == "table" then
			msg = msg.."<color="..v.r..","..v.g..","..v.b..">"
		else
			msg = msg..tostring(v):gsub("<", "&lt;"):gsub(">", "&gt;")
		end
	end
	msg = msg.."</font>"

	-- parse
	entry.message = markup.Parse(msg, 250)

	-- set frame position and height to suit the markup
	local height = 14 + entry.message:GetHeight()
	entry:SetTall(math.Clamp(height + 1, 35, 1000))

	local bodyCol = Color(50, 50, 50, 210)
	local meCol = Color(90, 90, 90, 210)
	function entry:Paint(w, h)
		if isMe then
			surface.SetDrawColor(meCol)
		else
			surface.SetDrawColor(bodyCol)
		end

		surface.DrawRect(0, 0, w, h)

		self.message:Draw(7, 14, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end

	if timestamp then
		local stamp = vgui.Create("DLabel", entry)
		stamp.timestamp = timestamp
		stamp:SetText(string.NiceTime(CurTime() - timestamp).." ago")
		stamp:SetSize(120, 12)
		stamp:SetFont("Impulse-Elements14-Shadow")
		stamp:SetPos(2, 2)

		function stamp:Think()
			self:SetText(string.NiceTime(CurTime() - self.timestamp).." ago")
		end
	end
end

function PANEL:SetupUI()
	local curReport = impulse.Ops.CurReport

	if self.title then
		self.title:Remove()
	end

	if self.log then
		self.log:Remove()
	end

	local text = ""

	if self.entry then
		text = self.entry:GetValue()
		self.entry:Remove()
		self.sendBtn:Remove()
	end

	if self.warn then
		self.warn:Remove()
	end

	if self.lbl then
		self.lbl:Remove()
	end

	self.title = vgui.Create("DLabel", self)
	self.title:SetFont("Impulse-Elements27-Shadow")
	self.title:SetPos(10, 30)

	local sendText = "Submit"

	if curReport then
		self.title:SetText("Active report #"..curReport)
		sendText = "Update"
	else
		self.title:SetText("Submit a new report")
	end

	self.title:SizeToContents()

	if curReport then
		self.warn = vgui.Create("DLabel", self)
		self.warn:SetFont("Impulse-Elements14-Shadow")
		self.warn:SetPos(10 + self.title:GetWide() + 3, 40)
		self.warn:SetText("Please note: All reports are recorded for quality control purposes.")
		self.warn:SizeToContents()
	end

	self.log = vgui.Create("DScrollPanel", self)
	self.log:SetPos(10, 60)
	self.log:SetSize(585, 290)
	self.log:GetVBar():AnimateTo(1000000, 0)

	local hasLog = false

	for v,k in pairs(impulse.Ops.Log) do
		self:AddLog(k.message, k.isMe, k.time)
		hasLog = true
	end

	if not hasLog then
		local darkText = Color(150, 150, 150, 210)
		local lbl = self.log:Add("DLabel")
		lbl:SetText("No report history here yet")
		lbl:SetFont("Impulse-Elements19-Shadow")
		lbl:Dock(TOP)
		lbl:SetContentAlignment(5)
		lbl:SetTextColor(darkText)

		local lbl = self.log:Add("DLabel")
		lbl:SetText("Once you submit a report you'll see the report history and additional report information here.")
		lbl:SetFont("Impulse-Elements14-Shadow")
		lbl:Dock(TOP)
		lbl:SetContentAlignment(5)
		lbl:SetTextColor(darkText)

		local lbl = self.log:Add("DLabel")
		lbl:SetText("How to submit a report")
		lbl:SetFont("Impulse-Elements19-Shadow")
		lbl:Dock(TOP)
		lbl:SetTall(60)
		lbl:SetContentAlignment(2)
		lbl:SetTextColor(darkText)

		local lbl = self.log:Add("DLabel")
		lbl:SetText("If you'd like to submit a report please enter a description in the box below and click submit.\nReports with invalid descriptions may be rejected.\nIf you forget anything or the circumtances of your report changes, just open this menu and update us.")
		lbl:SetFont("Impulse-Elements14-Shadow")
		lbl:Dock(TOP)
		lbl:SetTall(45)
		lbl:SetContentAlignment(8)
		lbl:SetTextColor(darkText)

		local lbl = self.log:Add("DLabel")
		lbl:SetText("We'll respond as soon as possible")
		lbl:SetFont("Impulse-Elements19-Shadow")
		lbl:Dock(TOP)
		lbl:SetTall(60)
		lbl:SetContentAlignment(2)
		lbl:SetTextColor(darkText)

		local lbl = self.log:Add("DLabel")
		lbl:SetText("When your report is submitted it will be put into the queue, please note this queue can be large.\nIt may some take time for a game moderator to become available.\nWhile waiting check the report log to see the status of your report and avoid asking in OOC.")
		lbl:SetFont("Impulse-Elements14-Shadow")
		lbl:Dock(TOP)
		lbl:SetTall(50)
		lbl:SetContentAlignment(8)
		lbl:SetTextColor(darkText)
	end

	self.lbl = vgui.Create("DLabel", self)
	self.lbl:SetFont("Impulse-Elements18-Shadow")
	self.lbl:SetPos(10, 355)
	self.lbl:SetText("Message:")
	self.lbl:SizeToContents()

	self.entry = vgui.Create("DTextEntry", self)
	self.entry:SetPos(10, 375)
	self.entry:SetSize(585, 50)
	self.entry:SetMultiline(true)
	self.entry:SetEnterAllowed(false)
	self.entry:SetFont("Impulse-Elements16")
	self.entry:SetValue(text)

	self.sendBtn = vgui.Create("DButton", self)
	self.sendBtn:SetPos(10, 430)
	self.sendBtn:SetSize(130, 30)
	self.sendBtn:SetText(sendText)

	local panel = self

	function self.sendBtn:DoClick()
		local msg = string.Trim(panel.entry:GetValue(), " ")

		if msg:len() < 3 then
			return LocalPlayer():Notify("Report message too short.")
		end

		impulse_reportMessage = msg

		panel.entry:SetValue("")

		net.Start("impulseChatMessage")
		net.WriteString("/report "..msg)
		net.SendToServer()
	end
end

vgui.Register("impulseUserReportMenu", PANEL, "DFrame")

concommand.Add("impulse_userreportmenu", function()
	if not impulse_userReportMenu or not IsValid(impulse_userReportMenu) then
		impulse_userReportMenu = vgui.Create("impulseUserReportMenu")
	end
end)