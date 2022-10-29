if SERVER then
	util.AddNetworkString("impulseOpsViewInv")
	util.AddNetworkString("impulseOpsRemoveInv")

	net.Receive("impulseOpsRemoveInv", function(len, ply)
		if not ply:IsAdmin() then return end

		local targ = net.ReadUInt(8)
		local invSize = net.ReadUInt(16)

		targ = Entity(targ)
		if not IsValid(targ) then return end

		for i=1,invSize do
			local itemid = net.ReadUInt(16)
			local hasItem = targ:HasInventoryItemSpecific(itemid)

			if hasItem then
				targ:TakeInventoryItem(itemid)
			end
		end

		ply:Notify("Removed "..invSize.." items from "..targ:Nick().."'s inventory.")
	end)
else
	net.Receive("impulseOpsViewInv", function()
		local searchee = Entity(net.ReadUInt(8))
		local invSize = net.ReadUInt(16)
		local invCompiled = {}

		if not IsValid(searchee) then return end

		for i=1,invSize do
			local itemnetid = net.ReadUInt(10)
			local itemrestricted = net.ReadBool()
			local itemequipped = net.ReadBool()
			local itemid = net.ReadUInt(16)
			local item = impulse.Inventory.Items[itemnetid]
			
			table.insert(invCompiled, {item, itemrestricted, itemequipped, itemid})
		end

		local searchMenu = vgui.Create("impulseSearchMenuAdmin")
		searchMenu:SetInv(invCompiled)
		searchMenu:SetPlayer(searchee)
	end)
end

local viewInvCommand = {
    description = "Allows you to view and delete items from the player specified.",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local name = arg[1]
		local plyTarget = impulse.FindPlayer(name)

		if plyTarget then
			if not plyTarget.beenInvSetup then return ply:Notify("Target is loading still...") end

			local inv = plyTarget:GetInventory(1)
			net.Start("impulseOpsViewInv")
			net.WriteUInt(plyTarget:EntIndex(), 8)
			net.WriteUInt(table.Count(inv), 16)

			for v,k in pairs(inv) do
				local netid = impulse.Inventory.ClassToNetID(k.class)
				net.WriteUInt(netid, 10)
				net.WriteBool(k.restricted or false)
				net.WriteBool(k.equipped or false)
				net.WriteUInt(v, 16)
			end

			net.Send(ply)
		else
			return ply:Notify("Could not find player: "..tostring(name))
		end
    end
}

impulse.RegisterChatCommand("/viewinv", viewInvCommand)

local restoreInvCommand = {
    description = "Restores a players inventory to the last state before death. (SteamID only)",
    requiresArg = true,
    adminOnly = true,
    onRun = function(ply, arg, rawText)
        local name = arg[1]
		local plyTarget = player.GetBySteamID(name)

		if plyTarget then
			if plyTarget.InventoryRestorePoint then
				plyTarget:ClearInventory(1)

				for v,k in pairs(plyTarget.InventoryRestorePoint) do
					plyTarget:GiveInventoryItem(k)
				end

				plyTarget.InventoryRestorePoint = nil

				plyTarget:Notify("Your inventory has been restored to its last state by a game moderator.")
				ply:Notify("You have restored "..plyTarget:Nick().."'s inventory to the last state.")

                for v,k in pairs(player.GetAll()) do
                    if k:IsLeadAdmin() then
                        k:AddChatText(Color(135, 206, 235), "[ops] Moderator "..ply:SteamName().." restored "..plyTarget:SteamName().."'s inventory.")
                    end
                end
			else
				return ply:Notify("No restore point found for this player.")
			end
		else
			return ply:Notify("Could not find player: "..tostring(name).." (needs SteamID value)")
		end
    end
}

impulse.RegisterChatCommand("/restoreinv", restoreInvCommand)