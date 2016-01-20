abstract class "NodeScrollContainer" extends "NodeContainer" {
    yOffset = 0;
    xOffset = 0;

    cache = {
        nodeHeight = 0;
        nodeWidth = 0;

        xScrollPosition = 0;
        yScrollPosition = 0;

        xScrollSize = 0;
        yScrollSize = 0;

        xActive = false;
        yActive = false;

        lastMouse = 0;
    };

    horizontalPadding = 0;
    verticalPadding = 0;

    currentScrollbar = false;

    autoDraw = true;

    trackColour = 128;
    barColour = 256;
    activeBarColour = colours.lightBlue;
}

function NodeScrollContainer:cacheAllInformation()
    self:cacheNodeSizes()
    self:cacheScrollbarInformation()
end

function NodeScrollContainer:cacheScrollbarInformation()
    self:cacheRequiredScrollbars()
    self:cacheDisplaySize()

    self:cacheScrollSizes()
    self:cacheScrollPositions()
end

function NodeScrollContainer:cacheDisplaySize()
    local cache = self.cache
    local xEnabled, yEnabled = cache.xActive, cache.yActive

    cache.displayWidth, cache.displayHeight = self.width - ( yEnabled and 1 or 0 ), self.height - ( xEnabled and 1 or 0 )
end

function NodeScrollContainer:cacheNodeSizes()
    local x, y = 0, 0
    local nodes = self.nodes

    local node
    for i = 1, #nodes do
        node = nodes[ i ]

        x = math.max( x, node.X + node.width - 1 )
        y = math.max( y, node.Y + node.height - 1 )
    end

    local cache = self.cache
    cache.nodeWidth = x
    cache.nodeHeight = y

    -- self.cache = cache
end

function NodeScrollContainer:cacheRequiredScrollbars()
    local cache = self.cache
    local width, height = cache.nodeWidth > self.width, cache.nodeHeight > self.height

    cache.xActive = width or ( height and cache.nodeWidth > self.width - 1 )
    cache.yActive = height or ( width and cache.nodeHeight > self.height - 1 )
end

function NodeScrollContainer:cacheScrollSizes()
    local cache = self.cache
    local dWidth, dHeight = cache.displayWidth, cache.displayHeight

    local xSize = math.ceil( dWidth / cache.nodeWidth * dWidth - .5 )
    local ySize = math.ceil( dHeight / cache.nodeHeight * dHeight - .5 )

    cache.xScrollSize, cache.yScrollSize = xSize, ySize
end

function NodeScrollContainer:cacheScrollPositions()
    local cache = self.cache
    if cache.xActive then
        local xPos
        local pos = math.ceil( self.xOffset / cache.nodeWidth * cache.displayWidth )
        if pos < 1 then -- scroll bar is off screen
            xPos = 1
        elseif pos == 1 and self.xOffset ~= 0 then -- scrollbar appears in the starting position even though the offset is not at the start
            xPos = 2
        else
            xPos = pos
        end

        if self.xOffset == 0 then
            cache.xDisplayPosition = 1
        elseif self.xOffset == cache.nodeWidth - cache.displayWidth then
            cache.xDisplayPosition = cache.displayWidth - cache.xScrollSize + 1
        else cache.xDisplayPosition = pos end

        cache.xScrollPosition = xPos
    end

    if cache.yActive then
        local yPos
        local pos = math.ceil( self.yOffset / cache.nodeHeight * cache.displayHeight )
        if pos < 1 then
            yPos = 1
        elseif pos == 1 and self.yOffset ~= 0 then
            yPos = 2
        else
            yPos = pos
        end

        if self.yOffset == 0 then
            cache.yDisplayPosition = 1
        elseif self.yOffset == cache.nodeHeight - cache.displayHeight then
            cache.yDisplayPosition = cache.displayHeight - cache.yScrollSize + 1
        else cache.yDisplayPosition = pos end

        cache.yScrollPosition = yPos
    end
end

function NodeScrollContainer:drawScrollbars()
    local canvas = self.canvas
    local cache = self.cache


    if cache.xActive then
        -- Draw the horizontal scrollbar & track
        local bg = self.currentScrollbar == "x" and self.activeBarColour or self.barColour

        canvas:drawArea( 1, self.height, cache.displayWidth, 1, self.trackColour, self.trackColour )
        canvas:drawArea( cache.xDisplayPosition, self.height, cache.xScrollSize, 1, bg, bg )
    end
    if cache.yActive then
        -- Draw the vertical scrollbar & track
        local bg = self.currentScrollbar == "y" and self.activeBarColour or self.barColour

        canvas:drawArea( self.width, 1, 1, cache.displayHeight, self.trackColour, self.trackColour )
        canvas:drawArea( self.width, cache.yScrollPosition, 1, cache.yScrollSize, bg, bg )
    end

    if cache.xActive and cache.yActive then
        canvas:drawArea( self.width, self.height, 1, 1, 32768, 32768 )
    end
end

function NodeScrollContainer:drawContent( force )
    -- Draw the nodes if they are visible in the container.
    local nodes = self.nodes
    local canvas = self.canvas

    canvas:clear()

    local xO, yO = -self.xOffset, -self.yOffset
    local manDraw = force or self.forceRedraw
    local autoDraw = self.autoDraw

    local node
    for i = 1, #nodes do
        node = nodes[ i ]

        if node.changed or node.forceRedraw or manDraw then
            node:draw( xO, yO, force )

            if autoDraw then
                node.canvas:drawToCanvas( canvas, node.X + xO, node.Y + yO )
            end
        end
    end
end

function NodeScrollContainer:draw( xO, yO, force )
    if self.recacheAllNextDraw then
        self:cacheAllInformation()

        self.recacheAllNextDraw = false
    else
        if self.recacheNodeInformationNextDraw then
            self:cacheNodeSizes()

            self.recacheNodeInformationNextDraw = false
        end
        if self.recacheScrollInformationNextDraw then
            self:cacheScrollbarInformation()

            self.recacheScrollInformationNextDraw = false
        end
    end

    self:drawContent( force )
    self:drawScrollbars( force )
end

--[[ Event Handling ]]--
function NodeScrollContainer:onAnyEvent( event )
    -- First, ship to nodes. If the event comes back unhandled then try to use it.
    --self:submitEvent( event )

    if not event.handled then
        local ownerApplication = self.stage.application
        local hotkey = ownerApplication.hotkey
        local cache = self.cache


        if event.main == "MOUSE" then
            local sub = event.sub
            local x, y = event:getRelative( self )


            if event:isInNode( self ) then
                if sub == "CLICK" then
                    -- Was this on a scrollbar?
                    if cache.xActive then
                        if y == self.height then -- its on the track so we will stop this event from propagating further.
                            event.handled = true

                            if x >= cache.xScrollPosition and x <= cache.xScrollPosition + cache.xScrollSize then
                                self.currentScrollbar = "x"
                                self.lastMouse = x

                                self.changed = true
                            end
                        end
                    end
                    if cache.yActive then
                        if x == self.width then
                            event.handled = true

                            if y >= cache.yScrollPosition and y <= cache.yScrollPosition + cache.yScrollSize - 1 then
                                self.currentScrollbar = "y"
                                self.lastMouse = y

                                self.changed = true
                            end
                        end
                    end
                elseif sub == "SCROLL" then
                    if cache.xActive and (not cache.yActive or hotkey.keys.shift) then
                        -- scroll the horizontal bar
                        self.xOffset = math.max( math.min( self.xOffset + event.misc, cache.nodeWidth - cache.displayWidth ), 0 )

                        self.changed = true
                        self:cacheScrollPositions()
                    elseif cache.yActive then
                        -- scroll the vertical bar
                        self.yOffset = math.max( math.min( self.yOffset + event.misc, cache.nodeHeight - cache.displayHeight ), 0 )

                        self.changed = true
                        self:cacheScrollPositions()
                    end
                end
            end

            if event.handled then return end -- We needn't continue.

            if sub == "DRAG" then
                local current = self.currentScrollbar

                if current == "x" then
                    local newPos, newOffset = cache.xScrollPosition + ( x < self.lastMouse and -1 or 1 )
                    log("w", "Last mouse location: "..tostring( self.lastMouse )..", Current mouse location: "..tostring( x )..", Current position: "..tostring( cache.xScrollPosition )..", new position: "..tostring( newPos ) )
                    if newPos <= 1 then newOffset = 0 else
                        newOffset = math.max( math.min( math.floor( ( newPos ) * ( ( cache.nodeWidth - .5 ) / cache.displayWidth ) ), cache.nodeWidth - cache.displayWidth ), 0 )
                    end
                    log( "w", "New offset from position: "..tostring( newOffset ) )

                    self.xOffset = newOffset
                    self.lastMouse = x
                elseif current == "y" then
                    local newPos = cache.yScrollPosition + ( y - self.lastMouse )
                    local newOffset
                    if newPos <= 1 then newOffset = 0 else
                        newOffset = math.max( math.min( math.floor( ( newPos ) * ( ( cache.nodeHeight - .5 ) / cache.displayHeight ) ), cache.nodeHeight - cache.displayHeight ), 0 )
                    end

                    self.yOffset = newOffset
                    self.lastMouse = y
                end

                self.changed = true
                self:cacheScrollPositions()
            elseif sub == "UP" then
                self.currentScrollbar = nil
                self.lastMouse = nil
                self.changed = true
            end
        end
    end
end

function NodeScrollContainer:submitEvent( event )

end

--[[ Intercepts ]]--
function NodeScrollContainer:addNode( node )
    self.super:addNode( node )

    self.recacheAllNextDraw = true
end

function NodeScrollContainer:removeNode( n )
    self.super:removeNode( n )

    self.recacheAllNextDraw = true
end
