# Building DynaCode

DynaCode can be built via two methods. The first is the usual and can be done rather quickly using just ComputerCraft. The second minifies DynaCode source and is only really used to create builds that will be used.

### On-The-Fly Building
This method uses the `dobuild.lua` file. This file must be passed the directory in which to get the source and the location to save the output.

Ex:
```lua
dobuild.lua src/ bin/DynaCode.lua
```

### Minification Building
This method is a little more complex. The files `minify` and `make` are used for this build technique. This method only works on Windows at the moment

Firstly, run `minify` using a Lua interpreter (this cannot be ComputerCraft) in your command prompt.

```
lua minify
```

This will quickly gather information about all source files, open them, minify them and save the result to 'minified/'.

Then, run `make` in ComputerCraft to load these minified files, serialise them and save them to a build location (`make <OUTPUT>`). The resulting file will contain a table of
minified files and the necessary code to load them.

If the `make` file is run with `--clean` then the minified build files will be removed (which should be done as the minify file will remove the folder before building to remove files that are no longer needed).
