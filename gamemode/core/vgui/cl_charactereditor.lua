local PANEL = {}

function PANEL:Init()
	self:SetSize(600, 400)
	self:Center()
	self:SetTitle("Character Editor")
	self:MakePopup()

	local panel = self

	self.nextButton = vgui.Create("DButton", self)
	self.nextButton:SetPos(470,370)
	self.nextButton:SetSize(120,20)
	self.nextButton:SetText("Change")
	self.nextButton:SetDisabled(false)
	self.nextButton.DoClick = function()
		local characterGender = self.genderBox:GetValue():lower()

		if characterGender == "male" then
			characterGender = false
		else
			characterGender = true
		end

		local characterModel = self.characterPreview.Entity:GetModel()
		local characterSkin = self.characterPreview.Entity:GetSkin()

		local msg = Derma_Message

		local skinBlacklist = impulse.Config.DefaultSkinBlacklist[characterModel]

		if skinBlacklist and table.HasValue(skinBlacklist, characterSkin) then
			return msg("The skin you selected was on the blacklist.\nPlease select another skin or change the model.", "impulse", "OK")
		end

		net.Start("impulseCharacterEdit")
		net.WriteString(characterModel)
		net.WriteUInt(characterSkin, 8)
		net.SendToServer()

		self:Remove()
	end

	local curModel = impulse_defaultModel
	local curSkin = impulse_defaultSkin
	local isFemale = LocalPlayer():IsCharacterFemale()

	function self.nextButton:Think()
		local cost = 0
		if panel.genderBox:GetValue() != panel.genderBox.normal then
			cost = cost + impulse.Config.CosmeticGenderPrice
		end

		if panel.characterPreview.Entity:GetModel() != curModel or panel.characterPreview.Entity:GetSkin() != curSkin then
			cost = cost + impulse.Config.CosmeticModelSkinPrice
		end

		if cost > 0 then
			self:SetDisabled(false)
			self:SetText("Change ("..impulse.Config.CurrencyPrefix..cost..")")
		else
			self:SetDisabled(true)
			self:SetText("Change")
		end
	end

	self.characterPreview = vgui.Create("DModelPanel", self)
	self.characterPreview:SetSize(600,400)
	self.characterPreview:SetPos(0,30)
	self.characterPreview:SetModel(curModel)
	self.characterPreview:MoveToBack()
	self.characterPreview:SetCursor("arrow")
	self.characterPreview:SetFOV(70)
	self.characterPreview:SetCamPos(Vector(52, 52, 52))
	self.characterPreview.Entity:SetSkin(curSkin)
 	function self.characterPreview:LayoutEntity(ent) 
  		ent:SetAngles(Angle(0,40,0))
 	end

 	local characterPreview = self.characterPreview

	self.genderLbl = vgui.Create("DLabel", self)
	self.genderLbl:SetFont("Impulse-Elements18-Shadow")
	self.genderLbl:SetText("Gender:")
	self.genderLbl:SizeToContents()
	self.genderLbl:SetPos(10,40)

  	self.genderBox = vgui.Create("DComboBox", self)
  	self.genderBox:SetPos(10,60)
  	self.genderBox:SetSize(180,23)

  	if isFemale then
  		self.genderBox:SetValue("Female")
  	else
  		self.genderBox:SetValue("Male")
  	end

  	self.genderBox.normal = self.genderBox:GetValue()

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

  	self.genderWarn = vgui.Create("DLabel", self)
  	self.genderWarn:SetFont("Impulse-Elements16")
  	self.genderWarn:SetText("Costs "..impulse.Config.CurrencyPrefix..impulse.Config.CosmeticGenderPrice.." per change")
  	self.genderWarn:SizeToContents()
  	self.genderWarn:SetPos(10, 90)

	self.modelLbl = vgui.Create("DLabel", self)
	self.modelLbl:SetFont("Impulse-Elements18-Shadow")
	self.modelLbl:SetText("Models:")
	self.modelLbl:SizeToContents()
	self.modelLbl:SetPos(400,40)

	if isFemale then
		self:PopulateModels(impulse.Config.DefaultFemaleModels)
	else
		self:PopulateModels(impulse.Config.DefaultMaleModels)
	end

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
	self.skinSlider:SetValue(curSkin)
	self.skinSlider.TextArea:SetTextColor(color_white)

	function self.skinSlider:OnValueChanged(newSkin)
		characterPreview.Entity:SetSkin(newSkin)
	end

  	self.skinWarn = vgui.Create("DLabel", self)
  	self.skinWarn:SetFont("Impulse-Elements16")
  	self.skinWarn:SetText("Costs "..impulse.Config.CurrencyPrefix..impulse.Config.CosmeticModelSkinPrice.." per change")
  	self.skinWarn:SizeToContents()
  	self.skinWarn:SetPos(400, 310)
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


vgui.Register("impulseCharacterEditor", PANEL, "DFrame")