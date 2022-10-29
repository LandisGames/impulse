-- impulse's chatbox is based uponimpulse.chatBox by Exho
-- Author: vin, Exho (obviously), Tomelyr, LuaTenshi
-- Version: 4/12/15

if impulse.chatBox and IsValid(impulse.chatBox.frame) then
	impulse.chatBox.frame:Remove()
end

impulse.chatBox = {}

impulse.DefineSetting("chat_fadetime", {name="Chatbox fade time", category="Chatbox", type="slider", default=12, minValue=4, maxValue=120})
impulse.DefineSetting("chat_fontsize", {name="Chatbox font size", category="Chatbox", type="dropdown", default="Medium", options={"Small", "Medium", "Large"}})

--// Builds the chatbox but doesn't display it
function impulse.chatBox.buildBox()
	impulse.chatBox.frame = vgui.Create("DFrame")
	impulse.chatBox.frame:SetSize( ScrW()*0.375, ScrH()*0.35 )
	impulse.chatBox.frame:SetTitle("")
	impulse.chatBox.frame:ShowCloseButton( false )
	impulse.chatBox.frame:SetDraggable( true )
	impulse.chatBox.frame:SetSizable( true )
	impulse.chatBox.frame:SetPos( 10, (ScrH() - impulse.chatBox.frame:GetTall()) - 200)
	impulse.chatBox.frame:SetMinWidth( 300 )
	impulse.chatBox.frame:SetMinHeight( 100 )
	impulse.chatBox.frame:SetPopupStayAtBack(true)
	impulse.chatBox.frame.Paint = function( self, w, h )
		impulse.blur( self, 10, 20, 255 )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 200 ) )
		
		draw.RoundedBox( 0, 0, 0, w, 25, Color( 80, 80, 80, 100 ) )
	end
	impulse.chatBox.oldPaint = impulse.chatBox.frame.Paint
	impulse.chatBox.frame.Think = function()
		if input.IsKeyDown( KEY_ESCAPE ) then
			impulse.chatBox.hideBox()
		end
	end
	
	impulse.chatBox.entry = vgui.Create("DTextEntry", impulse.chatBox.frame) 
	impulse.chatBox.entry:SetSize( impulse.chatBox.frame:GetWide() - 50, (impulse.IsHighRes() and 28 or 20) )
	impulse.chatBox.entry:SetTextColor( color_white )
	impulse.chatBox.entry:SetFont(impulse.IsHighRes() and "Impulse-ChatMedium" or "Impulse-ChatSmall")
	impulse.chatBox.entry:SetDrawBorder( false )
	impulse.chatBox.entry:SetDrawBackground( false )
	impulse.chatBox.entry:SetCursorColor( color_white )
	impulse.chatBox.entry:SetHighlightColor( Color(52, 152, 219) )
	impulse.chatBox.entry:SetPos( 45, impulse.chatBox.frame:GetTall() - impulse.chatBox.entry:GetTall() - 5 )
	impulse.chatBox.entry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
		derma.SkinHook( "Paint", "TextEntry", self, w, h )
	end

	impulse.chatBox.entry.OnTextChanged = function( self )
		if self and self.GetText then 
			gamemode.Call( "ChatTextChanged", self:GetText() or "" )
		end
	end

	impulse.chatBox.entry.OnKeyCodeTyped = function( self, code )
		local types = {"", "radio"}

		if code == KEY_ESCAPE then

			impulse.chatBox.hideBox()
			gui.HideGameUI()

		elseif code == KEY_TAB then
			
			impulse.chatBox.TypeSelector = (impulse.chatBox.TypeSelector and impulse.chatBox.TypeSelector + 1) or 1
			
			if impulse.chatBox.TypeSelector > 2 then impulse.chatBox.TypeSelector = 1 end
			if impulse.chatBox.TypeSelector < 1 then impulse.chatBox.TypeSelector = 2 end
			
			impulse.chatBox.ChatType = types[impulse.chatBox.TypeSelector]

			timer.Simple(0.001, function() impulse.chatBox.entry:RequestFocus() end)

		elseif code == KEY_UP then
			if self.LastMessage then
				self:SetText(self.LastMessage)
				self:SetCaretPos(self.LastMessage:len())
			end
		elseif code == KEY_ENTER then
			-- Replicate the client pressing enter
			
			if string.Trim(self:GetText()) != "" then
				if impulse.chatBox.ChatType == types[2] then
					net.Start("impulseChatMessage")
					net.WriteString("/r "..self:GetText())
					net.SendToServer()

					self.LastMessage = "/r "..self:GetText()
				else
					if not impulse.GetSetting("chat_oocenabled", true) then
						local text = string.Explode(" ", impulse.chatBox.entry:GetValue())
						text = text[1] or ""

						if text == "//" or text == "/ooc" then
							LocalPlayer():Notify("You have disabled OOC. You can re-enable it by pressing F1 > Settings > Chatbox.")
						else
							net.Start("impulseChatMessage")
							net.WriteString(self:GetText())
							net.SendToServer()

							self.LastMessage = self:GetText()
						end
					else
						net.Start("impulseChatMessage")
						net.WriteString(self:GetText())
						net.SendToServer()

						self.LastMessage = self:GetText()
					end
				end
			end

			impulse.chatBox.TypeSelector = 1
			impulse.chatBox.hideBox()
		end
	end

	impulse.chatBox.chatLog = vgui.Create("impulseRichText", impulse.chatBox.frame)
	impulse.chatBox.chatLog:SetPos(5, 30)
	impulse.chatBox.chatLog:SetSize(impulse.chatBox.frame:GetWide() - 10, impulse.chatBox.frame:GetTall() - 70)
	local strFind = string.find
	impulse.chatBox.chatLog.PaintOver = function(self, w, h)
		local entry = impulse.chatBox.entry

		if (impulse.chatBox.frame:IsActive() and IsValid(entry)) then
			local text = string.Explode(" ", entry:GetValue())
			text = text[1] or ""

			if (text:sub(1, 1) == "/") then
				local command = string.PatternSafe(string.lower(text))

				impulse.blur(self, 10, 20, 255)

				surface.SetDrawColor(0, 0, 0, 200)
				surface.DrawRect(0, 0, w, h)

				if text == "//" or text == "/ooc" then
					local limit = LocalPlayer().OOCLimit

					if not limit then
						if LocalPlayer():IsDonator() then
							LocalPlayer().OOCLimit = impulse.Config.OOCLimitVIP
						else
							LocalPlayer().OOCLimit = impulse.Config.OOCLimit
						end
					end



					draw.DrawText("(you have "..LocalPlayer().OOCLimit.." OOC messages left)", "Impulse-Elements18-Shadow", 5, h - 24)
					self:GetParent().TypingInOOC = true
				else
					self:GetParent().TypingInOOC = false
				end

				local i = 0
				local showing = 0
				local isAdmin = LocalPlayer():IsAdmin()
				local isLeadAdmin = LocalPlayer():IsLeadAdmin()
				local isSuperAdmin = LocalPlayer():IsSuperAdmin()

 				for k, v in pairs(impulse.chatCommands) do
 					if (strFind(k, command)) then
 						local c = impulse.Config.MainColour
 						
 						if v.adminOnly then
 							if isAdmin then
 								c = impulse.Config.InteractColour
 							else
 								continue 
 							end
 						end

   						if v.leadAdminOnly then
 							if isLeadAdmin or isSuperAdmin then
 								c = Color(128, 0, 128)
 							else
 								continue
 							end
 						end
 						
  						if v.superAdminOnly then
 							if isSuperAdmin then
 								c = Color(255, 0, 0, 255)
 							else
 								continue 
 							end
 						end
 
						draw.DrawText(k.." - "..v.description, "Impulse-ChatMedium", 10, 10 + i, c, TEXT_ALIGN_LEFT)
						i = i + (impulse.IsHighRes() and 22 or 15)
						showing = showing + 1

						if showing > 24 then
							break
						end
 					end
 				end
			end
		end
	end
	impulse.chatBox.chatLog.Think = function( self )
		self:SetSize( impulse.chatBox.frame:GetWide() - 10, impulse.chatBox.frame:GetTall() - impulse.chatBox.entry:GetTall() - 40 )
	end
	
	local text = "Say:"

	local say = vgui.Create("DLabel", impulse.chatBox.frame)
	say:SetText("")
	surface.SetFont( "Impulse-ChatSmall")
	local w, h = surface.GetTextSize( text )
	say:SetSize( w + 5, 20 )
	say:SetPos( 5, impulse.chatBox.frame:GetTall() - impulse.chatBox.entry:GetTall() - 5 )
	
	say.Paint = function( self, w, h )
		draw.DrawText( text, "Impulse-ChatSmall", 2, 1, color_white )
	end

	say.Think = function( self )
		local types = {"", "radio", "console"}
		local s = {}

		if impulse.chatBox.ChatType == types[2] then 
			text = "Radio:"	
		else
			text = "Say:"
			s.pw = 45
			s.sw = impulse.chatBox.frame:GetWide() - 50
		end

		if s then
			if not s.pw then s.pw = self:GetWide() + 10 end
			if not s.sw then s.sw = impulse.chatBox.frame:GetWide() - self:GetWide() - 15 end
		end

		local w, h = surface.GetTextSize( text )
		self:SetSize( w + 5, 20 )
		self:SetPos( 5, impulse.chatBox.frame:GetTall() - impulse.chatBox.entry:GetTall() - 5 )

		impulse.chatBox.entry:SetSize( s.sw, 20 )
		impulse.chatBox.entry:SetPos( s.pw, impulse.chatBox.frame:GetTall() - impulse.chatBox.entry:GetTall() - 5 )
	end	
	
	impulse.chatBox.hideBox()
end

--// Hides the chat box but not the messages
function impulse.chatBox.hideBox()
	impulse.chatBox.frame.Paint = function() end
	impulse.chatBox.chatLog:SetScrollBarVisible(false)
	impulse.chatBox.chatLog.active = false

	if impulse.chatBox.chatLog.lastChildMessage then
		impulse.chatBox.chatLog:ScrollToChild(impulse.chatBox.chatLog.lastChildMessage)
	end
	
	--impulse.chatBox.chatLog:GotoTextEnd()
	
	impulse.chatBox.lastMessage = impulse.chatBox.lastMessage or CurTime() - impulse.GetSetting("chat_fadetime")
	
	-- Hide the chatbox except the log
	local children = impulse.chatBox.frame:GetChildren()
	for _, pnl in pairs( children ) do
		if pnl == impulse.chatBox.frame.btnMaxim or pnl == impulse.chatBox.frame.btnClose or pnl == impulse.chatBox.frame.btnMinim then continue end
		
		if pnl != impulse.chatBox.chatLog then
			pnl:SetVisible( false )
		end
	end
	
	-- Give the player control again
	impulse.chatBox.frame:SetMouseInputEnabled( false )
	impulse.chatBox.frame:SetKeyboardInputEnabled( false )
	gui.EnableScreenClicker( false )

	-- We are done chatting
	hook.Run("FinishChat")
	
	-- Clear the text entry
	impulse.chatBox.entry:SetText( "" )
	hook.Run( "ChatTextChanged", "" )
end

--// Shows the chat box
function impulse.chatBox.showBox()
	-- Draw the chat box again
	impulse.chatBox.frame.Paint = impulse.chatBox.oldPaint

	impulse.chatBox.chatLog:SetScrollBarVisible(true)
	impulse.chatBox.chatLog.active = true
	
	impulse.chatBox.lastMessage = nil
	
	-- Show any hidden children
	local children = impulse.chatBox.frame:GetChildren()
	for _, pnl in pairs( children ) do
		if pnl == impulse.chatBox.frame.btnMaxim or pnl == impulse.chatBox.frame.btnClose or pnl == impulse.chatBox.frame.btnMinim then continue end
		
		pnl:SetVisible( true )
	end
	
	-- MakePopup calls the input functions so we don't need to call those
	impulse.chatBox.frame:MakePopup()
	impulse.chatBox.entry:RequestFocus()

	-- Make sure other addons know we are chatting
	hook.Run("StartChat")
end

chat.oldAddText = chat.oldAddText or chat.AddText

--// Overwrite chat.AddText to detour it into my chatbox
function chat.AddText(...)
	if not impulse.chatBox.chatLog then
		impulse.chatBox.buildBox()
	end

	if impulse.chatBox.chatLog.active and not impulse.chatBox.entry:IsEditing() then
		impulse.chatBox.chatLog.BlockScroll = true
	end
	
	impulse.chatBox.chatLog:AddText(...)
	--chat.oldAddText(...)

	if impulse.hudEnabled then
		chat.PlaySound()
	end
end

--// Stops the default chat box from being opened
hook.Remove("PlayerBindPress", "impulse.chatBox_hijackbind")
hook.Add("PlayerBindPress", "impulse.chatBox_hijackbind", function(ply, bind, pressed)
	if string.sub( bind, 1, 11 ) == "messagemode" then
		if ply:InVehicle() then -- piano compatablity kill me
			local p1 = ply:GetVehicle():GetParent()

			if p1 and IsValid(p1) then
				local p2 = p1:GetParent()

				if p2 and IsValid(p2) and p2:GetClass() == "gmt_instrument_piano" then
					return true
				end	
			end
		end

		if bind == "messagemode2" then 
			impulse.chatBox.ChatType = "radio"
		else
			impulse.chatBox.ChatType = ""
		end
		
		if IsValid( impulse.chatBox.frame ) then
			impulse.chatBox.showBox()
		else
			impulse.chatBox.buildBox()
			impulse.chatBox.showBox()
		end
		return true
	end
end)

--// Hide the default chat too in case that pops up
hook.Remove("HUDShouldDraw", "impulse.chatBox_hidedefault")
hook.Add("HUDShouldDraw", "impulse.chatBox_hidedefault", function( name )
	if name == "CHudChat" then
		return false
	end
end)

 --// Modify the Chatbox for align.
local oldGetChatBoxPos = chat.GetChatBoxPos
function chat.GetChatBoxPos()
	return impulse.chatBox.frame:GetPos()
end

function chat.GetChatBoxSize()
	return impulse.chatBox.frame:GetSize()
end

chat.Open = impulse.chatBox.showBox
function chat.Close(...)
	if IsValid( impulse.chatBox.frame ) then 
		impulse.chatBox.hideBox(...)
	else
		impulse.chatBox.buildBox()
		impulse.chatBox.showBox()
	end
end
