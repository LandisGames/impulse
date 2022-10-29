-- by vin aged 12 and a half
-- why am i making this

local prefixes = {
	'<3 ',
	'0w0 ',
	'H-hewwo?? ',
	'HIIII! ',
	'Haiiii! ',
	'Huohhhh. ',
	'OWO ',
	'OwO ',
	'UwU '
}

local suffixes = {
	' :3',
	' UwU',
	' (✿ ♡‿♡)',
	' ÙωÙ',
	' ʕʘ‿ʘʔ',
	' ʕ•̫͡•ʔ',
	' >_>',
	' ^_^',
	'..',
	' Huoh.',
	' ^-^',
	' ;_;',
	' ;-;',
	' xD',
	' x3',
	' :D',
	' :P',
	' ;3',
	' XDDD',
	', fwendo',
	' ㅇㅅㅇ',
	' (人◕ω◕)',
	'（＾ｖ＾）',
	' x3',
	' ._.',
	' (　\'◟ \')',
	' (• o •)',
	' (；ω；)',
	' (◠‿◠✿)',
	' >_<'
}

local substitutions = {
	['r'] = 'w',
	['l'] = 'w',
	['R'] = 'W',
	['L'] = 'W',
	['no'] = 'nu',
	['has'] = 'haz',
	['have'] = 'haz',
	['you'] = 'uu',
	['the'] = 'da',
	['The'] = 'Da'
}

function OwOifyText(text, doPrefix, doSuffix)
	if doPrefix then
		text = prefixes[math.random(1, #prefixes)] .. text
	end

	for v,k in pairs(substitutions) do -- probably slow
	    text = string.Replace(text, v, k)
	end

	if doSuffix then
		text = text .. suffixes[math.random(1, #suffixes)]
	end

	return text
end