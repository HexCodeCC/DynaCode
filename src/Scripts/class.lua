--[[
    ComputerCraft Class Iteration - 3
    Copyright Harry Felton (HexCodeCC) 2015

    This class system is still a heavy work in progress
    It should be assumed that certain features may be missing
    or do not function as they should.

    Please report any bugs you find to the hbomb79/DynaCode repo on GitHub

    Refer to file '/plan.md' for info on class
]]

local log = type(_G.log) == "function" and _G.log or (function() end)

local match, gsub = string.match, string.gsub

local class = {} -- Class API
local classes = {}

local lastSealed
local currentlyBuilding

local ENV = _G
local CUSTOM_CLASS_LOADER
local CUSTOM_SOURCE_VIEWER
local DUMP_CRASHED_FILES = true
local DUMP_LOCATION = "DynaCode-Crash.crash"
local SOURCE_DIRECTORY = "src/Classes"
local OVERWRITE_GLOBALS = false


--[[ Local Helper Functions ]]--

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

local blacklist = { -- these are class functions or reserved properties that shouldn't be taken accross to the instance from inheritance etc...
    ["__mixes"] = true;
    ["__implements"] = true;
    ["type"] = true;
    ["seal"] = true;
    ["__extends"] = true;
    ["spawn"] = true;
    ["setAbstract"] = true;
    ["setAlias"] = true;
    ["isSealed"] = true;
}

local function deepCopy( source )
    local orig_type = type(source)
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
local function getCurrent( ignore )
    return currentlyBuilding or ( not ignore and error("No class being built") or false )
end
local function getCurrentUnsealed( ignore )
    if not currentlyBuilding then
        return ignore and false or error("No class being built")
    else
        if currentlyBuilding:isSealed() then
            return error("Class is sealed")
        else
            return currentlyBuilding
        end
    end
end
local function propertyCatch( caught )
    if type( caught ) == "table" then
        for key, value in pairs( caught ) do
            if type( value ) == "function" then
                return error("Cannot set function in property list of class")
            else
                currentlyBuilding:addProperty( key, value )
            end
        end
    elseif type( caught ) ~= "nil" then
        return error("Unknown trailing property value: "..tostring(caught).." ("..type( caught )..")")
    end
end
local function setupSupersForInstance( instance, _super )
    -- Each super is basically an instance, it requires its own set of definedIndexes and Variables.
    local super = deepCopy( _super ) -- Create a copy of the super that is seperate from the base class.
    local new = {}
    local newMt = {}

    local function applyKeyValue( key, value )
        -- Search the instance supers for the key, return true if another super/the actual instance defines the key.
        local last = instance
        local isInstance = true

        local supers = {}

        while true do
            if last.__defined[ key ] then
                return true
            else
                supers [ #supers + 1 ] = last
                if last.super ~= new then
                    last = last.super
                else
                    -- set the key-value pair in all prior supers
                    for i = 1, #supers do
                        local super = supers[ i ]
                        if isInstance then
                            super:symIndex( key, value )
                            isInstance = false
                        else
                            super[ key ] = value
                        end
                    end
                    break
                end -- no super or its this super...
            end
        end
    end


    local function getKeyFromSuper( key )
        local last = new
        while true do
            local super = last.super
            if super then
                if super.__defined[ key ] then
                    return super[ key ]
                else
                    last = super
                end
            else
                break
            end
        end
    end

    -- If the super has a super as well, create a super for that
    if super.__extends then new.super = setupSupersForInstance( instance, super.__extends ) end

    -- Now, setup the interface
    local cache = {}
    function newMt:__index( k )
        if type( super[ k ] ) == "function" then
            if not cache[ k ] then
                -- Cache the return function
                cache[ k ] = function( self, ... )
                    local old = instance.super
                    instance.super = new.super

                    local v = { super[ k ]( instance, ... ) }

                    instance.super = old
                    return unpack( v )
                end
            end
            return cache[ k ]
        else
            return super[ k ]
        end
    end
    function newMt:__newindex( k, v )
        -- A new index! Set the value on the super and then check if the instance can have it too.
        -- Super
        super[ k ] = v == nil and getKeyFromSuper( k ) or v -- if nil fetch a replacement via inheritance.

        local t = type( v )
        super.__defined[ k ] = t ~= "nil"
        super.__definedProperty[ k ] = t ~= "function"
        super.__definedFunction[ k ] = t == "function"

        -- Instance
        applyKeyValue( k, v )
    end
    function newMt:__tostring()
        return "Super '"..super:type().."' of instance '"..instance:type().."'"
    end
    setmetatable( new, newMt )

    return new
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

    local f = fs.open(DUMP_LOCATION, "w")
    f.write( data .."-- END OF FILE --" )
    f.write("\n\n"..footer)
    f.close()
end

local function loadRequiredClass( class )
    if not class then return error("Class nil") end
    -- Search the source dir for the class.
    local path = fs.combine( SOURCE_DIRECTORY, class..".lua" )

    local pre = "Failed to load class '"..class.."' because the file '"..path.."'"
    if not fs.exists( path ) then
        return error( pre .. " doesn't exist")
    elseif fs.isDir( path ) then
        return error( pre .. " is a directory, expected a file")
    end

    -- Run the file and load the class
    dofile( path )
end

local function getRequiredClass( class )
    print("Class '"..tostring( class ).."' required by class '"..currentlyBuilding:type().."'")
    -- Class 'class' is required by another DynaCode task. Load it if not already loaded.
    if classes[ class ] then
        return classes[ class ]
    else
        -- Load the class
        local fn = CUSTOM_CLASS_LOADER or loadRequiredClass

        local oldBuild = currentlyBuilding
        local ok, err = pcall( function() fn( class ) end ) -- pcall so that oldBuild can still be restored.
        currentlyBuilding = oldBuild

        if err then
            return error("Failed to load required class '"..class.."' due to an exception: "..err)
        end
        return classes[ class ] or error("Failed to load class '"..class.."' because the file didn't define the class")
    end
end


--[[ Class Static Functions ]]--

class.preprocess = preprocess
function class.getClasses() return classes end

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

function class.getLast() return lastSealed end
function class.resolveSeal()
    -- Seal the currently building class
    if not currentlyBuilding then
        return error("No class is being built")
    else
        currentlyBuilding:seal()
    end
end
function class.setCustomLoader( fn )
    if type( fn ) ~= "function" then return error("Expected function") end

    CUSTOM_CLASS_LOADER = fn
end
function class.runClassString( str, file, ignore )
    -- str -> class data
    -- file --> Name used for loadString
    local ext = DUMP_CRASHED_FILES and " The file being loaded at the time of the crash has been saved to '"..DUMP_LOCATION.."'" or ""

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

function class:forge( name, ... )
    log("i", "Trying to create class '"..name.."'")
    -- Instance Local Variables --
    local isAbstract = false
    local sealed = false
    -- Instance Variables --
    local new = { __mixes = {}, __alias = {}, __implements = {}, __defined = {}, __definedProperty = {}, __definedFunction = {}, __class = true}
    local mixes, alias, implements, defined, definedProperty, definedFunction = new.__mixes, new.__alias, new.__implements, new.__defined, new.__definedProperty, new.__definedFunction
    local newMt = {}

    local function releaseClass()
        if classes[ name ] then
            log("e", "Failed to create class '"..name.."' because the class has already been created/name in use")
            return error("Class '"..name.."' is already defined")
        end
        if ENV[ name ] and not OVERWRITE_GLOBALS then
            log("e", "Failed to create class '"..name.."' because a variable with the same name already exists in the working class environment")
            return error("'"..name.."' already exists is the working environment")
        end
        classes[ name ] = new
        ENV[ name ] = new
        log("s", "Class '"..name.."' created and released")
    end

    function new:seal()
        -- Seal the class
        if sealed then log("e", "Class '"..name.."' already sealed, cannot seal again") return error("Class '"..name.."' has already been sealed") end
        if isAbstract then
            function self:spawn() return error("Cannot spawn instance of abstract class '"..name.."'") end
        else
            function self:spawn( ... )
                log("i", "Spawning instance of class '"..name.."'")
                local raw = deepCopy( self ) -- Literally copy the base class, no inheritance needed here as we do not care what happens to the base class after instantiation.
                local instanceMT = {}
                local instance = {}

                raw.__instance = true

                local mixes, alias, implements, defined, definedProperty, definedFunction = raw.__mixes, raw.__alias, raw.__implements, raw.__defined, raw.__definedProperty, raw.__definedFunction

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

                -- Instance is the ComputerCraft interface, raw contains all the variables/methods and instanceMT is the bridge between the two.

                -- Setup the bridge
                local getting = {}
                function instanceMT:__index( k )
                    -- If this key is aliased, then change the key to the redirect
                    local k = alias[ k ] or k

                    -- Search raw for a getter
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
                local sym = false
                function instanceMT:__newindex( k, v )
                    -- The setter is a little more complex. We must ensure that the instance definedIndex is updated when a new key is defined.
                    -- If the new value is nil, remove the key from the instance table completely and fetch a super alternative
                    -- If the new value is not nil, add the key to the appropiatte tables.

                    -- Because some variables may be 'symbolic', only update the definedIndex tables if the value is not symbolic
                    local k = alias[ k ] or k

                    local setter = setters[ k ]
                    if type( raw[ setter ] ) == "function" and not setting[ k ] then
                        setting[ k ] = true
                        raw[ setter ]( self, v )
                        setting[ k ] = nil
                    else
                        -- simply set
                        raw[ k ] = v
                    end
                    -- If the new value is nil, then grab an inherited version from the supers
                    if v == nil then
                        raw[ k ] = seekFromSuper( k )
                    elseif not sym then
                        local t = type( v )

                        self.__defined[ k ] = t ~= "nil" or nil
                        self.__definedProperty[ k ] = t ~= "function" or nil
                        self.__definedFunction[ k ] = t == "function" or nil
                    end
                end

                function instanceMT:__tostring()
                    return "Class Instance '"..name.."'"
                end

                -- Setup any instance methods
                function instance:symIndex( key, value )
                    sym = true
                    self[ key ] = value
                    sym = false
                end

                local overridable = {
                    ["__add"] = true
                }
                function instance:__overrideMetaMethod( method, fn )
                    if not overridable[method] then
                        return error("Meta method '"..tostring( method ).."' cannot be overridden")
                    end

                    instanceMT[ method ] = fn
                end

                function instance:__lockMetaMethod( method ) overridable[ method ] = nil end

                if raw.__extends then
                    instance.super = setupSupersForInstance( instance, raw.__extends )
                end

                setmetatable( instance, instanceMT )

                -- execute constructor
                local name = (type( instance[ "initialise" ] ) == "function" and instance.initialise or ( type( instance[ "initialize" ] ) == "function" and instance.initialize ) or false )
                if name then
                    log("i", "Running '"..self:type().."' instance constructor")
                    name( instance, ... )
                end

                return instance
            end
        end

        local function importTable( tbl, sym )
            for key, value in pairs( tbl ) do
                if not blacklist[ key ] and not self[ key ] then
                    self[ key ] = value

                    if not sym then
                        local t = type( value )
                        defined[ key ] = t ~= "nil" or nil
                        definedProperty[ key ] = t ~= "function" or nil
                        definedFunction[ key ] = t == "function" or nil
                    end
                elseif key == "__alias" and type( value ) == "table" and #value == 0 then
                    -- move the supers __alias table to this one.
                    self[ key ] = value
                end
            end
        end

        -- Initiate class
        importTable( self )

        -- Setup inheritance
        if self.__extends then
            -- copy keys accross raw
            importTable( self.__extends, true )
        end

        -- Copy mixins
        for i = 1, #mixes do
            importTable( mixes[i] ) -- order of mixes relates to importance
        end

        -- Check implements
        for i = 1, #implements do
            local implement = implements[ i ]

            for key, value in pairs( implement ) do
                if not blacklist[ key ] then
                    local t = type( value )
                    local tv = type( self[key] )
                    if t == "function" and tv ~= "function" then
                        return error("Cannot seal class because function "..key.." is missing as per implement '"..implement:type().."'")
                    elseif t ~= "nil" and tv == "nil" then
                        return error("Cannot seal class because property "..key.." is missing as per implement '"..implement:type().."'")
                    end
                end
            end
        end

        sealed = true

        lastSealed = currentlyBuilding
        currentlyBuilding = nil
    end
    function new:type()
        return tostring( name )
    end
    function new:isSealed() return sealed end
    function new:setAbstract( bool )
        if sealed then return error("Cannot change class abstract type after seal") end
        isAbstract = bool

        log("i", "Class '"..name.."' abstract adjusted: "..tostring( bool ))
    end
    function new:setAlias( tbl )
        if sealed then return error("Cannot set alias of class after seal") end
        if type( tbl ) ~= "table" and type( tbl ) ~= "string" then
            return error("Cannot set alias of class '"..name.."' to type '"..type( tbl ).."'")
        end

        if type( tbl ) == "string" then
            if ENV[ tbl ] then
                tbl = ENV[ tbl ]
            else
                return error("Cannot set alias to global variable '"..tbl.."'. The value doesn't exist in the class environment")
            end
        end
        self.__alias = tbl
    end

    function newMt:__tostring()
        return ( sealed and "Sealed" or "Un-sealed" ) .. " Class '"..self:type().."'"
    end

    newMt.__call = function( t, ... )
        if sealed then
            return t:spawn( ... )
        else
            return error("Cannot spawn instance of class '"..t:type().."' because the class is not sealed")
        end
    end

    function new:addProperty( k, v )
        if sealed then
            return error("Class has already been sealed, new settings cannot be added to this class via the base instance.")
        end
        local k = alias[ k ] or k

        local t = type( v )
        new[ k ] = v
        new.__defined[ k ] = t ~= "nil" or nil
        new.__definedProperty[ k ] = t ~= "function" or nil
        new.__definedFunction[ k ] = t == "function" or nil
    end

    setmetatable( new, newMt )

    releaseClass()
    currentlyBuilding = new

    return propertyCatch
end

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

setmetatable( class, {
    __call = class.forge
})

--[[ Global Functions ]]--
ENV.class = class
ENV.extends = function( _target )
    local class = getCurrentUnsealed()

    -- Extends to class
    if class.__extends then
        return error("Cannot extend class '"..class:type().."' to super '".._target.."' because the class already extends to '"..class.__extends.."'")
    end
    local target = getRequiredClass( _target )
    class.__extends = target

    return propertyCatch
end
ENV.abstract = function()
    -- set the currently building class to abstract
    local class = getCurrent()
    class:setAbstract( true )

    return propertyCatch
end
ENV.alias = function( alias )
    local class = getCurrent()
    class:setAlias( alias )

    return propertyCatch
end
ENV.implements = function( target )
    local class = getCurrentUnsealed()

    class.__implements[ #class.__implements + 1 ] = getRequiredClass( target )

    return propertyCatch
end
ENV.mixin = function( target )
    local class = getCurrentUnsealed()

    class.__mixes[ #class.__mixes + 1 ] = getRequiredClass( target )

    return propertyCatch
end
