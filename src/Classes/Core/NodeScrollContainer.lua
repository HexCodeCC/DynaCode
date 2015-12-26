abstract class "NodeScrollContainer" extends "NodeContainer" {
    verticalScroll = 0;
    horizontalScroll = 0;

    verticalPadding = 0;
    horizontalPadding = 0;

    currentScrollbar = false;
}

function NodeScrollContainer:calculateDisplaySize( h, v ) -- h, v (horizontal, vertical)
    -- if a scroll bar is in use the size will be decreased as the scroll bar will be inside the node.
    local width, height = self.width, self.height
    return ( v and width - 1 or width ), ( h and height - 1 or height )
end

function NodeScrollContainer:calculateContentSize()
    -- get total height of the content (excludes padding)
    local h, w = 0, 0
    local nodes = self.nodes

    for i = 1, #nodes do
        local node = nodes[i]
        local nodeX2, nodeY2 = node.X + node.width - 1, node.Y + node.height - 1

        w = nodeX2 > w and nodeX2 or w
        h = nodeY2 > h and nodeY2 or h
    end

    return w, h
end

function NodeScrollContainer:getScrollPositions( contentWidth, contentHeight, dWidth, dHeight, hSize, vSize )
    local h, v = math.floor( self.horizontalScroll / contentWidth * dWidth + .5 ), math.floor( self.verticalScroll / contentHeight * dHeight + .5 )

    return h, v <= 1 and ( self.verticalScroll ~= 0 and 2 or 1 ) or v
end

function NodeScrollContainer:getScrollSizes( contentWidth, contentHeight, dWidth, dHeight )
    return math.floor( dWidth / contentWidth * dWidth + .5 ), math.floor( dHeight / contentHeight * self.height + .5 )
end

function NodeScrollContainer:addNode( node )
    self.super:addNode( node )

    --self:updateScrollSizes()
    --self:updateScrollPositions()
end

function NodeScrollContainer:removeNode( node )
    self.super:removeNode( node )

    --self:updateScrollSizes()
    --self:updateScrollPositions()
end

function NodeScrollContainer:inView( node )
    local nodeX, nodeY, nodeWidth, nodeHeight = node.X, node.Y, node.width, node.height
    local hOffset, vOffset = self.horizontalScroll, self.verticalScroll

    return nodeX + nodeWidth - hOffset > 0 and nodeX - hOffset < self.width and nodeY - vOffset < self.height and nodeY + nodeHeight - vOffset > 0
end

local clickMatrix = {
    CLICK = "onMouseDown";
    UP = "onMouseUp";
    SCROLL = "onMouseScroll";
    DRAG = "onMouseDrag";
}

function NodeScrollContainer:onAnyEvent( event )
    -- submit this event to our children. First, make the event relative
    local oX, oY = event.X, event.Y
    local isMouseEvent = event.main == "MOUSE"

    local nodes = self.nodes

    if isMouseEvent then
        event:convertToRelative( self )

        -- Also, apply any offsets caused by scrolling.
        event.Y = event.Y + self.verticalScroll
        event.X = event.X + self.horizontalScroll
    end

    for i = 1, #nodes do
        nodes[i]:handleEvent( event )
    end

    if isMouseEvent then
        event.X = oX
        event.Y = oY
    end
end

function NodeScrollContainer:onMouseScroll( event )
    local contentWidth, contentHeight = self:calculateContentSize()
    local h, v = self:getActiveScrollbars( contentWidth, contentHeight )

    local dWidth, dHeight = self:calculateDisplaySize( h, v )

    if v then
		self.verticalScroll = math.max( math.min( self.verticalScroll + event.misc, contentHeight - dHeight ), 0 )
        self.forceRedraw = true
        self.changed = true
	elseif h then
		self.horizontalScroll = math.max( math.min( self.horizontalScroll + event.misc, contentWidth - dWidth ), 0 )
        self.forceRedraw = true
        self.changed = true
	end
end

function NodeScrollContainer:getActiveScrollbars( contentWidth, contentHeight )
    return contentWidth > self.width, contentHeight > self.height
end

function NodeScrollContainer:draw( xO, yO, force )
    log("w", "Scroll Container Drawn. Force: "..tostring( force ))
    local nodes = self.nodes
    local manDraw = force or self.forceRedraw
    local canvas = self.canvas

    canvas:clear()

    local xO, yO = xO or 0, yO or 0

    if self.preDraw then
        self:preDraw( xO, yO )
    end

    -- draw the content
    local hO, vO = -self.horizontalScroll, -self.verticalScroll
    local nC

    for i = #nodes, 1, -1 do
        local node = nodes[i]
        nC = node.changed

        if self:inView( node ) and nC or manDraw then
            -- draw the node using our offset
            node:draw( hO, vO, manDraw or force )
            node.canvas:drawToCanvas( canvas, node.X + hO, node.Y + vO )

            if nC then node.changed = false end
        end
    end
    self.forceRedraw = false

    if self.postDraw then
        self:postDraw( xO, yO )
    end


    self.changed = false
    self.canvas:drawToCanvas( ( self.parent or self.stage ).canvas, self.X + xO, self.Y + yO )
end

function NodeScrollContainer:postDraw()
    -- draw the scroll bars

    local contentWidth, contentHeight = self:calculateContentSize()
    local isH, isV = self:getActiveScrollbars( contentWidth, contentHeight ) -- uses the content size to determine which scroll bars are active.
    if isH or isV then
        local dWidth, dHeight = self:calculateDisplaySize( isH, isV )

        local hSize, vSize = self:getScrollSizes( contentWidth, contentHeight, dWidth, dHeight )
        local hPos, vPos = self:getScrollPositions( contentWidth, contentHeight, dWidth, dHeight, hSize, vSize )

        log("i", "Vertical Scroll Size: "..tostring( vSize )..". Position: "..tostring( vPos ))

        local canvas = self.canvas

        -- draw the scroll bars now. If both are active at the same time adjust the size slightly and fill the gap at the intersect
        local bothActive = isH and isV
        local bothOffset = bothActive and 1 or 0

        if isH then
            -- draw the scroll bar background mixed in with the actual bar.
            canvas:drawArea( 1, self.height, dWidth, 1, colours.red, colours.green )
            canvas:drawArea( hPos, self.height, (hPos + hSize - 2) - bothOffset, 1, colours.black, colours.grey )
        end
        if isV then
            canvas:drawArea( self.width, 1, 1, dHeight, colours.red, colours.green )
            canvas:drawArea( self.width, vPos, 1, (vPos + vSize - 2) - bothOffset, colours.black, colours.grey )
        end

        if bothActive then canvas:drawArea( self.width, self.height, 1, 1, colours.lightGrey, colours.lightGrey ) end
    end
end
