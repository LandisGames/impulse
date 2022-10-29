local PANEL = {}

function PANEL:Init()
	impulse.hudEnabled = false

	self:SetPos(0,0)
	self:SetSize(ScrW(), ScrH())
	self:MakePopup()
	self:SetPopupStayAtBack(true)

	local panel = self

	self.core = vgui.Create("DPanel", self)
	self.core:SetPos(0, 0)
	self.core:SetSize(ScrW(), ScrH())

	local splashCol = Color(200, 200, 200, 190)
	function self.core:Paint(w, h)
		local x = w * .5
		local y = h * .4
		local logo_scale = 1.1
		local logo_w = logo_scale * 367
		local logo_h = logo_scale * 99
		--draw.DrawText(self.welcomeMessage.." to", "Impulse-Elements27-Shadow", ScrW()/2, 150, color_white, TEXT_ALIGN_CENTER)
		impulse.render.glowgo(x - (logo_w * .5), y, logo_w, logo_h)
		draw.DrawText("press any key to continue", "Impulse-Elements27-Shadow", x, y + logo_h + 40, splashCol, TEXT_ALIGN_CENTER)
	end

	function self.core:OnMousePressed()
		panel:OnKeyCodeReleased()
	end

	self.welcomeMessage = "Welcome"

	impulse.splash = self
end

function PANEL:OnKeyCodeReleased()
	if self.used then return end
	
	--impulse.hudEnabled = true
	self.used = true
	impulse_IsReady = true
	self.core:AlphaTo(0, 1.5, 0, function()
		if not IsValid(self) then
			return
		end

		timer.Simple(0.33, function()
			if GetGlobalString("impulse_fatalerror", "") != "" then
				local x, y = ScrW() * .3, ScrH() * .3

				local sad = vgui.Create("DImage", self)
				sad:SetPos(x + 210, y - 100)
				sad:SetSize(224, 60)
				sad:SetImage("impulse/impulse-logo-white.png")
				sad:SetAlpha(100)

				local sad = vgui.Create("DImage", self)
				sad:SetPos(x, y)
				sad:SetSize(180, 180)
				sad:SetImage("impulse/icons/sad.png")

				local title = vgui.Create("DLabel", self)
				title:SetPos(x + 210, y)
				title:SetFont("Impulse-Elements32-Shadow")
				title:SetText("Fatal Error")
				title:SizeToContents()

				local desc = vgui.Create("DLabel", self)
				desc:SetPos(x + 210, y + 70)
				desc:SetSize(410, 500)
				desc:SetFont("Impulse-Elements19-Shadow")
				desc:SetContentAlignment(7)
				desc:SetWrap(true)
				desc:SetText(GetGlobalString("impulse_fatalerror", "").."\n\nCheck the server console for more details. When you have corrected the fault, restart the server.")

				return
			end

			self:Remove()

			if impulse_isNewPlayer or (cookie.GetString("impulse_em_do_intro") or "") == "true" then
				if (cookie.GetString("impulse_em_do_intro") or "") == "true" then
					cookie.Delete("impulse_em_do_intro")	
				end
				
				if impulse.Config.IntroScenes then
					impulse.Scenes.PlaySet(impulse.Config.IntroScenes, impulse.Config.IntroMusic, function()
						local mainMenu = vgui.Create("impulseMainMenu")
						mainMenu:SetAlpha(0)
						mainMenu:AlphaTo(255, 1)
					end)
				else
					local mainMenu = vgui.Create("impulseMainMenu")
					mainMenu:SetAlpha(0)
					mainMenu:AlphaTo(255, 1)
				end


				net.Start("impulseOpsEMIntroCookie")
				net.SendToServer()
			else
				local x = vgui.Create("impulseMainMenu")
				x.core:SetAlpha(0)
				x.core:AlphaTo(255, 1)
			end
		end)
	end)

	surface.PlaySound("UI/buttonclick.wav")

	hook.Run("PostReloadToolsMenu")
end

function PANEL:OnMousePressed()
	self:OnKeyCodeReleased()
end

function PANEL:Paint(w,h)
	Derma_DrawBackgroundBlur(self)
end

vgui.Register("impulseSplash", PANEL, "DPanel")