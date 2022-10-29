AddCSLuaFile()

if( CLIENT ) then
	SWEP.PrintName = "Loot Editor"
	SWEP.Slot = 0
	SWEP.SlotPos = 0
	SWEP.CLMode = 0
end
SWEP.HoldType = "fists"

SWEP.Category = "impulse"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.Primary.Delay			= 1
SWEP.Primary.Recoil			= 0	
SWEP.Primary.Damage			= 0
SWEP.Primary.NumShots		= 0
SWEP.Primary.Cone			= 0 	
SWEP.Primary.ClipSize		= -1	
SWEP.Primary.DefaultClip	= -1	
SWEP.Primary.Automatic   	= false	
SWEP.Primary.Ammo         	= "none"
SWEP.IsAlwaysRaised = true
 
SWEP.Secondary.Delay		= 0.9
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 0
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= false
SWEP.Secondary.Ammo         = "none"
SWEP.NextGo = 0

if SERVER then
	function SWEP:Equip(owner)
		if not owner:IsAdmin() then
			owner:StripWeapon("impulse_looteditor")
		end
	end
else
	function SWEP:DrawHUD()
		draw.SimpleText("LEFT: Register entity, RIGHT: Reset, RELOAD: Set as loot", "BudgetLabel", 100, 100)
		draw.SimpleText("STATE: "..(self.State or "Spawn a prop and select it..."), "BudgetLabel", 100, 120)

		local count = 0
		for v,k in pairs(ents.FindByClass("impulse_container")) do
			if k.GetLoot and k:GetLoot() then
				count = count + 1

				local sPos = k:GetPos():ToScreen()
				draw.SimpleText("Loot#"..k:EntIndex(), "ChatFont", sPos.x, sPos.y, Color(255, 0, 0), TEXT_ALIGN_CENTER)
			end
		end

		draw.SimpleText("INFO: LOOT CONTAINER COUNT: "..count, "BudgetLabel", 100, 140)
	end
end

function SWEP:PrimaryAttack()
	if SERVER then return end
	if self.NextGo > CurTime() then return end
	self.NextGo = CurTime() + .3

	local trace = {}
	trace.start = self.Owner:EyePos()
	trace.endpos = trace.start + self.Owner:GetAimVector() * 140
	trace.filter = self.Owner

	local tr = util.TraceLine(trace)
	local ent = tr.Entity

	if not self.SelectedStorage and IsValid(ent) and ent:GetClass() == "prop_physics" then
		self.SelectedStorage = ent
		self.State = "Prop "..ent:EntIndex().." ("..ent:GetModel()..") selected, ready for export..."

		if CLIENT then
			surface.PlaySound("buttons/blip1.wav")
			self.Owner:Notify("Ready for export!")
		end
	end
end

function SWEP:SecondaryAttack()
	if SERVER then return end
	if self.NextGo > CurTime() then return end

	self.SelectedStorage = nil
	self.SelectedDoor = nil
	self.State = nil

	if CLIENT then
		surface.PlaySound("buttons/button10.wav")
	end
	
	self.NextGo = CurTime() + .3
end

function SWEP:Reload()
	if SERVER then return end
	if self.NextGo > CurTime() then return end
	self.NextGo = CurTime() + .3

	local function sendLootReq(pool)
		if not IsValid(self.SelectedStorage) then
			return LocalPlayer():Notify("Entity missing.")
		end

		net.Start("impulseLootEditorSet")
		net.WriteString(pool)
		net.WriteEntity(self.SelectedStorage)
		net.SendToServer()

		self.SelectedStorage = nil
		self.State = nil
	end

	Derma_Query("Please select the lootpool for this container:", "impulse", 
		"generic", function()
			sendLootReq("generic")
		end, 
		"metal", function()
			sendLootReq("metal")
		end, 
		"electronic", function()
			sendLootReq("electronic")
		end, 
		"Cancel", function() 
	end)
end

if SERVER then
	util.AddNetworkString("impulseLootEditorSet")

	net.Receive("impulseLootEditorSet", function(len, ply)
		if not ply:IsSuperAdmin() then
			return
		end
		
		local pool = net.ReadString()
		local ent = net.ReadEntity()

		if not IsValid(ent) or ent:GetClass() != "prop_physics" then
			return
		end
		
		if not impulse.Config.LootPools[pool] then
			return
		end

		local entModel = ent:GetModel()
		local entPos = ent:GetPos()
		local entAng = ent:GetAngles()

		ent:Remove()

		local container = ents.Create("impulse_container")
		container.impulseSaveKeyValue = {}
		container.impulseSaveKeyValue["model"] = entModel
		container.impulseSaveKeyValue["lootpool"] = pool
		container:SetPos(entPos)
		container:SetAngles(entAng)
		container:Spawn()

		ply:Notify("Lootable container for with pool as "..pool.." created. Please mark and save the generated entity.")
	end)
end