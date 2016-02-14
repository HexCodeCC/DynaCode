local _

abstract class "ExceptionBase" {
    exceptionOffset = 1;
    levelOffset = 1;
    title = "UNKNOWN_EXCEPTION";
    subTitle = false;

    message = nil;
    level = 1;
    raw = nil;

    useMessageAsRaw = false;

    stacktrace = "\nNo stacktrace has been generated\n"
}

function ExceptionBase:initialise( m, l, handle )
    if l then self.level = l end

    self.level = self.level ~= 0 and (self.level + (self.exceptionOffset * 3) + self.levelOffset) or self.level
    self.message = m or "No error message provided"

    if self.useMessageAsRaw then
        self.raw = m
    else
        local ok, err = pcall( exceptionHook.getRawError(), m, self.level == 0 and 0 or self.level + 1 )
        self.raw = err or m
    end

    self:generateStack( self.level == 0 and 0 or self.level + 4 )
    self:generateDisplayName()

    if not handle then
        exceptionHook.throwSystemException( self )
    end
end

function ExceptionBase:generateDisplayName()
    local err = self.raw
    local pre = self.title

    local _, e, fileName, fileLine = err:find("(%w+%.?.-):(%d+).-[%s*]?[:*]?")
    if not e then self.displayName = pre.." (?): "..err return end

    self.displayName = pre.." ("..(fileName or "?")..":"..(fileLine or "?").."):"..tostring( err:sub( e + 1 ) )
end

function ExceptionBase:generateStack( level )
    local oError = exceptionHook.getRawError()

    if level == 0 then
        log("w", "Cannot generate stacktrace for exception '"..tostring( self ).."'. Its level is zero")
        return
    end

    local stack = "\n'"..tostring( self.title ).."' details\n##########\n\nError: \n"..self.message.." (Level: "..self.level..", pcall: "..tostring( self.raw )..")\n##########\n\nStacktrace: \n"

    local currentLevel = level
    local message = self.message

    while true do
        local _, err = pcall( oError, message, currentLevel )

        if err:find("bios[%.lua]?.-:") or err:find("shell.-:") or err:find("xpcall.-:") then
            stack = stack .. "-- End --\n"
            break
        end

        local fileName, fileLine = err:match("(%w+%.?.-):(%d+).-")
        if not fileName and not fileLine then
            stack = stack .. "> No further stack information could be generated"
            break
        end
        stack = stack .. "> "..(fileName or "?")..":"..(fileLine or "?").."\n"

        currentLevel = currentLevel + 1
    end

    if self.subTitle then
        stack = stack .. "\n"..self.subTitle
    end

    self.stacktrace = stack
end
