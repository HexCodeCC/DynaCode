class "Application" alias "COLOUR_REDIRECT" mixin "MDaemon" mixin "MCanvas" mixin "MSubscriber" {
    canvas = nil;
    hotkey = nil;
    timer = nil;

    changed = true;
    running = false;

    lastID = 0;

    terminatable = true;

    threads = {};
    layerMap = {};
    stages = {}
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
    if not classLib.typeOf( stageObject, "Stage", true ) then
        return ParameterException("Cannot add stage to Application instance. Invalid object: '"..tostring( stageObject ).."'")
    end

    stageObject.application = self
    stageObject:map()

    table.insert( self.stages, stageObject )
end

function Application:removeStage( stageNameOrObject )
    local stages = self.stages
    local searchForName = type( stageNameOrObject ) == "string"

    local stage
    for i = 1, #stages do
        if ( searchForName and stage.name == stageNameOrObject ) or ( not searchForName and stage == stageNameOrObject ) then
            return table.remove( self.stages, i )
        end
    end
end

function Application:getStage( stageName )
    local stages, stage = self.stages

    for i = 1, #stages do
        stage = stages[ i ]

        if stage.name == stageName then
            return stage
        end
    end
end

function Application:mapStage( x1, y1, x2, y2 )
    local stages = self.stages
    local layers = self.layerMap

    local stage, stageX, stageY, stageX2, stageY2, stageVisible, ID
    for i = #stages, 1, -1 do
        stage = stages[ i ]

        stageX = stage.X
        stageY = stage.Y
        stageX2 = stageX + stage.canvas.width
        stageY2 = stageY + stage.canvas.height

        stageVisible = stage.visible
        ID = stage.mappingID

        if not (stageX > x2 or stageY > y2 or x1 > stageX2 or y1 > stageY2) then
            local yPos, layer
            for y = math.max(stageY, y1), math.min(stageY2, y2) do
                yPos = self.width * ( y - 1 )

                for x = math.max(stageX, x1), math.min(stageX2, x2) do
                    layer = layers[ yPos + x ]

                    if layer ~= ID and stageVisible and ( stage:isPixel( x - stageX + 1 , y - stageY + 1 ) ) then
                        layers[ yPos + x ] = ID
                    elseif layer == ID and not stageVisible then
                        layers[ yPos + x ] = false
                    end
                end
            end
        end
    end

    local buffer = self.canvas.buffer
    local width = self.width

    local yPos, pos, layer
    for y = y1, y2 do
        yPos = width * ( y - 1 )

        for x = x1, x2 do
            pos = yPos + x
            layer = layers[ yPos + x ]
            if layer == false then
                if buffer[ pos ] then buffer[ pos ] = { false, false, false } end -- bg pixel. Anything may draw in this space.
            end
        end
    end
end

function Application:requestStageFocus( stage )
    self.toReorder = stage
end

--[[
    Thread management
]]
function Application:createThread( threadFunction, name )
    if not ( type( threadFunction ) == "function" ) then
        return ParameterException("Failed to create Application Thread. Expected function to execute as thread.")
    end

    local thread = { name, coroutine.create( threadFunction ), false }

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

function Application:submitDaemonEvent( ... )

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
        local draw, submitThread, submitUI, submitDaemon = self.draw, self.submitThreadEvent, self.submitUIEvent, self.submitDaemonEvent -- quicker maybe (because of class system and proxies etc..)?

        while true do
            draw( self, self.forceRedraw )
            local event = { coroutine.yield() }

            submitDaemon( self, event )
            submitThread( self, unpack( event ) )
            submitUI( self, event )

            if event[1] == "terminate" and self.terminatable then
                Exception("Application terminated", 0)
            end

            local re = self.toReorder
            if re then
                local stages, stage = self.stages

                for i = 1, #stages do
                    stage = stages[ i ]

                    if stage == re then
                        table.insert( stages, 1, table.remove( stages, i ) )
                        self.stageFocus = re
                        break
                    end
                end
                self.toReorder = nil
            end
        end
    end

    self:call( "start", ... )
    local ok, err = pcall( engine )
    print("OK: "..tostring( ok )..", error: "..tostring( err ))
end

function Application:stop()
    self:call( "stop", true )
end

function Application:setStageFocus( stage )
    if not classLib.typeOf( stage, "Stage", true ) then return ParameterException("Expected Class Instance Stage, not "..tostring( stage )) end

    self:unSetStageFocus()

    stage:onFocus()
    self.focusedStage = stage
end

function Application:unSetStageFocus()

    if self.focusedStage then
        self.focusedStage:onBlur()
        self.focusedStage = nil
    end
end
