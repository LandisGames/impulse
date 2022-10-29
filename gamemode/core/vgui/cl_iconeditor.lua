local PANEL = {}

function PANEL:Init()
	self:SetSize(800, 700)
	self:Center()
	self:SetTitle("Icon Camera Editor")
	self:MakePopup()

	local lbl = vgui.Create("DLabel", self)
	lbl:SetText("Real:                       Upscale:")
	lbl:SizeToContents()
	lbl:SetPos(5, 280)

	local panel = self

	self.bg = vgui.Create("DPanel", self)
	self.bg:SetPos(5, 300)
	self.bg:SetSize(64, 64)

	function self.bg:Paint(w, h)
		draw.RoundedBox(1, 0, 0, w, h, color_white)
	end

	self.model = vgui.Create("DModelPanel", self)
	self.model:SetPos(5, 300)
	self.model:SetSize(64, 64)
	self.model:SetModel("models/props_junk/wood_crate001a.mdl")
	self.model:SetSkin(0)
	self.model:SetFOV(55)

	local ang = Angle(0, 90, 0)
	local noCnt = false

	function self.model:LayoutEntity(ent)
		ent:SetAngles(ang)

		if not noCnt then
			self:SetLookAt(Vector(0, 0, 0))
		else
			local min, max = ent:GetRenderBounds()
			self:SetLookAt((max + min) / 2)
		end

		return
	end

	local camPos = self.model.Entity:GetPos()
	camPos:Add(Vector(0, 25, 25))

	local min, max = self.model.Entity:GetRenderBounds()
	self.model:SetCamPos(camPos -  Vector(10, 0, 16))
	self.model:SetLookAt((max + min) / 2)

	self.bg = vgui.Create("DPanel", self)
	self.bg:SetPos(100, 300)
	self.bg:SetSize(255, 255)

	function self.bg:Paint(w, h)
		draw.RoundedBox(1, 0, 0, w, h, color_white)
	end

	self.modelBig = vgui.Create("DModelPanel", self)
	self.modelBig:SetPos(100, 300)
	self.modelBig:SetSize(255, 255)
	self.modelBig:SetModel("models/props_junk/wood_crate001a.mdl")
	self.modelBig:SetSkin(0)
	self.modelBig:SetFOV(55)

	local ang = Angle(0, 90, 0)

	function self.modelBig:LayoutEntity(ent)
		ent:SetAngles(ang)

		if not noCnt then
			self:SetLookAt(Vector(0, 0, 0))
		else
			local min, max = ent:GetRenderBounds()
			self:SetLookAt((max + min) / 2)
		end

		return
	end

	local camPos = self.modelBig.Entity:GetPos()
	camPos:Add(Vector(0, 25, 25))

	local min, max = self.modelBig.Entity:GetRenderBounds()
	self.modelBig:SetCamPos(camPos -  Vector(10, 0, 16))
	self.modelBig:SetLookAt((max + min) / 2)

	self.modelEntry = vgui.Create("DTextEntry", self)
	self.modelEntry:SetPos(100, 50)
	self.modelEntry:SetSize(400, 20)
	self.modelEntry:SetText("Model name here")

	function self.modelEntry:OnEnter()
		panel.model:SetModel(self:GetValue())
		panel.modelBig:SetModel(self:GetValue())
	end

	self.useNoCenter = vgui.Create("DCheckBoxLabel", self)
	self.useNoCenter:SetPos(560, 50)
	self.useNoCenter:SetText("No Center")
	self.useNoCenter:SetValue(0)
	self.useNoCenter:SizeToContents()

	function self.useNoCenter:OnChange(v)
		noCnt = v
	end

	self.fovSlider = vgui.Create("DNumSlider", self)
	self.fovSlider:SetPos(100, 80)
	self.fovSlider:SetSize(700, 30)
	self.fovSlider:SetText("FOV")
	self.fovSlider:SetMin(2)
	self.fovSlider:SetMax(100)
	self.fovSlider:SetDecimals(0)
	self.fovSlider:SetValue(55)

	function self.fovSlider:OnValueChanged(val)
		panel.model:SetFOV(val)
		panel.modelBig:SetFOV(val)
	end

	self.camXSlider = vgui.Create("DNumSlider", self)
	self.camXSlider:SetPos(100, 110)
	self.camXSlider:SetSize(700, 30)
	self.camXSlider:SetText("Camera X")
	self.camXSlider:SetMin(-160)
	self.camXSlider:SetMax(160)
	self.camXSlider:SetDecimals(0)
	self.camXSlider:SetValue(10)

	function self.camXSlider:OnValueChanged(val)
		local curPos = panel.model:GetCamPos()
		panel.model:SetCamPos(Vector(val, curPos.y, curPos.z))
		panel.modelBig:SetCamPos(Vector(val, curPos.y, curPos.z))
	end

	self.camYSlider = vgui.Create("DNumSlider", self)
	self.camYSlider:SetPos(100, 140)
	self.camYSlider:SetSize(700, 30)
	self.camYSlider:SetText("Camera Y")
	self.camYSlider:SetMin(-160)
	self.camYSlider:SetMax(160)
	self.camYSlider:SetDecimals(0)
	self.camYSlider:SetValue(25)

	function self.camYSlider:OnValueChanged(val)
		local curPos = panel.model:GetCamPos()
		panel.model:SetCamPos(Vector(curPos.x, val, curPos.z))
		panel.modelBig:SetCamPos(Vector(curPos.x, val, curPos.z))
	end

	self.camZSlider = vgui.Create("DNumSlider", self)
	self.camZSlider:SetPos(100, 170)
	self.camZSlider:SetSize(700, 30)
	self.camZSlider:SetText("Camera Z")
	self.camZSlider:SetMin(-660)
	self.camZSlider:SetMax(660)
	self.camZSlider:SetDecimals(0)
	self.camZSlider:SetValue(9)

	function self.camZSlider:OnValueChanged(val)
		local curPos = panel.model:GetCamPos()
		panel.model:SetCamPos(Vector(curPos.x, curPos.y, val))
		panel.modelBig:SetCamPos(Vector(curPos.x, curPos.y, val))
	end

	self.output = vgui.Create("DButton", self)
	self.output:SetPos(105, 200)
	self.output:SetSize(650, 25)
	self.output:SetText("Output (copy data to clipboard)")

	function self.output:DoClick()
		local camPos = panel.model:GetCamPos()
		local output = "ITEM.FOV = "..panel.model:GetFOV().."\n"
		output = output.."ITEM.CamPos = Vector("..camPos.x..", "..camPos.y..", "..camPos.z..")"

		if noCnt then
			output = output.."\nITEM.NoCenter = true"
		end

		print(output)
		SetClipboardText(output)

		LocalPlayer():Notify("Exported.")
	end
end


vgui.Register("impulseIconEditor", PANEL, "DFrame")