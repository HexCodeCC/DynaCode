class "Anchor" {
    target = nil;
    properties = {};
    parent = nil;
}


function Anchor:initialise( target )
    self.target = classLib.isInstance( target ) or not target.anchorable or ConstructorException("Target is not a anchorable class")
    self.parent = self.target.stage or self.target.parent
end

function Anchor:addPropertyTarget( property, value )
    -- This property will stay at the value from the side of the parent.
    if self.target and self.target.anchorable then
        if self.target:isAnchorable( property, value ) then
            self.properties[ property ] = value
        else
            return Exception("Invalid property target '"..tostring( property ).."' to value '"..tostring( value ).."'")
        end
    else
        return Exception("Anchor target is missing or not achorable: '"..tostring( self.target ).."'")
    end
end

function Anchor:updateAnchor()
    -- Parent size has changed, lets adjust this node
    for property, target in self.properties do
        self.target[ property ] = self.target[ property - ( target - 1 ) ]
    end
end
