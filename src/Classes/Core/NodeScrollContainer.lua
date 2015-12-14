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
