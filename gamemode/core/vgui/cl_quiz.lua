local PANEL = {}

function PANEL:Init()
	self:SetSize(640, 500)
	self:Center()
	self:SetTitle("")
	self:ShowCloseButton(false)
	self:MakePopup()

	self.darkOverlay = Color(40, 40, 40, 160)

	self.info = vgui.Create("DLabel", self)
	self.info:SetFont("Impulse-Elements14")
	self.info:SetText("Before you can become this team, you must complete a basic competency quiz.\nPlease complete the questions below, if you fail you will have to wait "..impulse.Config.QuizWaitTime.." minutes to take the quiz again.\nDo NOT ask other players for the answers.")
	self.info:SizeToContents()
	self.info:Dock(TOP)

	self.scroll = vgui.Create("DScrollPanel", self)
	self.scroll:DockMargin(5, 20, 5, 20)
	self.scroll:Dock(FILL)
end

function PANEL:SetQuiz(team)
	local teamData = impulse.Teams.Data[team]
	local selections = {}
	self:SetTitle(teamData.name.." Entry Quiz")

	self.StartTeam = LocalPlayer():Team()

	for v,k in pairs(teamData.quiz) do
		selections[v] = {}

		local bg = vgui.Create("DPanel", self.scroll)
		bg:SetSize(300, 100)
		bg:DockMargin(5, 10, 10, 10)
		bg:Dock(TOP)

		local panel = self

		function bg:Paint(w, h)
			surface.SetDrawColor(panel.darkOverlay)
			surface.DrawRect(0, 0, w, h)
			return true
		end

		local question =  vgui.Create("DLabel", bg)
		question:SetText(k.question)
		question:SetFont("Impulse-Elements16")
		question:SetPos(5, 5)
		question:SetSize(580, 90)
		question:SetContentAlignment(7)
		question:SetWrap(true)

		local answerbox = vgui.Create("DComboBox", bg)
		answerbox:Dock(BOTTOM)
		answerbox:SetValue("Select answer...")
		answerbox.question = v

		for a,b in pairs(k.answers) do
			answerbox:AddChoice(b[1], b[2])
		end

		function answerbox:OnSelect(index, value, data)
			selections[self.question] = {self.question, data}
		end
	end

	self.finish = vgui.Create("DButton", self)
	self.finish:SetSize(300, 40)
	self.finish:Dock(BOTTOM)
	self.finish:SetText("Complete Quiz")
	self.finish:SetDisabled(true)

	function self.finish:Think()
		for v,k in pairs(selections) do
			if not k[1] then
				return
			end
		end

		self:SetEnabled(true)
	end

	local panel = self
	function self.finish:DoClick()
		local passed = true
		local answers = impulse.Teams.Data[team].quiz

		for v,k in pairs(selections) do
			local isCorrect = k[2]

			if not isCorrect then
				passed = false
				break
			end
		end

		net.Start("impulseQuizSubmit")
		net.WriteUInt(team, 8)
		net.WriteBool(passed)
		net.SendToServer()

		panel:Remove()
	end
end

function PANEL:Think()
	if self.StartTeam and (not LocalPlayer():Alive() or LocalPlayer():Team() != self.StartTeam) then
		self:Remove()
	end
end

vgui.Register("impulseQuiz", PANEL, "DFrame")