local len, sub = string.len, string.sub

class "NodeCanvas" extends "Canvas" {
    node = nil;
}

function NodeCanvas:initialise( ... )
    local node, width, height = ParseClassArguments( self, { ... }, { {"node", "table"}, {"width", "number"}, {"height", "number"} }, true, true )

    if not class.isInstance( node ) then
        return error("Node argument (first unordered) is not a class instance! Should be a node class instance. '" .. tostring( node ) .. "'")
    elseif not node.__node then
        return error("Node argument (first unordered) is an invalid class instance. '"..tostring( node ).."'")
    end

    self.super:initialise( width, height )
end


-- Methods for drawing geometry shapes into canvas.
function NodeCanvas:drawTextLine( text, x, y, tc, bg, width, overflow )
    -- draws a text line at the co-ordinates.
    if overflow and width then text = OverflowText( text, width ) end

    local yPos = self.width * (y - 1)
    for i = 1, width or len( text ) do
        if x + i + 1 < 0 or x + i - 1 > self.width then return end
        local char = sub( text, i, i )
        self.buffer[ yPos + i + x - 1 ] = { char ~= "" and char or " ", tc, bg }
    end
end

function NodeCanvas:drawXCenteredTextLine( text, y, tc, bg, overflow )
    -- calculate the best X ordinate based on the length of the text and width of the node.
end

function NodeCanvas:drawYCenteredTextLine( text, x, tc, bg, overflow )

end

function NodeCanvas:drawCenteredTextLine( text, tc, bg, overflow )

end
