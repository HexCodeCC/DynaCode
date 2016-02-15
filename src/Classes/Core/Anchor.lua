class "Anchor" {
    target = nil;
    parent = nil;

    config = {
        top = false,
        bottom = false,
        left = false,
        right = false,

        maximumWidth = false,
        maximumHeight = false,

        minimumWidth = false,
        minimumHeight = false
    };
}


function Anchor:initialise( target )
    self.target = classLib.isInstance( target ) and target.anchorable and target or ConstructorException("Target is not a anchorable class")
    self.parent = self.target.parent or self.target.stage
end

function Anchor:addPropertyTarget( property, value )
    -- This property will stay at the value from the side of the parent.
    if self.target and self.target.anchorable then
        if not self.target:isPropertyAnchorable( property, value ) then return ParameterException("Cannot anchor property '"..property.."' with value '"..tostring( value ).." (type: "..type( value )..")'") end

        self.config[ property ] = value
    else
        return Exception("Anchor target is missing or not achorable: '"..tostring( self.target ).."'")
    end
end

function Anchor:updateAnchor()
    local config, target, parent = self.config, self.target, self.parent
    target.__anchorWorking = true

    -- Sub anchors. No parent calculations required as the co-ordinates are relative to the top corner.
    if config.top then target.Y = config.top + 1 end
    if config.left then target.X = config.left + 1 end

    -- Main anchors. Parent calculations required.
    if config.bottom then
        if config.top then
            local desiredHeight = parent.height + 1 - target.Y - config.bottom
            local maxH, minH = config.maximumHeight or desiredHeight, config.minimumHeight or desiredHeight


            desiredHeight = desiredHeight > maxH and maxH or ( desiredHeight < minH and minH ) or desiredHeight
            target.height = desiredHeight < 1 and 1 or desiredHeight
        else
            target.Y = parent.height + 1 - config.bottom - target.height
        end
    end
    if config.right then
        if config.left then
            local desiredWidth = parent.width + 1 - target.X - config.right
            local maxW, minW = config.maximumWidth or desiredWidth, config.minimumWidth or desiredWidth

            desiredWidth = desiredWidth > maxW and maxW or ( desiredWidth < minW and minW ) or desiredWidth
            target.width = desiredWidth < 1 and 1 or desiredWidth
        else
            target.X = parent.width + 1 - config.right - target.width
        end
    end

    target.__anchorWorking = true
end
