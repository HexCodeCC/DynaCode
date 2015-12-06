class "Event" {
    raw = nil;

    handled = false;

    __event = true;
}

function Event:initialise( raw )
    self.raw = raw
end

function Event:isType( main, sub )
    if main == self.main and sub == self.sub then
        return true
    end
    return false
end
