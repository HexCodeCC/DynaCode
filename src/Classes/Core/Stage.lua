local insert = table.insert
local sub = string.sub
-- Stages have shadows when focused, these shadows are stored in the same buffer as the window. Because of this when a stage gains/looses a buffer the buffer should be resized accordingly.

local shadowB = false
class "Stage" alias "COLOUR_REDIRECT" {
    X = 1;
    Y = 1;

    width = 10;
    height = 6;

    borderless = false;

    canvas = nil;

    application = nil;

    nodes = nil;

    name = nil;

    textColour = 1;
    backgroundColour = 32768;

    shadow = true;
    shadowColour = colours.grey;

    focused = false;

    closeButton = true;
    closeButtonTextColour = 1;
    closeButtonBackgroundColour = colours.red;

    controller = nil;
}

function Stage:initialise( ... )
    -- Every stage has a unique ID used to find it afterwards, this removes the need to loop every stage looking for the correct object.
    local name, X, Y, width, height = ParseClassArguments( self, { ... }, { {"name", "string"}, {"X", "number"}, {"Y", "number"}, {"width", "number"}, {"height", "number"} }, true, true )

    self.canvas = StageCanvas( {width = width; height = height; textColour = self.textColour; backgroundColour = self.backgroundColour, stage = self} )

    self.controller = {}
    self.X = X
    self.Y = Y
    self.name = name

    self.width = width
    self.height = height

    self:__overrideMetaMethod("__add", function( a, b )
        if class.typeOf(a, "Stage", true) then
            if class.isInstance( b ) and b.__node then
                -- add b (node) to a (stage)
                return self:addNode( b )
            else
                return error("Invalid right hand assignment. Should be instance of DynaCode node. "..tostring( b ))
            end
        else
            return error("Invalid left hand assignment. Should be instance of Stage. "..tostring( b ))
        end
    end)

    self.nodes = {}
    self:updateCanvasSize()
end

function Stage:updateCanvasSize()
    if not self.canvas then return end
    local offset = 0
    if self.shadow then offset = 1 end

    self.canvas.width = self.width + offset
    self.canvas.height = self.height + offset + ( not self.borderless and 1 or 0 )

    self.canvas:redrawFrame()
end

function Stage:setShadow( bool )
    self.shadow = bool
    self:updateCanvasSize()
end

function Stage:setBorderless( bool )
    self.borderless = bool
    self:updateCanvasSize()
end

function Stage:setHeight( height )
    self.height = height
    self:updateCanvasSize()
end

function Stage:setWidth( width )
    self.width = width
    self:updateCanvasSize()
end

function Stage:setApplication( app )
    AssertClass( app, "Application", true, "Stage requires Application Instance as its application. Not '"..tostring( app ).."'")
    self.application = app
end

function Stage:draw()
    -- Firstly, clear the stage buffer and re-draw it.
    if self.forceRedraw then self.canvas:redrawFrame() end
    -- order all nodes to re-draw themselves
    for i = 1, #self.nodes do
        self.nodes[ i ]:draw()
    end

    -- draw this stages contents to the application canvas
    self.canvas:drawToCanvas( self.application.canvas, self.X, self.Y )
end

function Stage:addNode( node )
    -- add this node
    node.stage = self
    insert( self.nodes, node )
    return node
end

function Stage:setFocused( bool )

end

function Stage:hitTest( x, y )
    return InArea( x, y, self.X, self.Y, self.X + self.width - 1, self.Y + self.height - 1 )
end

function Stage:submitEvent( event )
    local nodes = self.nodes

    if event.main == "MOUSE" then
        -- convert X and Y to relative co-ords.
        event:convertToRelative( self )
        if not self.borderless then
            event.Y = event.Y - 1
        end
    end

    for i = 1, #nodes do
        nodes[ i ]:handleEvent( event )
    end
end

function Stage:handleClick( event )

end

function Stage:handleEvent( event )
    self:submitEvent( event )
    if event:isType("MOUSE", "CLICK") and not event.handled then
        -- is this on this stage?

        --TODO click detection, stage focusing, stage movement and resizing. *job feature/event-detection*
        if self:hitTest( event.X, event.Y ) then
            -- this click was on the stages hit area (not shadow)
            event.handled = true -- stop other stages from reacting to this event (or any other class actually)
            self:handleClick( event )
        end
    end
end

function Stage:mapNode( x1, y1, x2, y2 )
    -- functions similarly to Application:mapWindow.
end

function Stage:mapToApp()
    local canvas = self.canvas

    self.application:mapWindow( self.X, self.Y, self.X + canvas.width, self.Y + canvas.height )
end

local function getFromDCML( path )
    return DCML.parse( DCML.loadFile( path ) )
end
function Stage:replaceWithDCML( path )
    local data = getFromDCML( path )

    for i = 1, #self.nodes do
        local node = self.nodes[i]
        node.stage = nil

        table.remove( self.nodes, i )
    end

    for i = 1, #data do
        data[i].stage = self
        table.insert( self.nodes, data[i] )
    end
end

function Stage:appendFromDCML( path )
    -- TODO
end

function Stage:removeKeyboardFocus( from )
    local current = self.currentKeyboardFocus
    if current and current == from then
        current.acceptKeyboard = false
        if current.onFocusLost then current:onFocusLost( self, node ) end

        self.currentKeyboardFocus = false
    end
end

function Stage:redirectKeyboardFocusHere( node )
    self:removeKeyboardFocus( self.currentKeyboardFocus )
    
    node.acceptKeyboard = true
    self.currentKeyboardFocus = node
    if node.onFocusGain then self.currentKeyboardFocus:onFocusGain( self ) end
end

--[[ Controller ]]--
function Stage:addToController( name, fn )
    if type( name ) ~= "string" or type( fn ) ~= "function" then
        return error("Expected string, function")
    end
    self.controller[ name ] = fn
end

function Stage:removeFromController( name )
    self.controller[ name ] = nil
end

function Stage:getCallback( name )
    name = sub( name, 2 )
    return self.controller[ name ]
end

function Stage:executeCallback( name, ... )
    local cb = self:getCallback( name )
    if cb then
        local args = { ... }
        return cb( ... )
    else
        return error("Failed to find callback "..tostring( sub(name, 2) ).." on controller (node.stage): "..tostring( self ))
    end
end
