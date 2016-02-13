--[[
    DynaCode Class System (version 0.6)

    This class system has undergone a complete change
    and may still have a couple of bugs lying around.

    All previously reported bugs are not present in this
    system (tested).
]]

local gsub, match = string.gsub, string.match
local current
local classes = {}

local MISSING_CLASS_LOADER
local CRASH_DUMP = {
    ENABLE = false;
    LOCATION = "DynaCode-Dump.crash"
}
local rawAccess

local RESERVED = {
    __class = true;
    __instance = true;
    __defined = true;
    __definedProperties = true;
    __definedMethods = true;
    __extends = true;
    __interfaces = true;
    __type = true;
    __mixins = true;
    __super = true;
    __initialSuperValues = true;
    __alias = true;
}

local setters = setmetatable( {}, {__index = function( self, key )
    -- This will be called when a setter we need is not cached. Create the name and change the name.
    local setter = "set" .. key:sub( 1,1 ):upper() .. key:sub( 2 )
    self[ key ] = setter

    return setter
end})

local getters = setmetatable( {}, {__index = function( self, key )
    local getter = "get" .. key:sub( 1,1 ):upper() .. key:sub( 2 )
    self[ key ] = getter

    return getter
end})


-- Helper functions
local function throw( message, level )
    local level = type( level ) == "number" and level + 1 or 2
    local message = message:sub(-1) ~= "." and message .. "." or message

    return error("Class Exception: "..message, level)
end

local function loadRequiredClass( target )
    local oCurrent = current
    local c, _c

    c = MISSING_CLASS_LOADER( target )

    _c = classes[ target ]
    if classLib.isClass( _c ) then
        if not _c:isSealed() then _c:seal() end
    else
        return error("Target class '"..tostring( target ).."' failed to load")
    end

    current = oCurrent
    return _c
end

local function getClass( name, compile, notFoundError, notCompiledError )
    local _class = classes[ name ]

    if not _class or not classLib.isClass( _class ) then
        if MISSING_CLASS_LOADER then
            return loadRequiredClass( name )
        else
            throw( notFoundError or "Failed to fetch class '"..tostring( name ).."'. Class doesn't exist", 2 )
        end
    elseif not _class:isSealed() then
        throw( notCompiledError or "Failed to fetch class '"..tostring( name ).."'. Class is not compiled", 2 )
    end

    return _class
end

local function getRawContent( target )
    rawAccess = true
    local content = target:getRaw()
    rawAccess = false

    return content
end

local function deepCopy( source )
    local orig_type = type( source )
    local copy
    if orig_type == 'table' then
        copy = {}
        for key, value in next, source, nil do
            copy[ deepCopy( key ) ] = deepCopy( value )
        end
    else
        copy = source
    end
    return copy
end

local function preprocess( data )
    local name = match( data, "abstract class (\"%w*\")")
    if name then
        data = gsub( data, "abstract class "..name, "class "..name.." abstract()")
    end
    return data
end



local function export( data, _file, EX )

    -- Parse the error
    local EX_LINE
    local EX_MESSAGE
    -- Errors usually follow the format of: FILE:LINE: EXCEPTION. Or EXCEPTION alone. If we cannot find a line number we will declare it unknown
    local file, line, message = string.match( EX, "(.+)%:(%d+)%:(.*)" )

    if file and line and message then
        -- We parsed the data
        EX_LINE = line
        EX_MESSAGE = message
    else
        -- Maybe an error with no file name/line (error with level zero)
        EX_MESSAGE = EX
    end

    local footer = [==[
--[[
    DynaCode Crash Report (0.1)
    =================

    This file was generated because DynaCode's class system
    ran into a fatal exception while running this file.

    Exception Details
    -----------------
    File: ]==] .. tostring( file or _file or "?" ) .. [==[

    Line Number: ]==] .. tostring( EX_LINE or "?" ) .. [==[

    Error: ]==] .. tostring( EX_MESSAGE or "?" ) .. [==[


    Raw: ]==] .. tostring( EX or "?" ) .. [==[

    -----------------
    The file that was being loaded when DynaCode crashed
    has been inserted above.

    The file was pre-processed before loading, so as a result
    the code above may not match your original source
    exactly.

    NOTE: This file is purely a crash report, editing this file
    will not have any affect. Please edit the source file (]==] .. tostring( file or _file or "?" ) .. [==[)
]]]==]

    local f = fs.open(CRASH_DUMP.LOCATION, "w")
    f.write( data .."-- END OF FILE --" )
    f.write("\n\n"..footer)
    f.close()
end

local function propertyCatch( tbl )
    if not current then
        throw("Failed to catch property table, no class is being built.")
    end
    if type( tbl ) == "table" then
        for key, value in pairs( tbl ) do
            current[ key ] = value
        end
    elseif tbl ~= nil then
        throw("Failed to catch property table, got: '"..tostring( tbl ).."'.")
    end
end


-- Main functions
local function compileSuper( base, target, total, totalAlias, superNumber )
    -- This super will act as a template that can be used to spawn super instances.
    local matrix, matrixMt = {}, {}
    local totalKeyPairs = total or {}
    local totalAlias = totalAlias or {}
    local superNumber = superNumber or 1

    local superRaw = getRawContent( getClass( target, true ) )

    local function applyKeyValue( instance, thisSuper, k, v )
        local last = instance
        local supers = {}

        while true do
            if last.__defined[ k ] then
                return true
            else
                supers[ #supers + 1 ] = last
                if last.super ~= thisSuper and last.super then last = last.super
                else
                    for i = 1, #supers do supers[i]:addSymbolicKey( k, v ) end
                    break
                end
            end
        end
    end

    local function getKeyFromSuper( start, k )
        local last = start

        while true do
            local _super = last.super
            if _super then
                if _super.__defined[ k ] then return _super[ k ] else last = _super end
            else break end
        end
    end

    local factories = {}
    for key, value in pairs( superRaw ) do
        if not RESERVED[ key ] then
            -- If this is a function then create a factory for it.
            if type( value ) == "function" then
                if factories[ key ] then
                    throw("A factory for key '"..key.."' on super '"..target.__type.."' for '"..base.__type.."' already exists.")
                end

                factories[ key ] = function( instance, rawContent, ... )
                    if not rawContent then
                        throw("Failed to fetch raw content for factory '"..key.."'")
                    end

                    -- Adjust the super on the instance
                    local oSuper = instance.super


                    local new = instance:seekSuper( superNumber + 1 )
                    instance.super = new ~= nil and new ~= "nil" and new or nil

                    local returnData = { rawContent[ key ]( instance, ... ) }

                    instance.super = oSuper
                    return unpack( returnData )
                end
                if totalKeyPairs[ key ] == nil then totalKeyPairs[ key ] = factories[ key ] end
            else
                if totalKeyPairs[ key ] == nil then totalKeyPairs[ key ] = value end
            end
        elseif key == "__alias" then
            for key, value in pairs( value ) do
                if not totalAlias[ key ] then totalAlias[ key ] = value end
            end
        end
    end

    local inheritedFactories = {}
    if superRaw.__extends then
        local keys, alias
        matrix.super, keys, alias = compileSuper( base, superRaw.__extends, totalKeyPairs, totalAlias, superNumber + 1 )

        sym = true
        for key, value in pairs( keys ) do
            if not superRaw[ key ] and not RESERVED[ key ] then
                if type( value ) == "function" then
                    inheritedFactories[ key ] = value
                else
                    superRaw[ key ] = value
                end
            end
        end

        for key, value in pairs( alias ) do
            if not totalAlias[ key ] then
                totalAlias[ key ] = value
            end
        end

        sym = false
    end

    function matrix:create( instance )
        local raw = deepCopy( superRaw )
        local superMatrix, superMatrixMt = {}, {}
        local sym

        if matrix.super then
            superMatrix.super = matrix.super:create( instance )
        end

        -- Configure any pre-built inherited factories.
        sym = true
        for name, value in pairs( inheritedFactories ) do
            if not raw[ name ] then raw[ name ] = getKeyFromSuper( superMatrix, name ) end
        end
        sym = false

        function superMatrix:addSymbolicKey( k, v )
            sym = true
            raw[ k ] = v
            sym = false
        end

        -- Now create some proxies for key accessing on supers.
        local cache = {}
        local defined = raw.__defined
        local factoryCache = {}
        function superMatrixMt:__index( k )
            -- if the key is a function then return the factory.
            if type( raw[ k ] ) == "function" then
                if not factoryCache[ k ] then
                    factoryCache[ k ] = defined[ k ] and factories[ k ] or raw[ k ]
                end
                local factory = factoryCache[ k ]

                if not factory then
                    if defined[ k ] then
                        throw("Failed to create factory for key '"..k.."'. This error wasn't caught at compile time, please report immediately")
                    else
                        throw("Failed to find factory for key '"..k.."' on super '"..tostring( self ).."'. Was this function illegally created after compilation?", 0)
                    end
                end
                if not cache[ k ] then
                    cache[ k ] = function( self, ... )
                        local args = { ... }

                        -- if this is inherited do NOT pass the raw table. This is because the factory is just another wrapper (like this function) and this function doesn't want the raw table. Unless it is OUR factory don't pass raw.
                        local v
                        if inheritedFactories[ k ] then
                            v = { factory( instance, ... ) }
                        else
                            v = { factory( instance, raw, ... ) }
                        end

                        return unpack( v )
                    end
                end

                return cache[ k ]
            else
                return raw[ k ] -- just give them the value (if it exists)
            end
        end

        function superMatrixMt:__newindex( k, v )
            if k == nil then
                throw("Failed to set nil key with value '"..tostring( v ).."'. Key names must have a value.")
            elseif RESERVED[ k ] then
                throw("Failed to set key '"..k.."'. Key is reserved.")
            end
            raw[ k ] = v == nil and getKeyFromSuper( self, k ) or v

            if not sym then
                local vT = type( v )
                raw.__defined[ k ] = v ~= nil or nil
                raw.__definedProperties[ k ] = v and vT ~= "function" or nil
                raw.__definedMethods[ k ] = v and vT == "function" or nil
            end
            applyKeyValue( instance, superMatrix, k, v )
        end

        function superMatrixMt:__tostring()
            return "Super #"..superNumber.." '"..raw.__type.."' of '"..instance:type().."'"
        end

        function superMatrixMt:__call( ... )
            local fnName = type( superMatrix.initialise ) == "function" and "initialise" or "initialize"

            local fn = superMatrix[ fnName ]
            if type( fn ) == "function" then
                superMatrix[ fnName ]( superMatrix, ... )
            end
        end
        setmetatable( superMatrix, superMatrixMt )

        return superMatrix
    end

    return matrix, totalKeyPairs, totalAlias
end
local function compileClass()
    -- Compile the current class
    local raw = getRawContent( current )
    if not current then
        throw("Cannot compile class because no classes are being built.")
    end

    local mixins = raw.__mixins
    local pre
    for i = 1, #mixins do
        local mixin = mixins[ i ]
        pre = "Failed to mixin target '"..tostring( mixin ).."' into '"..current.__type.."'. "

        -- Fetch this mixin target
        local _mixin = getClass( mixin, true, pre.."The class doesn't exist", pre.."The class has not been compiled.")
        if _mixin then
            for key, value in pairs( getRawContent( _mixin ) ) do
                if not current[ key ] then
                    current[ key ] = value
                end
            end
        end
    end

    if current.__extends then
        local super, keys, alias = compileSuper( current, current.__extends ) -- begin super compilation.

        local currentAlias = raw.__alias
        for key, value in pairs( alias ) do
            if not currentAlias[ key ] then
                currentAlias[ key ] = value
            end
        end

        raw.__super = super
        raw.__initialSuperValues = keys
    end
end

local function spawnClass( name, ... )
    -- Spawn class 'name'
    local sym
    if type( name ) ~= "string" then
        throw("Failed to spawn class. Invalid name provided '"..tostring( name ).."'")
    elseif current then
        throw("Cannot spawn class '"..name.."' because a class is currently being built.")
    end

    local target = getClass( name, true, "Failed to spawn class '"..name.."'. The class doesn't exist", "Failed to spawn class '"..name.."'. The class is not compiled.")

    local instance, instanceMt, instanceRaw = {}, {}
    instanceRaw = deepCopy( getRawContent( target ) )
    instanceRaw.__instance = true

    local alias = instanceRaw.__alias or {}

    local function seekFromSuper( key )
        local last = instanceRaw
        while true do
            local super = last.super
            if super then
                if super.__defined[ key ] then return super[ key ] else last = super end
            else return nil end
        end
    end

    local superCache = {}
    function instance:seekSuper( number )
        return superCache[ number ]
    end

    local firstSuper
    if instanceRaw.__super then
        -- register this super
        instanceRaw.super = instanceRaw.__super:create( instance )
        firstSuper = instanceRaw.super

        local initial = instanceRaw.__initialSuperValues
        for key, value in pairs( initial ) do
            if not instanceRaw.__defined[ key ] and not RESERVED[ key ] then
                instanceRaw[ key ] = seekFromSuper( key )
            end
        end

        instanceRaw.__initialSuperValues = nil
        instanceRaw.__super = nil

        local last = instanceRaw
        local i = 1
        while true do
            if not last.super then break end

            superCache[ i ] = last.super

            last = last.super
            i = i + 1
        end
    end

    local getting = {}
    function instanceMt:__index( k )
        local k = alias[ k ] or k

        if k == nil then
            throw("Failed to get 'nil' key. Key names must have a value.")
        end

        -- Check if a getter is available. If there is and we own it set the super to #1 (lowest). Also, if the target is a function return a wrapper if we own it (to also set the super to #1).
        local getter = getters[ k ]
        if type( instanceRaw[ getter ] ) == "function" and not getting[ k ] then
            -- Use the getter function. If its ours then wrap it, otherwise do not (its a super factory).
            local adjustSuper = instanceRaw.__defined[ k ]
            local oSuper = instanceRaw.super
            if adjustSuper then instanceRaw.super = firstSuper end

            getting[ k ] = true
            local v = { instanceRaw[ getter ]( self ) }
            getting[ k ] = nil

            instanceRaw.super = oSuper

            return unpack( v )
        elseif type( instanceRaw[ k ] ) == "function" and instanceRaw.__defined[ k ] then
            -- Return a wrapper if its ours, otherwise don't (its inherited and will be a factory)
            return function( self, ... )
                local oSuper = instanceRaw.super
                instanceRaw.super = firstSuper

                local v = { instanceRaw[ k ]( self, ... ) }

                instanceRaw.super = oSuper

                return unpack( v )
            end
        else
            return instanceRaw[ k ]
        end

    end

    local setting = {}
    function instanceMt:__newindex( k, v )
        local k = alias[ k ] or k

        if k == nil then
            throw("Failed to set 'nil' key with value '"..tostring( v ).."'. Key names must have a value.")
        elseif RESERVED[ k ] then
            throw("Failed to set key '"..k.."'. Key is reserved.")
        elseif isSealed then
            throw("Failed to set key '"..k.."'. This class base is compiled.")
        end

        local setter = setters[ k ]
        if type( instanceRaw[ setter ] ) == "function" and not setting[ k ] then
            local oSuper = instanceRaw.super
            instanceRaw.super = firstSuper

            setting[ k ] = true
            instanceRaw[ setter ]( self, v )
            setting[ k ] = nil

            instanceRaw.super = oSuper
        else
            instanceRaw[ k ] = v
        end
        if v == nil then
            instanceRaw[ k ] = seekFromSuper( k )
        end
        if not sym then
            instanceRaw.__defined[ k ] = v ~= nil or nil
        end
    end

    function instanceMt:__tostring() return "[Instance] "..instanceRaw.__type end

    function instance:type() return instanceRaw.__type end

    function instance:addSymbolicKey( k, v )
        sym = true; self[ k ] = v; sym = false
    end

    local locked = {
        ["__index"] = true;
        ["__newindex"] = true;
    }
    function instance:__overrideMetaMethod( method, fn )
        if locked[ method ] then return error("Meta method '"..tostring( method ).."' cannot be overridden") end

        instanceMt[ method ] = fn
    end

    function instance:__lockMetaMethod( method ) locked[ method ] = true end
    setmetatable( instance, instanceMt )


    -- Search for initialise/initialize function. Execute if found.
    local fnName = type( instanceRaw.initialise ) == "function" and "initialise" or "initialize"
    if type( instanceRaw[ fnName ] ) == "function" then
        instance[ fnName ]( instance, ... )
    end

    return instance
end

_G.class = function( name )
    local sym
    local char = name:sub(1, 1)
    if char:upper() ~= char then
        throw("Class name '"..name.."' is invalid. Class names must begin with a uppercase character.")
    end

    if classes[ name ] then
        throw("Class name '"..name.."' is already in use.")
    end

    -- Instructs DynaCode to create a new class to be compiled later. This class will be stored in `current`.
    local isSealed, isAbstract = false, false
    local base = { __defined = {}, __definedMethods = {}, __definedProperties = {}, __class = true, __mixins = {}, __alias = {} }
    base.__type = name
    local class = {}
    local defined, definedMethods, definedProperties = base.__defined, base.__definedMethods, base.__definedProperties

    -- Seal
    function class:seal()
        -- Compile the class.
        if isSealed then
            throw("Failed to seal class '"..name.."'. The class is already sealed.")
        end

        compileClass()
        isSealed = true

        current = nil
    end
    function class:isSealed()
        return isSealed
    end

    -- Abstract
    function class:abstract( bool )
        if isSealed then throw("Cannot modify abstract state of sealed class '"..name.."'") end

        isAbstract = bool
    end
    function class:isAbstract()
        return isAbstract
    end

    function class:alias( target )
        local tbl
        if type( target ) == "table" then
            tbl = target
        elseif type( target ) == "string" and type( _G[ target ] ) == "table" then
            tbl = _G[ target ]
        end

        local currentAlias = base.__alias

        for key, value in pairs( tbl ) do
            if not RESERVED[ key ] then
                currentAlias[ key ] = value
            else
                throw("Cannot set redirects for reserved keys")
            end
        end
    end

    function class:mixin( target )
        base.__mixins[ #base.__mixins + 1 ] = target
    end

    function class:extend( target )
        if type( target ) ~= "string" then
            throw("Failed to extend class '"..name.."'. Target '"..tostring( target ).."' is not valid.")
        elseif base.__extends then
            throw("Failed to extend class '"..name.."' to target '"..target.."'. The base class already extends '"..base.__extends.."'")
        end

        base.__extends = target
    end

    function class:spawn( ... )
        if not isSealed then
            throw("Failed to spawn class '"..name.."'. The class is not sealed")
        elseif isAbstract then
            throw("Failed to spawn class '"..name.."'. The class is abstract")
        end

        return spawnClass( name, ... )
    end

    function class:getRaw()
        return base
    end

    function class:addSymbolicKey( k, v )
        sym = true
        self[ k ] = v
        sym = false
    end

    local baseProxy = {}
    function baseProxy:__newindex( k, v )
        if k == nil then
            throw("Failed to set nil key with value '"..tostring( v ).."'. Key names must have a value.")
        elseif RESERVED[ k ] then
            throw("Failed to set key '"..k.."'. Key is reserved.")
        elseif isSealed then
            throw("Failed to set key '"..k.."'. This class base is compiled.")
        end

        -- Set the value and 'defined' indexes
        base[ k ] = v

        if not sym then
            local vT = type( v )
            defined[ k ] = v ~= nil or nil
            definedProperties[ k ] = v and vT ~= "function" or nil -- if v is a value and its not a function then set true, otherwise nil.
            definedMethods[ k ] = v and vT == "function" or nil -- if v is a value and it is a function then true otherwise nil.
        end
    end
    baseProxy.__call = class.spawn
    baseProxy.__tostring = function() return "[Class Base] "..name end
    baseProxy.__index = base

    setmetatable( class, baseProxy )

    current = class
    classes[ name ] = class
    _G[ name ] = class

    return propertyCatch
end

_G.extends = function( target )
    if not current then
        throw("Failed to extend currently building class to target '"..tostring(target).."'. No class is being built.")
    end

    current:extend( target )
    return propertyCatch
end

_G.abstract = function()
    if not current then
        throw("Failed to set abstract state of currently building class because no class is being built.")
    end

    current:abstract( true )
    return propertyCatch
end

_G.mixin = function( target )
    if not current then
        throw("Failed to mixin target class '"..tostring( target ).."' to currently building class because no class is being built.")
    end

    current:mixin( target )
    return propertyCatch
end

_G.alias = function( target )
    if not current then
        throw("Failed to add alias redirects because no class is being built.")
    end

    current:alias( target )
    return propertyCatch
end

-- Class lib
local classLib = {}
function classLib.isClass( target )
    return type( target ) == "table" and target.__type and classes[ target.__type ] and classes[ target.__type ].__class -- target must be a table, must have a __type key and that key must correspond to a class name which contains a __class key.
end
function classLib.isInstance( target )
    return classLib.isClass( target ) and target.__instance
end
function classLib.typeOf( target, _type, isInstance )
    return ( ( isInstance and classLib.isInstance( target ) ) or ( not isInstance and classLib.isClass( target ) ) ) and target.__type == _type
end
function classLib.getClass( name ) return classes[ name ] end
function classLib.getClasses() return classes end
function classLib.setClassLoader( fn )
    if type( fn ) ~= "function" then return error("Cannot set missing class loader to variable of type '"..type( fn ).."'") end

    MISSING_CLASS_LOADER = fn
end
classLib.preprocess = preprocess
function classLib.runClassString( str, file, ignore )
    local ext = CRASH_DUMP.ENABLE and " The file being loaded at the time of the crash has been saved to '"..CRASH_DUMP.LOCATION.."'" or ""

    -- Preprocess the string
    local data = preprocess( str )

    local function errAndExport( err )
        export( data, file, err )
        error("Exception while loading class string for file '"..file.."': "..err.."."..ext, 0 )
    end

    -- Run the string
    local fn, exception = loadstring( data, file )
    if exception then
        errAndExport(exception)
    end

    local ok, err = pcall( fn )
    if err then
        errAndExport(err)
    end
    -- Load complete, seal the class if one was created.
    local name = gsub( file, "%..*", "" )
    local class = classes[ name ]
    if not ignore then
        if class then
            if not class:isSealed() then class:seal() end
        else
            -- The file didn't set a class, throw an error.
            export( data, file, "Failed to load class '"..name.."'" )
            error("File '"..file.."' failed to load class '"..name.."'"..ext, 0)
        end
    end
end

_G.classLib = classLib
