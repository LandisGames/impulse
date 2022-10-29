local PANEL = {}

local newReportCol = Color(173, 255, 47)
local claimedReportCol = Color(147, 112, 219)

function PANEL:Init()
	self:SetSize(605, 470)
	self:Center()
	self:SetTitle("")
	self:MakePopup()
	self:SetBackgroundBlur(true)

	local sad = vgui.Create("DImage", self)
	sad:SetPos(15, 35)
	sad:SetSize(110, 110)
	sad:SetImage("impulse/icons/sad.png")

	local title = vgui.Create("DLabel", self)
	title:SetPos(140, 35)
	title:SetFont("Impulse-Elements27-Shadow")
	title:SetText("Security Check Required")
	title:SizeToContents()

	local sec1 = "You have been automatically or manually marked as a possible threat to the security and stability of our services.\n\n"
	local sec2 = "As a result you will not be able to continue playing this server until the security check has been completed. Please note, this is not a ban, security checks are not always accurate and once the check is succsefully completed the incident will not be on record.\n\n"
	local sec3 = "To complete the security check please goto our support page, login with this Steam account and select the 'Security Check' category for your ticket. Please note it normally takes 24 hours to complete a security check. Click the link below to begin."
	local link = impulse.Config.SupportURL

	local desc = vgui.Create("DLabel", self)
	desc:SetPos(140, 70)
	desc:SetSize(370, 500)
	desc:SetFont("Impulse-Elements19-Shadow")
	desc:SetContentAlignment(7)
	desc:SetWrap(true)
	desc:SetText(sec1..sec2..sec3)

	local linkBtn = vgui.Create("DLabel", self)
	linkBtn:SetPos(140, 420)
	linkBtn:SetFont("Impulse-Elements19-Shadow")
	linkBtn:SetText("www.support.impulse-community.com")
	linkBtn:SetTextColor(Color(51, 102, 187))
	linkBtn:SizeToContents()
	linkBtn:SetMouseInputEnabled(true)
	linkBtn:SetCursor("hand")

	function linkBtn:DoClick()
		gui.OpenURL(link)
	end
end

vgui.Register("impulseSecurityCheck", PANEL, "DFrame")