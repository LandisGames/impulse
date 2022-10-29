local PANEL = {}

function PANEL:Init()
	self:SetSize(200, 150)
	self:Center()
	self:SetTitle("ATM")
	self:MakePopup()

	local bankBalance = LocalPlayer():GetSyncVar(SYNC_BANKMONEY, 0)
	local prefix = impulse.Config.CurrencyPrefix
	local parent = self

	self.balance = vgui.Create("DLabel", self)
	self.balance:SetText("Balance: "..prefix..bankBalance)
	self.balance:SetFont("Impulse-Elements18")
	self.balance:SizeToContents()
	self.balance:SetPos(100 - (self.balance:GetWide()/2), 30)

	self.withdrawInput = vgui.Create("DTextEntry", self)
	self.withdrawInput:SetPos(10, 70)
	self.withdrawInput:SetSize(120, 20)
	self.withdrawInput:SetNumeric(true)

	self.withdrawButton = vgui.Create("DButton", self)
	self.withdrawButton:SetText("Withdraw")
	self.withdrawButton:SetPos(135, 70)
	self.withdrawButton:SetSize(55, 20)
	function self.withdrawButton:DoClick()
		if parent.withdrawInput:GetValue() == "" then return true end
		local num = tonumber(parent.withdrawInput:GetValue())

		if not num then
			return
		end

		net.Start("impulseATMWithdraw")
		net.WriteUInt(math.floor(num), 32)
		net.SendToServer()
	end

	self.depositInput = vgui.Create("DTextEntry", self)
	self.depositInput:SetPos(10, 100)
	self.depositInput:SetSize(120, 20)
	self.depositInput:SetNumeric(true)

	self.despoitButton = vgui.Create("DButton", self)
	self.despoitButton:SetText("Deposit")
	self.despoitButton:SetPos(135, 100)
	self.despoitButton:SetSize(55, 20)
	function self.despoitButton:DoClick()
		if parent.depositInput:GetValue() == "" then return true end
		local num = tonumber(parent.depositInput:GetValue())

		if not num then
			return
		end

		net.Start("impulseATMDeposit")
		net.WriteUInt(math.floor(num), 32)
		net.SendToServer()
	end
end

function PANEL:SetBalance(m)
	self.balance:SetText("Balance: "..impulse.Config.CurrencyPrefix..m)
	self.balance:SizeToContents()
	self.balance:SetPos(100 - (self.balance:GetWide()/2), 30)
end

function PANEL:Think()
	local curMoney = LocalPlayer():GetSyncVar(SYNC_BANKMONEY, 0)
	self.lastMoney = self.lastMoney or curMoney

	if self.lastMoney != curMoney then
		self:SetBalance(curMoney)
	end
end


vgui.Register("impulseATMMenu", PANEL, "DFrame")