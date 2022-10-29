AddCSLuaFile()

if( CLIENT ) then
	SWEP.PrintName = "Scene Pos Editor"
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
			owner:StripWeapon("impulse_sceneeditor")
		end
	end
	function SWEP:PrimaryAttack()
	end

	function SWEP:Reload()
	end
	
	function SWEP:SecondaryAttack()
	end
else
	function SWEP:PrimaryAttack()
		if self.NextGo > CurTime() then return end
		
		if self.Pos1 then
			self.Pos2 = self.Owner:EyePos()
			self.Ang2 = self.Owner:EyeAngles()
			self.State = "Ready for export."

			surface.PlaySound("buttons/blip1.wav")
			self.Owner:Notify("Ready for export!")
		else
			self.Pos1 = self.Owner:EyePos()
			self.Ang1 = self.Owner:EyeAngles()
			self.State = "Ready for shot 2."

			self.Owner:Notify("First shot registered!")
		end

		self.NextGo = CurTime() + .3
	end

	function SWEP:SecondaryAttack()
		if self.NextGo > CurTime() then return end

		self.Pos1 = nil
		self.Ang1 = nil
		self.Pos2 = nil
		self.Ang2 = nil
		self.Type = nil
		self.State = nil
		self.Exporting = nil

		surface.PlaySound("buttons/button10.wav")
		
		self.NextGo = CurTime() + .3
	end

	function SWEP:Reload()
		if self.Pos1 and self.Pos2 and not self.Exporting then
			self.Exporting = true

			local pos1 = "Vector("..self.Pos1.x..", "..self.Pos1.y..", "..self.Pos1.z..")"
			local ang1 = "Angle("..self.Ang1.p..", "..self.Ang1.y..", "..self.Ang1.r..")"
			local pos2 = "Vector("..self.Pos2.x..", "..self.Pos2.y..", "..self.Pos2.z..")"
			local ang2 = "Angle("..self.Ang2.p..", "..self.Ang2.y..", "..self.Ang2.r..")"

			local output = "pos = "..pos1..",\nendpos = "..pos2..",\nang = "..ang1..",\nendang = "..ang2..","

			chat.AddText("-----------------OUTPUT-----------------")
			chat.AddText(output)
			chat.AddText("Output copied to clipboard.")
			SetClipboardText(output)

			self.Pos1 = nil
			self.Pos2 = nil
			self.State = nil
			self.Exporting = nil
		end
	end

	function SWEP:DrawHUD()
		draw.SimpleText("LEFT: Register shot, RIGHT: Reset, RELOAD: Export", "BudgetLabel", 100, 100)
		draw.SimpleText("STATE: "..(self.State or "Ready for shot 1."), "BudgetLabel", 100, 120)
	end
end