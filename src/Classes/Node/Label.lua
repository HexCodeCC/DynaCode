DCML.registerTag("Label", {
    contentCanBe = "text";
    argumentType = {
        X = "number";
        Y = "number";
        backgroundColour = "colour";
        textColour = "colour";
    };
    aliasHandler = true
})

local len = string.len

class "Label" extends "Node" alias "COLOUR_REDIRECT" {
    text = "Label";
}

function Label:initialise( ... )
    ParseClassArguments( self, { ... }, { {"text", "string"}, {"X", "number"}, {"Y", "number"} }, true, false )

    if not self.__defined.width then
        self.width = "auto"
    end
    self.super( self.X, self.Y, self.width, 1 )

    self.canvas.width = self.width
end

function Label:preDraw()
    -- draw the text to the canvas
    local draw = self.canvas

    draw:drawTextLine( self.text, 1, 1, self.textColour, self.backgroundColour, self.width ) -- text, X, Y, textColour, backgroundColour, maxWidth(optional)
end

function Label:getWidth()
    return self.width == "auto" and len( self.text ) or self.width
end

function Label:setWidth( width )
    self.width = width

    if not self.canvas then return end
    self.canvas.width = self.width
end

function Label:setText( text )
    self.text = text

    if not self.canvas then return end
    self.canvas.width = self.width
end
