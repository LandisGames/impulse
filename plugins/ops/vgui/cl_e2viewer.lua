local PANEL = {}

function PANEL:Init()
	self:SetSize(605, 470)
	self:Center()
	self:SetTitle("ops E2 Viewer")
	self:MakePopup()
end

function PANEL:SetupE2S(e2s)
	self.list = vgui.Create("DListView", self)
	self.list:Dock(FILL)
	self.list:SetMultiSelect(false)
	self.list:AddColumn("Owner")
	self.list:AddColumn("Name")
	self.list:AddColumn("CPU Time")

	self.list.lines = {}

	local panel = self

	for v,k in pairs(e2s) do
    	local owner = k.ent:CPPIGetOwner()

    	if not owner then
    		return
    	end

    	local cpuTime = k.perf * 1000000
    	if cpuTime < 0.01 then
    		cpuTime = 0
    	end

    	local x = self.list:AddLine(owner:Nick().." ("..owner:SteamName()..")", k.name, cpuTime)
    	x.Owner = owner:SteamID()
    	x.Ent = k.ent

    	table.insert(self.list.lines, x)

		function x:OnSelect()
			local row = x
			local m = DermaMenu()

			m:AddOption("Copy Owner SteamID", function()
				if not IsValid(row) then
					return
				end

				SetClipboardText(row.Owner)
				LocalPlayer():Notify("Copied SteamID.")
			end)

			m:AddOption("Remove E2", function()
				if not IsValid(row) then
					return
				end

				net.Start("opsE2ViewerRemove")
				net.WriteEntity(row.Ent)
				net.SendToServer()

				panel:Remove()
			end):SetIcon("icon16/delete.png")

			m:Open()
		end
	end

	function self.list:Think()
		for v,k in pairs(self.lines) do
			if not IsValid(k) or not IsValid(k.Ent) then
				return
			end

	    	local data = k.Ent:GetOverlayData()
	    	if not data then
	    		return
	    	end

	    	local cpuTime = data.timebench * 1000000
	    	if cpuTime < 0.01 then
	    		cpuTime = 0
	    	end

			k:SetColumnText(3, cpuTime)
		end
	end
end

vgui.Register("impulseE2Viewer", PANEL, "DFrame")