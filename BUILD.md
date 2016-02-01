# Building DynaCode

Depending on your use-case you will have to build DynaCode differently. This document aims to show you the two ways of building DynaCode.

#### What is building?
Building DynaCode is the process of gathering all source files and compacting them into one file. This one file can then be executed to load all DynaCode services.

## On The Fly Building
On the fly building is the fastest and easiest method of building DynaCode. To build DynaCode to `DynaCode.lua` the following command would be used:

`dobuild.lua` is the builder: `dobuild.lua <pathToSource> <outputFile>`

The first argument is the path to the DynaCode source, which in this repo is `/src/`. The second argument is the file to output the build to.

If you are building DynaCode from this repo then this is what I use to build it:
```lua
-- In a running file:
dofile("dobuild.lua", "src", "DynaCode.lua")

-- OR from command line:
dobuild.lua src DynaCode.lua
```

## Minification Building
This build method takes a little longer and requires you to install Lua on your computer command line.

#### Step 1
First, download Lua on your command line. The version you install needs to be 5.1.\*. When tested with 5.2 or 5.3 the builder failed (the third party LuaSrcDiet tool).

#### Step 2
Once Lua is ready to go, execute the `minify` file from this repo via the Lua interpreter (NOT ComputerCraft). This file takes no arguments as the paths are hardcoded. It will look in `/src/` for the source files and output the minified equivalent to `/minified/`.

If the minification fails check the troubleshooting section.

#### Step 3
Now that all the files are correctly minified execute `make <output> [--clean?]` in ComputerCraft.

The first argument being the file to output the build to. The second argument being `--clean`, this argument is optional and when provided the minified version of the files will be deleted once the build has completed.

### Troubleshooting
The DynaCode minification builder uses LuaSrcDiet (third party) to minify Lua source code. If your problem is due to this file please ensure you are running Lua version 5.1.\*

If the `minify` command doesn't work for you ensure you are running it through the Lua interpreter. Also, remember that the Minification builder only supports Windows and Mac.
