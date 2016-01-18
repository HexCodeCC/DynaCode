local oError
local last


_G.exceptionHook = {}
function exceptionHook.hook()
    if oError then
        Exception("Failed to create exception hook. A hook is already in use.")
    end

    oError = _G.error
    _G.error = function( m, l )
        Exception( m, type( l ) == "number" and ( l == 0 and 0 or l + 1 ) or 2 )
    end
    log("s", "Exception hook created")
end

function exceptionHook.unhook()
    if not oError then
        Exception("Failed to unhook exception hook. The hook doesn't exist.")
    end

    _G.error = oError
    log("s", "Exception hook removed")
end

function exceptionHook.isHooked()
    return type( oError ) == "function"
end

function exceptionHook.getRawError()
    return oError or _G.error
end

function exceptionHook.setRawError( fn )
    if type( fn ) == "function" then
        oError = fn
    else
        Exception("Failed to set exception hook raw error. The function is not valid")
    end
end

function exceptionHook.throwSystemException( exception )
    last = exception
    local oError = exceptionHook.getRawError()

    oError( exception.displayName or "?", 0 )
end

function exceptionHook.spawnException( exception )
    last = exception
end

function exceptionHook.getLastThrownException()
    return last
end
