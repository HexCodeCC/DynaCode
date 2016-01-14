class "Exception" extends "ExceptionBase"

function Exception:initialise( m, l )
    self.super( m, l, 6 )

    self.displayMessage = self:generateDisplayMessage("DynaCode Generic Exception")
end
