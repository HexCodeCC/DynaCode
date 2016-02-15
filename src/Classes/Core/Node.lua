local clickMatrix = {
    CLICK = "onMouseDown";
    UP = "onMouseUp";
    SCROLL = "onMouseScroll";
    DRAG = "onMouseDrag";
}

abstract class "Node" mixin "MAnchorable" mixin "MSubscriber" alias "COLOUR_REDIRECT" {
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

    acceptMisc = false;
    acceptKeyboard = false;
    acceptMouse = false;
    manuallyHandle = false;
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

function Node:triggerResize()
    if self.__anchorWorking then return end

    local nodes = self.nodes
    if not nodes then return end

    for i = 1, #nodes do
        nodes[ i ]:onParentResize()
    end
end
function Node:setWidth( width )
    self.width = width
    self.canvas.width = width

    self:triggerResize()
end

function Node:setHeight( height )
    self.height = height
    self.canvas.height = height - 1

    self:triggerResize()
end

function Node:setBackgroundColour( col )
    self.forceRedraw = true
    self.changed = true

    self.backgroundColour = col
end

function Node:setTextColour( col )
    self.forceRedraw = true
    self.changed = true

    self.textColour = col
end

function Node:onParentResize()
    -- Update any anchors
    local anchor = self.anchor
    if anchor then
        anchor:updateAnchor()
    end
end

local function call( self, callback, ... )
    local cb = self[ callback ]
    if type( cb ) == "function" then
        cb( self, ... )
    end
end

function Node:handleEvent( event )
    -- Automatically fires callbacks on the node depending on the event. For example onMouseMiss, onMouseDown, onMouseUp etc...
    if event.handled then return end
    local main, sub = event.main, event.sub

    if not self.manuallyHandle then
        local keyboard = self.acceptKeyboard
        if main == "MOUSE" and self.acceptMouse then
            if event.inParentBounds or self.ignoreEventParentBounds then
                local X, Y = self.X, self.Y
                if event:inArea( X, Y, X + self.width - 1, Y + self.height - 1 ) then
                    call( self, clickMatrix[ sub ] or Exception("No click matrix entry for "..tostring(main).."_"..tostring( sub )), event )
                else
                    call( self, "onMouseMiss", event )
                end
            else
                call( self, "onMouseMiss", event )
            end
        elseif main == "KEY" and keyboard then
            call( self, sub == "UP" and "onKeyUp" or "onKeyDown", event )
        elseif main == "CHAR" and keyboard then
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
    local X, Y, parent = 0, 0, self.parent
    if parent then
        -- get the offset from the parent, add this to the total
        local pX, pY = parent:getTotalOffset()
        X = X + pX - 1
        Y = Y + pY - 1
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
