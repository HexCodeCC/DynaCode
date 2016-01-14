local find = string.find
local match = string.match
local sub = string.sub

local defaultError = _G.error

abstract class "ExceptionBase" {
    stacktrace = nil;
    level = 0;
    message = false;
}

function ExceptionBase:initialise( m, l, levelOffset, raw )
    -- An exception has been thrown.
    local m = tostring( m )
    local levelOffset = type( levelOffset ) == "number" and levelOffset or 0

    self.level = type( l ) == "number" and ( l == 0 and 0 or l + 1 + levelOffset ) or 2 + levelOffset

    self.rawException = raw or (function() local _, err = pcall( defaultError, m, self.level == 0 and 0 or self.level + 1 ); return err end)()
    self.message = m

    self.stacktrace = "Stacktrace Follows:\n## Error ##\n"..m.."\n\n## Stacktrace ##\n"
    self:formStacktrace( 3 )
end

function ExceptionBase:generateDisplayMessage( pre )
    local err = self.rawException

    local _, e, fileName, fileLine = find( err, "(%w+%.?.-):(%d+).-[%s*]?[:*]?" )
    if not e then return pre.." (?): "..err end

    return pre.." ("..(fileName or "?")..":"..(fileLine or "?").."):"..tostring( sub( err, e + 1 ) )
end

function ExceptionBase:formStacktrace( lModifier )
    if self.level == 0 then
        log("eh", "Cannot form stacktrace for Exception. The level on the Exception is zero.")
        self.stacktrace = self.stacktrace .. "Cannot create stacktrace. Exception is level zero.\n"

        return
    end
    local level = self.level + ( lModifier or 0 )

    -- Trace this error
    local stack = self.stacktrace
    local oError = exceptionHandler.getRawError() or defaultError

    while true do
        local ok, err = pcall( oError, self.message, level )

        if find( err, "bios%.?.-:") or find( err, "shell.-:" ) or find( err, "xpcall.-:" ) then break end

        local name, line = match( err, "(%w+%.?.-):(%d+).-" )
        stack = stack .. "> "..(name or "?")..": "..(line or "?").."\n"

        level = level + 1
    end

    self.stacktrace = stack
end

function ExceptionBase:throw( m, l )
    log("eh", "Throwing exception: "..tostring( m ))

    exceptionHandler.throwSystemException( self )
end
