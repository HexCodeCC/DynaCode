local lastStack
local find = string.find
local oError = false
local trace = {}
local lastHookedError

local CRASH_ON_MANUAL_ERRORS = true

function trace.traceback( message, _level )
    if not oError then return end
    if message == "Terminated" or _level == 0 then
        return oError( message, _level )
    end

    local level = type( _level ) == "number" and _level + 1 or 2

    local stack = [[
## Error ##
]]..tostring( message )..[[


## Stacktrace Follows ##

]]
    local ok, err
    local running = true
    while running do
        local ok, err = pcall( oError, message, level )

        if find( err, "bios%.?.-:") or find( err, "shell.-:" ) or find( err, "xpcall.-:" ) then break end

        local name, line = err:match("(%w+%.?.-):(%d+).-")
        stack = stack .. "> "..(name or "?")..": "..(line or "?").."\n"

        level = level + 1
    end
    lastStack = stack
end

function trace.hook()
    oError = _G.error
    _G.error = function( m, l )
        l = type( l ) == "number" and l + 1 or 2

        local _, err = pcall( oError, m, l + 2 )
        lastHookedError = err

        trace.traceback( m, l + 1 )
        log("e", "A manual error occured, stack: \n"..tostring( lastStack ))
        if CRASH_ON_MANUAL_ERRORS then log("w", "The previous error will propagate") oError(m, l + 1) else log("i", "The previous error will not propagate. CRASH_ON_MANUAL_ERRORS is false") end
    end

    return oError
end
function trace.unhook( o )
    _G.error = o or oError or error("Already unhooked")
    oError = nil
end
function trace.getLastStack()
    return lastStack
end
function trace.getLastHookedError() return lastHookedError end

_G.trace = trace
