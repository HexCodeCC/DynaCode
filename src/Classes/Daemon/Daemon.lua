abstract class "Daemon" {
    acceptMouse = false;
    acceptMisc = false;
    acceptKeyboard = false;

    owner = nil;

    __daemon = true;
}

function Daemon:initialise( name )
    if not name then return error("Daemon '"..self:type().."' cannot initialise without name") end

    self.name = name
end

function Daemon:start() log("d", "WARNING: Daemon '"..self.name.."' ("..self:type()..") has no start function declared") end
function Daemon:stop() log("d", "WARNING: Daemon '"..self.name.."' ("..self:type()..") has no end function declared") end
