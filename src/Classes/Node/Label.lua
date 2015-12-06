local len = string.len

class "Label" extends "Node" {
    text = "Label";
}

function Label:initialise( ... )
    ParseClassArguments( self, { ... }, { {"text", "string"}, {"X", "number"}, {"Y", "number"} }, true, false )

    if not self.__defined.width then -- only checks this instance, ignores the width set by any supers (self.width).
        self.width = "auto"
    end
    self.super:initialise( self.X, self.Y, self.width, 1 )
end

function Label:preDraw()
    -- draw the text to the canvas
    local draw = self.canvas

    draw:drawTextLine( self.text, 1, 1, self.textColour, self.backgroundColour, self.width ) -- text, X, Y, textColour, backgroundColour, maxWidth(optional)
end

function Label:getWidth()
    return self.width == "auto" and len( self.text ) or self.width
end
