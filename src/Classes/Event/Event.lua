class "Event" {
    raw = nil;

    handled = false;

    __event = true;
}

function Event:isType( main, sub )
    if main == self.main and sub == self.sub then
        return true
    end
    return false
end
