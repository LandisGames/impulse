if CLIENT then
    net.Receive("impulseOpsItemSpawner", function()
        local panel = vgui.Create("DFrame")
        panel:SetSize(600, 500)
        panel:Center()
        panel:SetTitle("Item Spawner")
        panel:MakePopup()

        local lbl = vgui.Create("DLabel", panel)
        lbl:SetPos(5, 32)
        lbl:SetText("Target: ")
        lbl:SizeToContents()

        local targetBox = vgui.Create("DComboBox", panel)
        targetBox:SetPos(50, 30)
        targetBox:SetWide(400)

        targetBox:AddChoice("Me")
        targetBox:AddChoice("Custom SteamID (Offline User)")

        for v,k in pairs(player.GetAll()) do
            targetBox:AddChoice("PLAYER: "..k:Nick().." ("..k:SteamName()..")", k:SteamID())
        end

        targetBox:SetSortItems(false)

        function targetBox:OnSelect(index, text, sid)
            if text == "Me" then
                panel.Selected = LocalPlayer():SteamID()
            elseif text == "Custom SteamID (Offline User)" then
                Derma_StringRequest("impulse", "Enter the SteamID (not 64 format) below:", "", function(sid)
                    if IsValid(panel) then
                        sid = string.Trim(sid, " ")
                        panel.Selected = sid
                        self:SetText("Custom SteamID ("..sid..")")
                    end
                end)
            else
                panel.Selected = sid
            end
        end

        local scroll = vgui.Create("DScrollPanel", panel)
        scroll:SetPos(5, 60)
        scroll:SetSize(595, 440)

        local cats = {}

        for v,k in pairs(impulse.Inventory.Items) do
            if not cats[k.Category or "Unknown"] then 
                local cat = scroll:Add("DCollapsibleCategory")
                cat:Dock(TOP)
                cat:SetLabel(k.Category or "Unknown")
                
                cats[k.Category or "Unknown"] = vgui.Create("DPanelList", panel)
                local list =  cats[k.Category or "Unknown"]
                list:Dock(FILL)
                list:SetSpacing(5)
                cat:SetContents(list)
            end

            local btn = vgui.Create("DButton")
            btn:SetText("Give "..k.Name.." ("..k.UniqueID..")")
            btn:Dock(TOP)
            btn:DockMargin(0, 0, 0, 5)
            btn.ItemClass = k.UniqueID

            function btn:DoClick()
                if not panel.Selected then
                    return LocalPlayer():Notify("No target selected.")
                end

                LocalPlayer():ConCommand("say /giveitem "..panel.Selected.." "..self.ItemClass)
            end

            cats[k.Category or "Unknown"]:AddItem(btn)
        end
    end)
else
    util.AddNetworkString("impulseOpsItemSpawner")
end


local giveItemCommand = {
    description = "Gives a player the specified item. Use /itemspawner instead.",
    requiresArg = true,
    superAdminOnly = true,
    onRun = function(ply, arg, rawText)
        if not ply:IsSuperAdmin() then
            return
        end

        local steamid = arg[1]
        local item = arg[2]

        if not item then
            return ply:Notify("No item uniqueID supplied.")
        end

        if steamid:len() > 25 then
            return ply:Notify("SteamID too long.")
        end

        local query = mysql:Select("impulse_players")
        query:Select("id")
        query:Where("steamid", steamid)
        query:Callback(function(result)
            if not IsValid(ply) then
                return
            end

            if not type(result) == "table" or #result == 0 then
                return ply:Notify("This Steam account has not joined the server yet or the SteamID is invalid.")
            end

            if not impulse.Inventory.ItemsRef[item] then
                return ply:Notify("Item: "..item.." does not exist.")
            end

            local target = player.GetBySteamID(steamid)

            if target and IsValid(target) then
                target:GiveInventoryItem(item)
                return ply:Notify("You have given "..target:Nick().." a "..item..".")
            end

            local impulseID = result[1].id

            impulse.Inventory.DBAddItem(impulseID, item)
            ply:Notify("Offline player ("..steamid..") has been given a "..item..".")
        end)

        query:Execute()
    end
}

impulse.RegisterChatCommand("/giveitem", giveItemCommand)

local itemSpawnerCommand = {
    description = "Opens the item spawner.",
    superAdminOnly = true,
    onRun = function(ply, arg, rawText)
        if not ply:IsSuperAdmin() then
            return
        end

        net.Start("impulseOpsItemSpawner")
        net.Send(ply)
    end
}

impulse.RegisterChatCommand("/itemspawner", itemSpawnerCommand)