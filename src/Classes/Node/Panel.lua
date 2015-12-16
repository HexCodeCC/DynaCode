class "Panel" extends "NodeScrollContainer" {
    width = 2;
    height = 2;
}

function Panel:initialise( ... )
    local X, Y, width, height = ParseClassArguments( self, { ... }, {
        { "X", "number" },
        { "Y", "number" },
        { "width", "number" },
        { "height", "number" }
    }, false, true )

    self.super( X, Y, width or self.width, height or self.height ) -- this will call the Node.initialise because the super inherits that from the other super and so on...
end

function Panel:preDraw()
    self.canvas:drawArea( 1, 1, self.width, self.height, self.textColour, self.backgroundColour )
end
