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

    if fs.getName( path ) ~= ".DS_Store" then
        local h = fs.open( path, "r" )
        export[ fs.getName( files[i] ) ] = h.readAll()
        h.close()
    end
end

local final = "-- DynaCode - Class Edition - Harry Felton (HexCodeCC/hbomb_79)\n"
final = final .. "local files = "..textutils.serialise( export ) .. "\n"

final = final .. [==[
local dynacodeInitialisationFile = "init.lua"
local doNotVerify, loaded = {["Class.lua"] = true, [ dynacodeInitialisationFile ] = true}, {[ dynacodeInitialisationFile ] = true}
local function execute( data, name )
    if loaded[ name ] then return end

    local fn, err = loadstring( classLib and classLib.preprocess( data ) or data, name )
    if err then error("Failed to load string to Lua chunk for file '"..(name or "no name").."': "..err, 0) end

    local ok, err = pcall( fn )
    if err then error("Failed to execute Lua chunk for file '"..(name or "no name").."': "..err, 0) end

    if not doNotVerify[ name ] then
        local className = name:gsub("%..*", "")
        local class = classLib.getClass( className )

        if class then class:seal() else error("File '"..name.."' failed to create class '"..className.."'", 0) end
    end
    loaded[ name ] = true
end
local function executeFromPackage( name )
    execute( files[ name ] or error("File '"..name.."' couldn't be loaded because it doesn't exist in the package."), name)
end
local function scanLines( file, fn )
    local content = files[ file ]
    if content then for name in content:gmatch( "[^\n]+" ) do fn( name ) end loaded[ file ] = true end
end

if files["Class.lua"] then execute( files["Class.lua"], "Class.lua" ) else error("Failed to locate and load DynaCode Class System (Class.lua)", 0) end
classLib.setClassLoader(function( _c ) executeFromPackage( _c..".lua" ) end)

scanLines("scriptFiles.cfg", function( n ) doNotVerify[ n ] = true end)
scanLines("loadFirst.cfg", function( n ) executeFromPackage( n ) end)
for name, data in pairs( files ) do execute( data, name ) end

if files[ dynacodeInitialisationFile ] then
    loaded[ dynacodeInitialisationFile ] = nil
    execute( files[ dynacodeInitialisationFile ], dynacodeInitialisationFile )
end
]==]

local h = fs.open( OUTPUT_FILE, "w" )
h.write( final )
h.close()
