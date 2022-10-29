local PANEL = {}

surface.CreateFont("impulsePTCTitle", {
	font = "Consolas",
	size = 43,
	weight = 900,
	antialias = true,
	shadow = true,
	italic = false
})

surface.CreateFont("impulsePTCOther", {
	font = "Consolas",
	size = 33,
	weight = 900,
	antialias = true,
	shadow = true,
	italic = false
})

local levels = {
	[1] = {cans = 5, rate = 1, col = Color(0, 225, 0), snd = "vo/Streetwar/Alyx_gate/al_letsgo01.wav"},
	[2] = {cans = 10, rate = 1.5, col = Color(51, 179, 146), snd = "vo/npc/male01/gordead_ques16.wav"},
	[3] = {cans = 20, rate = 2, col = Color(0, 225, 255), snd = "vo/npc/male01/nice.wav"},
	[4] = {cans = 25, rate = 2.4, col = Color(225, 225, 0), snd = "vo/npc/male01/watchout.wav"},
	[5] = {cans = 30, rate = 2.6, col = Color(225, 0, 0), snd = "vo/k_lab/ba_goodluck02.wav"}
}

function PANEL:Init()
	self:SetSize(500, ScrH())
	self:Center()
	self:MakePopup()
	self.Score = 0
	self.Level = 1

	surface.PlaySound("npc/metropolice/vo/pickupthecan1.wav")

	local startScreen = vgui.Create("DNotify", self)
	startScreen:SetSize(480, 300)
	startScreen:Center()

	local title = vgui.Create("DLabel", startScreen)
	title:Dock(TOP)
	title:SetText("Pickup That Can!")
	title:SetTextColor(Color(0, 0, 200))
	title:SetFont("impulsePTCTitle")
	title:SizeToContents()

	local sub = vgui.Create("DLabel", startScreen)
	sub:Dock(TOP)
	sub:SetText("A game by Vinard Industries. Licensed UU product #43257. Rated A for AUGMENTED.\n\nCONTROLS: ARROW KEYS")
	sub:SetFont("Default")
	sub:SizeToContents()

	startScreen:AddItem(sub)
	startScreen:AddItem(title)

	if MINIGAME_MUSIC and MINIGAME_MUSIC:IsPlaying() then
		MINIGAME_MUSIC:Stop()
	end

	MINIGAME_MUSIC = CreateSound(LocalPlayer(), "music/HL2_song20_submix0.mp3")
	MINIGAME_MUSIC:SetSoundLevel(0)
	MINIGAME_MUSIC:ChangeVolume(0.6)
	MINIGAME_MUSIC:Play()

	timer.Simple(4, function()
		if IsValid(self) then
			self:StartLevel(1, 1)
		end
	end)
end

function PANEL:StartLevel(level, time)
	if self.go then
		return
	end

	local ldata = levels[level]
	self.Level = level
	self.Cans = ldata.cans

	self:SpawnBin()

	surface.PlaySound("friends/friend_online.wav")
	surface.PlaySound(ldata.snd)

	timer.Simple(time or 3, function()
		if IsValid(self) then
			timer.Create("PTCSpawner", 1.6 - (ldata.rate * 0.4), ldata.cans, function()
				if IsValid(self) then
					self:SpawnCan(ldata.rate)
				end
			end)
		end
	end)
end

function PANEL:GameOver(win)
	if self.go then
		return
	end

	self.go = true

	if not win then
		MINIGAME_MUSIC:FadeOut(1)
	else
		surface.PlaySound("npc/metropolice/die1.wav")
	end

	local startScreen = vgui.Create("DNotify", self)
	startScreen:SetSize(480, 300)
	startScreen:Center()

	local title = vgui.Create("DLabel", startScreen)
	title:Dock(TOP)
	if win then
		title:SetText("YOU WIN!!!!")
		hook.Run("PickUpThatCanWin")
	else
		title:SetText("GAME OVER")
	end
	if win then
		title:SetTextColor(Color(0, 255, 0))
	else
		title:SetTextColor(Color(255, 0, 0))
	end

	title:SetFont("impulsePTCTitle")
	title:SizeToContents()
	title:SetContentAlignment(5)

	startScreen:AddItem(title)

	if not win then
		surface.PlaySound("buttons/button8.wav")
		surface.PlaySound("music/stingers/HL1_stinger_song8.mp3")

		timer.Simple(0.5, function()
			surface.PlaySound("npc/metropolice/vo/chuckle.wav")
		end)

		timer.Simple(1.2, function()
			surface.PlaySound("weapons/stunstick/stunstick_fleshhit1.wav")
		end)
	end

	timer.Simple(6, function()
		if IsValid(self) then
			self:Remove()

			if win then
				Derma_Message("Nice work, you won!\nMostly due to luck though because the last level can be impossible if you get unlucky with spawns.\nAnyway glad you found this! - vin", "impulse", "Ok")
			end
		end
	end)
end

function PANEL:SpawnCan(speed)
	if self.go then
		return
	end

	local panel = self
	local x = math.random(50, 450)
	local can = vgui.Create("SpawnIcon", self)
	can:SetPos(x, 100)
	can:SetModel("models/props_junk/popcan01a.mdl")
	can:SetTooltip("")
	can:SetDisabled(true)
	can.Speed = speed

	function can:Think()
		local x, y = self:GetPos()
		self:SetPos(x, y + (FrameTime() * 335) * self.Speed)

		if y > ScrH() then
			panel:GameOver()
			self:Remove()
		end

		if panel.bin and IsValid(panel.bin) and self:Distance(panel.bin) < 50 then
			surface.PlaySound("physics/metal/metal_barrel_impact_soft"..math.random(1, 4)..".wav")
			panel.Score = panel.Score + 1
			panel.Cans = panel.Cans - 1

			if panel.Cans == 0 then
				if panel.Level == table.Count(levels) then
					panel:GameOver(true)
				else
					panel:StartLevel(panel.Level + 1)
				end
			end
			self:Remove()
		end
	end

	function can:DoClick()
	end

	function can:PaintOver()
	end
end

function PANEL:SpawnBin()
	if self.bin then
		self.bin:Remove()
	end

	self.bin = vgui.Create("SpawnIcon", self)
	self.bin:SetPos(0, ScrH() - 145)
	self.bin:SetSize(120, 120)
	self.bin:CenterHorizontal()
	self.bin:SetModel("models/props_trainstation/trashcan_indoor001b.mdl")
	self.bin:SetTooltip("")
	self.bin:SetDisabled(true)

	function self.bin:DoClick()
	end

	function self.bin:Think()
		local x, y = self:GetPos()
		local s = 360

		self:MoveToFront()

		if input.IsKeyDown(KEY_LEFT) then
			self:SetPos(math.Clamp(x - (FrameTime() * s), 0, 400), y)
		elseif input.IsKeyDown(KEY_RIGHT) then
			self:SetPos(math.Clamp(x + (FrameTime() * 630), 0, 400), y) -- idk why but right is slow af lol
		end
	end
	
	function self.bin:PaintOver()
	end
end

local darkCol = Color(60, 120, 0, 190)
local gradient = Material("vgui/gradient_down")

function PANEL:Paint(w,h)
	surface.SetMaterial(gradient)
	surface.SetDrawColor(levels[self.Level].col)
	surface.DrawTexturedRect(0, 0, w, h)

	draw.SimpleText("SCORE: "..self.Score, "impulsePTCOther", 5, 15)
	draw.SimpleText(self.Level.." :LEVEL", "impulsePTCOther", w - 5, 15, nil, TEXT_ALIGN_RIGHT)
end

function PANEL:OnFocusChanged(state)
	if not state then
		self:Remove()
	end
end

function PANEL:OnRemove()
	if MINIGAME_MUSIC and MINIGAME_MUSIC:IsPlaying() then
		MINIGAME_MUSIC:FadeOut(4)
		timer.Simple(4, function()
			if MINIGAME_MUSIC:IsPlaying() then
				MINIGAME_MUSIC:Stop()
			end
		end)
	end
end

function PANEL:OnMousePressed()

end

vgui.Register("impulseMinigame", PANEL, "DPanel")