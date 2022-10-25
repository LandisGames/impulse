local blur = Material("pp/blurscreen")
local surface = surface
local draw = draw
local Color = Color
local DARK_50, DARK_25, DARK_100, WHITE = Color(0,0,0,45), Color(0,0,0,35), Color(0, 0, 0, 80) Color(255,255,255,255)
local HIGHLIGHT = Color(14, 141, 201)


SKIN = {}

SKIN.PrintName 		= "impulse"
SKIN.Author 		= "vin"
SKIN.DermaVersion	= 1
SKIN.fontFrame = "Impulse-UI-SmallFont"
SKIN.fontTab = "Impulse-UI-SmallFont"
SKIN.fontButton = "Impulse-UI-SmallFont"
SKIN.Colours = table.Copy(derma.SkinList.Default.Colours)
SKIN.Colours.Window.TitleActive = Color(255, 255, 255)
SKIN.Colours.Window.TitleInactive = Color(255, 255, 255)

SKIN.Colours.Button.Normal = Color(255, 255, 255)
SKIN.Colours.Button.Hover = Color(255, 255, 255)
SKIN.Colours.Button.Down = Color(180, 180, 180)
SKIN.Colours.Button.Disabled = Color(0, 0, 0, 100)

SKIN.Colours.Label.Highlight = Color(90, 200, 250, 255)

function SKIN:GetTable(panel)
    panel.__derma__ = panel.__derma__ or {}
    return panel.__derma__
end

local topCol = Color(30, 30, 30, 200)
local bodyCol = Color(80, 80, 80, 100)
local bodyColOp = Color(80, 80, 80, 200)
function SKIN:PaintFrame(panel, w, h)
    impulse.blur(panel, 10, 20, 255)
	draw.RoundedBox(0, 0, 0, w, h, topCol) -- this is the body of the frame
    draw.RoundedBox(0, 0, 0, w, 25, bodyCol) -- this is the "top bar" of the derma frame
end

function SKIN:PaintMenuBar(panel, w, h)
	draw.RoundedBox(0, 0, 0, w, h, bodyColOp)
end

local btnCol = Color(80, 80, 80, 255)
function SKIN:PaintButton(panel) -- button skin from ns edited
	if (panel:GetPaintBackground()) then
		local w, h = panel:GetWide(), panel:GetTall()
		local alpha = 200

    	if (panel:GetDisabled()) then
			alpha = 10
		elseif (panel.Depressed) then
			alpha = 70
		elseif (panel.Hovered) then
			alpha = 150
		end
		surface.SetDrawColor(ColorAlpha(btnCol, alpha))
		surface.DrawRect(0, 0, w, h)
	end
end

function SKIN:PaintWindowMinimizeButton( panel, w, h ) -- dont need these

end

function SKIN:PaintWindowMaximizeButton( panel, w, h )

end

function SKIN:DrawGenericBackground(x, y, w, h)
	surface.SetDrawColor(45, 90, 45, 240)
	surface.DrawRect(x, y, w, h)

	surface.SetDrawColor(0, 0, 0, 180)
	surface.DrawOutlinedRect(x, y, w, h)

	surface.SetDrawColor(100, 100, 100, 25)
	surface.DrawOutlinedRect(x + 1, y + 1, w - 2, h - 2)
end

function SKIN:PaintVScrollBar(panel, w, h)
    surface.SetDrawColor(DARK_50)
    surface.DrawRect(0, 0, w, h)
end

local scrollCol = Color(120, 120, 120, 80)
function SKIN:PaintScrollBarGrip(panel, w, h)
    surface.SetDrawColor(scrollCol)
    surface.DrawRect(1, 0, w - 2, h)
end

function SKIN:PaintButtonDown(panel, w, h)
	if !panel.m_bBackground then return end

	if panel.Depressed || panel:IsSelected() then
		return self.tex.Scroller.DownButton_Down( 0, 0, w, h )
	end

	if panel.Hovered then
		return self.tex.Scroller.DownButton_Hover(0, 0, w, h, Color(130, 130, 130, 200))
	end

	self.tex.Scroller.DownButton_Normal(0, 0, w, h, Color(90, 90, 90, 200))
end

function SKIN:PaintButtonUp( panel, w, h )

	if ( !panel.m_bBackground ) then return end

	if ( panel.Depressed || panel:IsSelected() ) then
		return self.tex.Scroller.UpButton_Down( 0, 0, w, h )
	end

	if ( panel.Hovered ) then
		return self.tex.Scroller.UpButton_Hover( 0, 0, w, h, Color(130, 130, 130, 200))
	end

	self.tex.Scroller.UpButton_Normal(0, 0, w, h, Color(90, 90, 90, 200))

end

local depressedCol = Color(155, 52, 102, 255)
local normalCol = Color(240, 240, 240, 255)
function SKIN:PaintWindowCloseButton(panel, w, h)
    h = 22
    local min = math.min(w, h)
    local tbl = self:GetTable(panel)
    tbl.HoverTime = tbl.HoverTime or 0

	if not panel.m_bBackground then return end

	if panel:GetDisabled() then
		return
	end

	if panel.Hovered then
        tbl.HoverTime = SysTime()
	end

	if panel.Depressed and panel:IsSelected() then
		surface.SetDrawColor(depressedCol)
        surface.DrawRect(0,1,w,h)
	else
        local fraction = 1 - math.Clamp(Lerp((SysTime() - tbl.HoverTime) * 2, 0, 1), 0, 1)
        surface.SetDrawColor(232, 17, 35, 255* fraction)
        surface.DrawRect(0, 1, w, h)

    end
    local space = math.ceil(min / 6)
    local w2, h2 = math.floor(w / 2), math.floor(h / 2)
    surface.SetDrawColor(normalCol)
    surface.DrawLine(w2 + space, h2 + space, w2 - space, h2 - space)
    surface.DrawLine(w2 + space, h2 - space, w2 - space, h2 + space)
end

function SKIN:PaintComboBox(panel, w, h)
    self:PaintButton(panel, w, h)
end

function SKIN:PaintListBox(panel, w, h)
	self.tex.Input.ListBox.Background(0, 0, w, h)
end

function SKIN:PaintProgress(panel, w, h)
	surface.SetDrawColor(DARK_25)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(panel.BarCol or HIGHLIGHT)
	surface.DrawRect(0, 0, w * panel:GetFraction(), h)
	surface.SetDrawColor(DARK_50)
	surface.DrawOutlinedRect(0, 0, w, h)
end

local ccCol = Color(110, 110, 110, 130)
function SKIN:PaintCollapsibleCategory(panel, w, h)
	if h < 21 then
    	--surface.SetDrawColor(HIGHLIGHT)
    	--surface.DrawRect(0,0,w,h)
    	draw.RoundedBox( 0, 0, 0, w, h, ccCol)
    else
    	draw.RoundedBox( 0, 0, 0, w, h, ccCol)
	end
end

local darkCol = Color(0, 0, 0, 255)
function SKIN:PaintTooltip(panel, w, h)
    surface.SetDrawColor(color_white)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(darkCol)
    surface.DrawOutlinedRect(0, 0, w, h)
end

local propSheetCol = Color(110, 110, 110, 20)
function SKIN:PaintPropertySheet(panel, w, h)
	local activeTab = panel:GetActiveTab()
	local offset = 0

	if activeTab then 
		offset = activeTab:GetTall() - 8 
	end
	
	surface.SetDrawColor(propSheetCol)
	surface.DrawRect(0, 0+offset, w, h)
end

local tabColActive = Color(80, 80, 80, 100)
local tabColInactive = Color(80, 80, 80, 40)
function SKIN:PaintTab(panel, w, h)
	local h = 20

	if panel:IsActive() then
		surface.SetDrawColor(tabColActive)
		return surface.DrawRect(0, 0, w, h)
	end

	surface.SetDrawColor(tabColInactive)
	surface.DrawRect(0, 0, w, h)
end

local function PaintNotches(x, y, w, h, num)
	if !num then return end

	local space = w / num

	for i=0, num do
		surface.DrawRect(x + i * space, y + 4, 1, 5)
	end
end

function SKIN:PaintNumSlider(panel, w, h)
	surface.SetDrawColor(color_white)
	surface.DrawRect(8, h / 2 - 1, w - 15, 1)

	PaintNotches(8, h / 2 - 1, w - 16, 1, panel.m_iNotches)
end

derma.DefineSkin("impulse", "Skin made by TheVingard. A nice new lick of paint for BMRP's interfaces.", SKIN)
derma.RefreshSkins()
