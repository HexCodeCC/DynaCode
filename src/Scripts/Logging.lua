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
}
local clearWhenLow = true
local clearWhen = 50000

local loggingIntroString = [[
--@@== DynaCode Logging ==@@--


Log Start >
]]

local log = {}
function log:log( mode, message )
    if not (loggingEnabled and loggingPath and mode and message) then return end

    if clearWhenLow and fs.getSize( loggingPath ) >= clearWhen then
        self:clearLog()

        local f = fs.open( loggingPath, "w" )
        f.write([[
--@@== DynaCode Logging ==@@--

This file was cleared at os time ']] .. os.clock() .. [[' to reduce file size.


Log Resume >
]])
        f.close()
    end

    local f = fs.open( loggingPath, "a" )
    f.write( "["..os.clock().."][".. ( loggingModes[ mode ] or mode ) .."] > " .. message .. "\n" )
    f.close()
end

function log:registerMode( short, long )
    loggingModes[ short ] = long
end

function log:setLoggingEnabled( bool )
    loggingEnabled = bool
end

function log:getEnabled() return loggingEnabled end

function log:setLoggingPath( path )
    -- clear the path
    loggingPath = path
    self:clearLog( true )
end

function log:getLoggingPath() return loggingPath end

function log:clearLog( intro )
    if not loggingPath then return end

    local f = fs.open( loggingPath, "w" )
    if intro then
        f.write( loggingIntroString )
    end
    f.close()
end

setmetatable( log, {__call = log.log})
_G.log = log
