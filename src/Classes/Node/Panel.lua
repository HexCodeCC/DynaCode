class "Panel" extends "NodeScrollContainer" {
    height = 15;
    width = 10;

    nodes = nil;
}

function Panel:initialise( ... )
    local X, Y, width, height = ParseClassArguments( self, { ... }, {
        { "X", "number" },
        { "Y", "number" },
        { "width", "number" },
        { "height", "number" }
    }, true, true )

    self.super( X, Y, width, height ) -- this will call the Node.initialise because the super inherits that from the other super and so on...
    self.nodes = {}
end

function Panel:preDraw()

end
