abstract class "Node" alias "COLOUR_REDIRECT" {
    X = 1;
    Y = 1;

    width = 1;
    height = 1;

    visible = true;
    enabled = true;

    changed = true;

    stage = nil;

    canvas = nil;

    __node = true;
}

function Node:initialise( ... )
    ParseClassArguments( self, { ... }, { { "X", "number" }, { "Y", "number" }, { "width", "number" }, { "height", "number" } }, false, false )

    -- Creates a NodeCanvas
    self.canvas = NodeCanvas( self, self.width, self.height )
end

function Node:draw( xO, yO )
    -- Call any draw functions on the node (pre, post) and update its 'changed' state. Then draw the nodes canvas to the stages canvas
    if self.preDraw then
        self:preDraw( xO, yO )
    end

    -- Draw to the stageCanvas
    self.canvas:drawToCanvas( self.stage.canvas, self.X - 1, self.Y - 1 )
    self.changed = false

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
    --TODO Update canvas width
    self.width = width
end

function Node:setHeight( height )
    --TODO set height on instance and canvas.
end

function Node:setBackgroundColour( col )
    --TODO force update on children too (if they are using the nodes color as default)
    self.backgroundColour = col
end

function Node:setTextColour( col )
    --TODO force update on children too (if they are using the nodes color as default)
    self.textColour = col
end

function Node:onParentChanged()
    self.changed = true
end

function Node:handleEvent( event )
    -- Automatically fires callbacks on the node depending on the event. For example onMouseMiss, onMouseDown, onMouseUp etc...
end
