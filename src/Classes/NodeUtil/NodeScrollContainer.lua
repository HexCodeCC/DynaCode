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

        xDisplayPosition = 0;
        yDisplayPosition = 0;

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

    consumeAllMouseEvents = false; -- stops parent scroll containers from scrolling when this container reaches max offset.
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
        local pos = math.ceil( self.yOffset / cache.nodeHeight * (cache.displayHeight + .5) )
        if pos < 1 then
            yPos = 1
        elseif pos == 1 and self.yOffset ~= 0 then
            yPos = 2
        else
            yPos = pos
        end

        if self.yOffset == 0 then
            cache.yDisplayPosition = 1
        elseif pos == 1 and self.yOffset ~= 0 then
            cache.yDisplayPosition = 2
        elseif self.yOffset == cache.nodeHeight - cache.displayHeight then
            cache.yDisplayPosition = cache.displayHeight - cache.yScrollSize + 1
        else cache.yDisplayPosition = pos end

        cache.yScrollPosition = yPos
    end
end

function NodeScrollContainer:drawScrollbars()
    local canvas = self.canvas
    local cache = self.cache

    local trackColour, activeBarColour, barColour, width = self.trackColour, self.activeBarColour, self.barColour, self.width
    if cache.xActive then
        -- Draw the horizontal scrollbar & track
        local bg = self.currentScrollbar == "x" and self.activeBarColour or self.barColour

        canvas:drawArea( 1, self.height, cache.displayWidth, 1, self.trackColour, trackColour )
        canvas:drawArea( cache.xDisplayPosition, self.height, cache.xScrollSize, 1, bg, bg )
    end
    if cache.yActive then
        -- Draw the vertical scrollbar & track
        local bg = self.currentScrollbar == "y" and self.activeBarColour or self.barColour

        canvas:drawArea( width, 1, 1, cache.displayHeight, trackColour, trackColour )
        canvas:drawArea( width, cache.yDisplayPosition, 1, cache.yScrollSize, bg, bg )
    end

    if cache.xActive and cache.yActive then
        canvas:drawArea( width, self.height, 1, 1, trackColour, trackColour )
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
    local cache, x, y = self.cache
    if event.main == "MOUSE" then x, y = event:getRelative( self ) end

    if not ( (x or y) and event.sub == "CLICK" and ( cache.xActive and y == self.height or cache.yActive and x == self.width ) ) then
        self:submitEvent( event )
    end

    if not event.handled then
        local ownerApplication = self.stage.application
        local hotkey = ownerApplication.hotkey

        if event.main == "MOUSE" then
            local inBounds, dontUse = event:isInNode( self )
            local sub = event.sub

            if inBounds then
                if sub == "CLICK" then
                    -- Was this on a scrollbar?
                    if cache.xActive then
                        if y == self.height then -- its on the track so we will stop this event from propagating further.
                            if x >= cache.xScrollPosition and x <= cache.xScrollPosition + cache.xScrollSize then
                                self.currentScrollbar = "x"
                                self.lastMouse = x

                                self.changed = true
                            end
                        end
                    end
                    if cache.yActive then
                        if x == self.width then
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
                        local nOffset = math.max( math.min( self.xOffset + event.misc, cache.nodeWidth - cache.displayWidth ), 0 )
                        if nOffset ~= self.xOffset then
                            self.xOffset = nOffset

                            self.changed = true
                            self:cacheScrollPositions()

                            self:call("scroll", event)
                        else dontUse = true end
                    elseif cache.yActive then
                        -- scroll the vertical bar
                        local nOffset = math.max( math.min( self.yOffset + event.misc, cache.nodeHeight - cache.displayHeight ), 0 )
                        if nOffset ~= self.yOffset then
                            self.yOffset = nOffset

                            self.changed = true
                            self:cacheScrollPositions()

                            self:call("scroll", event)
                        else dontUse = true end
                    end
                elseif sub == "DRAG" then
                    local current = self.currentScrollbar

                    if current == "x" then
                        local newPos, newOffset = cache.xScrollPosition + ( x < self.lastMouse and -1 or 1 )
                        if newPos <= 1 then newOffset = 0 else
                            newOffset = math.max( math.min( math.floor( ( newPos ) * ( cache.nodeWidth / (cache.displayWidth + .5) ) ), cache.nodeWidth - cache.displayWidth ), 0 )
                        end

                        self.xOffset = newOffset
                        self.lastMouse = x

                        self:call("scroll", event)
                    elseif current == "y" then
                        local newPos = cache.yScrollPosition + ( y - self.lastMouse )
                        local newOffset
                        if newPos <= 1 then newOffset = 0 else
                            newOffset = math.max( math.min( math.floor( ( newPos ) * ( cache.nodeHeight / (cache.displayHeight + .5) ) ), cache.nodeHeight - cache.displayHeight ), 0 )
                        end

                        self.yOffset = newOffset
                        self.lastMouse = y

                        self:call("scroll", event)
                    end

                    self.changed = true
                    self:cacheScrollPositions()
                end
            else
                if self.focused then
                    self.stage:removeKeyboardFocus( self )
                end

                dontUse = true
            end

            if sub == "UP" then
                self.currentScrollbar = nil
                self.lastMouse = nil
                self.changed = true
                dontUse = true
            end

            if event.handled then return end
            if (not dontUse or self.consumeAllMouseEvents) and inBounds then
                event.handled = true

                if not self.focused then
                    self.stage:redirectKeyboardFocus( self )
                end
            end
        elseif self.focused and event.main == "KEY" then
            local function setOffset( target, value )
                self[target.."Offset"] = value

                self.changed = true
                self:cacheScrollPositions()
                self:call("scroll", event)
                event.handled = true
            end
            if event.sub == "KEY" and hotkey.keys.shift then
                -- offset adjustment
                if event.key == keys.up then
                    -- Shift the offset up (reduce)
                    setOffset( "y", math.max( self.yOffset - self.height, 0 ) )
                elseif event.key == keys.down then
                    setOffset( "y", math.min( self.yOffset + self.height, cache.nodeHeight - cache.displayHeight ) )
                elseif event.key == keys.left then
                    setOffset( "x", math.max( self.xOffset - self.width, 0 ) )
                elseif event.key == keys.right then
                    setOffset( "x", math.min( self.xOffset + self.width, cache.nodeWidth - cache.displayWidth ) )
                end
            elseif event.sub == "KEY" and not hotkey.keys.shift then
                if event.key == keys.up then
                    -- Shift the offset up (reduce)
                    setOffset( "y", math.max( self.yOffset - 1, 0 ) )
                elseif event.key == keys.down then
                    setOffset( "y", math.min( self.yOffset + 1, cache.nodeHeight - cache.displayHeight ) )
                elseif event.key == keys.left then
                    setOffset( "x", math.max( self.xOffset - 1, 0 ) )
                elseif event.key == keys.right then
                    setOffset( "x", math.min( self.xOffset + 1, cache.nodeWidth - cache.displayWidth ) )
                end
            end
        end
    end
end

function NodeScrollContainer:submitEvent( event )
    local main = event.main
    local oX, oY, oPb

    if main == "MOUSE" then
        oPb = event.inParentBounds
        event.inParentBounds = event:isInNode( self )

        oX, oY = event:getPosition()
        event:convertToRelative( self )

        event.X = event.X + self.xOffset
        event.Y = event.Y + self.yOffset
    end

    local nodes, node = self.nodes
    for i = 1, #nodes do
        nodes[ i ]:handleEvent( event )
    end

    if main == "MOUSE" then event.X, event.Y, event.inParentBounds = oX, oY, oPb end
end

function NodeScrollContainer:onFocusLost()
    self.focused = false;
    self.acceptKeyboard = false;
end

function NodeScrollContainer:onFocusGain()
    self.focused = true;
    self.acceptKeyboard = true;
end

function NodeScrollContainer:getCursorInformation() return false end -- this has no cursor

--[[ Intercepts ]]--
function NodeScrollContainer:addNode( node )
    self.super:addNode( node )

    self.recacheAllNextDraw = true
    return node
end

function NodeScrollContainer:removeNode( n )
    self.super:removeNode( n )

    self.recacheAllNextDraw = true
end


function NodeScrollContainer:onParentResize()
    self.super:onParentResize()

    self.recacheAllNextDraw = true
end
