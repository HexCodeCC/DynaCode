--[[
    DynaCode Project Compilation Software

    This program will build the given directory into a serialised table.
    Each file will then be run and will be expected to have created a class unless specified otherwise.

    Because certain files are not made to be run the builder allows you to exempt files or entire directories
    from execution. They will instead be unpacked into the environment and become an actual file. Thus allowing files that utilise
    those files to run them normally. IF you want all files to be unpacked then the --unpack-all can be used serving as an easy way to move
	an entire directory structure.

    To exempt a file (or directory) the path must be placed in a file, the file should then be named using the -e or --exempt flag.
    Eg: construct.lua -e MyExemptFile.txt

    The best way to layout a project in my opinion when using this compiler is:

    src/
      Classes/
        -- files that need to be run by the compiler
      Scripts/
        -- files that do not need to be run by the compiler

    This way the command:
      construct.lua -d --src src -e myExemptList.txt

	The .txt will contain the word Scripts/ on the first line.


    can be used to compile all your source with DynaCode included.

    In order to allow DynaCode to update after being packed into a package the DynaCode
    file will contain methods to search for updates

    If the --dynacode or -d flag is specified then DynaCode will be included (an installer) and run.
    Once DynaCode is run the users files will be executed.

    If the --src flag is specified followed by a source location then the files from that folder will be used
    when compiling. Eg: construct.lua -d --src my/source/folder/here

    The --out_dir and --out_file flag specify the build directory and file respectively.
    Eg: construct.lua -d --src SOURCE --out_dir bin --out_file MyProjectBuild.lua

    The --dynacode_location flag specifies where DynaCode will be downloaded to and loaded from
    in your projects. If DynaCode is included and the 'dynacode_location' file is not found DynaCode will
    be downloaded and saved to 'dynacode_location'.

    The --dyna-no-update flag will tell the builder to remove the snippet of code that handles DynaCode update.
    This means that the built in DynaCode updater will NOT be run when the project starts, helpful for projects that
    share a DynaCode installation.

    Flag --no-log will stop the builder from outputting debug information to a log file. The information in the log file matches the
    information on screen, however if too much is displayed or you don't want output to the terminal this is helpful.

    Flag --log-location will set the location that the builder will use to log information (if logger is note disabled)

    Flag --no-print will stop the builder from printing information to screen.

    Flag --no-output will stop the builder from printing or logging to file, this renders the builder completely silent (unless an error occurs.)

	Flag --init or -i specifies the file that will be called after loading DynaCode or before loading the users source code. This allows
	the developer a way to load DynaCode how they like and prepare the environment for them. The init file cannot be unpacked!

    Finally, if an argument does not match a flag it will be checked for a file. If a file at the path of the arguments
    exists it will be included in the export. If the file cannot be found then an error will be thrown stateing
    that the flag is unrecognised.
]]

local len, find, gsub, match = string.len, string.find, string.gsub, string.match
local insert = table.insert

local DYNACODE_URL = "https://raw.githubusercontent.com/HexCodeCC/DynaCode/master/bin/DynaCode-Stable.lua";

-- Default settings
local get_dynacode = false;
local src_directory = "/src/";
local out_directory = "/out/";
local out_file = "build.lua";
local check_dynacode_updates = true;
local dynacode_location = "DynaCode.lua";
local unpack_all_files = false;
local init_file = "startup";

local log_file = "construct.log";
local log_enable = true;
local print_enable = true;

local function explore( _path, _results )

    local path = _path or ""
    local results = _results or {}

    if fs.exists( path ) then
        for _, file in ipairs( fs.list( path ) ) do
            local fPath = fs.combine( path, file )

            if fs.isDir( fPath ) then
                explore( fPath, results, exempt )
            else
                table.insert( results, fPath )
            end
        end
    end

    return results
end

local toUnpack = {}

local function addExempt( args )
    local file = args[1]

    if not fs.exists( file ) then
        error("Cannot add exempt target file. File/Dir doesn't exist")
    end
    local toAdd = {}
    if fs.isDir( file ) then
        local content = explore( file )
        for i = 1, #content do
            insert( toAdd, content[i] )
        end
    else
        insert( toAdd, file )
    end

    for i = 1, #toAdd do
        toUnpack[ toAdd[i] ] = true
    end
end

local SUPPORTED_FLAGS = {
    ["-d"] = {0, function() get_dynacode = true end};
    ["--dynacode"] = {0, function() get_dynacode = true end};
    ["--dyna-no-update"] = {0, function() check_dynacode_updates = false end};
    ["--dynacode_location"] = {1, function( args ) dynacode_location = args[1] end};
    ["--src"] = {1, function( dir )
        src_directory = dir[1]
    end};
    ["--out_dir"] = {1, function( dir )
        out_directory = dir[1]
    end};
    ["--out_file"] = {1, function( file )
        out_file = file[1]
    end};
    ["--no-log"] = {0, function() log_enable = false end};
    ["--no-print"] = {0, function() print_enable = false end};
    ["--log-location"] = {1, function( args ) log_file = args[1] end};
    ["--no-output"] = {0, function() log_enable = false; print_enable = false; end};
    ["-e"] = {1, addExempt};
    ["--exempt"] = {1, addExempt};
    ["--unpack-all"] = {0, function() unpack_all_files = true end};
    ["-i"] = {1, function( args ) init_file = args[1] end};
    ["--init"] = {1, function( args ) init_file = args[1] end};
}

local function log( msg )
    local f = fs.open( log_file, "a" )
    f.write( msg .. "\n" )
    f.close()
end

local oPrint = _G.print
local function print( msg )
    if log_enable then log( msg ) end
    if print_enable then oPrint( msg ) end
end

if log_enable then
    local f = fs.open( log_file, "w" )
    f.close()
end


local oError = _G.error
local function error( msg, level )
    level = level and level + 1 or 2

    if log_enable then
        log("Construct Error: "..msg)
    end

    oError( msg, level )
end



-- Runtime
local toInclude = {}

local args = { ... }
if #args >= 1 then
    local i = 1
    while i <= #args do
        local flag = args[i]

        if SUPPORTED_FLAGS[ flag ] then
            -- check how many arguments this needs
            local amount = SUPPORTED_FLAGS[ flag ][1]
            local arguments
            if amount > 0 then
                if #args < amount or not args[ i + amount ] then
                    error("Flag '"..tostring( flag ).."' requires "..tostring( amount ).." argument"..( amount > 1 and "s" or ""))
                else
                    -- store the other flags and skip over them in the for loop.
                    arguments = {}
                    for k = i + 1, i + amount do
                        insert( arguments, args[ k ] )
                        i = i + 1
                    end
                end
            end

            local fn = SUPPORTED_FLAGS[ flag ][2]
            if type( fn ) == "function" then
                fn( arguments )
            end
        else
            -- must be a file to include.
            if fs.exists( flag ) then
                if fs.isDir( flag ) then
                    local contents = explore( flag )
                    for i = 1, #contents do
                        insert( toInclude, contents[i] )
                    end
                else
                    insert( toInclude, flag )
                end
            else
                error("Unknown flag or file not found '"..tostring( flag ).."'")
            end
        end
        i = i + 1
    end
end


local path = fs.combine( out_directory, out_file )
print("BEGIN export to '"..path.."'")

local file = fs.open( path, "w" )
file.write([=[--[[
This file was generated by DynaCodes project buider

]=] .. (get_dynacode and [[
DynaCode has been included in this package.
]] or "") .. [=[

The developers source code has been serialised into a table easy
distribution.
]]
]=])

print( (not get_dynacode and "Not t" or "T") .. "rying to include DynaCode" )
if get_dynacode then
    -- Insert a code snippet to download DynaCode on the client device
    file.write([[
if not fs.exists( "]] .. dynacode_location .. [[" ) then
    print("Downloading DynaCode to location ']]..dynacode_location..[['")
    local response = http.get("]]..DYNACODE_URL..[[")

    if response then
        local f = fs.open( "]]..dynacode_location..[[", "w" )
        f.write( response.readAll() )
        f.close()
    else
        error("Failed to download DynaCode from URL ']]..DYNACODE_URL..[['", 0)
    end
end

-- DynaCode should be ready to be used by user source now. User source included below

]])
end
print( "Building user source from directory: "..tostring( src_directory ) )

local files = explore( src_directory )
local file_contents = {}

print(#files.." files found in source directory '"..src_directory.."'")

for i = 1, #files do
    local file = files[i]

    print("Including source file '"..file.."'")

    local h = fs.open( file, "r" )
    file_contents[ (unpack_all_files or toUnpack[ file ]) and file or fs.getName( file ) ] = h.readAll()
    h.close()

	if unpack_all_files and not toUnpack[ file ] then
		toUnpack[ file ] = true
	end
end

print(#toInclude.." extra files to include")

for i = 1, #toInclude do
    local file = toInclude[i]

    print("Including extra file '"..file.."'")

    local h = fs.open( file, "r" )
    file_contents[ (unpack_all_files or toUnpack[ file ]) and file or fs.getName( file ) ] = h.readAll()
    h.close()

	if unpack_all_files and not toUnpack[ file ] then
		toUnpack[ file ] = true
	end
end

for name in pairs( toUnpack ) do
	print("File '"..name.."' will be unpacked on execution")
end

print(#toInclude + #files .." total files ready for export")

file.write([[
local filesToUnpack = ]] .. textutils.serialise( toUnpack ) .. [[

local files = ]]..textutils.serialise( file_contents )..[[

local function runFromString( name, content )
    local fn, err = loadstring( content, name )
    if err then
        error("Failed to load user source file '"..name.."'. Reason: Possible Syntax Exception "..tostring( err ), 0)
    end

    local ok, err = pcall( fn )
    if err then
        error("Failed to execute user source file '"..name.."'. Reason: Uncaught Exception "..tostring( err ), 0)
    end
end

if files[ "]] .. init_file .. [[" ] then
    runFromString( "]] .. init_file .. [[", files[ "]] .. init_file .. [[" ] )
    print("INIT file (]]..init_file..[[) executed")
end

for name, content in pairs( files ) do
	if filesToUnpack[ name ] then
		local h = fs.open( name, "w" )
		h.write( content )
		h.close()
	else
		print("Running file "..name)
        runFromString( name, content )
	end
end
]])

file.close()
print("Export complete!")
