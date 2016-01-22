local insert = table.insert
local sub = string.sub

--[[DCML.registerTag("Stage", {
    childHandler = function( self, element ) -- self = instance (new)
        -- the stage has children, create them using the DCML parser and add them to the instance.
        self.nodesToAdd = DCML.parse( element.content )
    end;
    onDCMLParseComplete = function( self )
        local nodes = self.nodesToAdd

        if nodes then
            for i = 1, #nodes do
                local node = nodes[i]

                self:addNode( node )
                if node.nodesToAdd and type( node.resolveDCMLChildren ) == "function" then
                    node:resolveDCMLChildren()
                end
            end

            self.nodesToAdd = nil
        end
    end;
    argumentType = {
        X = "number";
        Y = "number";
        width = "number";
        height = "number";
    },
})]]
local NO_REDRAW_ON_STAGE_AJUDST = true -- Stage contents will not be drawn while the stage has 'mouseMode' set (resize/move mode)

class "Stage" mixin "MTemplateHolder" alias "COLOUR_REDIRECT" {
    X = 1;
    Y = 1;

    width = 10;
    height = 6;

    borderless = false;

    canvas = nil;

    application = nil;

    scenes = {};
    activeScene = nil;

    name = nil;

    textColour = 32768;
    backgroundColour = 1;

    shadow = true;
    shadowColour = colours.grey;

    focused = false;

    closeButton = true;
    closeButtonTextColour = 1;
    closeButtonBackgroundColour = colours.red;

    titleBackgroundColour = 128;
    titleTextColour = 1;
    activeTitleBackgroundColour = colours.lightBlue;
    activeTitleTextColour = 1;

    controller = {};

    mouseMode = nil;

    visible = true;

    resizable = true;
    movable = true;
    closeable = true;
}

function Stage:initialise( ... )
    -- Every stage has a unique ID used to find it afterwards, this removes the need to loop every stage looking for the correct object.
    local name, X, Y, width, height = ParseClassArguments( self, { ... }, { {"name", "string"}, {"X", "number"}, {"Y", "number"}, {"width", "number"}, {"height", "number"} }, true, true )

    self.X = X
    self.Y = Y
    self.name = name

    self.canvas = StageCanvas( {width = width; height = height; textColour = self.textColour; backgroundColour = self.backgroundColour, stage = self} )

    self.width = width
    self.height = height

    self:__overrideMetaMethod("__add", function( a, b )
        if classLib.typeOf(a, "Stage", true) then
            if classLib.typeOf( b, "Scene", true ) then
                return self:addScene( b )
            else
                error("Invalid right hand assignment. Should be instance of Scene "..tostring( b ))
            end
        else
            error("Invalid left hand assignment. Should be instance of Stage. "..tostring( a ))
        end
    end)

    self:updateCanvasSize()
    --self.canvas:redrawFrame()

    self.mouseMode = false
end

function Stage:updateCanvasSize()
    if not self.canvas then return end
    local offset = 0
    if self.shadow and self.focused then offset = 1 end

    self.canvas.width = self.width + offset
    self.canvas.height = self.height + offset + ( not self.borderless and 1 or 0 )

    self.canvas:clear()
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
    local mH = self.maxHeight
    local bH = self.minHeight

    height = mH and height > mH and mH or height
    height = bH and height < bH and bH or height

    self.height = height > 0 and height or 1
    self:updateCanvasSize()
end

function Stage:setWidth( width )
    local mW = self.maxWidth
    local bW = self.minWidth

    width = mW and width > mW and mW or width
    width = bW and width < bW and bW or width
    self.width = width > 0 and width or 1
    self:updateCanvasSize()
end

function Stage:setApplication( app )
    AssertClass( app, "Application", true, "Stage requires Application Instance as its application. Not '"..tostring( app ).."'")
    self.application = app
end

function Stage:draw( _force )
    -- Firstly, clear the stage buffer and re-draw it.
    if not self.visible then return end

    local changed = self.changed
    local force = _force or self.forceRedraw
    local mm = self.mouseMode

    if force then
        self.canvas:clear()
        self.canvas:redrawFrame()
        self.forceRedraw = false
    end

    local canvas = self.canvas

    if (changed or force) and ( NO_REDRAW_ON_STAGE_AJUDST and not mm or not NO_REDRAW_ON_STAGE_AJUDST ) then
        local nodes = self.nodes
        for i = #nodes, 1, -1 do
            local node = nodes[i]
            if changed and node.changed or force then
                node:draw( 0, 0, force )
                node.canvas:drawToCanvas( canvas, node.X, node.Y )

                node.changed = false
            end
        end
        self.changed = false
    end

    -- draw this stages contents to the application canvas
    self.canvas:drawToCanvas( self.application.canvas, self.X, self.Y )
end

function Stage:appDrawComplete()
    if self.currentKeyboardFocus and self.focused then
        local enabled, X, Y, tc = self.currentKeyboardFocus:getCursorInformation()
        if not enabled then return end

        term.setTextColour( tc )
        term.setCursorPos( X, Y )
        term.setCursorBlink( true )
    end
end

function Stage:hitTest( x, y )
    return InArea( x, y, self.X, self.Y, self.X + self.width - 1, self.Y + self.height - ( self.borderless and 1 or 0 ) )
end

function Stage:isPixel( x, y )
    local canvas = self.canvas

    if self.shadow then
        if self.focused then
            return not ( x == self.width + 1 and y == 1 ) or ( x == 1 and y == self.height + ( self.borderless and 0 or 1 ) + 1 )
        else
            return not ( x == self.width + 1 ) or ( y == self.height + ( self.borderless and 0 or 1 ) + 1 )
        end
    elseif not self.shadow then return true end

    return false
end

function Stage:submitEvent( event )
    local nodes = self.nodes
    local main = event.main

    local oX, oY
    if main == "MOUSE" then
        -- convert X and Y to relative co-ords.
        oX, oY = event.X, event.Y
        event:convertToRelative( self ) -- convert to relative, but revert this later so other stages aren't using relative co-ords.
        if not self.borderless then
            event.Y = event.Y - 1
        end
    end

    for i = 1, #nodes do
        nodes[ i ]:handleEvent( event )
    end
    if main == "MOUSE" then
        event.X, event.Y = oX, oY -- convert back to global because other stages may need to use this event.
    end
end

function Stage:move( newX, newY )
    self:removeFromMap()
    self.X = newX
    self.Y = newY
    self:map()

    self.application.changed = true
end

function Stage:resize( nW, nH )
    self:removeFromMap()

    self.width = nW
    self.height = nH
    self.canvas:redrawFrame()

    self:map()

    self.forceRedraw = true
    self.application.changed = true
end

function Stage:focus()
    if self.focused then return end
    self.application:requestStageFocus( self )
end

function Stage:close()
    self:removeFromMap()
    self.application:removeStage( self )
end

function Stage:handleEvent( event )
    -- If the event is already handled ignore it.
    if event.handled then return end
    local borderOffset = self.borderless and 0 or 1

    if event.main == "MOUSE" then
        -- Handle the event
        if event.sub == "CLICK" then
            if event:inArea( self.X, self.Y, self.X + self.width - 1, self.Y + self.height - ( self.borderless and 1 or 0 ) ) then
                local X, Y = event:getRelative( self )
                self:focus()

                if Y == 1 then
                    if X == self.width then
                        return self:close()
                    else
                        self.mouseMode = "move"
                        self.lastX, self.lastY = event.X, event.Y
                        return
                    end
                elseif Y == self.height + borderOffset and X == self.width then
                    self.mouseMode = "resize"
                    return
                end
            end
        elseif event.sub == "UP" and self.mouseMode then
            self.mouseMode = false
            return
        elseif event.sub == "DRAG" and self.mouseMode then
            if self.mouseMode == "move" then
                self:move( self.X + ( event.X - self.lastX ), self.Y + ( event.Y - self.lastY ) )
                self.lastMouseEvent = os.clock()
                self.lastX, self.lastY = event.X, event.Y
            elseif self.mouseMode == "resize" then
                self:resize( event.X - self.X + 1, event.Y - self.Y + ( self.borderless and 1 or 0 ) )
                self.lastMouseEvent = os.clock()
            end
        end
        self:submitEvent( event )
    else self:submitEvent( event ) end
end

function Stage:setMouseMode( mode )
    self.mouseMode = mode
    self.canvas:redrawFrame()
end

function Stage:mapNode( x1, y1, x2, y2 )
    -- functions similarly to Application:mapWindow.
end

function Stage:map()
    local canvas = self.canvas

    self.application:mapWindow( self.X, self.Y, self.X + canvas.width - 1, self.Y + canvas.height - 1 )
end

function Stage:removeFromMap()
    local oV = self.visible

    self.visible = false
    self:map()
    self.visible = oV
end

function Stage:removeKeyboardFocus( from )
    local current = self.currentKeyboardFocus
    if current and current == from then
        if current.onFocusLost then current:onFocusLost( self, node ) end

        self.currentKeyboardFocus = false
    end
end

function Stage:redirectKeyboardFocus( node )
    self:removeKeyboardFocus( self.currentKeyboardFocus )

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
    return self.controller[ sub( name, 2 ) ]
end

function Stage:executeCallback( name, ... )
    local cb = self:getCallback( name )
    if cb then return cb( ... ) else
        return error("Failed to find callback "..tostring( sub(name, 2) ).." on controller (node.stage): "..tostring( self ))
    end
end

function Stage:onFocus()
    self.forceRedraw = true
    -- the application has granted focus to this stage. Create a shadow if required and update colour sheet.
    self.focused = true
    self.changed = true

    self:removeFromMap()
    self:updateCanvasSize()

    self:map()
    self.canvas:updateFilter()
    self.canvas:redrawFrame()
end

function Stage:onBlur()
    self.forceRedraw = true
    -- the application revoked focus, remove any shadows and grey out stage
    self.focused = false
    self.changed = true

    self:removeFromMap()
    self:updateCanvasSize()

    self:map()
    self.canvas:updateFilter()
    self.canvas:redrawFrame()
end

function Stage:setChanged( bool )
    self.changed = bool
    if bool then self.application.changed = true end
end
