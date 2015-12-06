local insert = table.insert
local len, sub, rep = string.len, string.sub, string.rep

_G.ParseClassArguments = function( instance, args, order, require, raw )
    -- 'instance' is the class instance (self) that is calling the ParseClassArguments function.
    -- 'args' should be an array of the properties passed to the constructor.
    -- 'order' is an optional array that specifies the required arguments and the order in which they should be returned to the caller (see raw)
    -- 'require' is an optional boolean, if true all arguments specified in order must be defined, if false they are all optional.
    -- 'raw' is an optional boolean, if true the 'order' table results will be returned to the caller, if false the required arguments will be set like normal settings.

    local types = {}
    local function checkType( key, value )
        -- get the required type from the order table.
        if type( order ) ~= "table" then return end
        local _type = types[ key ]

        if _type and type( value ) ~= _type then
            if not class.typeOf( value, _type, true ) then
                return error("Expected type '".._type.."' for argument '"..key.."', got '"..type( value ).."' instead.")
            end
        end
        return value
    end

    -- First, compile a list of required arguments using order and or require.
    -- Any required arguments that are defined must be added to a constructor return table.
    local argsToBeDefined = {}
    if type( order ) == "table" and require then
        for key, value in ipairs( order ) do
            argsToBeDefined[ value[1] ] = true
        end
    end
    local names = {}
    if type( order ) == "table" then
        for key, value in ipairs( order ) do
            insert( names, value[1] )
            types[ value[1] ] = value[2]
        end
    end

    local provided = {}
    if #args == 1 and type( args[1] ) == "table" then
        -- If the args table contains a single table then parse the table
        for key, value in pairs( args[1] ) do
            provided[ key ] = checkType( key, value )
            argsToBeDefined[ key ] = nil
        end
    else
        -- If the args table is an array of properties then parse accordingly.
        for key, value in ipairs( args ) do
            local name = names[ key ]
            if not name then
                return error("Instance '"..instance:type().."' only supports a max of ".. (key-1) .." unordered arguments. Consider using a key-pair table instead, check the wiki page for this class to find out more.")
            end
            provided[ name ] = checkType( name, value )
            argsToBeDefined[ name ] = nil
        end
    end

    -- If argsToBeDefined has any values left, display those as missing arguments.
    if next( argsToBeDefined ) then
        local err = "Instance '"..instance:type().."' requires arguments:\n"

        for key, value in ipairs( order ) do
            if argsToBeDefined[ value[1] ] then
                err = err .. "- "..value[1].." ("..value[2]..")\n"
            end
        end
        err = err .. "These arguments have not been defined."
        return error( err )
    end

    -- set all settings
    for key, value in pairs( provided ) do
        if (types[ key ] and not raw) or not types[ key ] then
            -- set the value
            print("Setting "..key)
            instance[ key ] = value
        end
    end

    local constructor = {}
    if type( order ) == "table" and raw then
        for key, value in ipairs( order ) do
            insert( constructor, provided[ value[1] ] )
        end
        return unpack( constructor )
    end
end

_G.AssertClass = function( _class, _type, _instance, err )
    if not class.typeOf( _class, _type, _instance ) then
        return error( err, 2 )
    end
    return _class
end

_G.AssertEnum = function( input, possible, err )
    local ok
    for i = 1, #possible do
        if possible[ i ] == input then
            ok = true
            break
        end
    end

    if ok then
        return input
    else
        return error( err, 2 )
    end
end

_G.COLOUR_REDIRECT = {
    textColor = "textColour";
    backgroundColor = "backgroundColour";

    disabledTextColor = "disabledTextColour";
    disabledBackgroundColor = "disabledBackgroundColour"
}

_G.OverflowText = function( text, max )
    if len( text ) > max then
        local diff = len( text ) - max
        if diff > 3 then
            if len( text ) - diff - 3 >= 1 then
                text = sub( text, 1, len( text ) - diff - 3 ) .. "..."
            else text = rep( ".", max ) end
        else
            text = sub( text, 1, len( text ) - diff*2 ) .. rep( ".", diff )
        end
    end
    return text
end

_G.InArea = function( x, y, x1, y1, x2, y2 )
    if x >= x1 and x <= x2 and y >= y1 and y <= y2 then
        return true
    end
    return false
end
