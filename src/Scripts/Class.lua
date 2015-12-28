--[[
    ComputerCraft Class Iteration - 4
    Copyright Harry Felton (HexCodeCC) 2015 - 2016

    This class system is still a heavy work in progress
    It should be assumed that certain features may be missing
    or do not function as they should.

    Please report any bugs you find to the HexCodeCC/DynaCode repo on GitHub

    Refer to file '/plan.md' for info on class
]]

local match, gsub = string.match, string.gsub

-- TODO load missing classes when using 'mixin' (current workaround: load the target class using 'loadFirst.cfg')

--[[ Settings ]]--
local WORK_ENV = _G;
local SAVE_CRASHED_FILES = false;
local CRASH_REPORT_LOCATION = "DynaCrash.crash";
local CUSTOM_CLASS_LOADER
local CUSTOM_SOURCE_VIEWER

--[[ Variables ]]--
local class = {}
local classes = {}
local building
local last

local allowRawAccess = false -- This is automatically changed, don't bother messing with it.

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

--[[ Methods ]]--
-- local helpers
local function propertyCatch( t )
    if type( t ) == "table" then
        for key, value in pairs( t ) do
            if type( value ) == "function" then return error("Cannot set function indexes in class properties!") end

            building[ key ] = value
        end
    elseif type( t ) ~= "nil" then
        return error("Unknown object trailing class declaration '"..tostring( t ).." (" .. type( t ) .. ")'")
    end
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

    local f = fs.open(CRASH_REPORT_LOCATION, "w")
    f.write( data .."-- END OF FILE --" )
    f.write("\n\n"..footer)
    f.close()
end

local blacklist = {
    __defined = true;
    __definedProperty = true;
    __definedFunction = true;
    __type = true;
    __class = true;

    spawn = true;
}
local function deepCopy( source, useB )
    local orig_type = type(source)
    local copy
    if orig_type == 'table' then
        copy = {}
        for key, value in next, source, nil do
            if not useB or ( useB and not blacklist[ key ] ) then
                copy[ deepCopy( key ) ] = deepCopy( value )
            end
        end
    else
        copy = source
    end
    return copy
end

local function formSupers( instance, _target, total )
    -- total will accumulate all supers keys, these can then be set on the instance afterwards to 'refresh' its indexes.
    local total = total or {}

    local sym = false

    local target = classes[ _target ]
    if not target then
        return error("Failed to extend instance '"..instance:type().."' to target '"..tostring( _target ).."'. The class cannot be found")
    elseif not target:isSealed() then
        return error("Failed to extend instance '"..instance:type().."' to target '"..tostring( _target ).."'. The class is not sealed")
    end

    -- We have the super class, create a copy of its contents, not the proxy.
    allowRawAccess = true
    local raw = deepCopy( target:getRaw() )
    allowRawAccess = false
    _G.raw = raw
    local super, superMt = {}, {}

    for key, value in pairs( raw ) do
        if not total[ key ] and not blacklist[ key ] then
            total[ key ] = value
        end
    end

    local function applyKeyValue( key, value )
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

    local function getKeyFromSuper( key )
        local last = super

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

    -- if this super has a super, then create that one too
    local _, keys
    if raw.__extends then super.super, _, keys = formSupers( instance, raw.__extends, total ) end
    -- Set any keys on this super from its parent. This only needs to be done for the immediate parent

    if keys then for key, value in pairs( keys ) do
        if not raw[ key ] and not blacklist[ key ] then
            raw[ key ] = value
        end
    end end

    -- Create the proxy (the interface between super and raw)
    local cache = {}
    function superMt:__index( k )
        if type( raw[ k ] ) == "function" then
            if not cache[ k ] then
                -- Cache the return function
                cache[ k ] = function( self, ... )
                    local old = instance.super
                    instance.super = super.super

                    local v = { raw[ k ]( instance, ... ) }

                    instance.super = old
                    return unpack( v )
                end
            end
            return cache[ k ]
        else
            return raw[ k ]
        end
    end
    function superMt:__newindex( k, v )
        -- A new index! Set the value on the super and then check if the instance can have it too.
        -- Super
        raw[ k ] = v == nil and getKeyFromSuper( k ) or v -- if nil fetch a replacement via inheritance.

        if not sym then
            local t = type( v )
            raw.__defined[ k ] = t ~= "nil" or nil
            raw.__definedProperty[ k ] = t ~= "function" or nil
            raw.__definedFunction[ k ] = t == "function" or nil
        end

        -- Instance
        applyKeyValue( k, v )
    end
    function superMt:__tostring()
        return "[Super] "..raw.__type.." of "..tostring( instance )
    end
    function superMt:__call( ... )
        -- if a super table is called run the constructor.
        local initName = ( type( raw.initialise ) == "function" and "initialise" or ( type( raw.initialize ) == "function" and "initialize" or false ) )
        if initName then
            raw[ initName ]( instance, ... )
        end
    end

    function super:addSymbolicKey( k, v )
        sym = true
        self[ k ] = v
        sym = false
    end
    setmetatable( super, superMt )


    return super, total, raw
end

-- Core class code
function class.getLast() return last end
function class.forge( name )

    if type( name ) ~= "string" or not string.match( name, "%a" ) then
        return error("Cannot create class with name '"..tostring( name ).."'. The name is invalid")
    end

    if classes[ name ] then return error("Cannot create class with name '"..tostring( name ).."'. A class with that name already exists") end

    local raw = {}
    local proxy, proxyMt = {}, {}
    local setToProxy = false

    local isAbstract, isSealed = false, false

    -- initialise the class base
    raw.__defined = {}
    raw.__definedProperty = {}
    raw.__definedFunction = {}
    raw.__type = name
    raw.__class = true

    -- create the class proxy
    function proxy:seal()
        setToProxy = true
        if isAbstract then
            function proxy:spawn()
                return error("Cannot spawn instance of abstract class '"..proxy:type().."'")
            end
        else
            function proxy:spawn( ... )
                -- instance private variables
                local sym = false
                local instanceRaw = deepCopy( raw )
                instanceRaw.__instance = true
                instanceRaw.__class = true

                local instance, instanceMt = {}, {}

                local alias = instanceRaw.__alias or {}

                local function seekFromSuper( key )
                    local last = instanceRaw
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
                -- Methods

                function instance:type()
                    return instanceRaw.__type
                end

                function instance:addSymbolicKey( k, v )
                    sym = true
                    self[ k ] = v
                    sym = false
                end

                local overridable = {
                    ["__add"] = true
                }
                function instance:__overrideMetaMethod( method, fn )
                    if not overridable[method] then
                        return error("Meta method '"..tostring( method ).."' cannot be overridden")
                    end

                    instanceMt[ method ] = fn
                end

                function instance:__lockMetaMethod( method ) overridable[ method ] = nil end

                -- metatable
                function instanceMt:__tostring()
                    return "[Instance] "..instanceRaw.__type
                end

                local getting = {}
                function instanceMt:__index( k )
                    -- If this key is aliased, then change the key to the redirect
                    local k = alias[ k ] or k

                    -- Search raw for a getter
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
                        -- simply set
                        instanceRaw[ k ] = v
                    end
                    -- If the new value is nil, then grab an inherited version from the supers
                    if v == nil then
                        instanceRaw[ k ] = seekFromSuper( k )
                    elseif not sym then
                        local t = type( v )

                        self.__defined[ k ] = t ~= "nil" or nil
                        self.__definedProperty[ k ] = t ~= "function" or nil
                        self.__definedFunction[ k ] = t == "function" or nil
                    end
                end


                -- create the super
                local keys
                if instanceRaw.__extends then
                    instanceRaw.super, keys = formSupers( instance, instanceRaw.__extends )
                end

                if keys then for name, value in pairs( keys ) do
                    -- if this instance doesn't define the key, set it from the supers
                    if not instanceRaw.__defined[ name ] and not blacklist[ name ] then
                        instanceRaw[ name ] = seekFromSuper( name )
                    end
                end end

                -- compile the instance alias table.
                if instanceRaw.super then
                    local new = {}

                    local current = instanceRaw
                    while true do
                        if current.__alias then
                            for k, v in pairs( current.__alias ) do
                                if not new[ k ] then
                                    new[ k ] = v
                                end
                            end
                        end
                        if current.super then current = current.super else break end
                    end

                    instanceRaw.__alias = new
                    alias = instanceRaw.__alias
                end

                setmetatable( instance, instanceMt )

                local initName = ( type( instanceRaw.initialise ) == "function" and "initialise" or ( type( instanceRaw.initialize ) == "function" and "initialize" or false ) )
                if initName then
                    instanceRaw[ initName ]( instance, ... )
                end

                return instance
            end
        end
        setToProxy = false

        -- any mixins?
        local mixins = raw.__mixinTargets
        if mixins then for i = 1, #mixins do
            local m = mixins[ i ]

            local class = classes[ m ]
            if not class then
                return error("Failed to mixin target class '"..tostring( m ).."'. The class cannot be found")
            elseif not class:isSealed() then
                return error("Failed to mixin target class '"..tostring( m ).."'. The class is not sealed")
            end

            allowRawAccess = true
            for key, value in pairs( class:getRaw() ) do
                if not raw[ key ] and not blacklist[ key ] then
                    raw[ key ] = value
                end
            end
            allowRawAccess = false

        end end

        proxyMt.__call = proxy.spawn
        isSealed = true

        last = building
        building = nil
    end

    function proxy:abstract( bool )
        if isSealed then return error("Cannot change abstract property of sealed class") end

        isAbstract = bool
    end

    function proxy:type()
        return raw.__type
    end

    function proxy:isSealed() return isSealed end
    function proxy:isAbstract() return isAbstract end

    function proxy:getRaw()
        return raw
    end

    -- redirect
    local setting = {}
    function proxyMt:__newindex( k, v )
        if isSealed then return error("Cannot create new indexes on sealed base class!") end

        raw[ k ] = v
        if not setToProxy then
            local tV = type( v )
            raw.__defined[ k ] = tV ~= "nil" or nil
            raw.__definedProperty[ k ] = tV ~= "function" or nil
            raw.__definedFunction[ k ] = tV == "function" or nil
        end
    end

    proxyMt.__index = raw

    function proxyMt:__tostring()
        return "[" .. (isSealed and "Sealed" or "Un-Sealed") .. " Class] " .. raw.__type
    end

    function proxyMt:__call() return error("Cannot spawn instance of class '" .. raw.__type .. "'. The class is not sealed.") end

    setmetatable( proxy, proxyMt )

    building = proxy
    classes[ name ] = building
    WORK_ENV[ name ] = building

    return propertyCatch
end

-- Other class code (mainly class parsing)
function class.isClass( _class ) return (type( _class ) == "table" and _class.__class) or false end

function class.isInstance( _class ) return (type( _class ) == "table" and _class.__instance) or false end

function class.typeOf( _class, _type, strict )
    -- is this even a class?
    if type( _class ) == "table" and _class.__class then
        if _class:type() ~= _type then return false end

        return ( strict and ( _class.__instance ) ) or not strict
    end
    return false
end

function class.setCustomLoader( fn )
    if type( fn ) ~= "function" then return error("Expected function") end

    CUSTOM_CLASS_LOADER = fn
end
function class.runClassString( str, file, ignore )
    -- str -> class data
    -- file --> Name used for loadString
    local ext = SAVE_CRASHED_FILES and " The file being loaded at the time of the crash has been saved to '"..CRASH_REPORT_LOCATION.."'" or ""

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
class.preprocess = preprocess
function class.getClasses() return classes end

function class.getClass( name ) return classes[ name ] end

function class.setCustomViewer( fn )
    if type( fn ) ~= "function" then return error("Expected function") end

    CUSTOM_SOURCE_VIEWER = fn
end

function class.viewSource( _class )
    -- finds the source of the class
    if not CUSTOM_SOURCE_VIEWER then
        return error("Cannot load source of class because no source viewer has been defined.")
    end

    CUSTOM_SOURCE_VIEWER( _class )
end


setmetatable( class, {__call = function(t, ...) return t.forge( ... ) end})


-- Global declaration
WORK_ENV.class = class
WORK_ENV.extends = function( target )
    if type( target ) ~= "string" then return error("Failed to extend building class to target '"..tostring( target ).."'. Invalid target") end

    building.__extends = target
    return propertyCatch
end
WORK_ENV.mixin = function( target )
    if type( target ) ~= "string" then return error("Failed to mix target class '"..tostring( target ).."' into the building class. Invalid target") end
    building.__mixinTargets = building.__mixinTargets or {}
    local t = building.__mixinTargets

    t[ #t + 1 ] = target

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
    building.__alias = tbl

    return propertyCatch
end
