local sub = string.sub

class "MouseEvent" mixin "Event" {
    main = "MOUSE";
    sub = nil;
    X = nil;
    Y = nil;
    misc = nil; -- scroll direction or mouse button

    inParentBounds = false;
}

function MouseEvent:initialise( raw )
    self.raw = raw
    local t = sub( raw[1], string.find( raw[1], "_" ) + 1, raw[1]:len() )

    self.sub = t:upper()
    self.misc = raw[2]
    self.X = raw[3]
    self.Y = raw[4]
end

function MouseEvent:inArea( x1, y1, x2, y2 )
    local x, y = self.X, self.Y
    if x >= x1 and x <= x2 and y >= y1 and y <= y2 then
        return true
    end
    return false
end

function MouseEvent:isInNode( node )
    return self:inArea( node.X, node.Y, node.X + node.width - 1, node.Y + node.height - 1 )
end

function MouseEvent:onPoint( x, y )
    if self.X == x and self.Y == y then
        return true
    end
    return false
end

function MouseEvent:getPosition() return self.X, self.Y end

function MouseEvent:convertToRelative( parent )
    self.X, self.Y = self:getRelative( parent )
end

function MouseEvent:getRelative( parent )
    -- similar to convertToRelative, however this leaves the event unchanged
    return self.X - parent.X + 1, self.Y - parent.Y + 1
end

function MouseEvent:inBounds( parent )
    local X, Y = parent.X, parent.Y
    return self:inArea( X, Y, X + parent.width - 1, Y + parent.height - 1 )
end

function MouseEvent:restore( x, y )
    self.X, self.Y = x, y
end
