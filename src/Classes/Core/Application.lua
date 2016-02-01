local oError
class "Application" alias "COLOUR_REDIRECT" mixin "MDaemon" {
    canvas = nil;
    hotkey = nil;
    timer = nil;
    event = nil;

    stages = {};

    changed = true;
    running = false;

    lastID = 0;
}

function Application:initialise( ... )
    -- Classes can be called with either a single table of arguments, or a series of required arguments. The latter only allows certain arguments.
    -- Here, we use the classUtil.lua functionality to parse the arguments passed to the application.
    if not exceptionHook.isHooked() then
        log("i", "Creating exception hook")
        exceptionHook.hook()
    end

    ParseClassArguments( self, { ... }, { { "width", "number" }, {"height", "number"} }, true )

    self.canvas = ApplicationCanvas( self, self.width, self.height )
    self.hotkey = HotkeyManager( self )
    self.event = EventManager( self, {
        ["mouse_up"] = MouseEvent;
        ["mouse_click"] = MouseEvent;
        ["mouse_scroll"] = MouseEvent;
        ["mouse_drag"] = MouseEvent;

        ["key"] = KeyEvent;
        ["key_up"] = KeyEvent;
        ["char"] = KeyEvent;
    });
    self.timer = TimerManager( self )

    --self.stages = {}
    self:__overrideMetaMethod( "__add", function( a, b ) -- only allows overriding certain metamethods.
        if classLib.typeOf( a, "Application", true ) then
            -- allows stages to be added into the instance via the sugar of (app + stage)
            if classLib.typeOf( b, "Stage", true ) then
                return self:addStage( b )
            else
                return error("Invalid right hand assignment ("..tostring( b )..")")
            end
        else
            return error("Invalid left hand assignment (" .. tostring( a ) .. ")")
        end
    end)

    self:clearLayerMap()
end

function Application:clearLayerMap()
    local layerMap = {}
    for i = 1, self.width * self.height do
        layerMap[ i ] = false
    end

    self.layerMap = layerMap
end

function Application:setTextColour( col )
    self.canvas.textColour = col
    self.textColour = col
end

function Application:setBackgroundColour( col )
    self.canvas.backgroundColour = col
    self.backgroundColour = col
end

function Application:addStage( stage )
    stage.application = self
    stage.mappingID = self.lastID + 1

    self.lastID = self.lastID + 1

    self.stages[ #self.stages + 1 ] = stage

    stage:map()
    return stage
end

function Application:removeStage( stageOrName )
    local isStage = classLib.typeOf( stageOrName, "Stage", true )
    for i = 1, #self.stages do
        local stage = self.stages[ i ]
        if ( isStage and stage == stageOrName ) or ( not isStage and stage.name == stageOrName ) then
            table.remove( self.stages, i )
            self.changed = true
            self.canvas:clear()

            break
        end
    end
end

function Application:draw( force )
    -- orders all stages to draw to the application canvas
    if (not self.changed and not force) then return end

    for i = #self.stages, 1, -1 do
        self.stages[ i ]:draw( force )
    end

    -- Then draw the application to screen
    self.canvas:drawToScreen( force )
    self.changed = false
end


function Application:run( thread )
    -- If present, execute the callback thread in parallel with the main event loop.
    log("i", "Attempting to start application")
    self.running = true
    self.hotkey:reset()

    local function engine()
        -- DynaCode main runtime loop
        local hk = self.hotkey
        local tm = self.timer

        if self.onRun then self:onRun() end

        self:draw( true )
        log("s", "Engine start successful. Running in protected mode")
        while self.running do

            -- If there is an outstanding stage re-order request then handle this now (move the new stage to the top of the stage table)
            if self.reorderRequest then
                log("i", "Reordering stage list")
                -- remove this stage from the table and re-insert it at the beggining.
                local stage = self.reorderRequest
                for i = 1, #self.stages do
                    if self.stages[i] == stage then
                        table.insert( self.stages, 1, table.remove( self.stages, i ) )
                        self:setStageFocus( stage )
                        break
                    end
                end
                self.reorderRequest = nil
            end


            term.setCursorBlink( false )
            self:draw()

            for i = 1, #self.stages do --< temporary 'for' loop
                self.stages[i]:appDrawComplete() -- stages may want to add a cursor blink on screen etc..
            end

            local event = self.event:create( { coroutine.yield() } )
            self.event:shipToRegistrations( event )

            if event.main == "KEY" then
                hk:handleKey( event )
                hk:checkCombinations()
            elseif event.main == "TIMER" then
                tm:update( event.raw[2] )
            end

            for i = 1, #self.stages do
                if self.stages[i] then
                    self.stages[i]:handleEvent( event )
                end
            end
        end
    end

    log("i", "Trying to start daemon services")
    local ok, err = xpcall( function() self:startDaemons() end, function( err )
        log("f", "Failed to start daemon services. Reason '" .. tostring( err ) .. "'")
        if self.errorHandler then
            self:errorHandler( err, false )
        else
            if self.onError then self:onError( err ) end
            error("Failed to start daemon service: "..err)
        end
    end)
    if ok then
        log("s", "Daemon service started")
    end


    log("i", "Starting engine")

    local _, err = xpcall( engine, function( err )
        log("f", "Engine error: '"..tostring( err ).."'")

        local last = exceptionHook.getLastThrownException()
        if last then
            log("eh", "Error '"..err.."' has been previously hooked by the trace system.")
        else
            log("eh", "Error '"..err.."' has not been hooked by the trace system. Last hook: "..tostring( last and last.rawException or nil ))
            -- virtual machine exception (like syntax, attempt to call nil etc...)

            exceptionHook.spawnException( LuaVMException( err, 4, true ) )
        end

        log("eh", "Gathering currently loaded classes")
        local str = ""
        local ok, _err = pcall( function()
            for name, class in pairs( classLib.getClasses() ) do
                str = str .. "- "..name.."\n"
            end
        end )

        if ok then
            log("eh", "Loaded classes at the time of crash: \n"..tostring(str))
        else
            log("eh", "ERROR: Failed to gather currently loaded classes (error: "..tostring( _err )..")")
        end

        if exceptionHook.isHooked() then
            log("eh", "Unhooking traceback")
            exceptionHook.unhook()
        end

        return err
    end )

    if err then
        if self.errorHandler then
            self:errorHandler( err, true )
        else
            local exception = exceptionHook.getLastThrownException()
            -- crashed
            term.setTextColour( colours.yellow )
            print("DynaCode has crashed")
            term.setTextColour( colours.red )
            print( exception and exception.displayName or err )
            print("")

            local function crashProcess( preColour, pre, fn, errColour, errPre, okColour, okMessage, postColour )
                term.setTextColour( preColour )
                print( pre )

                local ok, err = pcall( fn )
                if err then
                    term.setTextColour( errColour )
                    print( errPre .. err )
                else
                    term.setTextColour( okColour )
                    print( okMessage )
                end

                term.setTextColour( postColour )
            end

            local YELLOW, RED, LIME = colours.yellow, colours.red, colours.lime

            crashProcess( YELLOW, "Attempting to stop daemon service and children", function() self:stopDaemons( false ) end, RED, "Failed to stop daemon service: ", LIME, "Stopped daemon service", 1 )
            print("")

            crashProcess( YELLOW, "Attempting to write crash information to log file", function()
                log("f", "DynaCode crashed: "..err)
                if exception then log("f", exception.stacktrace) end
            end, RED, "Failed to write crash information: ", LIME, "Wrote crash information to file (stacktrace)", 1 )
            if self.onError then self:onError( err ) end
        end
    end
end

function Application:finish( thread )
    log("i", "Stopping Daemons")
    self:stopDaemons( true )

    log("i", "Stopping Application")
    self.running = false
    os.queueEvent("stop") -- if the engine is waiting for an event give it one so it can realise 'running' is false -> while loop finished -> exit and return.
    if type( thread ) == "function" then return thread() end
end

function Application:mapWindow( x1, y1, x2, y2 )
    -- Updates drawing map for windows. Prevents windows that aren't visible from drawing themselves (if they are covered by other windows)
    -- Also clears the area used by the window if the current window is not visible.


    local stages = self.stages
    local layers = self.layerMap

    for i = #stages, 1, -1 do -- This loop works backwards, meaning the stage at the top of the stack is ontop during drawing and mapping also.
        local stage = stages[ i ]

        local stageX, stageY = stage.X, stage.Y
        local stageWidth, stageHeight = stage.canvas.width, stage.canvas.height

        local width, height = self.width, self.height

        local stageX2, stageY2
        stageX2 = stageX + stageWidth
        stageY2 = stageY + stageHeight

        local stageVisible = stage.visible
        local ID = stage.mappingID

        if not (stageX > x2 or stageY > y2 or x1 > stageX2 or y1 > stageY2) then
            for y = math.max(stageY, y1), math.min(stageY2, y2) do
                if y > height or y < 1 then break end
                local yPos = self.width * ( y - 1 )

                for x = math.max(stageX, x1), math.min(stageX2, x2) do
                    if x <= width and x >= 1 then
                        local layer = layers[ yPos + x ]

                        if layer ~= ID and stageVisible and ( stage:isPixel( x - stageX + 1 , y - stageY + 1 ) ) then
                            layers[ yPos + x ] = ID
                        elseif layer == ID and not stageVisible then
                            layers[ yPos + x ] = false
                        end
                    end
                end
            end
        end
    end

    local buffer = self.canvas.buffer
    local width = self.width
    local layers = self.layerMap
    for y = y1, y2 do
        -- clear the unused pixels back to background colours.
        local yPos = width * ( y - 1 )

        for x = x1, x2 do
            local pos = yPos + x
            local layer = layers[ yPos + x ]
            if layer == false then
                if buffer[ pos ] then buffer[ pos ] = { false, false, false } end -- bg pixel. Anything may draw in this space.
            end
        end
    end
end

function Application:requestStageFocus( stage )
    -- queue a re-order of the stages.
    self.reorderRequest = stage
end

function Application:setStageFocus( stage )
    if not classLib.typeOf( stage, "Stage", true ) then return error("Expected Class Instance Stage, not "..tostring( stage )) end

    -- remove the current stage focus (if one)
    self:unSetStageFocus()

    stage:onFocus()
    self.focusedStage = stage
end

function Application:unSetStageFocus( stage )
    local stage = stage or self.focusedStage

    if self.focusedStage and self.focusedStage == stage then
        self.focusedStage:onBlur()
        self.focusedStage = nil
    end
end

function Application:getStageByName( name )
    local stages = self.stages

    for i = 1, #stages do
        local stage = stages[i]

        if stage.name == name then return stage end
    end
end

local function getFromDCML( path )
    return DCML.parse( DCML.loadFile( path ) )
end

function Application:appendStagesFromDCML( path )
    local data = getFromDCML( path )

    for i = 1, #data do
        local stage = data[i]
        if classLib.typeOf( stage, "Stage", true ) then
            self:addStage( stage )
        else
            return error("The DCML parser has created a "..tostring( stage )..". This is not a stage and cannot be added as such. Please ensure the DCML file '"..tostring( path ).."' only creates stages with nodes inside of them, not nodes by themselves. Refer to the wiki for more information")
        end
    end
end
