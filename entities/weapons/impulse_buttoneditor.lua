AddCSLuaFile()

if( CLIENT ) then
	SWEP.PrintName = "Button Editor"
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
			owner:StripWeapon("impulse_buttoneditor")
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

		local trace = {}
		trace.start = LocalPlayer():EyePos()
		trace.endpos = trace.start + LocalPlayer():GetAimVector() * 140
		trace.filter = LocalPlayer()

		local tr = util.TraceLine(trace)
		local button = tr.Entity

		if not self.Selected and IsValid(button) and button:GetClass() == "class C_BaseEntity" then
			self.Selected = button
			self.State = "Button "..button:EntIndex().." registered, ready for export."

			surface.PlaySound("buttons/blip1.wav")

			self.Owner:Notify("Ready for export!")
		end

		self.NextGo = CurTime() + .3
	end

	function SWEP:SecondaryAttack()
		if self.NextGo > CurTime() then return end

		self.Selected = nil
		self.Button = nil
		self.State = nil

		surface.PlaySound("buttons/button10.wav")
		
		self.NextGo = CurTime() + .3
	end

	function SWEP:Reload()
		if self.NextGo > CurTime() then return end
		self.NextGo = CurTime() + .3

		if self.Selected then
			local buttonPos = self.Selected:GetPos()
			local pos = "Vector("..buttonPos.x..", "..buttonPos.y..", "..buttonPos.z..")"
			-- im sorry i had to do this indent god, pls forgiv
			local output = ""

			Derma_Query("Please select template", "impulse", 
				"generic", function()
					output = [[{
	desc = "Desc or remove line for no desc",
	pos = ]]..pos.."\n}"

			chat.AddText("-----------------OUTPUT-----------------")
			chat.AddText(output)
			chat.AddText("Output copied to clipboard.")
			SetClipboardText(output)

			self.Selected = nil
			self.Button = nil
			self.State = nil
				end, 
				"doorgroup", function()
					output = [[{
	desc = "Desc or remove line for no desc",
	pos = ]]..pos..[[,
	doorgroup = 1
}]]

			chat.AddText("-----------------OUTPUT-----------------")
			chat.AddText(output)
			chat.AddText("Output copied to clipboard.")
			SetClipboardText(output)

			self.Selected = nil
			self.Button = nil
			self.State = nil
				end, 
				"staffonly", function()
					output = [[{
	desc = "Desc or remove line for no desc",
	pos = ]]..pos..[[,
	customCheck = function(ply)
		return ply:IsAdmin()
	end
}]]

			chat.AddText("-----------------OUTPUT-----------------")
			chat.AddText(output)
			chat.AddText("Output copied to clipboard.")
			SetClipboardText(output)

			self.Selected = nil
			self.Button = nil
			self.State = nil
				end,
				"disabled", function()
					output = [[{
	pos = ]]..pos..[[,
	customCheck = function(ply)
		return false
	end
}]]

			chat.AddText("-----------------OUTPUT-----------------")
			chat.AddText(output)
			chat.AddText("Output copied to clipboard.")
			SetClipboardText(output)

			self.Selected = nil
			self.Button = nil
			self.State = nil
			end)
		end
	end

	function SWEP:DrawHUD()
		draw.SimpleText("LEFT: Register button, RIGHT: Reset, RELOAD: Export", "BudgetLabel", 100, 100)
		draw.SimpleText("STATE: "..(self.State or "Nothing selected"), "BudgetLabel", 100, 120)

		local lpPos = LocalPlayer():GetPos()

		for v,k in pairs(impulse.Config.Buttons) do
			if lpPos:DistToSqr(k.pos) < 900 ^ 2 then
				local cent = k.pos:ToScreen()
				draw.SimpleText(k.desc or "ScriptedButton", "ChatFont", cent.x, cent.y)
			end
		end
	end
end