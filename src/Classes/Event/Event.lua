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

function Event:getName()
    local name = self.name
    if not name then
        self.name = self.main .. "_" .. self.sub

        return self.name
    end

    return name
end
