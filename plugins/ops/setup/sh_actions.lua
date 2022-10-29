impulse.Ops = impulse.Ops or {}
impulse.Ops.QuickTools = impulse.Ops.QuickTools or {}

function impulse.Ops.RegisterAction(command, cmdData, qtName, qtIcon, qtDo)
	impulse.RegisterChatCommand(command, cmdData)

	if qtName and qtDo then
		impulse.Ops.QuickTools[qtName] = {name = qtName, icon = qtIcon, onRun = qtDo}
	end
end

if CLIENT then
	-- load up windows toast notifications for reports if staff have it
	if file.Exists("garrysmod/lua/bin/gmcl_win_toast_win32.dll", "BASE_PATH") or file.Exists("garrysmod/lua/bin/gmcl_win_toast_win64.dll", "BASE_PATH") then
		require("win_toast")
	end
end