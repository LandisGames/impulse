impulse.DefineSetting("admin_onduty", {name="Moderator on duty (DO NOT LEAVE UNTICKED FOR A LONG TIME)", category="ops", type="tickbox", default=true})
impulse.DefineSetting("admin_reportalpha", {name="Report menu fade alpha", category="ops", type="slider", default=130, minValue=0, maxValue=255})
impulse.DefineSetting("admin_esp", {name="Observer ESP enabled", category="ops", type="tickbox", default=false})
impulse.DefineSetting("admin_showgroup", {name="Show player groups", category="ops", type="tickbox", default=true})
impulse.DefineSetting("admin_lightcol", {name="Observer light colour", category="ops", type="dropdown", options={"White", "Blue", "Blue Soft", "Amber", "Amber Soft"}, default="White"})

hook.Add("CreateMenuMessages", "opsOffDutyWarn", function()
	if not LocalPlayer():IsAdmin() then
		return
	end

	if impulse.GetSetting("admin_onduty", true) == false then
		impulse.MenuMessage.Add("offduty", "Game Moderator Off Duty Notice", "You are currently off-duty. This is a reminder to ensure you return to duty as soon as possible.\nTo return to duty, goto settings, ops and tick the on duty box.", Color(238, 210, 2))
	else
		impulse.MenuMessage.Remove("offduty")
	end
end)