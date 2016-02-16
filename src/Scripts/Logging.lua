local loggingEnabled
local loggingPath
local loggingModes = {
    i = "Information";
    w = "Warning";
    e = "Error";
    f = "FATAL";
    s = "Success";


    di = "Daemon Information";
    dw = "Daemon Warning";
    de = "Daemon Error";
    df = "Daemon Fatal";
    ds = "Daemon Success";

    eh = "Exception Handling";
}
local clearWhenLarge = true
local fileSizeLimit = 50000
local loggingIntroString = "--@@== DynaCode Logging ==@@--\n\n\nLog Start >\n"
local handle

local log = {}
function log:log( mode, message )
    if not mode or not message or not handle then
        return
    end

    if clearWhenLarge and fs.getSize( loggingPath ) > fileSizeLimit then
        self:closeHandle()
        fs.delete( loggingPath )

        self:openHandle("--@@== DynaCode Logging ==@@--\n\nThis file was cleared at os time '"..os.clock().."' to save system storage space\n\nLog Start >\n")
    end

    handle.write( "["..os.clock().."]["..( loggingModes[ mode ] or tostring( mode ) ).."] > "..message.."\n" )
    handle.flush()
end

function log:registerMode( short, long )
    loggingModes[ short ] = long
end

function log:closeHandle()
    if not handle or not loggingEnabled then return end

    handle.close()
    handle = nil
end

function log:openHandle( intro )
    if handle or not loggingEnabled or not loggingPath then return end

    handle = fs.open( loggingPath, "w" )
    handle.write( intro or loggingIntroString )
end

function log:setPath( path )
    if not type( path ) == "string" then
        ParameterException("Failed to set loggingPath to '"..tostring( path )..". Must be string file location'")
    end

    self:closeHandle()
    loggingPath = path
    self:openHandle()
end

function log:setEnabled( enabled )
    self:closeHandle()

    loggingEnabled = enabled
    if enabled then self:openHandle() end
end

setmetatable( log, {__call = log.log})
_G.log = log
