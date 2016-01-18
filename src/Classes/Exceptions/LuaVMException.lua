class "LuaVMException" extends "ExceptionBase" {
    title = "Virtual Machine Exception";
    subTitle = "This exception has been raised because the Lua VM has crashed.\nThis is usually caused by errors like 'attempt to index nil', or 'attempt to perform __add on nil and number' etc...";
    useMessageAsRaw = true;
}
