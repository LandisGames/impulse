AddCSLuaFile()

if( CLIENT ) then
	SWEP.PrintName = "NPC Spawn Editor"
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
			owner:StripWeapon("impulse_npcspawneditor")
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
		
		if not self.Pos1 then
			self.Pos1 = self.Owner:GetPos()
			self.Pos2 = self.Owner:GetAngles()
			self.State = "Ready for export."

			surface.PlaySound("buttons/blip1.wav")
			self.Owner:Notify("Ready for export!")
		end

		self.NextGo = CurTime() + .3
	end

	function SWEP:SecondaryAttack()
		if self.NextGo > CurTime() then return end

		self.Pos1 = nil
		self.Pos2 = nil
		self.Type = nil
		self.State = nil
		self.Exporting = nil

		surface.PlaySound("buttons/button10.wav")
		
		self.NextGo = CurTime() + .3
	end

	function SWEP:Reload()
		if self.Pos1 and self.Pos2 and not self.Exporting then
			self.Exporting = true
			Derma_StringRequest("impulse", "Enter type:", nil, function(name)
				local pos1 = "Vector("..self.Pos1.x..", "..self.Pos1.y..", "..self.Pos1.z..")"
				local pos2 = "Angle("..self.Pos2.y..", "..self.Pos2.p..", "..self.Pos2.r..")"
				local output = '{type = "'..name..'", dist = 1000, pos = '..pos1..', ang = '..pos2..'}'
				
				chat.AddText("-----------------OUTPUT-----------------")
				chat.AddText(output)
				chat.AddText("Output copied to clipboard.")
				SetClipboardText(output)

				self.Pos1 = nil
				self.Pos2 = nil
				self.State = nil
				self.Exporting = nil
			end)
		end
	end

	function SWEP:DrawHUD()
		draw.SimpleText("LEFT: Register spawn, RIGHT: Reset, RELOAD: Export", "BudgetLabel", 100, 100)
		draw.SimpleText("STATE: "..(self.State or "Nothing selected"), "BudgetLabel", 100, 120)
		draw.SimpleText("Warning, when you click your current position\nwill be registered, not your weapon aim position!", "BudgetLabel", 100, 140)

		if not impulse.Config.NPCSpawns then
			return
		end

		for v,k in pairs(impulse.Config.NPCSpawns) do
			local cent = k.pos:ToScreen()
			draw.SimpleText(k.type, "BudgetLabel", cent.x, cent.y)
		end
	end

	local yel = Color(255, 255, 153, 50)

	local function stringColBasic(str)
		local r, g, b = string.byte(str, 1, 3)
		r = r / 128
		g = g / 128
		b = b / 128

		r = r * 255
		g = g * 255
		b = b * 255

		return Color(r, g, b, 70)
	end

	hook.Add("PostDrawOpaqueRenderables", "zoneEditor3D", function()
		if LocalPlayer():IsAdmin() then
			local activeWep =  LocalPlayer():GetActiveWeapon()
			if activeWep and IsValid(activeWep) and activeWep:GetClass() == "impulse_npcspawneditor" then
				for v,k in pairs(impulse.Config.NPCSpawns) do
					render.SetColorMaterial()
					render.SetColorModulation(yel.r / 255, yel.g / 255, yel.b / 255)
					render.DrawSphere(k.pos, k.dist, 16, 16, stringColBasic(k.type))
				end
			end
		end
	end)
end