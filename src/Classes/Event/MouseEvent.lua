local sub = string.sub

class "MouseEvent" extends "Event" {
    main = "MOUSE";
    sub = nil;
    X = nil;
    Y = nil;
    misc = nil; -- scroll direction, mouse button
}

function MouseEvent:initialise( raw )
    self.super:initialise( raw )
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

function MouseEvent:onPoint( x, y )
    if self.X == x and self.Y == y then
        return true
    end
    return false
end

function MouseEvent:convertToRelative( parent )
    self.X = self.X - parent.X + 1
    self.Y = self.Y - parent.Y + 1
end
