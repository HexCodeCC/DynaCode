local insert = table.insert
-- Stages have shadows when focused, these shadows are stored in the same buffer as the window. Because of this when a stage gains/looses a buffer the buffer should be resized accordingly.

local function submitEvent( event )
    -- sends event to nodes
end

local function handleClick( click )

end

local shadowB = false
class "Stage" alias "COLOUR_REDIRECT" {
    X = 1;
    Y = 1;

    width = 10;
    height = 6;

    --TODO: Proper borderless property.
    borderless = false;

    canvas = nil;

    application = nil;

    nodes = nil;

    name = nil;

    textColour = 1;
    backgroundColour = 32768;

    shadow = true;
    focused = false;

    closeButton = true;
    closeButtonTextColour = 1;
    closeButtonBackgroundColour = colours.red;
}

function Stage:initialise( ... )
    -- Every stage has a unique ID used to find it afterwards, this removes the need to loop every stage looking for the correct object.
    --TODO: Stage IDs

    local name, X, Y, width, height = ParseClassArguments( self, { ... }, { {"name", "string"}, {"X", "number"}, {"Y", "number"}, {"width", "number"}, {"height", "number"} }, true, true )

    self.canvas = StageCanvas( {width = width; height = height; textColour = self.textColour; backgroundColour = self.backgroundColour, stage = self} )

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
    self:shadowUpdated()
end

function Stage:shadowUpdated()
    -- if shadow is true and shadowB is false, expand the buffer
    if self.shadow and not shadowB then
        self.canvas.width = self.width + 1
        self.canvas:redrawFrame()
        shadowB = true
    elseif not self.shadow and shadowB then
        self.canvas.width = self.width
        self.canvas:redrawFrame()
        shadowB = false
    end
end

function Stage:setApplication( app )
    AssertClass( app, "Application", true, "Stage requires Application Instance as its application. Not '"..tostring( app ).."'")
    self.application = app
end

function Stage:draw()
    -- Firstly, clear the stage buffer and re-draw it.
    self.canvas:redrawFrame()
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

function Stage:handleEvent( event )
    submitEvent( event )
    --error( event )
    if event:isType("MOUSE", "CLICK") and not event.handled then
        -- is this on this stage?

        --TODO click detection, stage focusing, stage movement and resizing.
        if self:onPoint( event.X, event.Y ) then
            -- this click was on the stages hit area (not shadow)
            event.handled = true -- stop other stages from reacting to this event (or any other class actually)
            handleClick( event )
        end
    end
end
