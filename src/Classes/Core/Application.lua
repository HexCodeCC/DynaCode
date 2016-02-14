class "Application" alias "COLOUR_REDIRECT" mixin "MDaemon" mixin "MCanvas" mixin "MSubscriber" {
    canvas = nil;
    hotkey = nil;
    timer = nil;
    event = nil;

    stages = {};

    changed = true;
    running = false;

    lastID = 0;

    terminatable = true;

    threads = {}
}

function Application:initialise( ... )
    ParseClassArguments( self, { ... }, { { "width", "number" }, {"height", "number"} }, true )

    if not exceptionHook.isHooked() then
        log("i", "Creating exception hook")
        exceptionHook.hook()
    end

    self.canvas = ApplicationCanvas( self, self.width, self.height )
    self.hotkey = HotkeyManager( self )
    self.timer = TimerManager( self )

    self:__overrideMetaMethod( "__add", function( a, b )
        if classLib.typeOf( a, "Application", true ) then
            if classLib.typeOf( b, "Stage", true ) then
                return self:addStage( b )
            else
                return ParameterException("Invalid right hand assignment ("..tostring( b )..")")
            end
        else
            return ParameterException("Invalid left hand assignment (" .. tostring( a ) .. ")")
        end
    end)
end

--[[
    Stage management
]]

function Application:addStage( stageObject )

end

function Application:removeStage( stageNameOrObject )

end

function Application:getStage( stageName )

end

--[[
    Thread management
]]
function Application:createThread( threadFunction, name )
    if not ( type( threadFunction ) == "function" ) then
        return ParameterException("Failed to create Application Thread. Expected function to execute as thread.")
    end

    local thread = {
        name, -- name
        coroutine.create( threadFunction ), -- the coroutine
        false -- the coroutines event filter
    }

    return table.insert( self.threads, thread )
end

function Application:destroyThread( t )
    local searchForName = type( t ) == "string"
    local threads = self.threads

    local thread
    for i = #threads, 1, -1 do
        thread = threads[ i ]

        if ( searchForName and thread[1] == t ) or ( not searchForName and thread == t ) then
            thread[2] = false

            table.remove( self.threads, i )
        end
    end
end



--[[
    Miscellaneous
]]
function Application:submitUIEvent( event )
    self:call( event[1] )

    local dEvent = spawnEvent( event )
    local stages = self.stages

    local stage
    for i = 1, #stages do
        stages[ i ]:handleEvent( dEvent )
    end
end

function Application:submitThreadEvent( ... )
    local threads = self.threads
    local raw = { ... }

    local thread
    for i = 1, #threads do
        thread = threads[ i ]

        if not thread[ 3 ] or thread[ 3 ] == raw[ 1 ] or raw[ 1 ] == "terminate" then
            local ok, param = coroutine.resume( thread[2], ... )
            if not ok and param then
                log( "e", "Thread '"..tostring(thread[1]).."' crashed, debug information follows. ok: "..tostring( ok )..", error: "..tostring( param )..", status: "..coroutine.status( thread[2] ) )
                self:call( "thread_crash", thread, ok, param )

                self:destroyThread( thread )
            elseif ok then
                if coroutine.status( thread[2] ) == "dead" then
                    log( "s", "Thread '"..tostring(thread[1]).."' finished without exception" )

                    self:call( "thread_finish", thread )
                    self:destroyThread( thread )
                else
                    thread[ 3 ] = param
                end
            end
        end
    end
end

function Application:draw( force )
    if not self.changed and not force then return end
    local stages, stage = self.stages

    for i = #stages, 1, -1 do
        stage = stages[ i ]

        stage:draw( force )
    end

    self.canvas:drawToScreen( force )
    self.changed = false
end

function Application:start( ... )
    local function engine()
        -- Listen for events, submit to threads and stages when caught.
        local draw, submitThread, submitUI = self.draw, self.submitThreadEvent, self.submitUIEvent -- quicker maybe (because of class system and proxies etc..)?
        while true do
            draw( self )
            local event = { coroutine.yield() }

            if event[1] == "terminate" and self.terminatable then
                Exception("Application terminated", 0)
            end

            submitThread( self, unpack( event ) )
            submitUI( self, event )
        end
    end
    
    self:call( "start", ... )
    engine()
end

function Application:stop()
    self:call( "stop", true )
end
