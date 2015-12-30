-- Define Class Settings
local CRASH_DUMP = {
    enable = false;
    location = "DynaCrash-Dump.crash"
}

local MISSING_CLASS_LOADER
local RESERVED = {}
local WORK_ENV = _G

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

    c = exec( MISSING_CLASS_LOADER, "MISSING_CLASS_LOADER method not defined. Cannot load missing target class '"..target.."' required by '"..oCurrent:type().."'", target )

    _c = classes[ target ]
    if class.isClass( _c ) then
        _c:seal()
    else
        return error("Target class failed to load")
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
            return error("Failed to fetch target '"..target.."'")
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
    local orig_type = type(source)
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

    local super = fetchClass( target, true )
    local superRaw = deepCopy( getRawContent( super ) )
    local superProxy = {}
    local superProxyMt = {}

    local sym

    for key, value in pairs( superRaw ) do
        if not totalKeyPairs[ key ] and not RESERVED[ key ] then
            totalKeyPairs[ key ] = value
        end
    end

    if superRaw.__extends then
        superProxy.super = formSuper( instance, superRaw.__extends, totalKeyPairs )
    end

    local function getKeyFromSuper( k )
        local last = superProxy

        while true do
            local _super = last.super
            if _super then
                if _super.__defined[ key ] then
                    return _super[ key ]
                else
                    last = _super
                end
            else
                break
            end
        end
    end

    local function applyKeyValue( k, v )
        local last = instance
        local isInstance = true

        local supers = {}

        while true do
            if last.__defined[ key ] then
                return true
            else
                supers[ #supers + 1 ] = last
                if last.super ~= super then
                    last = last.super
                else
                    -- set the key-value pair in all prior supers
                    for i = 1, #supers do
                        local _super = supers[ i ]
                        if isInstance then
                            isInstance = false
                        end

                        _super:addSymbolicKey( key, value )
                    end
                    break
                end -- no super or its this super...
            end
        end
    end

    function superProxyMt:__index( k )
        -- search for the method on the supers raw
        if type( superRaw[ k ] ) == "function" then
            if not cache[ k ] then cache[ k ] = function( self, ... )
                local old = instance.super
                instance.super = superProxy.super

                local v = { raw[ k ]( instance, ... ) }

                instance.super = old
                return unpack( v )
            end end
            return cache[ k ]
        else
            return superRaw[ k ]
        end
    end

    function superProxyMt:__newindex( k, v )
        raw[ k ] = v == nil and getKeyFromSuper( k ) or v -- if nil fetch a replacement via inheritance.

        if not sym then
            superRaw.__defined[ k ] = v ~= nil or nil
        end

        -- Instance
        applyKeyValue( k, v )
    end

    function superProxy:addSymbolicKey( k, v )
        sym = true
        self[ k ] = v
        sym = false
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
local function new( obj )
    local raw = deepCopy( obj )
    local instance, instanceMt = {}, {}

    local function seekFromSuper( key )
        local last = raw
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
    if raw.__extends then
        instance.super, keys = formSuper( instance, raw.__extends )
    end

    local getting = {}
    function instanceMt:__index( k )
        local k = alias[ k ] or k

        local getter = getters[ k ]
        if type(raw[ getter ]) == "function" and not getting[ k ] then
            getting[ k ] = true
            local v = { raw[ getter ]( self ) }
            getting[ k ] = nil

            return unpack( v )
        else
            return raw[ k ]
        end
    end

    local setting = {}
    function instanceMt:__newindex( k, v )
        local k = alias[ k ] or k

        local setter = setters[ k ]
        if type( raw[ setter ] ) == "function" and not setting[ k ] then
            setting[ k ] = true
            raw[ setter ]( self, v )
            setting[ k ] = nil
        else
            raw[ k ] = v
        end
        if v == nil then
            raw[ k ] = seekFromSuper( k )
        elseif not sym then
            raw.__defined[ k ] = v ~= nil or nil
        end
    end

    setmetatable( instance, instanceMt )
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
    local isAbstract, isSealed, mixinTargets, rawMode, alias = false, false, {}, false, false

    function proxy:seal()
        if isSealed then return error("Class is already sealed") end
        isSealed = true


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
    end

    function proxy:spawn( ... )
        if not isSealed then return error("Cannot spawn instance of '"..name.."'. Class is un-sealed") end
        if isAbstract then return error("Cannot spawn instance of '"..name.."'. Class is abstract") end

        return new( self, ... )
    end

    function proxy:getRaw()
        if not raw_access then return error("Cannot fetch raw content of class") end

        return raw
    end

    function proxy:type()
        return self.__type
    end

    function proxy:symIndex( k, v )
        rawMode = true
        self[ k ] = v
        rawMode = false
    end

    function proxy:extend( target )
        if isSealed then return error("Cannot extend base class after being sealed") end

        self.__extends = target
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

        alias = tbl
    end

    local proxyMt = {}
    function proxyMt:__newindex( k, v )
        if isSealed then return error("Cannot create new indexes on class base after being sealed") end

        raw[ k ] = v
        if not rawMode then
            raw.__defined[ k ] = v ~= nil or nil
        end
    end

    function proxyMt:__tostring()
        return (isSealed and "[Sealed]" or "[Un-sealed]") .. name
    end


    current = proxy
    WORK_ENV[ name ] = proxy
    classes[ name ] = proxy

    return propertyCatch
end


-- Util functions
function class.setClassLoader( fn )
    if type( fn ) ~= "function" then return error("Cannot set missing class loader to variable of type '"..type( fn ).."'") end

    MISSING_CLASS_LOADER = fn
end
function class.isClass( target )
    return classes[ target ] and target.__class
end
function class.isInstance( target )
    return class.isClass( target ) and target.__instance
end
function class.typeOf( target, _type, strict )
    if not class.isClass( target ) or ( strict and not class.isInstance( target ) ) then return false end

    return class:type() == _type
end


WORK_ENV.class = class
WORK_ENV.extends = function( target )
    if type( target ) ~= "string" then return error("Failed to extend building class to target '"..tostring( target ).."'. Invalid target") end

    current:extend( target )
    return propertyCatch
end
WORK_ENV.mixin = function( target )
    if type( target ) ~= "string" then return error("Failed to mix target class '"..tostring( target ).."' into the building class. Invalid target") end

    building:mixin( target )
    return propertyCatch
end
WORK_ENV.abstract = function()
    building:abstract( true )

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
