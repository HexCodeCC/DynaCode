local gsub, match = string.gsub, string.match

-- Define Class Settings
local CRASH_DUMP = {
    ENABLE = false;
    LOCATION = "DynaCrash-Dump.crash"
}

local MISSING_CLASS_LOADER;
local RESERVED = {
    __type = true;
    __defined = true;
    __class = true;
    __extends = true;
    __instance = true;
    __alias = true;
};
local WORK_ENV = _G;

-- Define Class Variables
local raw_access

local current
local last
local classes = {}

local class = {}

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

--[[
    @local
    @desc Will try to execute 'method' passing arg 3+ to the call. If failed to execute 'err' will be thrown.
    @param
        @var method
        @string err
        @args ...
    @return methodCall OR error
]]
local function exec( method, err, ... )
    if type( method ) == "function" then
        return method( ... )
    else
        return error( err )
    end
end


--[[
    @local
    @desc Enables accessing of class raw content, grabs the raw content and disables access again. Returns content
    @param
        @class target
    @return table
]]
local function getRawContent( target )
    raw_access = true
    local c = target:getRaw()
    raw_access = false

    return c
end


--[[
    @local
    @desc Attempts to load 'target' via use of the custom class loader.
    @param
        @string target
    @return class OR error
]]
local function loadRequiredClass( target )
    -- Target class is required by another class. Store current configuration settings and load this class.
    local oCurrent = current
    local c, _c

    c = exec( MISSING_CLASS_LOADER, "MISSING_CLASS_LOADER method not defined. Cannot load missing target class '"..tostring(target).."'", target )

    _c = classes[ target ]
    if class.isClass( _c ) then
        if not _c:isSealed() then _c:seal() end
    else
        return error("Target class '"..tostring( target ).."' failed to load")
    end

    current = oCurrent -- restore old current (continue olding the class that required this class) AFTER the new class has been sealed (the target class may also require a class)
    return _c
end


local function fetchClass( target, mustBeSealed )
    local _c = classes[ target ]
    if class.isClass( _c ) then
        if _c:isSealed() or not mustBeSealed then
            return _c
        elseif mustBeSealed then
            return error("Failed to fetch target class '"..target.."'. Target isn't sealed.")
        end
    else
        return loadRequiredClass( target )
    end
end


--[[
    @local
    @desc Returned by class functions when a table of arguments may be expected to trail the call. The contents of the table will be added to the current class
    @param
        @table t
    @return nil OR error
]]
local function propertyCatch( t )
    if type( t ) == "table" then
        for key, value in pairs( t ) do
            if type( value ) == "function" then return error("Cannot set function indexes in class properties!") end

            current[ key ] = value
        end
    elseif type( t ) ~= "nil" then
        return error("Unknown object trailing class declaration '"..tostring( t ).." (" .. type( t ) .. ")'")
    end
end

--[[
    @local
    @desc Creates a completely independant table that contains all the same information as the 'source'
    @param
        @var source
    @return var
]]
local function deepCopy( source, useB )
    local orig_type = type( source )
    local copy
    if orig_type == 'table' then
        copy = {}
        for key, value in next, source, nil do
            if not useB or ( useB and not RESERVED[ key ] ) then
                copy[ deepCopy( key ) ] = deepCopy( value )
            end
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

--[[
    @local
    @desc Creates a matrix of super methods
    @param
        @class instance
        @string target
    @return table
]]
local function formSuper( instance, target, total )
    -- Find the class, load if it is required and not already loaded.
    local totalKeyPairs = total or {}
    local localKeys = {}

    local super = fetchClass( target, true )
    local superRaw = deepCopy( getRawContent( super ) )
    local superProxy, superProxyMt = {}, {}

    local sym

    for key, value in pairs( superRaw ) do
        if not RESERVED[ key ] then
            if not totalKeyPairs[ key ] then
                totalKeyPairs[ key ] = value
            end
            --localKeys[ key ]
        end
    end

    local function getKeyFromSuper( k )
        local last = superProxy

        while true do
            local _super = last.super
            if _super then
                if _super.__defined[ k ] then return _super[ k ] else last = _super end
            else break end
        end
    end

    if superRaw.__extends then
        local keys
        superProxy.super, keys = formSuper( instance, superRaw.__extends, totalKeyPairs )

        sym = true
        for key, value in pairs( keys ) do
            if not superRaw.__defined[ key ] then
                superRaw[ key ] = superProxy.super[ key ]
            end
        end
        sym = false
    end

    local function applyKeyValue( k, v )
        local last = instance
        local supers = {}

        while true do
            if last.__defined[ k ] then
                return true
            else
                supers[ #supers + 1 ] = last
                if last.super ~= superProxy and last.super then last = last.super
                else
                    for i = 1, #supers do supers[i]:addSymbolicKey( k, v ) end
                    break
                end
            end
        end
    end

    local cache = {}
    function superProxyMt:__index( k )
        -- search for the method on the supers raw
        if type( superRaw[ k ] ) == "function" then
            if not cache[ k ] then cache[ k ] = function( self, ... )
                local old = instance.super
                instance.super = superProxy.super

                local v = { superRaw[ k ]( instance, ... ) }

                instance.super = old
                return unpack( v )
            end end
            return cache[ k ]
        else
            return superRaw[ k ]
        end
    end

    function superProxyMt:__newindex( k, v )
        superRaw[ k ] = v == nil and getKeyFromSuper( k ) or v

        if not sym then superRaw.__defined[ k ] = v ~= nil or nil end
        applyKeyValue( k, v )
    end

    function superProxyMt:__tostring() return "[Super] "..superRaw.__type.." of "..tostring( instance ) end

    function superProxyMt:__call( ... )
        -- if a super table is called run the constructor.
        local initName = ( type( superRaw.initialise ) == "function" and "initialise" or ( type( superRaw.initialize ) == "function" and "initialize" or false ) )
        if initName then
            return superProxy[ initName ]( instance, ... )
        end
    end

    function superProxy:addSymbolicKey( k, v )
        sym = true; self[ k ] = v; sym = false
    end


    setmetatable( superProxy, superProxyMt )
    return superProxy, totalKeyPairs
end

--[[
    @local
    @desc Creates a new instance of class 'obj'
    @param
        @class obj
    @return class instance
]]
local function new( obj, ... )
    -- create instance tables
    local instanceRaw = deepCopy( getRawContent( obj ) )
    instanceRaw.__instance = true

    local instance, instanceMt = {}, {}
    local alias = instanceRaw.__alias or {}
    local sym

    instance.raw = instanceRaw

    local function seekFromSuper( key )
        local last = instance
        while true do
            local super = last.super
            if super then
                -- Check the super
                if super.__defined[ key ] then
                    -- This super owns a property with this key name
                    return super[ key ]
                else
                    last = super
                end
            else
                return nil
            end
        end
    end

    local keys
    if instanceRaw.__extends then
        instance.super, keys = formSuper( instance, instanceRaw.__extends )

        for key, value in pairs( keys ) do
            if not instanceRaw.__defined[ key ] and not RESERVED[ key ] then
                instanceRaw[ key ] = instance.super[ key ]
            end
        end
    end

    -- create instance proxies

    local getting = {}
    function instanceMt:__index( k )
        local k = alias[ k ] or k

        local getter = getters[ k ]
        if type(instanceRaw[ getter ]) == "function" and not getting[ k ] then
            getting[ k ] = true
            local v = { instanceRaw[ getter ]( self ) }
            getting[ k ] = nil

            return unpack( v )
        else
            return instanceRaw[ k ]
        end
    end

    local setting = {}
    function instanceMt:__newindex( k, v )
        local k = alias[ k ] or k

        local setter = setters[ k ]
        if type( instanceRaw[ setter ] ) == "function" and not setting[ k ] then
            setting[ k ] = true
            instanceRaw[ setter ]( self, v )
            setting[ k ] = nil
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

    -- additional instance methods
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

    local initName = ( type( instanceRaw.initialise ) == "function" and "initialise" or ( type( instanceRaw.initialize ) == "function" and "initialize" or false ) )
    if initName then instanceRaw[ initName ]( instance, ... ) end

    return instance
end


--[[
    @static
    @desc Creates a new class base
    @param
        @string name
    @return function
]]
function class.forge( name )
    -- Class definition
    local raw = {}
    raw.__class = true
    raw.__type = name
    raw.__defined = {}

    local proxy = {}

    -- Class private settings
    local isAbstract, isSealed, mixinTargets, rawMode = false, false, {}, false

    function proxy:isSealed() return isSealed end
    function proxy:isAbstract() return isAbstract end

    function proxy:seal()
        if isSealed then return error("Class is already sealed") end

        if #mixinTargets > 0 then
            -- implement these mixin targets
            for i = 1, #mixinTargets do
                local mixin = mixinTargets[ i ]

                local _class = fetchClass( mixin )

                local cnt = getRawContent( _class )
                for key, value in pairs( cnt ) do
                    if not raw[ key ] and not RESERVED[ key ] then
                        raw[ key ] = value
                    end
                end
            end
        end

        -- Compile the alias NOW! This is needed because DCML parsing gets the alias settings from the base class (because the instance isn't ready when DCML is parsing).
        local tAlias = self.__alias or {}
        local last = self

        local super, cnt
        while true do
            super = last.__extends
            if super then
                cnt = getRawContent( fetchClass( super, true ) )

                local _alias = cnt.__alias
                if _alias then
                    -- add these keys
                    for key, value in pairs( _alias ) do
                        if not tAlias[ key ] then tAlias[ key ] = value end
                    end
                end
                last = super
            else
                break
            end
        end

        self.__alias = tAlias

        isSealed = true
        if current == self then last = self current = nil end
    end

    function proxy:spawn( ... )
        if not isSealed then return error("Cannot spawn instance of '"..name.."'. Class is un-sealed") end
        if isAbstract then return error("Cannot spawn instance of '"..name.."'. Class is abstract") end

        return new( self, ... )
    end

    function proxy:getRaw()
        if not raw_access then return error("Cannot fetch raw content of class (DISABLED)") end

        return raw
    end

    function proxy:type()
        return self.__type
    end

    function proxy:symIndex( k, v )
        rawMode = true; self[ k ] = v; rawMode = false
    end

    function proxy:extend( target )
        if isSealed then return error("Cannot extend base class after being sealed") end

        self:symIndex( "__extends", target )
    end

    function proxy:mixin( target )
        if isSealed then return error("Cannot add mixin targets to class base after being sealed") end

        mixinTargets[ #mixinTargets + 1 ] = target
    end

    function proxy:abstract( bool )
        if isSealed then return error("Cannot modify abstract state of class base after being sealed") end

        isAbstract = bool
    end

    function proxy:alias( tbl )
        if isSealed then return error("Cannot set alias table of class base after being sealed") end

        if not raw.__alias then
            raw.__alias = tbl
        else
            for key, value in pairs( tbl ) do
                raw.__alias[ key ] = value -- override any others with the same key.
            end
        end
    end

    local proxyMt = {}
    function proxyMt:__newindex( k, v )
        if isSealed then return error("Cannot create new indexes on class base after being sealed") end

        raw[ k ] = v
        if not rawMode then
            raw.__defined[ k ] = v ~= nil or nil
        end
    end
    proxyMt.__index = raw

    function proxyMt:__tostring()
        return (isSealed and "[Sealed] " or "[Un-sealed] ") .. name
    end

    function proxyMt:__call( ... ) return self:spawn( ... ) end

    setmetatable( proxy, proxyMt )

    current = proxy
    WORK_ENV[ name ] = proxy
    classes[ name ] = proxy

    return propertyCatch
end


-- Util functions
function class.getClass( name ) return classes[ name ] end
function class.setClassLoader( fn )
    if type( fn ) ~= "function" then return error("Cannot set missing class loader to variable of type '"..type( fn ).."'") end

    MISSING_CLASS_LOADER = fn
end
function class.isClass( target )
    return type( target ) == "table" and type( target.type ) == "function" and classes[ target:type() ] and target.__class
end
function class.isInstance( target )
    return class.isClass( target ) and target.__instance
end
function class.typeOf( target, _type, strict )
    if not class.isClass( target ) or ( strict and not class.isInstance( target ) ) then return false end

    return target:type() == _type
end

function class.runClassString( str, file, ignore )
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

setmetatable( class, {
    __call = function( self, name ) return class.forge( name ) end
})

WORK_ENV.class = class
WORK_ENV.extends = function( target )
    if type( target ) ~= "string" then return error("Failed to extend building class to target '"..tostring( target ).."'. Invalid target") end

    current:extend( target )
    return propertyCatch
end
WORK_ENV.mixin = function( target )
    if type( target ) ~= "string" then return error("Failed to mix target class '"..tostring( target ).."' into the building class. Invalid target") end

    current:mixin( target )
    return propertyCatch
end
WORK_ENV.abstract = function()
    current:abstract( true )

    return propertyCatch
end
WORK_ENV.alias = function( tbl )
    if type( tbl ) == "string" then
        if type( WORK_ENV[ tbl ] ) == "table" then
            tbl = WORK_ENV[ tbl ]
        else
            return error("Cannot load table for alias from WORK_ENV: "..tostring( tbl ))
        end
    elseif type( tbl ) ~= "table" then
        return error("Cannot set alias to '"..tostring( tbl ).."'. Invalid type")
    end

    current:alias( tbl )
    return propertyCatch
end
