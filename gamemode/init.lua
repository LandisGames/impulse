resource.AddWorkshop("1651398810") -- framework content

DeriveGamemode("sandbox")

MsgC(Color(83, 143, 239), '[impulse] Starting boot sequence...')

print('\n\n\nCopyright (c) 2021 2i games (www.2i.games)')
print('No permission is granted to USE, REPRODUCE, EDIT or SELL this software.\n\n\n')

MsgC( Color( 83, 143, 239 ), "[impulse] Starting server load...\n" )
impulse = impulse or {} -- defining global function table

impulse.meta = FindMetaTable("Player")
impulse.lib = {}

-- load the framework bootstrapper

AddCSLuaFile("shared.lua")
include("shared.lua")

MsgC( Color( 0, 255, 0 ), "[impulse] Completed server load...\n" )

-- security overrides, people should have these set anyway, but this is just in case
RunConsoleCommand("sv_allowupload", "0")
RunConsoleCommand("sv_allowdownload", "0")
RunConsoleCommand("sv_allowcslua", "0")

if engine.ActiveGamemode() == "impulse" then
	local gs = ""
	for v,k in pairs(engine.GetGamemodes()) do
		if k.name:find("impulse") and k.name != "impulse" then
			gs = gs..k.name.."\n"
		end
	end

    SetGlobalString("impulse_fatalerror", "No schema loaded. Please place the schema in your gamemodes folder, then set it as your gamemode.\n\nInstalled available schemas:\n"..gs)
end