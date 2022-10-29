IES = IES or {}

local LANG = {}
LANG.NEWLINE = "\n"
LANG.ESCAPER = "#"
LANG.COMMENT = "//"
LANG.OR = "?"
LANG.EQ = ":"
LANG.SEP = ","
LANG.GET = "@"
LANG.STR = [["]]
LANG.STR2 = [[']]
LANG.UID_START = "("
LANG.UID_END = ")"
LANG.PROP_START = "{"
LANG.PROP_END = "}"

local COMP_SKIPLINE = 1
local COMP_REPROCESS = 2
local COMP_HALT = 3
local COMP_CONSTRUCTING = ""
local COMP_GOTOTERM = ""
local COMP_GOTOPARSER = ""
local COMP_CURLINE = ""
local COMP_CURTERM
local COMP_LINESTRBUFFER = {}
local COMP_CURWORDPOS = 0
local COMP_STARTLINE = nil
local VAR_PARSED = 99
local CALL
local MAKECALL
local MAKEPARSE 
local MAKEVAR 
local MAKEWAIT 
local MACRO 
local MAKETAG 
local PARSER
local TAGS
local VARS

local function Ex(no, msg)
    local red = Color(246, 131, 0)

    MsgC(red, "------------------------------\n")
    MsgC(red, "|[IES ERROR]\n")
    MsgC(red, "|    Line: "..no.."\n")
    MsgC(red, "|    "..msg, "\n")
    MsgC(red, "------------------------------\n")
end

local function find(word, t)
    return string.find(word, t, nil, true)
end

local function trim(word)
    return string.Trim(word)
end

local function VarCheck(no, word)
    if string.StartWith(word, LANG.GET) then
        local name = string.sub(word, 2)
        local var = VARS[name]

        if var != nil then
            if isstring(var) then
                return var
            end
            
            if istable(var) then
                print("VARCHECK TABLE GET!! PANIC")
                PrintTable(var)
                return var
            end
            return var
        end

        Ex(no, "Can not find VAR called '"..word.."'") -- FIX ME this doesnt error correctly!
        return nil, COMP_HALT
    end
end

local parserWorkers = {
    ["String"] = function(word, no)
        print("str parser")
        local ender = find(word, LANG.STR)

        if not ender then
            print("no str ender")
            return COMP_REPROCESS, {TERM = COMP_CURTERM}
        end

        print("str ender found")

        local val = table.remove(COMP_LINESTRBUFFER, 1)

        print("I HAVE PARSED A STRING VALUE AND I AM GONNA RETURN IT!!")
        print(val)

        return VAR_PARSED, val
    end,
    ["Vector"] = function(word, no) -- aliases: Angle
        print("VEC IN: "..word)
        if not PARSER.Opened then
            local opener = find(word, "(")

            if opener then
                print("VEC OPENER: ", opener)
                PARSER.Opened = true
                PARSER.NeedVal = true
            end

            return COMP_REPROCESS, {TERM = COMP_CURTERM, SUB_WORD = string.sub(word, opener + 1)}
        end

        if PARSER.NeedComma then
            local comma = find(word, LANG.SEP)

            print("VEC COMMA time")
            print("VEC COMMA IS: ", word)

            if comma then
                print("VEC COMMA FOUND: "..comma)
                PARSER.NeedComma = false
                PARSER.NeedVal = true
            end

            return COMP_REPROCESS, {TERM = COMP_CURTERM, SUB_WORD = string.sub(word, comma + 1)}
        end

        if PARSER.NeedVal then
            local hasComma = find(word, LANG.SEP)
            local hasEnder = find(word, ")")
            local len = string.len(word)
            local scannable = word
            local subWord = nil

            print("has comma", hasComma)
            print("has ender", hasEnder)

            if hasComma and (not hasEnder or hasComma < hasEnder) then
                scannable = string.sub(scannable, 0, hasComma - 1)
                subWord = string.sub(word, hasComma, len)
            elseif hasEnder then
                scannable  = string.sub(scannable, 0, hasEnder - 1)
                print("SCN RESULT :"..scannable..":")
                subWord = string.sub(word, hasEnder, len)
            end

            local num = tonumber(scannable)

            if not num then
                Ex(no, "Expected number inside Vector, got '"..word.."'")
                return COMP_HALT
            end

            if PARSER.Values and #PARSER.Values >= 3 then
                Ex(no, "Too many values passed to Vector, expected 3")
                return COMP_HALT
            end

            PARSER.Values = PARSER.Values or {}
            PARSER.Values[#PARSER.Values + 1] = num

            print("VEC ADDED VAL: ", num)

            if #PARSER.Values != 3 then
                PARSER.NeedComma = true
            end

            PARSER.NeedVal = false

            print("VEC SUBWORD: ", subWord)

            return COMP_REPROCESS, {TERM = COMP_CURTERM, SUB_WORD = subWord}
        end

        local ender = find(word, ")")

        if ender then
            PrintTable(PARSER)
            return VAR_PARSED, PARSER.Values
        end
    end

}

local function ParseVar(word, no)
    local varVal, rCode = VarCheck(no, word) -- needs work :/

    if rCode then
        return rCode
    end

    if varVal != nil then
        return VAR_PARSED, varVal
    end

    if PARSER and parserWorkers[PARSER.Current] then
        return parserWorkers[PARSER.Current](word, no)
    end

    local num = tonumber(word)
    if num then
        PARSER = {}
        PARSER.Number = true
        PARSER = nil
        return VAR_PARSED, num
    end

    print(word)

    if string.StartWith(word, LANG.STR) then
        print("str")
        PARSER = {}
        PARSER.Current = "String"

        local endPos = find(string.sub(word, 2, string.len(word)), LANG.STR)
        if endPos then
            print("STR ENDER IN SAME WORD! LOC:")
            print(endPos)
            return COMP_REPROCESS, {TERM = COMP_CURTERM, SUB_WORD = LANG.STR}
        end

        return COMP_REPROCESS, {TERM = COMP_CURTERM}
    end

    print("CHECKING WORD FOR KEYTERM VEC/ANG :: "..word)

    if string.StartWith(word, "Vector") or string.StartWith(word, "Angle") or string.StartWith(word, "Color") then
        PARSER = {}
        PARSER.Current = "Vector"

        return COMP_REPROCESS, {TERM = COMP_CURTERM, SUB_WORD = word}
    end

    if word == "true" or word == "false" then
        PARSER = {}
        PARSER.Boolean = true
        PARSER = nil
        return VAR_PARSED, word == "true" and true or false
    end

    Ex(no, "Unknown variable to parse '"..word.."'")
    return COMP_HALT
end

local function DoInProps(word, no, data)
    local pre = ":::::::::::::::::::::::::::::"
    print(pre.." PROPS IN WORD: "..word)
    if data.NEEDCOMMA then
        print(pre.." LOOKING FOR COMMA")
        local findComma = find(word, LANG.SEP)
        if findComma then
            print(pre.." found COMMA")
            data.NEEDCOMMA = false
            data.CURKEY = nil
            return COMP_REPROCESS, {SUB_WORD = string.sub(word, findComma + 1)}
        end
    end

    if data.NEEDEQ then
        local findEq = find(word, LANG.EQ)
        print(pre.." looking for EQ")

        if findEq then
            print(pre.." found EQ")
            data.NEEDEQ = false
            data.NEEDVAL = true
            return COMP_REPROCESS, {SUB_WORD = string.sub(word, findEq + 1)}
        end
    end

    if data.NEEDVAL then
        local x,y = ParseVar(word, no)

        print(pre.." LOOKING FOR VAL")

        if x and x == VAR_PARSED then
            print(pre.." VAL DONE")
            data.Values[data.CURKEY] = y
            data.NEEDCOMMA = true

            return COMP_REPROCESS, {SUB_WORD = word}
        else
            print(pre.." VAL PASSTHRU")
            return x,y
        end
    end

    if not data.CURKEY then
        print(pre.." LOOKING FOR KEY")
        local findEq = find(word, LANG.EQ)
        local s = word

        if findEq then
            s = string.sub(word, 1, findEq - 1)
        end

        data.CURKEY = s
        data.NEEDEQ = true

        return COMP_REPROCESS, {SUB_WORD = word}
    end

    return VAR_PARSED, data
end

local function DoOutProps(word, no, data)

end

local function DoCall(word, no)
    CALL = CALL or {}

    if not CALL.NAME then
        local split = string.Split(word, LANG.UID_START)
        local splitx = string.Split(split[1], LANG.PROP_START)
        local x = split[1]

        if not impulse.Ops.EventManager.Config.Events[x] then
            Ex(no, "Can not find event matching '"..x.."'")
            return COMP_HALT
        end

        CALL.NAME= x
        COMP_CONSTRUCTING = "CALL"

        local found = find(word, LANG.UID_START)

        if not found then
            found = find(word, LANG.PROP_START)
        end

        if found then
            return COMP_REPROCESS, {SUB_WORD = string.sub(word, found)}
        end
    end

    if not CALL.UID and string.StartWith(word, LANG.UID_START) then
        local findEnd = find(word, LANG.UID_END)

        if not findEnd then
            Ex(no, "Can not find UID bracket close '"..word.."'")
            return COMP_HALT
        end

        local varName = string.sub(word, 2, findEnd-1)

        CALL.UID = varName

        local found = find(word, LANG.PROP_START)

        if found then
            return COMP_REPROCESS, {SUB_WORD = string.sub(word, found)}
        end
    end

    local findStart = string.StartWith(word, LANG.PROP_START)

    if not CALL.PROP and (findStart or CALL.PROP_OPEN) then
        CALL.PROP_TMP = CALL.PROP_TMP or {}

        if findStart then
            word = string.sub(word, 2)
        end

        local findEnd = find(word, LANG.PROP_END)

        if findEnd then
            local x,y = DoInProps(string.sub(word, 1, findEnd - 1), no, CALL.PROP_TMP)
            if x and x == VAR_PARSED then
                CALL.PROP = y
                CALL.PROP_TMP = nil 
                CALL.PROP_OPEN = false
                return
            end

            return x,y
        else
            local x,y = DoInProps(word, no, CALL.PROP_TMP)
            if x and x == VAR_PARSED then
                CALL.PROP_TMP = y
                return
            end
            return x,y
        end

        CALL.PROP_OPEN = true
    end
end

LANG.TERMS = {
    macro = {
        Handler = function(word, no)
            if not word then
                if MACRO then
                    Ex(no, "Nested macros are not supported")
                    return COMP_HALT
                end
                MACRO = {}
                MACRO.START_LINE = no + 1

                print("MACRO reprocess code:")
                print(COMP_REPROCESS)

                return COMP_REPROCESS, {TERM = "macro"}
            end

            print("2nd stage macro")

            PrintTable(MACRO)
            if not MACRO.NAME then
                if word == "" then
                    Ex(no, "Can not find macro name")
                    return COMP_HALT
                end

                MACRO.NAME = word

                local split = find(word, LANG.PROP_START)

                if split then
                    return COMP_REPROCESS, {TERM = "macro", SUB_WORD = string.sub(word, split)}
                end

                return COMP_REPROCESS, {TERM = "macro"}
            end

            if not MACRO.PROPS and (string.StartWith(word, LANG.PROP_START) or MACRO.PROP_OPEN) then
                MACRO.PROP_TMP = MACRO.PROP_TMP or ""
                MACRO.PROP_OPEN = true
                local split = find(word, LANG.PROP_END)

                if split then
                    MACRO.PROP_OPEN = false 
                    MACRO.PROP = MACRO.PROP_TMP..string.sub(word, 1, split)
                    MACRO.PROP_TMP = nil
                else
                    MACRO.PROP_TMP = MACRO.PROP_TMP..word
                end

                return COMP_REPROCESS, {TERM = "macro"}
            end

            print("MACRO skipline")            
            return COMP_SKIPLINE
        end,
        OnLineDone = function(no)
            if not MACRO.NAME then
                Ex(no, "Can not find macro name")
                return COMP_HALT
            end

            if MACRO.PROP_OPEN then
                Ex(no, "Can not find macro property bracket close")
                return COMP_HALT
            end

            PrintTable(MACRO)
        end
    },
    ["end"] = {
        Handler = function(word, no)
            if not MACRO then
                Ex(no, "Can not find start of statment for end")
                return COMP_HALT
            end

            MACRO.END_LINE = no - 1

            PrintTable(MACRO)

            MACRO = nil

            return COMP_SKIPLINE
        end
    },
    call = {
        Handler = function(word, no)
            if not word then
                MAKECALL = {}
                return COMP_REPROCESS, {TERM = "call"}
            end

            MAKECALL.HasCall = true

            local x,y = DoCall(word, no)

            if x != nil then
                return x,y
            end

            return COMP_SKIPLINE
        end,
        OnLineDone = function(no)
            if not MAKECALL.HasCall then
                Ex(no, "Call was made but no arguments were provided")
                return COMP_HALT
            end

            print("Call final result:")
            PrintTable(MAKECALL)
        end
    },
    call_async = {
        Handler = function(word, no)
            if not word then
                MAKECALL = {}
                return COMP_REPROCESS, {TERM = "call_async"}
            end

            MAKECALL.HasCall = true
            MAKECALL.ASync = true

            return DoCall(word, no) or COMP_SKIPLINE
        end,
        OnLineDone = function(no)
            if not MAKECALL.HasCall then
                Ex(no, "ASync Call was made but no arguments were provided")
                return COMP_HALT
            end
        end
    },
    wait = {
        Handler = function(word, no)
            if not word then
                MAKEWAIT = {}
                return COMP_REPROCESS, {TERM = "wait"}
            end

            local n = tonumber(word)

            if not n then
                Ex(no, "Wait value must be a valid number")
                return COMP_HALT
            end

            MAKEWAIT.HasWait = true
            MAKEWAIT.Wait = n

            PrintTable(MAKEWAIT)

            return COMP_SKIPLINE
        end,
        OnLineDone = function(no)
            if not MAKEWAIT.HasWait then
                Ex(no, "Wait was made but no arguments were provided")
                return COMP_HALT
            end
        end
    },
    tag = {
        Handler = function() 
            return COMP_SKIPLINE
        end
    },
    var = {
        Handler = function(word, no) 
            print("var call")
            if not word then
                MAKEVAR = {}
                MAKEVAR.NAME_START = true
                print("make var")
                return COMP_REPROCESS, {TERM = "var"}
            end
    
            if not MAKEVAR.NAME and MAKEVAR.NAME_START then
                if word == "" then
                    Ex(no, "Can not find VAR name")
                    return COMP_HALT
                end

                print("var name")
    
                MAKEVAR.NAME = word
                MAKEVAR.NAME_START = false
                return COMP_REPROCESS, {TERM = "var"}
            end

            print("var before val")
            PrintTable(MAKEVAR)
    
            if MAKEVAR.NAME and not MAKEVAR.VALUE then
                local r, data = ParseVar(word, no)

                print("pre parse info")
                print(r)

                if r and r == VAR_PARSED then
                    print("PARSE COMPLETED:")

                    print(r)
                    print("--parse complete data")
                    PrintTable({data})
                    PARSER = nil
                    MAKEVAR.VALUE = data
                    return COMP_SKIPLINE
                else
                    return r, data
                end
            end
    
            print(word)
            --SUB_WORD = string.TrimLeft(word, )
            return COMP_REPROCESS, {TERM = "var"}
        end,
        OnLineDone = function(no)
            if not MAKEVAR.NAME then
                Ex(no, "Can not find VAR name")
                return COMP_HALT
            end

            if MAKEVAR.VALUE == nil then
                Ex(no, "No value provided for VAR '"..MAKEVAR.NAME.."'")
                return COMP_HALT
            end
            
            VARS[MAKEVAR.NAME] = MAKEVAR.VALUE
            print("var done")
            PrintTable(MAKEVAR)
        end
    },
    start = {
        Handler = function(word, no)
            COMP_STARTLINE = no
            return COMP_SKIPLINE
        end
    },
    ["break"] = {
        Handler = function() 
            return 102 -- COMP_HALT WITH NO ERRORCODE
        end
    },
}

local function DoTerm(macro, no)
    local x = string.sub(macro, 2) -- remove #
    x = string.Trim(x, " ")

    print("trying to term "..x)

    local term = LANG.TERMS[x]

    if term then
        COMP_CURTERM = x
        return term.Handler(nil, no)
    else
        Ex(no, "Can not find term matching '"..x.."'")
        return COMP_HALT
    end
end

local function DoEvent(word, no)
    return DoCall(word, no)
end


local function DoWord(word, no)
    word = trim(word)

    if word == "" then
        if COMP_GOTOTERM then
            return COMP_REPROCESS, {TERM = COMP_GOTOTERM}
        end
        return 
    end

    print("doing a word: "..word)

    if string.StartWith(word, LANG.COMMENT) then
        print("found comment!")
        return COMP_SKIPLINE
    end

    if COMP_CONSTRUCTING == "CALL" then
        print("constructing")
        return DoCall(word, no)
    end

    if COMP_GOTOPARSER then
        print("1111111111111111PARSING")
        local c, data = ParseVar(word, no)
        return c, data
    end

    print("COMP_GOTOTERM IS: ")
    print(COMP_GOTOTERM)

    if COMP_GOTOTERM and COMP_GOTOTERM != "" then
        print("going to "..COMP_GOTOTERM)
        return LANG.TERMS[COMP_GOTOTERM].Handler(word, no)
    end

    if string.StartWith(word, LANG.ESCAPER) then
        return DoTerm(word, no)
    end

    return DoEvent(word, no)
end

local function DoLine(line, no)
    if COMP_CONSTRUCTING != "MACRO" then -- macro is multi-line
        COMP_CONSTRUCTING = ""
    end

    line = string.Trim(line, " ")
    line = string.Trim(line, "\n")
    line = string.Trim(line, "\r") -- carriage return line feed support

    if line == "" then
        return -- empty line
    end

    COMP_CURLINE = line
    COMP_LINESTRBUFFER = {}
    local strOpen = false
    local strOpenPos = 0
    local strLastStart = -1

    local commentPos = find(line, LANG.COMMENT)

    local function strSearch(start)
        if start < strLastStart then
            return
        end

        strLastStart = start

        local find = string.find(line, LANG.STR, start, true)

        if find then
            if !commentPos or strOpen or find < commentPos then
                if strOpen then
                    local str = string.sub(line, strOpenPos + 1, find - 1)
                    print("STR SEARCH FOUND: "..str)
                    table.insert(COMP_LINESTRBUFFER, str)
                    strOpen = false
                    strSearch(find + 1)
                    return
                end

                strOpen = true
                strOpenPos = find
                strSearch(find + 1)
            end
        end
    end

    strSearch(0)

    if strOpen then
        Ex(no, "String opened but did not end")
        return 101
    end

    local words = string.Explode(" ", line)

    local function caller(word, no)
        local act, data = DoWord(word, no)

        if not data or not data.TERM then
            print("COMP GOTOTERM SET TO NIL")
            COMP_GOTOTERM = nil
        end

        if not data or not data.PARSER then
            COMP_GOTOPARSER = nil
        end

        print("Passed ACT is:")
        print(act)

        if act == COMP_SKIPLINE then
            return 100 -- continue
        elseif act == COMP_REPROCESS then
            COMP_GOTOTERM = data.TERM or nil -- route next word into term
            COMP_GOTOPARSER = data.PARSER or nil

            if data.SUB_WORD and data.SUB_WORD != "" then
                print("calling sub word term call")
                caller(data.SUB_WORD, no)
            end
        elseif act == COMP_HALT then
            return 101 -- break
        elseif act == 102 then
            return act
        end
    end

    print("doing line "..no)

    local function completeLine()
        if COMP_GOTOTERM or COMP_CURTERM then
            local term = LANG.TERMS[COMP_GOTOTERM or COMP_CURTERM]
    
            if term and term.OnLineDone then
                COMP_GOTOTERM = nil
                return term.OnLineDone(no)
            end
        end
    end

    for x, word in pairs(words) do
        print("word progression: "..word)
        local r = caller(word, no) or 0

        print("ReturnCode: ", r)

        if r == 100 then
            local x = completeLine() -- SKIP LINE
            if x and x == COMP_HALT then
                return 101
            end

            return
        elseif r == 101 then
            return 101
        elseif r == 102 then
            return 102
        end
    end

    if CALL and CALL.NAME then
        if CALL.PROP_OPEN then
            Ex(no, "Can not find PROP bracket close")
            return COMP_HALT    
        end

        print("making call")
        PrintTable(CALL)


        CALL = nil
    end

    local x = completeLine()
    if x and x == COMP_HALT then
        return 101
    end

    return
end

function IES.Compile(script)
    local startTime = SysTime()

    COMP_CONSTRUCTING = ""
    COMP_GOTOTERM = nil
    COMP_GOTOPARSER = nil
    COMP_CURTERM = nil
    COMP_STARTLINE = nil
    CALL = {}
    VARS = {}
    TAGS = {}
    PARSER = nil

    local lines = string.Explode(LANG.NEWLINE, script)
    local errored = false

    for lineNo, line in pairs(lines) do
        local returnCode = DoLine(line, lineNo)

        if returnCode then
            if returnCode == 101 then
                errored = true
                break
            elseif returnCode == 102 then
                break
            end
        end
    end

    if not errored and MACRO then
        Ex(MACRO.START_LINE - 1, "Can not find end for macro")
        return
    end

    if not errored then
        local endTime = SysTime()
        local green = Color(76, 240, 61)

        MsgC(green, "------------------------------\n")
        MsgC(green, "|[IES COMPILE]\n")
        MsgC(green, "|    Successfully compiled "..#lines.." lines\n")
        MsgC(green, "|    Took "..endTime - startTime.." seconds", "\n")
        MsgC(green, "------------------------------\n")
    end

    print("FINAL VARS")

    PrintTable(VARS)

    return TAGS
end

if CLIENT then
    concommand.Add("ies_test", function()
        local x = file.Read("impulse/ops/eventmanager/test.ies", "DATA")

        IES.Compile(x)
    end)
end