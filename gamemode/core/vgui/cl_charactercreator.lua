local PANEL = {}

function PANEL:Init()
	self:SetSize(600, 400)
	self:Center()
	self:SetTitle("Character Creation")
	self:MakePopup()
	self:SetBackgroundBlur(true)

	self.nextButton = vgui.Create("DButton", self)
	self.nextButton:SetPos(530,370)
	self.nextButton:SetSize(60,20)
	self.nextButton:SetText("Finish")
	self.nextButton:SetDisabled(false)
	self.nextButton.DoClick = function()
		local characterName = self.nameEntry:GetValue()
		local characterGender = self.genderBox:GetValue():lower()
		local characterModel = self.characterPreview.Entity:GetModel()
		local characterSkin = self.characterPreview.Entity:GetSkin()

		local msg = Derma_Message

		local skinBlacklist = impulse.Config.DefaultSkinBlacklist[characterModel]

		if skinBlacklist and table.HasValue(skinBlacklist, characterSkin) then
			return msg("The skin you selected was on the blacklist.\nPlease select another skin or change the model.", "impulse", "OK")
		end
		
		local name, rejectReason = impulse.CanUseName(characterName)
		if name == false then return msg(rejectReason, "impulse", "OK") end

		Derma_Query("Are you sure you are finished?\nYou can edit your character later, but it will cost a fee.", "impulse", "Yes", function()
			print("[impulse] Sending character data to server...")

			net.Start("impulseCharacterCreate")
			net.WriteString(characterName)
			net.WriteString(characterModel)
			net.WriteUInt(characterSkin, 8)
			net.SendToServer()

    		LocalPlayer():ScreenFade(SCREENFADE.IN, color_black, 4, 0.3)
    		self:Remove()
    		self:GetParent():Remove()
			impulse.hudEnabled = true
			FORCE_FADESPAWN = true
			impulse_isNewPlayer = false

			if CHAR_MUSIC and CHAR_MUSIC:IsPlaying() then
				CHAR_MUSIC:FadeOut(15)

				timer.Simple(16, function()
					if CHAR_MUSIC:IsPlaying() then
						CHAR_MUSIC:Stop()
					end
				end)
			end
		end, "No, take me back")
	end

	self.characterPreview = vgui.Create("DModelPanel", self)
	self.characterPreview:SetSize(600,400)
	self.characterPreview:SetPos(0,30)
	self.characterPreview:SetModel(impulse.Config.DefaultMaleModels[1])
	self.characterPreview:MoveToBack()
	self.characterPreview:SetCursor("arrow")
	self.characterPreview:SetFOV(70)
	self.characterPreview:SetCamPos(Vector(52, 52, 52))
 	function self.characterPreview:LayoutEntity(ent) 
  		ent:SetAngles(Angle(0,40,0))
 	end

 	local characterPreview = self.characterPreview

	self.nameLbl = vgui.Create("DLabel", self)
 	self.nameLbl:SetFont("Impulse-Elements18-Shadow")
	self.nameLbl:SetText("Full Name:")
	self.nameLbl:SizeToContents()
	self.nameLbl:SetPos(10,40)

 	self.nameEntry = vgui.Create("DTextEntry", self)
 	self.nameEntry:SetSize(180,23)
 	self.nameEntry:SetPos(10,60)
 	self.nameEntry:SetAllowNonAsciiCharacters(false)

	self.genderLbl = vgui.Create("DLabel", self)
	self.genderLbl:SetFont("Impulse-Elements18-Shadow")
	self.genderLbl:SetText("Gender:")
	self.genderLbl:SizeToContents()
	self.genderLbl:SetPos(10,90)

  	self.genderBox = vgui.Create("DComboBox", self)
  	self.genderBox:SetPos(10,110)
  	self.genderBox:SetSize(180,23)
  	self.genderBox:SetValue("Male")
  	self.genderBox:AddChoice("Male")
  	self.genderBox:AddChoice("Female")
  	function self.genderBox.OnSelect(panel, index, value)
  		if value == "Male" then
  			self:PopulateModels(impulse.Config.DefaultMaleModels)
  			characterPreview:SetModel(impulse.Config.DefaultMaleModels[1])
  			self.skinSlider:SetValue(0)
  			self.skinSlider:SetMax(characterPreview.Entity:SkinCount())
  		else
  			self:PopulateModels(impulse.Config.DefaultFemaleModels)
  			characterPreview:SetModel(impulse.Config.DefaultFemaleModels[1])
  			self.skinSlider:SetValue(0)
  			self.skinSlider:SetMax(characterPreview.Entity:SkinCount())
  		end
  	end

	self.modelLbl = vgui.Create("DLabel", self)
	self.modelLbl:SetFont("Impulse-Elements18-Shadow")
	self.modelLbl:SetText("Models:")
	self.modelLbl:SizeToContents()
	self.modelLbl:SetPos(400,40)

  	self:PopulateModels(impulse.Config.DefaultMaleModels)

	self.skinLbl = vgui.Create("DLabel", self)
	self.skinLbl:SetFont("Impulse-Elements18-Shadow")
	self.skinLbl:SetText("Skin:")
	self.skinLbl:SizeToContents()
	self.skinLbl:SetPos(400,260)

	self.skinSlider = vgui.Create("DNumSlider", self)
	self.skinSlider:SetMin(0)
	self.skinSlider:SetDecimals(0)
	self.skinSlider:SetMax(characterPreview.Entity:SkinCount()-1)
	self.skinSlider:SetSize(395,20)
	self.skinSlider:SetPos(230, 280)
	self.skinSlider:SetValue(0)
	self.skinSlider.TextArea:SetTextColor(color_white)

	function self.skinSlider:OnValueChanged(newSkin)
		characterPreview.Entity:SetSkin(newSkin)
	end
end

function PANEL:PopulateModels(modelTable)
	if self.modelScroll then self.modelScroll:Remove() end -- done to fix some weird bugs when changing size of the iconlayout with the sidebar

 	self.modelScroll = vgui.Create("DScrollPanel", self)
 	self.modelScroll:SetPos(400,60)
 	self.modelScroll:SetSize(200,185)

 	self.modelBase = vgui.Create("DIconLayout", self.modelScroll)
 	self.modelBase:Dock(FILL)
 	self.modelBase:SetSpaceY(5)
 	self.modelBase:SetSpaceX(5)

  	for _, model in pairs(modelTable) do
    	local modelIcon = vgui.Create("SpawnIcon", self.modelBase)
    	modelIcon:SetModel(model)
    	modelIcon:SetSize(58,58)
    	modelIcon.savedModel = model
    	modelIcon.DoClick = function()
    		self.characterPreview:SetModel(modelIcon.savedModel)
    		self.skinSlider:SetValue(0)
    		self.skinSlider:SetMax(self.characterPreview.Entity:SkinCount()-1)
    	end
  	end
end


vgui.Register("impulseCharacterCreator", PANEL, "DFrame")