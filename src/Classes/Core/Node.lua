abstract class "Node" alias "COLOUR_REDIRECT" {
    X = 1;
    Y = 1;

    width = 0;
    height = 0;

    visible = true;
    enabled = true;

    changed = true;

    stage = nil;

    canvas = nil;

    __node = true;

    eventConfig = {
        ["MouseEvent"] = {
            acceptAll = false
        };
        acceptAll = false;
        acceptMisc = false;
        acceptKeyboard = false;
        acceptMouse = false;
        manuallyHandle = false;
    }
}

function Node:initialise( ... )
    local X, Y, width, height = ParseClassArguments( self, { ... }, { { "X", "number" }, { "Y", "number" }, { "width", "number" }, { "height", "number" } }, false, true )

    -- Creates a NodeCanvas
    self.canvas = NodeCanvas( self, width or 1, height and (height - 1) or 0 )

    self.X = X
    self.Y = Y
    self.width = width or 1
    self.height = height or 1
end

function Node:draw( xO, yO )
    -- Call any draw functions on the node (pre, post) and update its 'changed' state. Then draw the nodes canvas to the stages canvas
    if self.preDraw then
        self:preDraw( xO, yO )
    end

    if self.postDraw then
        self:postDraw( xO, yO )
    end
end

function Node:setX( x )
    self.X = x
end

function Node:setY( y )
    self.Y = y
end

function Node:setWidth( width )
    --TODO Update canvas width *job release-0*
    self.width = width
end

function Node:setHeight( height )
    --TODO set height on instance and canvas. *job release-0*
    self.height = height
end

function Node:setBackgroundColour( col )
    --TODO force update on children too (if they are using the nodes color as default) *job release-0*
    self.backgroundColour = col
end

function Node:setTextColour( col )
    --TODO force update on children too (if they are using the nodes color as default) *job release-0*
    self.textColour = col
end

function Node:onParentChanged()
    self.changed = true
end

local function call( self, callback, ... )
    if type( self[ callback ] ) == "function" then
        self[ callback ]( self, ... )
    end
end

local clickMatrix = {
    CLICK = "onMouseDown";
    UP = "onMouseUp";
    SCROLL = "onMouseScroll";
    DRAG = "onMouseDrag";
}
function Node:handleEvent( event )
    -- Automatically fires callbacks on the node depending on the event. For example onMouseMiss, onMouseDown, onMouseUp etc...
    if event.handled then return end

    if not self.manuallyHandle then
        if event.main == "MOUSE" and self.acceptMouse then
            if event:inArea( self.X, self.Y, self.X + self.width - 1, self.Y + self.height - 1 ) then
                call( self, clickMatrix[ event.sub ] or error("No click matrix entry for "..tostring( event.sub )), event )
            else
                call( self, "onMouseMiss", event )
            end
        elseif event.main == "KEY" and self.acceptKeyboard then
            call( self, event.sub == "UP" and "onKeyUp" or "onKeyDown", event )
        elseif event.main == "CHAR" and self.acceptKeyboard then
            call( self, "onChar", event )
        elseif self.acceptMisc then
            -- unknown main event
            call( self, "onUnknownEvent", event )
        end

        call( self, "onAnyEvent", event )
    else
        call( self, "onEvent", event )
    end
end

function Node:setChanged( bool )
    self.changed = bool

    if bool then
        local parent = self.parent or self.stage
        if parent then
            parent.changed = true
        end
    end
end

function Node:getTotalOffset()
    -- goes up through every parent and returns the total X, Y offset.
    local X, Y = 0, 0
    if self.parent then
        -- get the offset from the parent, add this to the total
        local pX, pY = self.parent:getTotalOffset()
        X = X + pX - 1
        Y = Y + pY - 1
    elseif self.stage then
        X = X + self.stage.X
        Y = Y + self.stage.Y
    end

    X = X + self.X
    Y = Y + self.Y
    return X, Y
end

-- STATIC
function Node.generateNodeCallback( node, a, b )
    return (function( ... )
        local stage = node.stage
        if not stage then
            return error("Cannot link to node '"..node:type().."' stage.")
        end
        stage:executeCallback( b, ... )
    end)
end
