local tArgs = { ... }
if #tArgs < 1 then
    error("dobuild.lua <OUTPUT> [--clean ?]", 1)
end

local OUTPUT_FILE = tArgs[1]
local CLEAN = tArgs[2]


if not fs.isDir("minified") then error([[
DynaCode Make Error
===================

This file is the second step in building DynaCode, first 'minify'
must be executed using a Lua interpreter (which is not ComputerCraft).
]], 0) end

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


local files = explore( "minified" )
local content = {}

for i = 1, #files do
    local file = files[i]

    local h = fs.open( file, "r" )
    content[ fs.getName( file ) ] = h.readAll()
    h.close()
end

local final = ""
final = final .. [==[
--[[
    DynaCode Build

    The following document was created via a makefile. The 'files' table
    contains minified versions of every file for DynaCode's default source.

    To view the un-minified code please visit GitHub (HexCodeCC/DynaCode)
]]

]==]
final = final .. "local files = "..textutils.serialise( content ) .. "\n"

final = final .. [==[
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

class.setClassLoader( function( _c )
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
]==]


local h = fs.open( OUTPUT_FILE, "w" )
h.write( final )
h.close()

if CLEAN then
    fs.delete("minified")
end
