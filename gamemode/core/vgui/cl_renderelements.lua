impulse.render = impulse.render or {}

local impulseLogo = Material("impulse/impulse-logo-white.png")
local fromCol = Color(255, 45, 85, 255)
local toCol = Color(90, 200, 250, 255)
local fromColHalloween = Color(252, 70, 5) 
local toColHalloween = Color(148, 1, 148)
local fromColXmas = Color(223, 17, 3)
local toColXmas = Color(240, 240, 236)

local dateCustom = {
	["12-25"] = {fromColXmas, toColXmas}, -- dec 25th
	["10-31"] = {fromColHalloween, toColHalloween} -- oct 31st
}

local function Glow(c, t, m)
    return Color(c.r + ((t.r - c.r) * (m)), c.g + ((t.g - c.g) * (m)), c.b + ((t.b - c.b) * (m)))
end

local date = os.date("%m-%d")
function impulse.render.glowgo(x,y,w,h)
	local from, to = hook.Run("GetFrameworkLogoColour")
	local col = Glow(from or fromCol, to or toCol, math.abs(math.sin((RealTime() - 0.08) * .2)))

	surface.SetMaterial(impulseLogo)
	surface.SetDrawColor(col)
	surface.DrawTexturedRect(x,y,w,h)
end