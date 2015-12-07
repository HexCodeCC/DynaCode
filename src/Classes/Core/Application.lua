local running
local debug = true -- Allows reboot and application exit using keys. (\ for reboot, / for application close)

class "Application" alias "COLOUR_REDIRECT" {
    canvas = nil;
    hotkey = nil;
    schedule = nil;
    timer = nil;
    event = nil;

    stages = nil;

    changed = true
}

function Application:initialise( ... )
    -- Classes can be called with either a single table of arguments, or a series of required arguments. The latter only allows certain arguments.
    -- Here, we use the classUtil.lua functionality to parse the arguments passed to the application.

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
    })
    --[[self.schedule = ApplicationScheduler( self )
    self.timer = TimeManager( self )]]

    self.stages = {}
    self:__overrideMetaMethod( "__add", function( a, b ) -- only allows overriding certain metamethods.
        if class.typeOf( a, "Application", true ) then
            -- allows stages to be added into the instance via the sugar of (app + stage)
            if class.typeOf( b, "Stage", true ) then
                return self:addStage( b )
            else
                return error("Invalid right hand assignment ("..tostring( b )..")")
            end
        else
            return error("Invalid left hand assignment (" .. tostring( a ) .. ")")
        end
    end)
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
    --stage.ID = (type( stage )):sub( 8 )

    self.stages[ #self.stages + 1 ] = stage
    return stage
end

function Application:removeStage( stageOrName )
    local isStage = class.typeOf( stageOrName, "Stage", true )
    for i = 1, #self.stages do
        local stage = self.stages[ i ]
        if ( isStage and stage == stageOrName ) or ( not isStage and stage.name and stage.name == stageOrName ) then
            table.remove( self.stages, i )
        end
    end
end

function Application:draw()
    -- orders all stages to draw to the application canvas
    --if not self.changed then return end

    for i = 1, #self.stages do
        self.stages[ i ]:draw()
    end

    -- Then draw the application to screen
    self.canvas:drawToScreen()
    self.changed = false
end

function Application:run( thread )
    -- If present, exectute the callback thread in parallel with the main event loop.
    running = true

    local function engine()
        -- DynaCode main runtime loop
        while running do
            self:draw()
            local ev = { coroutine.yield() } -- more direct version of os.pullEventRaw
            local event = self.event:create( ev )

            if event.main == "KEY" and ev[1] == "char" then
                error("Application fatal exception: Invalid event created, expected char event")
            end

            if debug then if ev[1] == "char" and ev[2] == "\\" then os.reboot() elseif ev[1] == "char" and ev[2] == "/" then self:finish() end end

            -- Pass the event to stages and process through any application daemons
            for i = 1, #self.stages do
                self.stages[i]:handleEvent( event )
            end
        end
    end

    if type(thread) == "function" then
        ok, err = pcall( function() parallel.waitForAll( engine, thread ) end )
    else
        ok, err = pcall( engine )
    end

    if not ok and err then
        -- crashed
        term.setTextColour( colours.yellow )
        print("DynaCode has crashed")
        term.setTextColour( colours.red )
        print( err )
        term.setTextColour( 1 )
    end
end

function Application:finish( thread )
    running = false
    os.queueEvent("stop") -- if the engine is waiting for an event give it one so it can realise 'running' is false -> while loop finished -> exit and return.
    if type( thread ) == "function" then thread() end
end

function Application:mapWindow( x1, y1, x2, y2 )
    -- Updates drawing map for windows. Prevents windows that aren't visible from drawing themselves (if they are covered by other windows)
    -- Also clears the area used by the window if the current window is not visible.
end
