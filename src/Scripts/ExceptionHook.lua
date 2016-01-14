local find = string.find
local oError = false
_G.exceptionHandler = {}
local lastHookedError

local CRASH_ON_MANUAL_ERRORS = true

function exceptionHandler.hook()
    oError = _G.error
    _G.error = function( m, l )
        local ex = Exception( m, type( l ) == "number" and ( l == 0 and 0 or l + 2 ) or 2 )
        log("eh", "A manual error occurred: " .. ex.stacktrace )


        if CRASH_ON_MANUAL_ERRORS then log("eh", "The previous error will propagate") exceptionHandler.throwSystemException( ex ) else log("eh", "The previous error will not propagate. CRASH_ON_MANUAL_ERRORS is false") end
    end

    return oError
end
function exceptionHandler.unhook( o )
    _G.error = o or oError or error("Already unhooked")
    oError = nil
end
function exceptionHandler.getLastHookedError() return lastHookedError end
function exceptionHandler.throwSystemException( exception, levelIncrement )
    log("eh", "Throwing DynaCode Exception '"..tostring( exception ).."' at level '"..exception.level.."'")
    lastHookedError = exception

    oError( "haha", exception.level + (levelIncrement or 0) )
end
function exceptionHandler.getRawError() return oError end
function exceptionHandler.spawnException( ex )
    lastHookedError = ex
end
