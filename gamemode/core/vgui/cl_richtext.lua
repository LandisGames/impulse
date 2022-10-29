local PANEL = {}

function PANEL:Init()
	local bar = self:GetVBar()

	self.barPaint = bar.Paint
	self.btnUpPaint = bar.btnUp.Paint
	self.btnDownPaint = bar.btnDown.Paint
	self.btnGripPaint = bar.btnGrip.Paint
end

function PANEL:SetTextRaw(text, draw)
	local panel = markup.Parse(text, self:GetWide())
	panel.OnDrawText = draw

	self:SetTall(object:GetHeight())
	self.Paint = function(self, w, h)
		panel:Draw(0, 0)
	end
end

local setTextPos = surface.SetTextPos
local setTextCol = surface.SetTextColor
local setTextFont = surface.SetFont
local drawText = surface.DrawText
local function OnDrawText(text, font, x, y, color, alignX, alignY, alpha)
	alpha = alpha or 255

	setTextPos(x+1, y+1)
	setTextCol(0, 0, 0, alpha)
	setTextFont(font)
	drawText(text)

	setTextPos(x, y)
	setTextCol(color.r, color.g, color.b, alpha)
	setTextFont(font)
	drawText(text)
end

function PANEL:SetScrollBarVisible(visible)
	local bar = self:GetVBar()

	if visible == true then
		bar.btnUp.Paint = self.btnUpPaint
		bar.btnDown.Paint = self.btnDownPaint
		bar.btnGrip.Paint = self.btnGripPaint
		bar.Paint = self.barPaint
	else
		bar.btnUp.Paint = function() end
		bar.btnDown.Paint = function() end
		bar.btnGrip.Paint = function() end
		bar.Paint = function() end
	end
end

function PANEL:ScrollToChild(panel)
	self:PerformLayout()

	local x, y = self.pnlCanvas:GetChildPosition(panel)
	local w, h = panel:GetSize()

	y = y + h * 0.5
	y = y - self:GetTall() * 0.5

	self.VBar:AnimateTo(y, 0.5, 0, 0.5)
end

function PANEL:AddText(...)
	local text = "<font=".."Impulse-Chat"..impulse.GetSetting("chat_fontsize")..">"
	local plainText = ""
	local luaMsg = {}

	if impulse.customChatFont then
		text = "<font="..impulse.customChatFont..">"
		impulse.customChatFont = nil
	end
	
	for k, v in ipairs({...}) do
		if (type(v) == "table" and v.r and v.g and v.b) then
			text = text.."<color="..v.r..","..v.g..","..v.b..">"

			table.insert(luaMsg, Color(v.r, v.g, v.b, 255))
		elseif (type(v) == "Player") then
			local color = team.GetColor(v:Team())
			local str = v:KnownName():gsub("<", "&lt;"):gsub(">", "&gt;")

			text = text.."<color="..color.r..","..color.g..","..color.b..">"..str
			painText = plainText..v:Name()
			
			table.insert(luaMsg, color)
			table.insert(luaMsg, str)
		else
			local str = tostring(v):gsub("<", "&lt;"):gsub(">", "&gt;")
			text = text..str
			plainText = plainText..str

			table.insert(luaMsg, v)
		end
	end

	text = text.."</font>"

	local textElement = self:Add("DPanel")
	textElement:SetWide(self:GetWide() - 15)
	textElement:SetDrawBackground(false)
	textElement:SetMouseInputEnabled(true)
	textElement.plainText = plainText

	local mrkup = markup.Parse(text, self:GetWide() - 15)
	mrkup.OnDrawText = drawText

	textElement:SetTall(mrkup:GetHeight())
	textElement.Paint = function(self, w, h)
		if self.sleeping then
			return
		end

		mrkup:Draw(0, 0)
	end

	textElement.start = CurTime() + impulse.GetSetting("chat_fadetime")
	textElement.finish = textElement.start + 10

	local setAlpha = textElement.SetAlpha
	textElement.Think = function(this)
		if self.active then
			this.sleeping = false
			setAlpha(this, 255)
		elseif not this.sleeping then
			local alpha = (1 - math.TimeFraction(this.start, this.finish, CurTime())) * 255
			setAlpha(this, alpha)

			if alpha <= 0 then
				this.sleeping = true
			end
		end
	end

	if impulse.customChatPlayer then
		textElement.player = impulse.customChatPlayer
	end

	impulse.customChatPlayer = nil

	textElement.OnMousePressed = function()
		local subMenu = DermaMenu()

		subMenu.Think = function()
			subMenu:MoveToFront()
		end

		local copyText = subMenu:AddOption("Copy text to clipboard", function()
			SetClipboardText(textElement.plainText)
			chat.AddText(color_white, "Text copied to clipboard.")
		end)
		copyText:SetIcon("icon16/page_copy.png")

		if LocalPlayer():IsAdmin() and IsValid(textElement.player) then
			local banPly = subMenu:AddOption("OOC timeout sender", function()
				Derma_StringRequest("impulse", "Enter timeout length in minutes:", "15", function(x)
					if not IsValid(textElement.player) then
						return
					end


					LocalPlayer():ConCommand("say /ooctimeout "..textElement.player:SteamID().." "..x)
				end, nil, "Issue timeout")
			end)
			banPly:SetIcon("icon16/sound_add.png")
		end

		subMenu:Open()
		subMenu:SetPos(gui.MouseX(), gui.MouseY())
	end

	textElement:Dock(TOP)
	textElement:InvalidateParent(true)

	if not self.BlockScroll then
		self:ScrollToChild(textElement)
	else
		self.BlockScroll = false
	end

	self.lastChildMessage = textElement

	MsgC(unpack(luaMsg))
	MsgN("")
end

vgui.Register("impulseRichText", PANEL, "DScrollPanel")