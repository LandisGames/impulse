local PANEL = {}

function PANEL:Init()
	self:SetSize(780, 610)
	self:Center()
	self:SetTitle("")
	self:MakePopup()
end

local bodyCol = Color(50, 50, 50, 210)
function PANEL:SetupCrafting()
	local lp = LocalPlayer()

	local trace = {}
	trace.start = lp:EyePos()
	trace.endpos = trace.start + lp:GetAimVector() * 120
	trace.filter = lp

	local tr = util.TraceLine(trace)

	if not tr.Entity or not IsValid(tr.Entity) or tr.Entity:GetClass() != "impulse_bench" then
		return self:Remove()
	end

	self.bench = tr.Entity

	local benchType = tr.Entity:GetBenchType()
	local benchClass = impulse.Inventory.Benches[benchType]
	local panel = self

	self:SetTitle(benchClass.Name)

	self.upper = vgui.Create("DPanel", self)
	self.upper:SetTall(40)
	self.upper:Dock(TOP)
	self.upper:DockMargin(0, 0, 0, 5)

	function self.upper:Paint(w, h)
		return true
	end

	self.mixes = {}

	self.craftLbl = vgui.Create("DLabel", self.upper)
	self.craftLbl:SetPos(5, 5)
	self.craftLbl:SetFont("Impulse-Elements22-Shadow")
	self.craftLbl:SetText("Crafting Level: "..LocalPlayer():GetSkillLevel("craft"))
	self.craftLbl:SizeToContents()

	self.scroll = vgui.Create("DScrollPanel", self)
	self.scroll:Dock(FILL)

	self.availibleMixes = vgui.Create("DCollapsibleCategory", self.scroll)
	self.availibleMixes:SetLabel("Unlocked mixes")
	self.availibleMixes:Dock(TOP)

	function self.availibleMixes:Paint()
		self:SetBGColor(colInv)
	end

	self.availibleMixesLayout = vgui.Create("DListLayout")
	self.availibleMixesLayout:Dock(FILL)
	self.availibleMixes:SetContents(self.availibleMixesLayout)

	self.unAvailibleMixes = self.scroll:Add("DCollapsibleCategory")
	self.unAvailibleMixes:SetLabel("Locked mixes")
	self.unAvailibleMixes:Dock(TOP)

	function self.unAvailibleMixes:Paint()
		self:SetBGColor(colInv)
	end

	self.unAvailibleMixesLayout = vgui.Create("DListLayout")
	self.unAvailibleMixesLayout:Dock(FILL)
	self.unAvailibleMixes:SetContents(self.unAvailibleMixesLayout)

	local level = LocalPlayer():GetSkillLevel("craft")
	local mix = impulse.Inventory.Mixtures[benchType]
	local sortedMix = {}

	for v,k in pairs(mix) do
		table.insert(sortedMix, k)
	end

	table.sort(sortedMix, function(a, b)
		return a.Level < b.Level
	end)

	for v,k in pairs(sortedMix) do
		local cat = self.availibleMixesLayout

		if level < k.Level then
			cat = self.unAvailibleMixesLayout
		end

		local mix = cat:Add("impulseCraftingItem")
		mix:Dock(TOP)
		mix:SetMix(k)
		mix.dad = self

		table.insert(self.mixes, mix)
	end
end

function PANEL:Think()
	if self.bench and (not IsValid(self.bench) or self.bench:GetPos():DistToSqr(LocalPlayer():GetPos()) > (120 ^ 2)) then
		return self:Remove()
	end
	
	if not LocalPlayer():Alive() or LocalPlayer():IsCP() then
		return self:Remove()
	end

	if LocalPlayer():GetSyncVar(SYNC_ARRESTED, false) then
		return self:Remove()
	end
end

function PANEL:ShowNormal(should)
	if should then
		self.scroll:Show()
		self.craftLbl:Show()
		self.upper:Show()
	else
		self.scroll:Hide()
		self.craftLbl:Hide()
		self.upper:Hide()
	end
end

function PANEL:PaintOver(w, h)
	if self.IsCrafting then
		draw.SimpleText("Crafting "..self.CraftingItem.."...", "Impulse-Elements22-Shadow", w / 2, 380, color_white, TEXT_ALIGN_CENTER)
	end
end

function PANEL:DoCraft(item, mix)
	local wide = self:GetWide()
	local panel = self
	local length = impulse.Inventory.GetCraftingTime(mix)

	self:ShowNormal(false)
	self:ShowCloseButton(false)
	self.IsCrafting = true
	self.CraftingItem = item.Name

	self.craftBar = vgui.Create("DProgress", self)
	self.craftBar:SetPos((wide / 2) - 300, 410)
	self.craftBar:SetSize(600, 38)
	self.craftBar:SetFraction(0.5)
	self.StartTime = CurTime()
	self.EndTime = CurTime() + length

	function self.craftBar:Think()
		local timeDist = panel.EndTime - CurTime()
		local progress = math.Clamp(((panel.StartTime - CurTime()) / (panel.StartTime - panel.EndTime)), 0, 1)

		self:SetFraction(progress)
		panel.model:SetColor(Color(255, 255, 255, progress * 255))

		if progress == 1 then
			panel:ShowNormal(true)
			panel:ShowCloseButton(true)
			panel.craftBar:Remove()
			panel.model:Remove()
			panel.IsCrafting = false

			timer.Simple(0.2, function()
				if IsValid(panel) then
					for v,k in pairs(panel.mixes) do
						if IsValid(k) then
							k:RefreshCanCraft()
						end
					end
				end
			end)
		end
	end

	self.model = vgui.Create("DModelPanel", self)
	self.model:SetPaintBackground(false)
	self.model:SetPos((wide / 2) - 150, 100)
	self.model:SetSize(300, 300)
	self.model:SetMouseInputEnabled(true)
	self.model:SetModel(item.Model)
	self.model:SetSkin(item.Skin or 0)
	self.model:SetFOV(item.FOV or 35)
	self.model:SetCursor("none")

	function self.model:LayoutEntity(ent)
		ent:SetAngles(Angle(0, 90, 0))

		if item.Material then
			ent:SetMaterial(item.Material)
		end

		if not item.NoCenter then
			self:SetLookAt(Vector(0, 0, 0))
		end
	end

	function self.model:Think()
		if self.Entity and IsValid(self.Entity) and not self.Entity.rmSet then
			self.Entity:SetRenderMode(RENDERMODE_TRANSCOLOR)
			self.Entity.rmSet = true
		end
	end

	local camPos = self.model.Entity:GetPos()
	camPos:Add(Vector(0, 25, 25))

	local min, max = self.model.Entity:GetRenderBounds()

	if item.CamPos then
		self.model:SetCamPos(item.CamPos)
	else
		self.model:SetCamPos(camPos -  Vector(10, 0, 16))
	end

	self.model:SetLookAt((max + min) / 2)
end

vgui.Register("impulseCraftingMenu", PANEL, "DFrame")