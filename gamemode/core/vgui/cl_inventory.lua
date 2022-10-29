local PANEL = {}

function PANEL:Init()
	self:SetSize(ScrW() * .58, ScrH() * .7)
	self:Center()
	self:CenterHorizontal()
	self:SetTitle("")
	self:ShowCloseButton(false)
	self:SetDraggable(false)
	--self:MakePopup()
 	self:MoveToFront()

 	local w, h = self:GetSize()

 	self.infoName = vgui.Create("DLabel", self)
 	self.infoName:SetPos(15, 40)
 	self.infoName:SetText(LocalPlayer():Nick())
 	self.infoName:SetFont(HIGH_RES("Impulse-Elements24-Shadow", "Impulse-Elements27-Shadow"))
 	self.infoName:SizeToContents()

 	if self.infoName:GetWide() > 245 then
 		self.infoName:SetFont(HIGH_RES("Impulse-Elements19-Shadow", "Impulse-Elements24-Shadow"))
 	end

 	local lpTeam = LocalPlayer():Team()
  	self.infoTeam = vgui.Create("DLabel", self)
 	self.infoTeam:SetPos(15, 64)
 	self.infoTeam:SetText(team.GetName(lpTeam))
 	self.infoTeam:SetFont(HIGH_RES("Impulse-Elements19-Shadow", "Impulse-Elements22-Shadow"))
 	self.infoTeam:SetColor(team.GetColor(lpTeam))
 	self.infoTeam:SizeToContents()

 	local className = LocalPlayer():GetTeamClassName()
 	local rankName = LocalPlayer():GetTeamRankName()

 	if className != "Default" then
	 	self.infoClassRank = vgui.Create("DLabel", self)
	 	self.infoClassRank:SetPos(15, 80)
	 	self.infoClassRank:SetFont(HIGH_RES("Impulse-Elements19-Shadow", "Impulse-Elements22-Shadow"))
	 	self.infoClassRank:SetText(className)
	 	self.infoClassRank:SetColor(team.GetColor(lpTeam))
	 	self.infoClassRank:SizeToContents()
	end

 	local model = LocalPlayer():GetModel()
 	local skin = LocalPlayer():GetSkin()

 	self.modelPreview = vgui.Create("impulseModelPanel", self)
	self.modelPreview:SetPos(HIGH_RES(0, 20), 80)
	self.modelPreview:SetSize(HIGH_RES(270, 335), h * .75)
	self.modelPreview:SetModel(model, skin)
	self.modelPreview:MoveToBack()
	self.modelPreview:SetCursor("arrow")

	if impulse.IsHighRes() then
		self.modelPreview:SetFOV((324 / ScrH()) * 140) -- a incredible equation that makes the model fit onto the ui, patent by professor vin
	else
		self.modelPreview:SetFOV((324 / ScrH()) * 100) -- a incredible equation that makes the model fit onto the ui, patent by professor vin
	end

	function self.modelPreview:LayoutEntity(ent)
		ent:SetAngles(Angle(-1, 45, 0))
		ent:SetPos(Vector(0, 0, 2.5))
		self:RunAnimation()

		if not self.setup then
			for v,k in pairs(LocalPlayer():GetBodyGroups()) do
				ent:SetBodygroup(k.id, LocalPlayer():GetBodygroup(k.id))
			end

			for v,k in pairs(LocalPlayer():GetMaterials()) do
				local mat = LocalPlayer():GetSubMaterial(v - 1)

				if mat != k then
					ent:SetSubMaterial(v - 1, mat)
				end
			end

			hook.Run("SetupInventoryModel", self, ent)

			self.setup = true
		end
	end

 	--self.invName = vgui.Create("DLabel", self)
 	--self.invName:SetPos(270, 35)
 	--self.invName:SetText("Inventory")
 	--self.invName:SetFont("Impulse-Elements24-Shadow")
 	--self.invName:SizeToContents()

 	self:SetupItems(w, h)
end

function PANEL:SetupItems()
	local w, h = self:GetSize()

	if self.tabs and IsValid(self.tabs) then
		self.tabs:Remove()
	end

	local s = HIGH_RES(270, 400)
	
 	self.tabs = vgui.Create("DPropertySheet", self)
 	self.tabs:SetPos(s, 40)
 	self.tabs:SetSize(w - s, h - 42)
 	self.tabs.tabScroller:DockMargin(-1, 0, -1, 0)
 	self.tabs.tabScroller:SetOverlap(0)

 	function self.tabs:Paint()
 		return true
 	end
	
	if self.invScroll and IsValid(self.invScroll) then
		self.invScroll:Remove()
	end

	self.invScroll = vgui.Create("DScrollPanel", self.tabs)
 	self.invScroll:SetPos(0, 0)
 	self.invScroll:SetSize(w - math.Clamp(s, 100, 270), h - 42)

	self.items = {}
	self.itemsPanels = {}
 	local weight = 0
 	local realInv = impulse.Inventory.Data[0][1]
 	local localInv = table.Copy(impulse.Inventory.Data[0][1]) or {}
 	local reccurTemp = {}
 	local equipTemp = {}

 	local shouldSortEq = impulse.GetSetting("inv_sortequippablesattop", true)
 	local sortMethod = impulse.GetSetting("inv_sortweight", "Inventory only")
 	local invertSort = true

 	for v,k in pairs(localInv) do -- fix for fucking table.sort desyncing client/server itemids!!!!!!!
 		k.realKey = v

 		if sortMethod == "Always" or sortMethod == "Inventory only" then
 			reccurTemp[k.id] = (reccurTemp[k.id] or 0) + (impulse.Inventory.Items[k.id].Weight or 0)
 			k.sortWeight = reccurTemp[k.id]
 		else
 			k.sortWeight = impulse.Inventory.Items[k.id].Name
 			invertSort = false
 		end
 	end

 	if localInv and table.Count(localInv) > 0 then
 		if shouldSortEq then
	 		for v,k in SortedPairsByMemberValue(localInv, "sortWeight", invertSort) do
	 			if not k.equipped then continue end
	 			local itemX = impulse.Inventory.Items[k.id]

	 			local item = self.invScroll:Add("impulseInventoryItem")
				item:Dock(TOP)
				item:DockMargin(0, 0, 15, 5)
				item:SetItem(k, w)
				item.InvID = k.realKey
				item.InvPanel = self
				self.items[k.id] = item
				self.itemsPanels[k.realKey] = item

	 			weight =  weight + (itemX.Weight or 0)
	 		end
	 	end
 		
	 	for v,k in SortedPairsByMemberValue(localInv, "sortWeight", invertSort) do -- 01 is player 0 (localplayer) and storage 1 (local inv)
	 		if shouldSortEq and k.equipped then continue end
	 		local otherItem = self.items[k.id]
	 		local itemX = impulse.Inventory.Items[k.id]

	 		if itemX.CanStack and otherItem then
	 			otherItem.Count = (otherItem.Count or 1) + 1
	 		else
	 			local item = self.invScroll:Add("impulseInventoryItem")
				item:Dock(TOP)
				item:DockMargin(0, 0, 15, 5)
				item:SetItem(k, w)
				item.InvID = k.realKey
				item.InvPanel = self
				self.items[k.id] = item
				self.itemsPanels[k.realKey] = item
			end

			weight =  weight + (itemX.Weight or 0)
		end
	else
		self.empty = self.invScroll:Add("DLabel", self)
		self.empty:SetContentAlignment(5)
		self.empty:Dock(TOP)
		self.empty:SetText("Empty")
		self.empty:SetFont(HIGH_RES("Impulse-Elements19-Shadow", "Impulse-Elements22-Shadow"))
	end

	self.invWeight = weight

	self.tabs:AddSheet("Inventory", self.invScroll)

	self:SetupSkills(w, h)
end


local bodyCol = Color(50, 50, 50, 210)
function PANEL:SetupSkills(w, h)
	self.skillScroll = vgui.Create("DScrollPanel", self.tabs)
 	self.skillScroll:SetPos(0, 0)
 	self.skillScroll:SetSize(w - 270, h - 42)

 	for v,k in pairs(impulse.Skills.Skills) do
 		local skillBg = self.skillScroll:Add("DPanel")
 		skillBg:SetTall(80)
 		skillBg:Dock(TOP)
 		skillBg:DockMargin(0, 0, 15, 5)
 		skillBg.Skill = v

 		local level = LocalPlayer():GetSkillLevel(v)
 		local xp = LocalPlayer():GetSkillXP(v)

 		function skillBg:Paint(w, h)
 			surface.SetDrawColor(bodyCol)
			surface.DrawRect(0, 0, w, h)

			local skill = self.Skill
			local skillName = impulse.Skills.GetNiceName(skill)

			draw.DrawText(skillName.." - Level "..level, "Impulse-Elements22-Shadow", 5, 3, color_white, TEXT_ALIGN_LEFT)
			draw.DrawText("Total skill: "..xp.."XP", "Impulse-Elements16-Shadow", w - 5, 7, color_white, TEXT_ALIGN_RIGHT)

 			return true
 		end

 		local lastXp = impulse.Skills.GetLevelXPRequirement(level - 1)
 		local nextXp = impulse.Skills.GetLevelXPRequirement(level)
 		local perc = (xp - lastXp) / (nextXp - lastXp)

 		local bar = vgui.Create("DProgress", skillBg)
 		bar:SetPos(20, 30)
 		bar:SetSize(self.skillScroll:GetWide() - 73, 40)

 		if level == 10 then
 			bar:SetFraction(1)
 			bar.BarCol = Color(218, 165, 32)
 		else
 			bar:SetFraction(perc)
 		end

 		function bar:PaintOver(w, h)
 			if level != 10 then
 				draw.DrawText(math.Round(perc * 100, 1).."% to next level", "Impulse-Elements18-Shadow", w / 2, 10, color_white, TEXT_ALIGN_CENTER)
 			else
 				draw.DrawText("Mastered", "Impulse-Elements18-Shadow", w / 2, 10, color_white, TEXT_ALIGN_CENTER)
 			end

 			draw.DrawText(lastXp.."XP", "Impulse-Elements16-Shadow", 10, 10, color_white)
 			draw.DrawText(nextXp.."XP", "Impulse-Elements16-Shadow", w - 10, 10, color_white, TEXT_ALIGN_RIGHT)
 		end
 	end

 	self.tabs:AddSheet("Skills", self.skillScroll)
end

function PANEL:FindItemPanelByID(id)
	return self.itemsPanels[id]
end

local grey = Color(209, 209, 209)
function PANEL:PaintOver(w, h)
	draw.SimpleText(self.invWeight.."kg/"..impulse.Config.InventoryMaxWeight.."kg", HIGH_RES("Impulse-Elements18-Shadow", "Impulse-Elements22-Shadow"), w - 18, 40, grey, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end

vgui.Register("impulseInventory", PANEL, "DFrame")
