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

    self:__overrideMetaMethod("__add", function( a, b )
        if class.typeOf(a, "Panel", true) then
            if class.isInstance( b ) and b.__node then
                return self:addNode( b )
            else
                return error("Invalid right hand assignment. Should be instance of DynaCode node. "..tostring( b ))
            end
        else
            _G.invalid = a
            return error("Invalid left hand assignment. Should be instance of Panel. "..tostring( a ))
        end
    end)
    self.super( X, Y, width or self.width, height or self.height ) -- this will call the Node.initialise because the super inherits that from the other super and so on...
end
