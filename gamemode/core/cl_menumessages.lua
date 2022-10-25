--- Allows for the creation of persistent menu messages similar in style to CS:GO's menu notifications
-- @module MenuMessage

file.CreateDir("impulse/menumsgs")

impulse.MenuMessage = impulse.MenuMessage or {}
impulse.MenuMessage.Data = impulse.MenuMessage.Data or {}

--- Creates a new MenuMessage and displays it
-- @realm client
-- @string uid Unique name
-- @string title Message title
-- @string message Message content
-- @color[opt] col The message colour
-- @string[opt] url The URL to open if pressed
-- @string[opt] urlText The text of the URL button
-- @int[opt] expiry UNIX time until when this message will automatically expire
function impulse.MenuMessage.Add(uid, title, xmessage, xcol, url, urlText, expiry)
	if impulse.MenuMessage.Data[uid] then
		return
	end

	impulse.MenuMessage.Data[uid] = {
		type = uid,
		title = title,
		message = xmessage,
		colour = xcol or impulse.Config.MainColour,
		url = url or nil,
		urlText = urlText or nil,
		expiry = expiry or nil
	}
end

--- Removes an active MenuMessage
-- @realm client
-- @string uid Unique name
function impulse.MenuMessage.Remove(uid)
	local msg = impulse.MenuMessage.Data[uid]
	if not msg then
		return
	end

	impulse.MenuMessage.Data[uid] = nil

	local fname = "impulse/menumsgs/"..uid..".dat"

	if file.Exists(fname, "DATA") then
		file.Delete(fname)
	end
end

--- Saves the specified MenuMessage to file so it persists
-- @realm client
-- @string uid Unique name
function impulse.MenuMessage.Save(uid)
	local msg = impulse.MenuMessage.Data[uid]
	if not msg then
		return
	end

	local compiled = util.TableToJSON(msg)

	file.Write("impulse/menumsgs/"..uid..".dat", compiled)
end

--- Returns if a MenuMessage can be seen
-- @realm client
-- @string uid Unique name
-- @internal
function impulse.MenuMessage.CanSee(uid)
	local msg = impulse.MenuMessage.Data[uid]

	if not msg then
		return
	end

	if not msg.scheduled then
		return true
	end

	if msg.scheduledTime and msg.scheduledTime != 0 then
		if os.time() > msg.scheduledTime then
			return true
		end
	end

	return false
end