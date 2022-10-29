properties.Add( "ops_copysteamid", {
	MenuLabel = "[ops] Copy player SteamID", -- Name to display on the context menu
	Order = 1005, -- The order to display this property relative to other properties
	MenuIcon = "icon16/shield.png", -- The icon to display next to the property

	Filter = function( self, ent, ply ) -- A function that determines whether an entity is valid for this property
		if not ply:IsAdmin() then
			return false
		end

		if not ent:IsPlayer() then
			return false
		end

		return true
	end,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
		SetClipboardText(ent:SteamID())
		LocalPlayer():Notify("Copied "..ent:Nick().."'s SteamID to clipboard.")
	end
} )

properties.Add( "ops_openplayercard", {
	MenuLabel = "[ops] Open player card", -- Name to display on the context menu
	Order = 1006, -- The order to display this property relative to other properties
	MenuIcon = "icon16/shield.png", -- The icon to display next to the property

	Filter = function( self, ent, ply ) -- A function that determines whether an entity is valid for this property
		if not ply:IsAdmin() then
			return false
		end

		if not ent:IsPlayer() then
			return false
		end

		return true
	end,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
		local badges = {}

		for v,k in pairs(impulse.Badges) do
			if k[3](ent) then
				badges[v] = k
			end 	
		end

		impulse_infoCard = vgui.Create("impulsePlayerInfoCard")
		impulse_infoCard:SetPlayer(ent, badges)
	end
} )

properties.Add( "ops_openplayercardprop", {
	MenuLabel = "[ops] Open owner player card", -- Name to display on the context menu
	Order = 5000, -- The order to display this property relative to other properties
	MenuIcon = "icon16/shield.png", -- The icon to display next to the property

	Filter = function( self, ent, ply ) -- A function that determines whether an entity is valid for this property
		if not ply:IsAdmin() then
			return false
		end

		if not ent.CPPIGetOwner or not IsValid(ent:CPPIGetOwner()) or not ent:CPPIGetOwner():IsPlayer() then
			return false
		end

		return true
	end,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
		local ent = ent:CPPIGetOwner()

		local badges = {}

		for v,k in pairs(impulse.Badges) do
			if k[3](ent) then
				badges[v] = k
			end 	
		end

		impulse_infoCard = vgui.Create("impulsePlayerInfoCard")
		impulse_infoCard:SetPlayer(ent, badges)
	end
} )