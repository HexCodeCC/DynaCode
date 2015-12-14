-- Compile DynaCode into one source files.

local tArgs = { ... }
if #tArgs ~= 2 then
    error(shell.getRunningProgram().." <SOURCE> <OUTPUT>", 1)
end

local SOURCE_DIRECTORY = tArgs[1]
local OUTPUT_FILE = tArgs[2]

local dirs = {""}
local files = {}

local function isInTable( tbl, key )
    if not tbl then return false end
    for i = 1, #tbl do
        if tbl[i] == key then return true end
    end
    return false
end

local function explore( _path, _results, exempt )

    local path = _path or ""
    local results = _results or {}

    if fs.exists( path ) then

        for _, file in ipairs( fs.list( path ) ) do
            local fPath = fs.combine( path, file )

            if not isInTable( exempt, fPath ) then
                if fs.isDir( fPath ) then
                    explore( fPath, results, exempt )
                else
                    table.insert( results, fPath )
                end
            end
        end
    else
        print("[WARN] Skipping path "..path.." as the location doesn't exist")
    end

    return results

end

local files = explore( SOURCE_DIRECTORY )

--[[local filesToRun = explore( SOURCE_DIRECTORY, nil, { "src/classes", "src/interfaces" } )
local classes = explore( fs.combine( SOURCE_DIRECTORY, "classes" ) )
local interfaces = explore( fs.combine( SOURCE_DIRECTORY, "interfaces" ) )]]

-- Open these files and output their content into the table.
local export = {}
for i = 1, #files do
    local path = files[ i ]
    local h = fs.open( path, "r" )
    export[ fs.getName( files[i] ) ] = h.readAll()
    h.close()
end


local final = ""
final = final .. [[
-- DynaCode - Class Edition

-- Files follow:
]]
final = final .. "local files = "..textutils.serialise( export ) .. "\n"

final = final .. [==[
-- Start of unpacker. This script will load all packed files and verify their classes were created correctly.

--[[
    Files checked (in order):
    - scriptFiles.cfg - Files in here are assumed to not load any classes, therefore the class will not be verified. (IGNORE FILE)
    - loadFirst.cfg - Files in here will be loaded before other classes
]]

local ignore = {
    ["Class.lua"] = true
}
local loaded = {}

local function executeString( name )
    -- Load this lua chunk from string.
    local fn, err = loadstring( files[ name ], name )
    if err then
        return error("Failed to load file '"..name.."'. Exception: "..err, 0)
    end

    -- Execute the Lua chunk if the loadstring was successful.
    local ok, err = pcall( fn )
    if err then
        return error("Error occured while running chunk '"..name.."': "..err, 0)
    end
end

-- Load the class library now!
if files[ "Class.lua" ] then
    executeString( "Class.lua" )
    loaded[ "Class.lua" ] = true
else
    return error("Cannot unpack DynaCode because the class library is missing (Class.lua)")
end

local function getHandleFromPack( file )
    if not files[ file ] then return false, 404 end
    return files[ file ]
end

local function loadFromPack( name )
    print( name )
    if loaded[ name ] then return end

    local ignoreFile = ignore[ name ]

    if not files[ name ] then
        return error("Cannot load file '"..name.."' from packed files because it cannot be found. Please check your DynaCode installation")
    end

    -- Execution complete, check class validity
    class.runClassString( files[ name ], name, ignoreFile )
    loaded[ name ] = true
end

class.setCustomLoader( function( _c )
    loadFromPack( _c..".lua" )
end )

-- First, compile a list of files to be ignored.
local content, err = getHandleFromPack( "scriptFiles.cfg" )
if content then
    for name in content:gmatch( "[^\n]+" ) do
		ignore[ name ] = true
	end
    loaded[ "scriptFiles.cfg" ] = true
end

local content, err = getHandleFromPack( "loadFirst.cfg" )
if content then
    for name in content:gmatch( "[^\n]+" ) do
		loadFromPack( name )
	end
    loaded[ "loadFirst.cfg" ] = true
end

for name, _ in pairs( files ) do
    loadFromPack( name )
end

class.setCustomViewer(function(_class)
    if class.isClass( _class ) then
        local t = _class:type()
        local file = t..".lua"

        if files[ file ] then
            local h = fs.open("tempSource.lua", "w")
            h.write( files[ file ] )
            h.close()

            shell.run("edit", "tempSource.lua")
        else
            return error("Class originates from unknown source")
        end
    else return error("Unknown object to anaylyse '" .. tostring( _class ) .. "'") end
end)
]==]


local h = fs.open( OUTPUT_FILE, "w" )
h.write( final )
h.close()
