class "Button" extends "Node" {
    text = "Button";

    yCenter = false;
    xCenter = false;

    active = false;
    focused = false;

    -- colours
    textColour = 1;
    backgroundColour = colours.cyan;

    activeTextColour = 1;
    activeBackgroundColour = colours.lightBlue;

    acceptMouse = true;
}

function Button:initialise( ... )
    local text, X, Y, width, height = ParseClassArguments( self, { ... }, { {"text", "string"}, {"X", "number"}, {"Y", "number"}, {"width", "number"}, {"height", "number"} }, true, true )

    self.super:initialise( X, Y, width, height )

    self.text = text
    self.X = X
    self.Y = Y
    self.width = width
    self.height = height
end

function Button:updateLines()
    self.lines = self.canvas:wrapText( self.text, self.width )
end

function Button:setText( text )
    -- set the raw text, also generate a wrapped version.
    self.text = text
    self:updateLines()
end

function Button:setWidth( width )
    self.width = width
    self:updateLines()
end

function Button:preDraw( xO, yO )
    self.canvas:drawWrappedText( 1, 1, self.width, self.height, self.lines, "center", "center", self.backgroundColour, self.textColour )
end
