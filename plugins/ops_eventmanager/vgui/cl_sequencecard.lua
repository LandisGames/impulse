local PANEL = {}

function PANEL:Init()
end

function PANEL:SetSequence(key, data)
	self.main = vgui.Create("DCollapsibleCategory", self)
	self.main:Dock(FILL)
	self.main:SetLabel("Sequence: "..key)
	self.main.Header:SetTall(25)
	self.main:SetTooltip("Version hash: "..(impulse.Ops.EventManager.Sequences[key].VersionHash or "outdated"))

	self.mainScroll = vgui.Create("DScrollPanel", self.main)
	self.mainScroll:Dock(FILL)
	self.main:SetContents(self.mainScroll)

	self.mainList = vgui.Create("DIconLayout", self.mainScroll)
	self.mainList:Dock(FILL)
	self.mainList:SetSpaceY(5)
	self.mainList:SetSpaceX(5)

	self.Sequence = key

	for v,k in pairs(data.Events) do
		self:AddEvent(v, k)
	end

	local panel = self

	local newSeq = vgui.Create("DButton", self.main)
	newSeq:SetPos(540, 0)
	newSeq:SetSize(100, 20)
	newSeq:SetText("Add event")
	newSeq:SetImage("icon16/script_add.png")

	function newSeq:DoClick()
		local id = table.insert(impulse.Ops.EventManager.Sequences[key].Events, {
			Type = "empty",
			Prop = {},
			UID = nil,
			Delay = 0
		})

		table.Merge(impulse.Ops.EventManager.Sequences[key].Events[id].Prop, impulse.Ops.EventManager.Config.Events["empty"].Prop)

		panel:AddEvent(id, impulse.Ops.EventManager.Sequences[key].Events[id])
	end

	local remSeq = vgui.Create("DButton", self.main)
	remSeq:SetPos(435, 0)
	remSeq:SetSize(100, 20)
	remSeq:SetText("Close")
	remSeq:SetImage("icon16/delete.png")

	function remSeq:DoClick()
		impulse.Ops.EventManager.Sequences[key] = nil
		panel.Dad:ReloadSequences()
	end

	local saveSeq = vgui.Create("DButton", self.main)
	saveSeq:SetPos(330, 0)
	saveSeq:SetSize(100, 20)
	saveSeq:SetText("Save")
	saveSeq:SetImage("icon16/script_save.png")

	function saveSeq:DoClick()
		if not impulse.Ops.EventManager.Sequences[key].FileName then
			Derma_StringRequest("impulse", "Enter sequence file name:", nil, function(name)
				impulse.Ops.EventManager.Sequences[key].FileName = name
				impulse.Ops.EventManager.SequenceSave(key)
				LocalPlayer():Notify("Saved sequence: "..key..".")
			end)
		else
			impulse.Ops.EventManager.SequenceSave(key)
			LocalPlayer():Notify("Saved sequence: "..key..".")
		end
	end

	local uploadSeq = vgui.Create("DButton", self.main)
	uploadSeq:SetPos(225, 0)
	uploadSeq:SetSize(100, 20)
	uploadSeq:SetText("Push")
	uploadSeq:SetImage("icon16/server_connect.png")

	function uploadSeq:DoClick()
		impulse.Ops.EventManager.SequencePush(key)
	end

	function uploadSeq:DoRightClick()
		impulse.Ops.EventManager.SequencePush(key)

		timer.Simple(0.1, function()
			net.Start("impulseOpsEMPlaySequence")
			net.WriteString(key)
			net.SendToServer()
		end)

		LocalPlayer():Notify("Quick pushed sequence, playing...")
	end

	function self.main:Toggle() -- allowing them to accordion causes bugs
		return
	end
end

function PANEL:AddEvent(id, eventdata)
	local event = self.mainList:Add("DPanel")
	event:Dock(TOP)

	local panel = self

	function event:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60, 200))

		local colTag = impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].z_MetaTag
		if colTag and impulse.Ops.EventManager.Config.TagColours[colTag] then
			draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(impulse.Ops.EventManager.Config.TagColours[colTag], 40))
		end

		draw.RoundedBox(0, 0, h-2, w, 2, Color(100, 100, 100, 150))

		local curEvents = impulse.Ops.EventManager.GetCurEvents()

		if not curEvents then
			return
		end

		local curEvent = curEvents[id]

		if not curEvent then
			return
		end

		if not curEvents[id + 1] and (impulse.Ops.EventManager.GetSequence() and panel.Sequence == impulse.Ops.EventManager.GetSequence()) then
			impulse_OpsEM_CurEvents[id] = CurTime()
		end

		local perc = math.Clamp((curEvent - CurTime()) / (curEvent - (curEvent + 1)), 0, 1)
		perc = 1 - perc

		if perc == 0 then
			impulse_OpsEM_CurEvents[id] = nil
		end

		draw.RoundedBox(0, 0, 0, w, h, Color(127, 255, 0, (perc * 30)))
	end

	event.etypeicon = vgui.Create("DImage", event)
	event.etypeicon:SetPos(2, 2)
	event.etypeicon:SetSize(16, 16)
	event.etypeicon:SetImage(impulse.Ops.EventManager.Config.CategoryIcons[impulse.Ops.EventManager.Config.Events[eventdata.Type].Cat])

	event.etype = vgui.Create("DLabel", event)
	event.etype:SetPos(20, 2)
	event.etype:SetText("Event: "..eventdata.Type.." ("..id..")")
	event.etype:SizeToContents()

	local delay = vgui.Create("DLabel", event)
	delay:SetPos(510, 2)
	delay:SetText("Delay:")
	delay:SizeToContents()

	event.edelay = vgui.Create("DNumberWang", event)
	event.edelay:SetDecimals(2)
	event.edelay:SetPos(555, 2)
	event.edelay:SetSize(40, 18)
	event.edelay:SetMin(0)
	event.edelay:SetUpdateOnType(true)
	event.edelay:SetMinMax(0, 9999)
	event.edelay:SetValue(eventdata.Delay)

	function event.edelay:OnValueChanged(new)
		if tonumber(new) then
			local realNew = math.Clamp(tonumber(new), 0, 9999)
			impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].Delay = realNew
		end
	end

	event.eremove = vgui.Create("DImageButton", event)
	event.eremove:SetPos(606, 2)
	event.eremove:SetImage("icon16/script_delete.png")
	event.eremove:SizeToContents()
	event.eremove:SetTooltip("Delete event")

	function event.eremove:DoClick()
		table.remove(impulse.Ops.EventManager.Sequences[panel.Sequence].Events, id)
		panel.Dad:ReloadSequences()
	end

	event.etypebtn = vgui.Create("DImageButton", event)
	event.etypebtn:SetPos(206, 2)
	event.etypebtn:SetImage("icon16/textfield_rename.png")
	event.etypebtn:SizeToContents()
	event.etypebtn:SetTooltip("Change event type")

	function event.etypebtn:DoClick()
		local m = DermaMenu()
		local cats = {}

		for v,k in pairs(impulse.Ops.EventManager.Config.Events) do
			if k.Cat == "hidden" then
				continue
			end

			if not cats[k.Cat] then
				local c, p = m:AddSubMenu(k.Cat)
				p:SetIcon(impulse.Ops.EventManager.Config.CategoryIcons[k.Cat])
				cats[k.Cat] = c
			end

			local parent = cats[k.Cat]
			parent:AddOption(v, function()
				impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].Type = v
				impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].Prop = {}
				table.Merge(impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].Prop, impulse.Ops.EventManager.Config.Events[v].Prop)
				panel.Dad:ReloadSequences()
			end)
		end

		m:Open()
	end

	event.eprop = vgui.Create("DImageButton", event)
	event.eprop:SetPos(226, 2)
	event.eprop:SetImage("icon16/script_edit.png")
	event.eprop:SizeToContents()
	event.eprop:SetTooltip("Event properties")

	if table.Count(impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].Prop) == 0 then
		event.eprop:SetDisabled(true)
	end

	function event.eprop:DoClick()
		if panel.Dad.Properties and IsValid(panel.Dad.Properties) then
			panel.Dad.Properties:Remove()
		end

		panel.Dad.Properties = vgui.Create("impulsePropertyEditor")
		panel.Dad.Properties:SetTable(impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].Prop, function(key, val)
			impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].Prop[key] = val
		end)
		panel.Dad.Properties:SetTitle(impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].Type.."("..id..") properties")

		local x, y = panel.Dad:GetPos()
		panel.Dad.Properties:SetPos(x + panel.Dad:GetWide() + 10, y)
		panel.Dad.Properties:SetSize(300, 580)

		local x = self

		function panel.Dad.Properties:Think()
			if not IsValid(x) then
				self:Remove()
			end
		end

		panel.Dad.Properties.props:DockMargin(0, 0, 0, 130)

		local me = panel.Dad.Properties

		local lbl = vgui.Create("DLabel", me)
		lbl:SetPos(10, 450)
		lbl:SetText("Event Metadata")
		lbl:SizeToContents()

		local lbl = vgui.Create("DLabel", me)
		lbl:SetPos(20, 470)
		lbl:SetText("Colour Tag")
		lbl:SizeToContents()

		local l = vgui.Create("DIconLayout", me)
		l:SetPos(20, 485)
		l:SetSize(260, 26)
		l:SetSpaceY(5)
		l:SetSpaceX(5)

		for v,k in pairs(impulse.Ops.EventManager.Config.TagColours) do
			local a = l:Add("DButton")
			a:SetText("")
			a:SetSize(20, 20)
			a:SetTooltip(v)

			function a:Paint(w, h)
				draw.RoundedBox(12, 0, 0, w, h, k)
			end

			function a:DoClick()
				impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].z_MetaTag = v
			end
		end

		local noCol = l:Add("DButton")
		noCol:SetText("None")
		noCol:SetSize(40, 20)

		function noCol:DoClick()
			impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].z_MetaTag = nil
		end

		local lbl = vgui.Create("DLabel", me)
		lbl:SetPos(20, 510)
		lbl:SetText("Director's Notes")
		lbl:SizeToContents()

		local notes = vgui.Create("DTextEntry", me)
		notes:SetPos(20, 525)
		notes:SetSize(260, 50)
		notes:SetMultiline(true)
		notes:SetUpdateOnType(true)
		notes:SetPlaceholderText("Write notes here...")
		notes:SetValue(impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].z_MetaNotes or "")

		function notes:OnValueChange()
			impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].z_MetaNotes = self:GetValue()
		end
	end

	local delay = vgui.Create("DLabel", event)
	delay:SetPos(320, 2)
	delay:SetText("UID:")
	delay:SizeToContents()

	event.euid = vgui.Create("DTextEntry", event)
	event.euid:SetPos(360, 2)
	event.euid:SetSize(140, 20)
	event.euid:SetText(impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].UID or "")
	event.euid:SetUpdateOnType(true)

	function event.euid:OnValueChange(new)
		local new = string.Trim(new, " ")

		if new == "" then
			impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].UID = nil
			return
		end

		impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id].UID = new
	end

	function event.euid:PaintOver(w, h)
		if impulse.Ops.EventManager.Config.Events[eventdata.Type].NeedUID and not self:IsEditing() and string.Trim(self:GetText(), " ") == "" then
			draw.SimpleText("Requires UID value", "DermaDefaultBold", 5, 2, Color(255, 0, 0))
		end
	end

	function event.euid:GetAutoComplete(text)
		local suggest = {}
		local suggested = {}

		for v,k in pairs(impulse.Ops.EventManager.Sequences[panel.Sequence].Events) do
			if v == id then
				continue
			end

			if k.UID and not suggested[k.UID] and string.StartWith(k.UID, text) then
				table.insert(suggest, k.UID)
				suggested[k.UID] = true
			end
		end

		return suggest
	end

	local function moveToCustomSlot()
		Derma_StringRequest("impulse ops", "Enter where you wish to move this event to:", "", function(slot)
			if not tonumber(slot) then
				return
			end

			local me = impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id]
			local oldId = id
			local size = table.Count(impulse.Ops.EventManager.Sequences[panel.Sequence].Events)
			slot = math.Clamp(math.floor(slot), 1, size)

			table.remove(impulse.Ops.EventManager.Sequences[panel.Sequence].Events, id)
			table.insert(impulse.Ops.EventManager.Sequences[panel.Sequence].Events, slot, me)

			panel.Dad:ReloadSequences()
 		end, nil, "Move")
	end

	event.emup = vgui.Create("DImageButton", event)
	event.emup:SetPos(250, 2)
	event.emup:SetImage("icon16/arrow_up.png")
	event.emup:SizeToContents()
	event.emup:SetTooltip("Move event up (right click for manual input)")

	function event.emup:DoClick()
		local me = impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id]
		local oldId = id
		local size = table.Count(impulse.Ops.EventManager.Sequences[panel.Sequence].Events)

		table.remove(impulse.Ops.EventManager.Sequences[panel.Sequence].Events, id)
		table.insert(impulse.Ops.EventManager.Sequences[panel.Sequence].Events, math.Clamp(oldId - 1, 1, size), me)

		panel.Dad:ReloadSequences()
	end

	function event.emup:DoRightClick()
		moveToCustomSlot()
	end

	event.emdown = vgui.Create("DImageButton", event)
	event.emdown:SetPos(266, 2)
	event.emdown:SetImage("icon16/arrow_down.png")
	event.emdown:SizeToContents()
	event.emdown:SetTooltip("Move event down (right click for manual input)")

	function event.emdown:DoClick()
		local me = impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id]
		local oldId = id
		local size = table.Count(impulse.Ops.EventManager.Sequences[panel.Sequence].Events)

		table.remove(impulse.Ops.EventManager.Sequences[panel.Sequence].Events, id)
		table.insert(impulse.Ops.EventManager.Sequences[panel.Sequence].Events, math.Clamp(oldId + 1, 1, size), me)

		panel.Dad:ReloadSequences()
	end

	function event.emdown:DoRightClick()
		moveToCustomSlot()
	end

	event.edupe = vgui.Create("DImageButton", event)
	event.edupe:SetPos(290, 2)
	event.edupe:SetImage("icon16/page_copy.png")
	event.edupe:SizeToContents()
	event.edupe:SetTooltip("Copy event")

	local function copy1(obj)
	    if type(obj) ~= 'table' then return obj end
	    local res = {}
	    for k, v in pairs(obj) do res[copy1(k)] = copy1(v) end
	    return res
	end


	function event.edupe:DoClick()
		local me = impulse.Ops.EventManager.Sequences[panel.Sequence].Events[id]
		local oldId = id
		local size = table.Count(impulse.Ops.EventManager.Sequences[panel.Sequence].Events)

		table.insert(impulse.Ops.EventManager.Sequences[panel.Sequence].Events, math.Clamp(oldId + 1, 1, size), copy1(me))

		panel.Dad:ReloadSequences()
	end

	self:SetTall(self:GetTall() + event:GetTall())
end

local normal = Color(90, 90, 90, 255)
function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, normal)
end

vgui.Register("impulseSequenceCard", PANEL, "DPanel")