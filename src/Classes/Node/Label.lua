class "Label" extends "Node" {
    text = "Label";
}

function Label:preDraw()
    -- draw the text to the canvas
    local draw = self.canvas

    draw:drawTextLine( self.text, 1, 1, self.textColour, self.backgroundColour, self.width, true )
end
