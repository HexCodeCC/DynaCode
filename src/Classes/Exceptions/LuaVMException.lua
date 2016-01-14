class "LuaVMException" extends "ExceptionBase"
function LuaVMException:initialise( m, l )
    self.super( m, l, 6, m )

    self.displayMessage = self:generateDisplayMessage("LuaVM Exception")
end
