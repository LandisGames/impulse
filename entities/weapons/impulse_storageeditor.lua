AddCSLuaFile()

if( CLIENT ) then
	SWEP.PrintName = "Storage/Door Link Editor"
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
			owner:StripWeapon("impulse_storageeditor")
		end
	end
else
	function SWEP:DrawHUD()
		draw.SimpleText("LEFT: Register entity, RIGHT: Reset, RELOAD: Link", "BudgetLabel", 100, 100)
		draw.SimpleText("STATE: "..(self.State or "Select a storage container..."), "BudgetLabel", 100, 120)

		local count = 0
		for v,k in pairs(ents.FindByClass("impulse_storage")) do
			count = count + 1
			if k:GetPos():DistToSqr(LocalPlayer():GetPos()) < (1000 ^ 2) then
				local sPos = k:GetPos():ToScreen()
				draw.SimpleText("Cont#"..k:EntIndex(), "ChatFont", sPos.x, sPos.y, Color(255, 0, 0), TEXT_ALIGN_CENTER)
			end
		end
	end
end

function SWEP:PrimaryAttack()
	if self.NextGo > CurTime() then return end
	self.NextGo = CurTime() + .3

	local trace = {}
	trace.start = self.Owner:EyePos()
	trace.endpos = trace.start + self.Owner:GetAimVector() * 140
	trace.filter = self.Owner

	local tr = util.TraceLine(trace)
	local ent = tr.Entity

	if not self.SelectedStorage and IsValid(ent) and ent:GetClass() == "impulse_storage" then
		if SERVER and not ent.impulseSaveEnt then
			self.Owner:Notify("You must mark the storage chest for saving first! Reset.")
			return
		end
		self.SelectedStorage = ent
		self.State = "Storage "..ent:EntIndex().." selected, now select door..."
	elseif not self.SelectedDoor and IsValid(ent) and ent:IsDoor() then
		self.SelectedDoor = ent
		self.State = "Storage "..self.SelectedStorage:EntIndex().." and door "..ent:EntIndex().." selected, ready for export."

		if CLIENT then
			surface.PlaySound("buttons/blip1.wav")
			self.Owner:Notify("Ready for export!")
		end
	end
end

function SWEP:SecondaryAttack()
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
	if CLIENT then
		self.SelectedStorage = nil
		self.SelectedDoor = nil
		self.State = nil
	else
		if self.SelectedDoor and self.SelectedStorage then
			self.SelectedStorage.impulseSaveKeyValue = self.SelectedStorage.impulseSaveKeyValue or {}
			self.SelectedStorage.impulseSaveKeyValue["MasterDoor"] = self.SelectedDoor:MapCreationID()

			self.Owner:Notify("Linked. When done remember to run impulse_save_saveall!")

			self.SelectedStorage = nil
			self.SelectedDoor = nil
			self.State = nil
		end
	end
end
