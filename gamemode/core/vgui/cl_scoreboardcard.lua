local PANEL = {}

function PANEL:Init()
	self.Colour = Color(60,255,105,150)
	self.Name = "Connecting..."
	self.Ping = 0
	self:SetCursor("hand")
	self:SetTooltip("Left click to open info card. Right click to copy SteamID.")
end

function PANEL:SetPlayer(player)
	self.Colour = team.GetColor(player:Team()) -- Store colour and name micro optomization, other things can be calculated on the go.
	self.Name = player:Nick()
	self.Player = player
	self.Badges =  {}

	for v,k in pairs(impulse.Badges) do
		if k[3](player) then
			self.Badges[v] = k
		end 	
	end

 	self.modelIcon = vgui.Create("impulseSpawnIcon", self)
	self.modelIcon:SetPos(10,4)
	self.modelIcon:SetSize(52,52)
	self.modelIcon:SetModel(player:GetModel(), player:GetSkin())
	self.modelIcon:SetTooltip(false)
	self.modelIcon:SetDisabled(true)

	timer.Simple(0, function()
		if not IsValid(self) then
			return
		end

		local ent = self.modelIcon.Entity

		if IsValid(ent) and IsValid(self.Player) then
			for v,k in pairs(self.Player:GetBodyGroups()) do
				ent:SetBodygroup(k.id, self.Player:GetBodygroup(k.id))
			end
		end
	end)

	function self.modelIcon:PaintOver() -- remove that mouse hover effect
		return false
	end
end

local gradient = Material("vgui/gradient-l")
local gradientr = Material("vgui/gradient-r")
local outlineCol = Color(190,190,190,240)
local darkCol = Color(30,30,30,200)

function PANEL:Paint(w,h)
	if not IsValid(self.Player) then return end
	-- Frame
	surface.SetDrawColor(outlineCol)
	surface.DrawOutlinedRect(0,0,w, h)


	surface.SetDrawColor(self.Colour)
 	surface.SetMaterial(gradient)
 	surface.DrawTexturedRect(1,1,w-1,h-2)

 	if self.Player == LocalPlayer() or self.Player:GetFriendStatus() == "friend" then
		surface.SetDrawColor(255, 255, 255, (50 + math.sin(RealTime() * 2) * 50) * .4)
		surface.SetMaterial(gradientr)
		surface.DrawTexturedRect(w - 210, 1, 210-1, h-1)
	end

	surface.SetMaterial(gradient)
	surface.SetDrawColor(darkCol)
 	surface.DrawTexturedRect(1,1,w-1,h-2)

	 -- OOC/IC name
	 surface.SetFont(HIGH_RES("Impulse-Elements20-Shadow", "Impulse-Elements20A-Shadow"))
	 surface.SetTextColor(color_white)
	 surface.SetTextPos(65,10)

	 local icName = ""
	 if LocalPlayer():IsAdmin() then 
	 	icName = " ("..self.Player:Name()..")"

		local rpGroup = self.Player:GetSyncVar(SYNC_GROUP_NAME, nil)
		if impulse.GetSetting("admin_showgroup") and rpGroup then
			icName = icName.." ("..rpGroup..")"
		end
	 end
	 surface.DrawText(self.Player:SteamName()..icName)

	 -- Ping
	 surface.SetTextPos(w-30,10)
	 surface.DrawText(self.Player:Ping())

	 -- Team name
	 surface.SetFont(HIGH_RES("Impulse-Elements18-Shadow", "Impulse-Elements19-Shadow"))
	 surface.SetTextPos(65,30)
	 surface.DrawText(team.GetName(self.Player:Team()))
	 
	 -- Badges 
	 surface.SetDrawColor(color_white)

	local xShift = 0
	for badgeName, badgeData in pairs(self.Badges) do
		surface.SetMaterial(badgeData[1])
		surface.DrawTexturedRect(w-34-xShift,30,16,16)
		xShift = xShift + 20
	end 
end
function PANEL:OnMousePressed(key)
	if not IsValid(self.Player) then
		return false
	end

	if key == MOUSE_RIGHT then
		LocalPlayer():Notify("You have copied "..self.Player:SteamName().."'s Steam ID.")
		SetClipboardText(self.Player:SteamID())
	else
		if impulse_infoCard and IsValid(impulse_infoCard) then 
			impulse_infoCard:Remove() 
		end
		
		impulse_infoCard = vgui.Create("impulsePlayerInfoCard")
		impulse_infoCard:SetPlayer(self.Player, self.Badges)
	end
end

vgui.Register("impulseScoreboardCard", PANEL, "DPanel")