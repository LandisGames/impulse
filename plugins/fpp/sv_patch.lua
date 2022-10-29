
if FPP then
    local function runIfAccess(priv, f)
        return function(ply, cmd, args)
            CAMI.PlayerHasAccess(ply, priv, function(allowed, _)
                if allowed then return f(ply, cmd, args) end

                FPP.Notify(ply, string.format("You need the '%s' privilege in order to be able to use this command", priv), false)
            end)
        end
    end
    
    local function CleanupDisconnected(ply, cmd, args)
        if not args[1] then FPP.Notify(ply, "Invalid argument", false) return end
        if args[1] == "disconnected" then
            for _, v in ipairs(ents.GetAll()) do
                local Owner = v:CPPIGetOwner()
                if Owner and not IsValid(Owner) then
                    v:Remove()
                end
            end
            FPP.NotifyAll(((ply.Nick and ply:Nick()) or "Console") .. " removed all disconnected players' props", true)
            return
        elseif not tonumber(args[1]) or not IsValid(Player(tonumber(args[1]))) then
            FPP.Notify(ply, "Invalid player", false)
            return
        end
    end
    concommand.Add("FPP_Cleanup", runIfAccess("FPP_Cleanup", CleanupDisconnected))

    local function nothin()
        return false
    end
    concommand.Add("FPP_FallbackOwner", nothin) -- turn this off cause it causes a lot of issues
end