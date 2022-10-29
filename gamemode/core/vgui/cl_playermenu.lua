local PANEL = {}

function PANEL:Init()
	self:SetSize(HIGH_RES(770, 770 * 1.5), HIGH_RES(580, 580 * 1.5))
	self:Center()
	self:SetTitle("Player menu")
	self:MakePopup()

	self.darkOverlay = Color(40, 40, 40, 160)

	self.tabSheet = vgui.Create("DColumnSheet", self)
	self.tabSheet:Dock(FILL)
	self.tabSheet.Navigation:SetWidth(100)

	-- actions
	self.quickActions = vgui.Create("DPanel", self.tabSheet)
	self.quickActions:Dock(FILL)
	function self.quickActions:Paint(w, h)
		return true
	end

	-- teams
	self.teams = vgui.Create("DPanel", self.tabSheet)
	self.teams:Dock(FILL)
	function self.teams:Paint(w, h)
		return true
	end

	-- business
	self.business = vgui.Create("DPanel", self.tabSheet)
	self.business:Dock(FILL)
	function self.business:Paint()
		return true
	end

	-- info
	self.info = vgui.Create("DPanel", self.tabSheet)
	self.info:Dock(FILL)
	function self.info:Paint(w, h)
		return true
	end

	local defaultButton = self:AddSheet("Actions", Material("impulse/icons/banknotes-256.png"), self.quickActions, self.QuickActions)
	self:AddSheet("Teams", Material("impulse/icons/group-256.png"), self.teams, self.Teams)
	self:AddSheet("Business", Material("impulse/icons/cart-73-256.png"), self.business, self.Business)
	self:AddSheet("Information", Material("impulse/icons/info-256.png"), self.info, self.Info)

	self.tabSheet:SetActiveButton(defaultButton)
	defaultButton.loaded = true
	self:QuickActions()
	self.tabSheet.ActiveButton.Target:SetVisible(true)
	self.tabSheet.Content:InvalidateLayout()
end

function PANEL:QuickActions()
	self.quickActionsInner = vgui.Create("DPanel", self.quickActions)
	self.quickActionsInner:Dock(FILL)

	local panel = self
	function self.quickActionsInner:Paint(w, h)
		surface.SetDrawColor(panel.darkOverlay)
		surface.DrawRect(0, 0, w, h)
		return true
	end

	self.collapsableOptions = vgui.Create("DCollapsibleCategory", self.quickActionsInner)
	self.collapsableOptions:SetLabel("Actions")
	self.collapsableOptions:Dock(TOP)
	local colInv = Color(0, 0, 0, 0)
	function self.collapsableOptions:Paint()
		self:SetBGColor(colInv)
	end

	function self.collapsableOptions:Toggle() -- allowing them to accordion causes bugs
		return
	end

	self.collapsableOptionsScroll = vgui.Create("DScrollPanel", self.collapsableOptions)
	self.collapsableOptionsScroll:Dock(FILL)
	self.collapsableOptions:SetContents(self.collapsableOptionsScroll)

	self.list = vgui.Create("DIconLayout", self.collapsableOptionsScroll)
	self.list:Dock(FILL)
	self.list:SetSpaceY(5)
	self.list:SetSpaceX(5)

	local btn = self.list:Add("DButton")
	if impulse.IsHighRes() then btn:SetTall(30) btn:SetFont("Impulse-Elements17-Shadow") end
	btn:Dock(TOP)
	btn:SetText("Drop money")
	function btn:DoClick()
		Derma_StringRequest("impulse", "Enter amount of money to drop:", nil, function(amount)
			LocalPlayer():ConCommand("say /dropmoney "..amount)
		end)
	end

	local btn = self.list:Add("DButton")
	if impulse.IsHighRes() then btn:SetTall(30) btn:SetFont("Impulse-Elements17-Shadow") end
	btn:Dock(TOP)
	btn:SetText("Write a letter")
	function btn:DoClick()
		Derma_StringRequest("impulse", "Write letter content:", nil, function(text)
			LocalPlayer():ConCommand("say /write "..text)
		end)
	end

	local btn = self.list:Add("DButton")
	if impulse.IsHighRes() then btn:SetTall(30) btn:SetFont("Impulse-Elements17-Shadow") end
	btn:Dock(TOP)
	btn:SetText("Change RP name (requires "..impulse.Config.CurrencyPrefix..impulse.Config.RPNameChangePrice..")")
	function btn:DoClick()
		Derma_StringRequest("impulse", "Enter your new RP name:", nil, function(text)
			net.Start("impulseChangeRPName")
			net.WriteString(text)
			net.SendToServer()
		end)
	end

	local btn = self.list:Add("DButton")
	if impulse.IsHighRes() then btn:SetTall(30) btn:SetFont("Impulse-Elements17-Shadow") end
	btn:Dock(TOP)
	btn:SetText("Sell all doors")
	function btn:DoClick()
		net.Start("impulseSellAllDoors")
		net.SendToServer()
	end

	self.collapsableOptions = vgui.Create("DCollapsibleCategory", self.quickActionsInner)
	self.collapsableOptions:SetLabel(team.GetName(LocalPlayer():Team()).." options")
	self.collapsableOptions:Dock(TOP)
	local colTeam = team.GetColor(LocalPlayer():Team())
	function self.collapsableOptions:Paint(w, h)
		surface.SetDrawColor(colTeam)
		surface.DrawRect(0, 0, w, 20)
		self:SetBGColor(colInv)
	end

	function self.collapsableOptions:Toggle() -- allowing them to accordion causes bugs
		return
	end

	self.collapsableOptionsScroll = vgui.Create("DScrollPanel", self.collapsableOptions)
	self.collapsableOptionsScroll:Dock(FILL)
	self.collapsableOptions:SetContents(self.collapsableOptionsScroll)

	self.list = vgui.Create("DIconLayout", self.collapsableOptionsScroll)
	self.list:Dock(FILL)
	self.list:SetSpaceY(5)
	self.list:SetSpaceX(5)

	local classes = impulse.Teams.Data[LocalPlayer():Team()].classes
	if classes and LocalPlayer():InSpawn() then
		for v,classData in pairs(classes) do
			if not classData.noMenu and LocalPlayer():GetTeamClass() != v then
				local btn = self.list:Add("DButton")
				if impulse.IsHighRes() then btn:SetTall(30) btn:SetFont("Impulse-Elements17-Shadow") end
				btn:Dock(TOP)
				btn.classID = v

				local btnText = "Become "..classData.name
				if classData.xp then
					btnText = btnText.." ("..classData.xp.."XP)"
				end
				btn:SetText("Become "..classData.name.." ("..classData.xp.."XP)")

				local panel = self
				function btn:DoClick()
					net.Start("impulseClassChange")
					net.WriteUInt(btn.classID, 8)
					net.SendToServer()
				end
			end
		end
	end
end

function PANEL:Teams()
	self.modelPreview = vgui.Create("DModelPanel", self.teams)
	self.modelPreview:SetPos(373, 0)
	self.modelPreview:SetSize(300, 370)
	self.modelPreview:MoveToBack()
	self.modelPreview:SetCursor("arrow")
	self.modelPreview:SetFOV(self.modelPreview:GetFOV() - 19)
 	function self.modelPreview:LayoutEntity(ent)
 		ent:SetAngles(Angle(0, 43, 0))
 		--ent:SetSequence(ACT_IDLE)
 		--self:RunAnimation()
 	end

 	self.descLbl = vgui.Create("DLabel", self.teams)
 	self.descLbl:SetText("Description:")
 	self.descLbl:SetFont("Impulse-Elements18")
 	self.descLbl:SizeToContents()
 	self.descLbl:SetPos(410, 380)

  	self.descLblT = vgui.Create("DLabel", self.teams)
 	self.descLblT:SetText("")
 	self.descLblT:SetFont("Impulse-Elements14")
 	self.descLblT:SetPos(410, 400)
 	self.descLblT:SetContentAlignment(7)
  	self.descLblT:SetSize(230, 230)

	self.teamsInner = vgui.Create("DPanel", self.teams)
	self.teamsInner:SetSize(400, 580)
	local panel = self
	function self.teamsInner:Paint(w, h)
		surface.SetDrawColor(panel.darkOverlay)
		surface.DrawRect(0, 0, w, h)
		return true
	end

	self.availibleTeams = vgui.Create("DCollapsibleCategory", self.teamsInner)
	self.availibleTeams:SetLabel("Available teams")
	self.availibleTeams:Dock(TOP)
	local colInv = Color(0, 0, 0, 0)
	function self.availibleTeams:Paint()
		self:SetBGColor(colInv)
	end

	self.availibleTeamsScroll = vgui.Create("DScrollPanel", self.availibleTeams)
	self.availibleTeamsScroll:Dock(FILL)
	self.availibleTeams:SetContents(self.availibleTeamsScroll)

	local availibleList = vgui.Create("DIconLayout", self.availibleTeamsScroll)
	availibleList:Dock(FILL)
	availibleList:SetSpaceY(5)
	availibleList:SetSpaceX(5)

	self.unavailibleTeams = vgui.Create("DCollapsibleCategory", self.teamsInner)
	self.unavailibleTeams:SetLabel("Unavailable teams")
	self.unavailibleTeams:Dock(TOP)
	function self.unavailibleTeams:Paint()
		self:SetBGColor(colInv)
	end

	self.unavailibleTeamsScroll = vgui.Create("DScrollPanel", self.unavailibleTeams)
	self.unavailibleTeamsScroll:Dock(FILL)
	self.unavailibleTeams:SetContents(self.unavailibleTeamsScroll)

	local unavailibleList = vgui.Create("DIconLayout", self.unavailibleTeamsScroll)
	unavailibleList:Dock(FILL)
	unavailibleList:SetSpaceY(5)
	unavailibleList:SetSpaceX(5)

	for v,k in pairs(impulse.Teams.Data) do
		local selectedList

		if (k.xp > LocalPlayer():GetXP()) or (k.donatorOnly and k.donatorOnly == true and LocalPlayer():IsDonator() == false) then
			selectedList = unavailibleList
		else
			selectedList = availibleList
		end

		local teamCard = selectedList:Add("impulseTeamCard")
		teamCard:SetTeam(v)
		teamCard.team = v
		teamCard:Dock(TOP)
		teamCard:SetHeight(60)
		teamCard:SetMouseInputEnabled(true)
		
		local realSelf = self

		function teamCard:OnCursorEntered()
			local model = impulse.Teams.Data[self.team].model
			local skin = impulse.Teams.Data[self.team].skin or 0
			local desc = impulse.Teams.Data[self.team].description
			local bodygroups = impulse.Teams.Data[self.team].bodygroups

			if not model then
				model = impulse_defaultModel or "models/Humans/Group01/male_02.mdl" 
				skin = impulse_defaultSkin or 0
			end

			realSelf.modelPreview:SetModel(model)
			realSelf.modelPreview.Entity:SetSkin(skin)

			if bodygroups then
				for v, bodygroupData in pairs(bodygroups) do
					realSelf.modelPreview.Entity:SetBodygroup(bodygroupData[1], (bodygroupData[2] or 0))
				end
			end

			realSelf.descLblT:SetText(desc)
			realSelf.descLblT:SetWrap(true)
		end

		function teamCard:OnMousePressed()
			net.Start("impulseTeamChange")
			net.WriteUInt(self.team, 8)
			net.SendToServer()

			realSelf:Remove()
		end
	end
end

function PANEL:Business()
	self.businessInner = vgui.Create("DPanel", self.business)
	self.businessInner:Dock(FILL)

	local panel = self
	function self.businessInner:Paint(w, h)
		surface.SetDrawColor(panel.darkOverlay)
		surface.DrawRect(0, 0, w, h)
		return true
	end

	self.itemsScroll = vgui.Create("DScrollPanel", self.businessInner)
	self.itemsScroll:Dock(FILL)

	self.utilItems = self.itemsScroll:Add("DCollapsibleCategory")
	self.utilItems:SetLabel("Utilities")
	self.utilItems:Dock(TOP)
	local colInv = Color(0, 0, 0, 0)
	function self.utilItems:Paint()
		self:SetBGColor(colInv)
	end

	local utilList = vgui.Create("DIconLayout", self.utilItems)
	utilList:Dock(FILL)
	utilList:SetSpaceY(5)
	utilList:SetSpaceX(5)
	self.utilItems:SetContents(utilList)

	self.cat = {}

	for name,k in pairs(impulse.Business.Data) do
		if not LocalPlayer():CanBuy(name) then
			continue
		end

		local parent = nil

		if k.category then
			if self.cat[k.category] then
				parent = self.cat[k.category]
			else
				local cat = self.itemsScroll:Add("DCollapsibleCategory")
				cat:SetLabel(k.category)
				cat:Dock(TOP)
				local colInv = Color(0, 0, 0, 0)
				function cat:Paint()
					self:SetBGColor(colInv)
				end

				self.cat[k.category] = vgui.Create("DIconLayout", cat)
				self.cat[k.category]:Dock(FILL)
				self.cat[k.category]:SetSpaceY(5)
				self.cat[k.category]:SetSpaceX(5)
				cat:SetContents(self.cat[k.category])

				parent = self.cat[k.category]
			end
		end

		local item = (parent or utilList):Add("SpawnIcon")

		if k.item then
			local x = impulse.Inventory.Items[impulse.Inventory.ClassToNetID(k.item)]
			item:SetModel(x.Model)
		else
			item:SetModel(k.model)
		end

		if impulse.IsHighRes() then
			item:SetSize(78,78)
		else
			item:SetSize(58,58)
		end
		item:SetTooltip(name.." \n"..impulse.Config.CurrencyPrefix..k.price)
		item.id = table.KeyFromValue(impulse.Business.DataRef, name)

		function item:DoClick()
			net.Start("impulseBuyItem")
			net.WriteUInt(item.id, 8)
			net.SendToServer()
		end

		local costLbl = vgui.Create("DLabel", item)
		costLbl:SetPos(5,HIGH_RES(35, 55))
		costLbl:SetFont(HIGH_RES("Impulse-Elements20-Shadow", "Impulse-Elements22-Shadow"))
		costLbl:SetText(impulse.Config.CurrencyPrefix..k.price)
		costLbl:SizeToContents()
	end
end

function PANEL:Info()
	self.infoSheet = vgui.Create("DPropertySheet", self.info)
	self.infoSheet:Dock(FILL)

	local webRules = vgui.Create("DHTML", self.infoSheet)
	webRules:OpenURL(impulse.Config.RulesURL)

	self.infoSheet:AddSheet("Rules", webRules)

	local webTutorial = vgui.Create("DHTML", self.infoSheet)
	webTutorial:OpenURL(impulse.Config.TutorialURL)

	self.infoSheet:AddSheet("Help & Tutorials", webTutorial)

	local commands = vgui.Create("DScrollPanel", self.infoSheet)
	commands:Dock(FILL)

	for v,k in pairs(impulse.chatCommands) do
		local c = impulse.Config.MainColour
 						
 		if k.adminOnly == true and LocalPlayer():IsAdmin() == false then 
 			continue 
 		elseif k.adminOnly == true then
 			c = impulse.Config.InteractColour
 		end
 						
 		if k.superAdminOnly == true and LocalPlayer():IsSuperAdmin() == false then 
 			continue 
 		elseif k.superAdminOnly == true then
 			c = Color(255, 0, 0, 255)
 		end

		local command = commands:Add("DPanel", commands)
		command:SetTall(40)
		command:Dock(TOP)
		command.name = v
		command.desc = k.description
		command.col = c

		function command:Paint()
			draw.SimpleText(self.name, "Impulse-Elements22-Shadow", 5, 0, self.col)
			draw.SimpleText(self.desc, "Impulse-Elements18-Shadow", 5, 20, color_white)
			return true
		end
	end

	self.infoSheet:AddSheet("Commands", commands)
end

function PANEL:AddSheet(name, icon, pnl, loadFunc)
	local tab = self.tabSheet:AddSheet(name, pnl)
	local panel = self
	tab.Button:SetSize(120, 130)

	function tab.Button:Paint(w, h)
		if panel.tabSheet.ActiveButton == self then
			surface.SetDrawColor(impulse.Config.MainColour)
		else
			surface.SetDrawColor(color_white)
		end
		surface.SetMaterial(icon)
		surface.DrawTexturedRect(0, 0, w-10, h-40)

		draw.DrawText(name, HIGH_RES("Impulse-Elements18", "Impulse-Elements20A-Shadow"), (w-10)/2, 95, color_white, TEXT_ALIGN_CENTER)

		return true
	end

	local oldClick = tab.Button.DoClick
	function tab.Button:DoClick()
		oldClick()

		if loadFunc and not self.loaded then
			loadFunc(panel)
			self.loaded = true
		end
	end
	return tab.Button
end

vgui.Register("impulsePlayerMenu", PANEL, "DFrame")