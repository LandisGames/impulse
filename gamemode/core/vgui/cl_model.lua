-- replacement for spawnicon that performs a live model render, this is from NUTSCRIPT https://github.com/Chessnut/NutScript/blob/f7479a2d9cc893240093252bd89ca5813c59ea71/gamemode/core/derma/cl_spawnicon.lua

local PANEL = {}

local otaModels = {
	["models/combine_soldier.mdl"] = true,
	["models/combine_soldier_prisonguard.mdl"] = true,
	["models/combine_super_soldier.mdl"] = true
}
function PANEL:Init()
	self.OldSetModel = self.SetModel
	self.SetModel = function(self, model, skin, hidden)
		self:OldSetModel(model)

		local entity = self.Entity

		if (skin) then
			entity:SetSkin(skin)
		end

		local sequence = entity:SelectWeightedSequence(ACT_IDLE)

		if otaModels[model] or (sequence <= 0) then
			sequence = entity:LookupSequence("idle_unarmed")
		end

		if (sequence > 0) then
			entity:ResetSequence(sequence)
		else
			local found = false

			for k, v in ipairs(entity:GetSequenceList()) do
				if ((v:lower():find("idle") or v:lower():find("fly")) and v != "idlenoise") then
					entity:ResetSequence(v)
					found = true

					break
				end
			end

			if (!found) then
				entity:ResetSequence(4)
			end
		end

		entity:SetIK(false)
	end
end

function PANEL:LayoutEntity()
	self:RunAnimation()
end

vgui.Register("impulseModelPanel", PANEL, "DModelPanel")