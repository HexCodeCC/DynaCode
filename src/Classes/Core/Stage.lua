local insert = table.insert
local sub = string.sub

DCML.registerTag("Stage", {
    childHandler = function( self, raw )
        -- Because we need the Stage to be ready for us (properties assigned) we wait until everyone is ready before adding nodes incrementally.
        self.toFinishParsing = DCML.parse( raw.content )
    end;
    onDCMLParseComplete = function( self )
        local element = self.toFinishParsing

        for i = 1, #element do
            local node = element[ i ]
            -- If its not a template throw an exception.

            if classLib.typeOf( node, "Template", true ) then
                -- Add the Template
                self:registerTemplate( node )

                if node.toFinishParsing and type( node.resolveDCMLChildren ) == "function" then
                    node:resolveDCMLChildren()
                end

                if node.active then
                    self.activeTemplate = node
                end
            else
                DCMLParseException("Failed to parse DCML for Stage creation. '"..tostring( node ).."' was found inside a Stage (should be inside a Template)")
            end
        end
        self.toFinishParsing = nil
    end;
    argumentType = {
        X = "number";
        Y = "number";
        width = "number";
        height = "number";
    },
})

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

    noRedrawOnStageAdjust = false;
}

function Stage:initialise( ... )
    -- Every stage has a unique ID used to find it afterwards, this removes the need to loop every stage looking for the correct object.
    local X, Y, width, height = ParseClassArguments( self, { ... }, {{"X", "number"}, {"Y", "number"}, {"width", "number"}, {"height", "number"} }, true, true )

    self.X = X
    self.Y = Y

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
    local hotkey = self.application.hotkey

    local changed = self.changed
    local force = _force or self.forceRedraw
    local mm = self.mouseMode
    local noRedrawOnStageAdjust = self.noRedrawOnStageAdjust

    if force then
        self.canvas:clear()
        self.canvas:redrawFrame()
        self.forceRedraw = false
    end

    local canvas = self.canvas

    if (changed or force) and ( not mm or ( ( mm and noRedrawOnStageAdjust and hotkey.keys.shift ) or ( mm and not noRedrawOnStageAdjust and not hotkey.keys.shift ) ) ) then
        local nodes = self.nodes
        for i = #nodes, 1, -1 do
            local node = nodes[i]
            if node.changed or changed or force then
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
        term.setCursorPos( X + self.X - 1, Y + self.Y - (self.borderless and 1 or 0) )
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
            return not (( x == self.width + 1 and y == 1 ) or ( x == 1 and y == self.height + ( self.borderless and 0 or 1 ) + 1 ))
        else
            return not (( x == self.width + 1 ) or ( y == self.height + ( self.borderless and 0 or 1 ) + 1 ))
        end
    elseif not self.shadow then return true end

    return false
end

function Stage:submitEvent( event )
    if not self.focused then return end
    local nodes = self.nodes
    local main = event.main

    local oX, oY, oPb
    if main == "MOUSE" then
        oPb = event.inParentBounds
        event.inParentBounds = event:isInNode( self )

        -- convert X and Y to relative co-ords.
        oX, oY = event:getPosition()
        event:convertToRelative( self ) -- convert to relative, but revert this later so other stages aren't using relative co-ords.
        if not self.borderless then
            event.Y = event.Y - 1
        end
    end

    for i = 1, #nodes do
        nodes[ i ]:handleEvent( event )
    end
    if main == "MOUSE" then
        event.X, event.Y, event.inParentBounds = oX, oY, oPb -- convert back to global because other stages may need to use this event.
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

    if type( self.onResize ) == "function" then
        self:onResize()
    end

    local nodes, anchor = self.nodes
    for i = 1, #nodes do
        nodes[ i ]:onParentResize()
    end
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
        local inNode = event:inArea( self.X, self.Y, self.X + self.width - 1, self.Y + self.height - ( self.borderless and 1 or 0 ) )
        -- Handle the event
        if event.sub == "CLICK" then
            if inNode then
                local X, Y = event:getRelative( self )
                self:focus()

                if Y == 1 then
                    if X == self.width then
                        event.handled = true
                        return self:close()
                    else
                        self.mouseMode = "move"
                        self.lastX, self.lastY = event.X, event.Y

                        event.handled = true
                        return
                    end
                elseif Y == self.height + borderOffset and X == self.width then
                    self.mouseMode = "resize"

                    event.handled = true
                    return
                end
            end
        elseif event.sub == "UP" and self.mouseMode then
            self.mouseMode = false
            event.handled = true
            return
        elseif event.sub == "DRAG" and self.mouseMode then
            if self.mouseMode == "move" then
                self:move( self.X + ( event.X - self.lastX ), self.Y + ( event.Y - self.lastY ) )
                self.lastX, self.lastY = event.X, event.Y

                event.handled = true
            elseif self.mouseMode == "resize" then
                self:resize( event.X - self.X + 1, event.Y - self.Y + ( self.borderless and 1 or 0 ) )

                event.handled = true
            end
        end
        self:submitEvent( event )
        if inNode then event.handled = true end
    else self:submitEvent( event ) end
end

function Stage:setMouseMode( mode )
    self.mouseMode = mode
    self.canvas:redrawFrame()
    self.changed = true
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
    if bool and self.application then self.application.changed = true end
end

function Stage:getNodes()
    if self.activeTemplate then
        return self.activeTemplate.nodes
    else
        return {}
    end
end
