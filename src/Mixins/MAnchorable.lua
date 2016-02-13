local allowedProperties = { "right", "left", "bottom", "top", "minimumWidth", "maximumWidth", "minimumHeight", "maximumHeight" }

local function isInTable( tbl, key )
    if not tbl then return false end
    for i = 1, #tbl do
        if tbl[i] == key then return true end
    end
    return false
end

abstract class "MAnchorable" {
    anchorable = true;
    achor = false;

    __anchorWorking = false;
}

function MAnchorable:createAnchor( property, value )
    local anchor
    if type( property ) == "table" then
        if value then
            ParameterException("Passed table of properties with second argument. Only table OR property - value args can be used.")
        end

        anchor = Anchor( self )

        for key, val in pairs( property ) do
            anchor:addPropertyTarget( key, val )
        end
    else
        anchor = Anchor( self )
        anchor:addPropertyTarget( property, value )
    end

    self:bindAnchor( anchor )
    return anchor
end

function MAnchorable:bindAnchor( anchor )
    if self.anchor then
        return Exception("An anchor already exists on this Node. Add extra properties to this achor instead of making a new one.")
    end
end

function MAnchorable:unbindAnchor()
    if self.anchor then
        self.anchor:unbind()
        self.anchor = nil
    else
        return Exception("No anchor exists on this Node.")
    end
end
