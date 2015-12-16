abstract class "NodeScrollContainer" extends "NodeContainer"

function NodeScrollContainer:getContentHeight()
    -- gets the total height of all visible nodes within this panel
end

function NodeScrollContainer:getContentWidth()
    -- returns the total width of all visible nodes within this panel
end

function NodeScrollContainer:isNodeInview( node )
    -- checks that the node is actually visible before drawing it
end

function NodeScrollContainer:updateScrollPositions()

end

function NodeScrollContainer:updateScrollSizes()

end

function NodeScrollContainer:addNode( node )
    print("node add caught. Passing to super" )
    self.super:addNode( node )

    self:updateScrollSizes()
    self:updateScrollPositions()

    print("Scroll sizes/positions updated")
end

function NodeScrollContainer:removeNode( node )
    self.super:removeNode( node )

    self:updateScrollSizes()
    self:updateScrollPositions()
end

function NodeScrollContainer:draw( xO, yO )
    local nodes = self.nodes
    local manDraw = self.changed
    local inView = self.isInView

    if self.preDraw then
        self:preDraw( xO, yO )
    end

    -- Draw to the stageCanvas
    self.canvas:drawToCanvas( self.stage.canvas, self.X, self.Y )

    if self.postDraw then
        self:postDraw( xO, yO )
    end

    for i = #nodes, 1, -1 do
        local node = nodes[i]
        if inView( node ) and ( manDraw or node.changed ) then
            node:draw()
        end
    end
end
