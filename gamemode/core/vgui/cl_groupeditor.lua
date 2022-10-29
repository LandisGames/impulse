local PANEL = {}

function PANEL:Init()
	self:SetSize(640, 500)
	self:Center()
	self:SetTitle("Group Menu")
	self:MakePopup()

	self.sheets = {}
	local panel = self

	if LocalPlayer():GetSyncVar(SYNC_GROUP_NAME, "") != "" then
		self:ShowGroup()
	else
		self:NoGroup()
	end
end

function PANEL:AddSheet(name, icon)
	local sheet = vgui.Create("DPanel", self.sheet)
	sheet.Paint = function() end
	sheet:DockMargin(5, 5, 5, 5)
	sheet:Dock(FILL)

	local x = self.sheet:AddSheet(name, sheet, icon)
	x.Panel.name = name
	x.Button.name = name
	table.insert(self.sheets, x.Panel)

	return sheet
end

function PANEL:NoGroup()
	local panel = self
	local darkText = Color(150, 150, 150, 210)

	local lbl = vgui.Create("DLabel", self)
	lbl:SetText("You are not a member of a group")
	lbl:SetFont("Impulse-Elements19-Shadow")
	lbl:Dock(TOP)
	lbl:SetTall(60)
	lbl:SetContentAlignment(2)
	lbl:SetTextColor(darkText)

	local lbl = vgui.Create("DLabel", self)
	lbl:SetText("Once you get invited to a group you'll be able to accept the invite here.")
	lbl:SetFont("Impulse-Elements14-Shadow")
	lbl:Dock(TOP)
	lbl:SetContentAlignment(5)
	lbl:SetTextColor(darkText)

	local scroll = vgui.Create("DScrollPanel", self)
	scroll:SetPos(125, 110)
	scroll:SetSize(480, 100)
	scroll:CenterHorizontal()

	for v,k in pairs(impulse.Group.Invites) do
		local btn = scroll:Add("DButton")
		btn:SetText("Accept invite to "..v.." from "..k)
		btn:Dock(TOP)

		function btn:DoClick()
			net.Start("impulseGroupDoInviteAccept")
			net.WriteString(v)
			net.SendToServer()

			impulse.Group.Invites[v] = nil
		end
	end

	local lbl = vgui.Create("DLabel", self)
	lbl:SetText("Create a new group")
	lbl:SetFont("Impulse-Elements19-Shadow")
	lbl:Dock(TOP)
	lbl:SetTall(150)
	lbl:SetContentAlignment(2)
	lbl:SetTextColor(darkText)

	local lbl = vgui.Create("DLabel", self)
	lbl:SetText("Creating a new group will cost "..impulse.Config.CurrencyPrefix..impulse.Config.GroupMakeCost.." and will require at least "..impulse.Config.GroupXPRequirement.."XP.")
	lbl:SetFont("Impulse-Elements14-Shadow")
	lbl:Dock(TOP)
	lbl:SetContentAlignment(5)
	lbl:SetTextColor(darkText)

	local newGroup = vgui.Create("DButton", self)
	newGroup:SetTall(25)
	newGroup:SetWide(450)
	newGroup:SetText("Create new group ("..impulse.Config.CurrencyPrefix..impulse.Config.GroupMakeCost..")")
	newGroup:DockMargin(120, 0, 120, 0)
	newGroup:Dock(TOP)

	function newGroup:DoClick()
		if LocalPlayer():GetXP() < impulse.Config.GroupXPRequirement then
			return LocalPlayer():Notify("You need at least "..impulse.Config.GroupXPRequirement.."XP to make a group.")
		end

		if not LocalPlayer():CanAfford(impulse.Config.GroupMakeCost) then
			return LocalPlayer():Notify("You can not afford to make a group.")
		end

		Derma_StringRequest("impulse",
			"Enter the group name below:\nTHIS CAN NOT BE EDITED LATER!",
			"",
			function(name)
				impulse.Group.Groups[1] = {}

				net.Start("impulseGroupDoCreate")
				net.WriteString(name)
				net.SendToServer()
			end, nil, "Create group")
	end
end

function PANEL:ShowGroup()
	local panel = self
	self.sheet = vgui.Create("DColumnSheet", self)
	self.sheet:Dock(FILL)

	local sheet = self:AddSheet("Overview", "icon16/vcard.png")
	local panel = self

	local lbl = vgui.Create("DLabel", sheet)
	lbl:SetText(LocalPlayer():GetSyncVar(SYNC_GROUP_NAME, "Unknown Name"))
	lbl:SetFont("Impulse-CharacterInfo-NO")
	lbl:SetPos(5, 0)
	lbl:SizeToContents()

	local group = impulse.Group.Groups[1]

	if not group then
		LocalPlayer():Notify("Failed to load group data!")
		return
	end

	if group.Color then
		lbl:SetTextColor(group.Color)
	end

	local lblM = vgui.Create("DLabel", sheet)
	lblM:SetText("")
	lblM:SetFont("Impulse-Elements20-Shadow")
	lblM:SetPos(5, 32)

	local lbl = vgui.Create("DLabel", sheet)
	lbl:SetText("Your rank: "..LocalPlayer():GetSyncVar(SYNC_GROUP_RANK, "Unknown Rank"))
	lbl:SetFont("Impulse-Elements20-Shadow")
	lbl:SetPos(5, 47)
	lbl:SizeToContents()

	local leave = vgui.Create("DButton", sheet)
	leave:SetText("Leave group")
	leave:SetPos(420, 7)
	leave:SetSize(80, 20)

	if LocalPlayer():GroupHasPermission(99) then
		leave:SetDisabled(true)
	end

	function leave:DoClick()
		Derma_Query("Are you sure you want to leave this group?",
			"impulse",
			"Leave",
			function()
				net.Start("impulseGroupDoLeave")
				net.SendToServer()
				panel:Remove()
			end, "Go back")
	end

	local inv = vgui.Create("DButton", sheet)
	inv:SetText("Invite a new member")
	inv:SetPos(5, 70)
	inv:SetSize(500, 20)

	function inv:DoClick()
		local m = DermaMenu()

		local gname = LocalPlayer():GetSyncVar(SYNC_GROUP_NAME, nil)

		if not gname then
			return
		end

		for v,k in pairs(player.GetAll()) do
			if k:GetSyncVar(SYNC_GROUP_NAME, nil) then
				continue
			end

			if k:IsCP() then
				continue
			end

			m:AddOption(k:Nick(), function()
				if not IsValid(panel) then
					return
				end

				if not IsValid(k) then
					return
				end

				net.Start("impulseGroupDoInvite")
				net.WriteEntity(k)
				net.SendToServer()
			end)
		end

		m:Open()
	end

	if not LocalPlayer():GroupHasPermission(3) then
		inv:SetDisabled(true)
	end

	local members = vgui.Create("DListView", sheet)
	members:SetPos(5, 100)
	members:SetSize(500, 360)
	members:SetMultiSelect(false)
	members:AddColumn("Name")
	members:AddColumn("Rank")
	members:AddColumn("Is Online")

	local ons = 0

	for v,k in SortedPairsByMemberValue(group.Members, "Rank") do
		local p = player.GetBySteamID(v)
		local state = "Offline"

		if IsValid(p) then
			state = "Online"
			ons = ons + 1
		end

		local line = members:AddLine(k.Name, k.Rank, state)
		line.SteamID = v
		line.Name = k.Name
	end

	lblM:SetText("Total members: "..table.Count(group.Members).." ("..ons.." online)")
	lblM:SizeToContents()

	function members:OnRowSelected(index, row)
		local sid = row.SteamID

		local m = DermaMenu()

		m:AddOption("View Steam profile", function()
			local sid64 = util.SteamIDTo64(sid)

			gui.OpenURL("https://steamcommunity.com/profiles/"..sid64)
		end)

		if LocalPlayer():GroupHasPermission(5) then
			local sRank = m:AddOption("Set rank")
			sRank:SetIcon("icon16/user_edit.png")
			local sub = sRank:AddSubMenu(a)

			for a,b in SortedPairs(group.Ranks) do
				if b[99] then
					continue
				end

				sub:AddOption(a, function()
					if not IsValid(panel) then
						return
					end

					net.Start("impulseGroupDoSetRank")
					net.WriteString(sid)
					net.WriteString(a)
					net.SendToServer()
				end)
			end
		end

		if LocalPlayer():GroupHasPermission(4) then
			local sRmv = m:AddOption("Remove", function()
				Derma_Query("Are you sure you wish to remove "..row.Name.."?",
					"impulse",
					"Yes",
					function()
						if not IsValid(panel) then
							return
						end

						net.Start("impulseGroupDoRemove")
						net.WriteString(sid)
						net.SendToServer()
					end,
					"No")
			end)
			sRmv:SetIcon("icon16/user_delete.png")
		end

		m:Open()
	end

	self:ShowInfo()

	if LocalPlayer():GroupHasPermission(6) then
		self:ShowRanks()
	end

	if LocalPlayer():GroupHasPermission(99) then
		self:ShowAdmin()
	end
end

local function addGroup(s, name)
	local sheet = vgui.Create("DPanel", s.ranks)
	sheet.Paint = function() end
	sheet:DockMargin(5, 5, 5, 5)
	sheet:Dock(FILL)

	s:AddSheet(name, sheet)

	return sheet
end

function PANEL:Refresh()
	if not IsValid(self.sheet) then
		self:Remove()

		impulse.groupEditor = vgui.Create("impulseGroupEditor")
		return 
	end

	--local lastTab = self.sheet:GetActiveButton().name

	self.sheet:Remove()
	self:Init()

	--for v,k in pairs(self.sheets) do
	--	print(k.name)
	--	if k.name == lastTab then
	--		self.sheet:SetActiveButton(k)
	--	end
	--end
end


function PANEL:ShowInfo()
	local group = impulse.Group.Groups[1]
	local name = LocalPlayer():GetSyncVar(SYNC_GROUP_NAME, "ERROR")
	local sheet = self:AddSheet("Info", "icon16/information.png")
	local canEdit = LocalPlayer():GroupHasPermission(8)

	local lbl = vgui.Create("DLabel", sheet)
	lbl:SetText("Group info:")
	lbl:SetFont("Impulse-Elements19-Shadow")
	lbl:SizeToContents()
	lbl:Dock(TOP)
	lbl:SetTextColor(darkText)

	local msg = vgui.Create("DTextEntry", sheet)
	msg:Dock(TOP)
	msg:SetTall(400)
	msg:SetFont("Impulse-Elements18")
	msg:SetText("")

	if group.Info then
		msg:SetText(group.Info)
	end
	
	msg:SetPlaceholderText("No infomation here yet...")
	msg:SetEditable(canEdit and true or false)
	msg:SetMultiline(true)
	msg:DockMargin(0, 5, 0, 0)

	if not canEdit then
		return
	end
	
	local btn = vgui.Create("DButton", sheet)
	btn:SetText("Update text")
	btn:DockMargin(0, 10, 0, 0)
	btn:Dock(TOP)

	function btn:DoClick()
		net.Start("impulseGroupDoSetInfo")
		net.WriteString(msg:GetValue())
		net.SendToServer()
	end
end

function PANEL:ShowRanks()
	local group = impulse.Group.Groups[1]
	local sheet = self:AddSheet("Ranks", "icon16/group_edit.png")
	local panel = self

	self.ranks = vgui.Create("DColumnSheet", sheet)
	self.ranks:Dock(FILL)

	self.ranks.Navigation:SetWide(150)

	for v,k in SortedPairs(group.Ranks) do
		local group = addGroup(self.ranks, v)

		local scroll = vgui.Create("DScrollPanel", group)
		scroll:Dock(FILL)

		local lbl = vgui.Create("DLabel", scroll)
		lbl:SetText("")
		lbl:SetColor(Color(220, 20, 60))
		lbl:SetFont("Impulse-Elements16-Shadow")
		lbl:Dock(TOP)

		local removable = true
		if k[99] or k[0] then
			lbl:SetText("this rank can not be removed")
			removable = false
		end

		local lbl = vgui.Create("DLabel", scroll)
		lbl:SetText("Name:")
		lbl:SetFont("Impulse-Elements18-Shadow")
		lbl:Dock(TOP)

		local name = vgui.Create("DTextEntry", scroll)
		name:SetValue(v)
		name:Dock(TOP)
		name:DockMargin(0, 0, 0, 5)

		local perms = {}
		for a,b in pairs(RPGROUP_PERMISSIONS) do
			local check = vgui.Create("DCheckBoxLabel", scroll)
			check:SetValue(k[a] or false)
			check:SetText(b)
			check:Dock(TOP)

			if a == 0 or a == 99 then
				check:SetDisabled(true)
			end

			perms[a] = check
		end

		local create = vgui.Create("DButton", scroll)
		create:SetText("Update rank")
		create:DockMargin(0, 10, 0, 0)
		create:Dock(TOP)

		function create:DoClick()
			local name = string.Trim(name:GetValue(), " ")

			net.Start("impulseGroupDoRankAdd")
			net.WriteString(v)
			if name != v then
				net.WriteBool(true)
				net.WriteString(name)
			else
				net.WriteBool(false)
			end
			for v,k in pairs(RPGROUP_PERMISSIONS) do
				net.WriteUInt(v, 8)
				net.WriteBool(perms[v]:GetChecked())
			end
			net.SendToServer()
		end

		local del = vgui.Create("DButton", scroll)
		del:SetText("Remove rank")
		del:SetTextColor(Color(255, 0, 0))
		del:DockMargin(0, 10, 0, 0)
		del:Dock(TOP)

		if not removable then
			del:SetDisabled(true)
		end

		function del:DoClick()
			Derma_Query("Are you sure you want to remove this rank?\nThis will set all rank members to the default rank.",
				"impulse",
				"Remove",
				function()
					if not IsValid(panel) then
						return
					end

					net.Start("impulseGroupDoRankRemove")
					net.WriteString(v)
					net.SendToServer()
				end,
				"Take me back")
		end
	end

	local addRank = addGroup(self.ranks, "New rank...")

	local scroll = vgui.Create("DScrollPanel", addRank)
	scroll:Dock(FILL)

	local lbl = vgui.Create("DLabel", scroll)
	lbl:SetText("Create new rank:")
	lbl:SetFont("Impulse-Elements16-Shadow")
	lbl:Dock(TOP)

	local lbl = vgui.Create("DLabel", scroll)
	lbl:SetText("Name:")
	lbl:SetFont("Impulse-Elements18-Shadow")
	lbl:Dock(TOP)

	local name = vgui.Create("DTextEntry", scroll)
	name:SetValue("Rank name")
	name:Dock(TOP)
	name:DockMargin(0, 0, 0, 5)

	local perms = {}
	for a,b in pairs(RPGROUP_PERMISSIONS) do
		local check = vgui.Create("DCheckBoxLabel", scroll)
		check:SetValue(false)
		check:SetText(b)
		check:Dock(TOP)
		check.PermID = a

		if a == 0 or a == 99 then
			check:SetDisabled(true)
		end

		perms[a] = check
	end

	local create = vgui.Create("DButton", scroll)
	create:SetText("Create rank")
	create:DockMargin(0, 10, 0, 0)
	create:Dock(TOP)

	function create:DoClick()
		local name = string.Trim(name:GetValue(), " ")

		net.Start("impulseGroupDoRankAdd")
		net.WriteString(name)
		net.WriteBool(false)
		for v,k in pairs(RPGROUP_PERMISSIONS) do
			net.WriteUInt(v, 8)
			net.WriteBool(perms[v]:GetChecked())
		end
		net.SendToServer()
	end
end


function PANEL:ShowAdmin()
	local group = impulse.Group.Groups[1]
	local name = LocalPlayer():GetSyncVar(SYNC_GROUP_NAME, "ERROR")
	local sheet = self:AddSheet("Admin", "icon16/shield.png")

	local lbl = vgui.Create("DLabel", sheet)
	lbl:SetText("Group colour")
	lbl:SetFont("Impulse-Elements19-Shadow")
	lbl:SizeToContents()
	--lbl:DockMargin(0, 10, 0, 0)
	lbl:Dock(TOP)
	lbl:SetTextColor(darkText)

	local colPicker = vgui.Create("DColorMixer", sheet)
	colPicker:Dock(TOP)
	colPicker:DockMargin(0, 10, 0, 0)
	colPicker:SetPalette(false)
	colPicker:SetAlphaBar(false)
	colPicker:SetWangs(true)
	colPicker:SetTall(70)

	if group.Color then
		colPicker:SetColor(group.Color)
	else
		colPicker:SetColor(Color(0, 0, 0))
	end

	local btn = vgui.Create("DButton", sheet)
	btn:SetText("Update colour")
	btn:DockMargin(0, 10, 0, 0)
	btn:Dock(TOP)

	function btn:DoClick()
		local col = colPicker:GetColor()

		print(col)

		net.Start("impulseGroupDoSetColor")
		net.WriteColor(Color(col.r, col.g, col.b, 255))
		net.SendToServer()
	end

	local lbl = vgui.Create("DLabel", sheet)
	lbl:SetText("Administrative actions")
	lbl:SetFont("Impulse-Elements19-Shadow")
	lbl:SizeToContents()
	lbl:DockMargin(0, 25, 0, 0)
	lbl:Dock(TOP)
	lbl:SetTextColor(darkText)

	local del = vgui.Create("DButton", sheet)
	del:SetText("Close group (this can not be undone)")
	del:SetTextColor(Color(255, 0, 0))
	del:DockMargin(0, 10, 0, 0)
	del:Dock(TOP)

	local panel = self

	function del:DoClick()
		Derma_StringRequest("impulse", 
			"Closing this group will delete it forever. You will have to pay to make another group.\nPlease type '"..name.."' below to confirm the deletion:",
			"",
			function(text)
				if text != name then
					return LocalPlayer():Notify("Name does not match.")
				end

				net.Start("impulseGroupDoDelete")
				net.SendToServer()

				panel:Remove()
			end, nil, "Delete forever")
	end
end

vgui.Register("impulseGroupEditor", PANEL, "DFrame")