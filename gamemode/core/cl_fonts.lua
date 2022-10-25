-- Font's are still a bit squiffy, they will all be scaled properly soon. Also - please name none specific fonts 'Impulse-Elements<description>'

surface.CreateFont("Impulse-Elements18", {
	font = "Arial",
	size = 18,
	weight = 800,
	antialias = true,
	shadow = false,
} )

surface.CreateFont("Impulse-Elements19", {
	font = "Arial",
	size = 19,
	weight = 1000,
	antialias = true,
	shadow = false,
} )

surface.CreateFont("Impulse-Elements16", {
	font = "Arial",
	size = 16,
	weight = 800,
	antialias = true,
	shadow = false,
} )

surface.CreateFont("Impulse-Elements17", {
	font = "Arial",
	size = 17,
	weight = 800,
	antialias = true,
	shadow = false,
} )

surface.CreateFont("Impulse-Elements17-Shadow", {
	font = "Arial",
	size = 17,
	weight = 800,
	antialias = true,
	shadow = true
} )

surface.CreateFont("Impulse-Elements14", {
	font = "Arial",
	size = 14,
	weight = 800,
	antialias = true,
	shadow = false,
} )

surface.CreateFont("Impulse-Elements14-Shadow", {
	font = "Arial",
	size = 14,
	weight = 800,
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-Elements18-Shadow", {
	font = "Arial",
	size = 18,
	weight = 900,
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-Elements16-Shadow", {
	font = "Arial",
	size = 16,
	weight = 900,
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-Elements19-Shadow", {
	font = "Arial",
	size = 19,
	weight = 900,
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-Elements20-Shadow", { -- dont change this font to actually be 20 its a dumb mistake
	font = "Arial",
	size = 18,
	weight = 900,
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-Elements20A-Shadow", { -- dont change this font to actually be 20 its a dumb mistake
	font = "Arial",
	size = 20,
	weight = 900,
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-CharacterInfo", {
	font = "Arial",
	size = 34,
	weight = 900,
	antialias = true,
	shadow = true,
	outline = true
} )

surface.CreateFont("Impulse-CharacterInfo-NO", {
	font = "Arial",
	size = 34,
	weight = 900,
	antialias = true,
	shadow = true,
	outline = false
} )

surface.CreateFont("Impulse-Elements13", {
	font = "Arial",
	size = 18,
	weight = 800,
	antialias = true,
	shadow = false,
} )

surface.CreateFont("Impulse-Elements22-Shadow", {
	font = "Arial",
	size = 22,
	weight = 700,
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-Elements72-Shadow", {
	font = "Arial",
	size = 72,
	weight = 700,
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-Elements23", {
	font = "Arial",
	size = 23,
	weight = 800,
	antialias = true,
	shadow = false,
} )

surface.CreateFont("Impulse-Elements23-Shadow", {
	font = "Arial",
	size = 23,
	weight = 800,
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-Elements23-Italic", {
	font = "Arial",
	size = 23,
	weight = 800,
	italic = true,
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-Elements24-Shadow", {
	font = "Arial",
	size = 24,
	weight = 800,
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-Elements27-Shadow", {
	font = "Arial",
	size = 27,
	weight = 800,
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-Elements27", {
	font = "Arial",
	size = 27,
	weight = 800,
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-Elements32", {
	font = "Arial",
	size = 32,
	weight = 800,
	antialias = true,
	shadow = false,
} )

surface.CreateFont("Impulse-Elements32-Shadow", {
	font = "Arial",
	size = 32,
	weight = 800,
	antialias = true,
	shadow = true
} )

surface.CreateFont("Impulse-Elements36", {
	font = "Arial",
	size = 36,
	weight = 800,
	antialias = true,
	shadow = false,
} )

surface.CreateFont("Impulse-Elements48", {
	font = "Arial",
	size = 48,
	weight = 1000,
	antialias = true,
	shadow = false,
} )

surface.CreateFont("Impulse-Elements78", {
	font = "Arial",
	size = 78,
	weight = 1000,
	antialias = true,
	shadow = false,
} )

surface.CreateFont("Impulse-ChatSmall", {
	font = "Arial",
	size = (impulse.IsHighRes() and 20 or 16),
	weight = 700,
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-ChatMedium", {
	font = "Arial",
	size = (impulse.IsHighRes() and 21 or 17),
	weight = 700,
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-ChatRadio", {
	font = "Consolas",
	size = (impulse.IsHighRes() and 24 or 17),
	weight = (impulse.IsHighRes() and 700 or 500),
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-ChatLarge", {
	font = "Arial",
	size = (impulse.IsHighRes() and 27 or 20),
	weight = (impulse.IsHighRes() and 1100 or 700),
	antialias = true,
	shadow = true,
} )

surface.CreateFont("Impulse-UI-SmallFont", {
	font = "Arial",
	size = math.max(ScreenScale(6), 17),
	extended = true,
	weight = 500
})

surface.CreateFont("Impulse-SpecialFont", {
	font = "Arial",
	size = 33,
	weight = 3700,
	antialias = true,
	shadow = true
})

hook.Run("PostLoadFonts")