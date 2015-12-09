abstract class "MDaemon" -- this class is used for mixin(s) only.

function MDaemon:registerDaemon( service )
    -- name -> string
    -- service -> daemonService (class extending Daemon)
    if not class.isInstance( service ) or not service.__daemon then
        return error("Cannot register daemon '"..tostring( service ).."' ("..type( service )..")")
    end

    if not service.name then return error("Daemon '"..service:type().."' has no name!") end
    log("di", "Registered daemon of type '"..service:type().."' (name "..service.name..") to "..self:type())

    service.owner = self
    table.insert( self.__daemons, service )
end

function MDaemon:removeDaemon( name )
    if not name then return error("Cannot un-register daemon with no name to search") end
    local daemons = self.__daemons

    for i = 1, #daemons do
        local daemon = daemons[i]
        if daemon.name == name then
            log("di", "Removed daemon of type '"..daemon:type().."' (name "..daemon.name..") from "..self:type()..". Index "..i)
            table.remove( self.__daemons, i )
        end
    end
end

function MDaemon:shipToDaemons( event )
    for i = 1, #self.__daemons do
        self.__daemons[i]:handleEvent( event )
    end
end

function MDaemon:get__daemons()
    if type( self.__daemons ) ~= "table" then
        self.__daemons = {}
    end
    return self.__daemons
end

function MDaemon:startDaemons()
    local daemons = self.__daemons

    for i = 1, #daemons do
        daemons[i]:start()
    end
end

function MDaemon:stopDaemons( graceful )
    local daemons = self.__daemons

    for i = 1, #daemons do
        daemons[i]:stop( graceful )
    end
end
