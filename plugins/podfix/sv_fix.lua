-- gs_podfix in plugin format. By code_gs. https://github.com/Kefta/gs_podfix

hook.Add("OnEntityCreated", "GS_PodFix", function(pEntity)
	if (pEntity:GetClass() == "prop_vehicle_prisoner_pod") then
		pEntity:AddEFlags(EFL_NO_THINK_FUNCTION)
	end
end)

hook.Add("PlayerEnteredVehicle", "GS_PodFix", function(_, pVehicle)
	if (pVehicle:GetClass() == "prop_vehicle_prisoner_pod") then
		pVehicle:RemoveEFlags(EFL_NO_THINK_FUNCTION)
	end
end)

hook.Add("PlayerLeaveVehicle", "GS_PodFix", function(_, pVehicle)
	if (pVehicle:GetClass() == "prop_vehicle_prisoner_pod") then
		local sName = "GS_PodFix_" .. pVehicle:EntIndex()

		hook.Add("Think", sName, function()
			if (pVehicle:IsValid()) then
				local tSave = pVehicle:GetSaveTable()
				
				-- If set manually
				if (tSave.m_bEnterAnimOn) then
					hook.Remove("Think", sName)
				elseif (not tSave.m_bExitAnimOn) then
					pVehicle:AddEFlags(EFL_NO_THINK_FUNCTION)

					hook.Remove("Think", sName)
				end
			else
				hook.Remove("Think", sName)
			end
		end)
	end
end)