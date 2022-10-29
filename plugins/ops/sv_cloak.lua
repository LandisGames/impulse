impulse.Ops = impulse.Ops or {}

function impulse.Ops.Cloak(ply)
	ply:SetNoDraw(true)
	ply.isCloaked = true

	for v,k in ipairs(ply:GetWeapons()) do
		k:SetNoDraw(true)
	end

	for v,k in ipairs(ents.FindByClass("physgun_beam")) do
		if k:GetParent() == ply then
			k:SetNoDraw(true)
		end
	end

	hook.Add("Think", "opsCloak", cloakThink)
end

function impulse.Ops.Uncloak(ply)
	ply:SetNoDraw(false)
	ply.isCloaked = nil

	for v,k in pairs(ply:GetWeapons()) do
		k:SetNoDraw(false)
	end

	for v,k in pairs(ents.FindByClass("physgun_beam")) do
		if k:GetParent() == ply then
			k:SetNoDraw(false)
		end
	end

	ply.cloakWeapon = nil

	local shouldRemoveThink = true

	for v,k in ipairs(player.GetAll()) do
		if k.isCloaked then
			shouldRemoveThink = false
			break
		end
	end

	if shouldRemoveThink then
		hook.Remove("Think", "opsCloak")
	end
end

local nextCloakThink = 0

function cloakThink()
	if nextCloakThink > CurTime() then return end -- put a limiter on this because it can go very fast

	for v,k in ipairs(player.GetAll()) do
		if k.isCloaked then
			local activeWeapon = k:GetActiveWeapon()

			if activeWeapon:IsValid() and activeWeapon != k.cloakWeapon then
				k.cloakWeapon = activeWeapon
				activeWeapon:SetNoDraw(true)

				if activeWeapon:GetClass() == "weapon_physgun" then
					for x,y in ipairs(ents.FindByClass("physgun_beam")) do
						if y:GetParent() == k then
							y:SetNoDraw(true)
						end
					end
				end
			end
		end
	end

	nextCloakThink = CurTime() + 0.1
end