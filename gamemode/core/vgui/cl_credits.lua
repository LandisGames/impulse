local PANEL = {}

function PANEL:Init()
	self:SetAlpha(255)
	self:SetSize(600, ScrH())
	self:Center()

	self.killTime = CurTime() + 39

	self.mainCredits = markup.Parse([[
		<font=Impulse-Elements32>
		Framework creator
		<font=Impulse-Elements23>vin</font>

		Framework contributor(s)
		<font=Impulse-Elements23>aLoneWitness</font>

		Third-party contrbutors
		<font=Impulse-Elements23>Alex Grist - mysql wrapper
		FredyH - mysqloo
		thelastpenguin - pon
		Kyle Smith - UTF-8 module
		rebel1234 and Chessnut - animations base
		wyozi - medialib
		Dominic Letz - yaml parser
		Falco - CPPI
		vin - impulse markup language
		kikito - tween.lua</font>

		Powered by
		<font=Impulse-Elements23>Discord - Discord API
		Osyris - RbxDiscordProxy
		Wordpress - Wordpress API</font>

		Inspired by
		<font=Impulse-Elements23>Aerolite, Apex-Roleplay and Cookie-Network</font>

		Testing team
		<font=Impulse-Elements23>Aquaman
		Baker
		Bee
		Bwah
		confuseth
		Solo_D
		Desxon
		EnigmaFusion
		Bobby
		Shadow
		Ho
		greasy breads
		Jamsu
		KTG
		Angrycrumpet
		Mats
		Lukyn150
		Law
		Lefton
		Morgan
		psycho
		Ramtin
		StrangerThanYou
		ThePersonWhoPlaysGames
		Twatted
		Y Tho</font>

		Special thanks
		<font=Impulse-Elements23>StrangerThanYou (mapping)
		aLoneWitness (framework coding and feedback)
		oscar holmes (early feedback)
		Law (mod)
		Bwah (mod)
		Bee (mod)
		Lefton (mod)
		Y Tho (mod and early feedback)
		morgan (mod and early feedback)</font>
		</font>
		]]..[[
		<font=Impulse-Elements32>

		]]..impulse.Config.SchemaName..[[


		]]..string.Replace(impulse.Config.SchemaCredits, "\n", "\n		")..[[
		</font>




		<font=Impulse-Elements23>
		Copyright 2i.games 2021
		</font>]], 550)

	self.scrollY = ScrH() + 160

	if CREDIT_MUSIC and CREDIT_MUSIC:IsPlaying() then
		CREDIT_MUSIC:Stop()
	end

	CREDIT_MUSIC = CreateSound(LocalPlayer(), "music/HL2_song20_submix4.mp3")
	CREDIT_MUSIC:SetSoundLevel(0)
	CREDIT_MUSIC:ChangeVolume(1)
	CREDIT_MUSIC:Play()
end

local bodyCol = Color(30, 30, 30, 190)
function PANEL:Paint(w,h)
	Derma_DrawBackgroundBlur(self)
	surface.SetDrawColor(bodyCol) -- menu body
	surface.DrawRect(0, 0, w, h) -- left body

	self.scrollY = self.scrollY - (FrameTime() * 88)

	impulse.render.glowgo((w / 2) - 165, self.scrollY + 70, 337, 91)
	self.mainCredits:Draw(0, self.scrollY + 190, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

function PANEL:OnRemove()
	if CREDIT_MUSIC and CREDIT_MUSIC:IsPlaying() then
		CREDIT_MUSIC:FadeOut(4)
		timer.Simple(4, function()
			if CREDIT_MUSIC:IsPlaying() then
				CREDIT_MUSIC:Stop()
			end
		end)
	end
end

function PANEL:Think()
	if CurTime() > self.killTime then
		self:AlphaTo(0, 2, 0, function()
			self:Remove()
			impulse.MainMenu:AlphaTo(255, 2, 0)
		end)
	end
end

vgui.Register("impulseCredits", PANEL, "DPanel")
