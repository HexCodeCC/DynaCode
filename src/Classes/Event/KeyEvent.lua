local sub = string.sub

class "KeyEvent" mixin "Event" {
    main = nil;
    sub = nil;
    key = nil;
    held = nil;
}

function KeyEvent:initialise( raw )
    self.raw = raw
    local u = string.find( raw[1], "_" )

    local t, m
    if u then
        t = sub( raw[1], u + 1, raw[1]:len() )
        m = sub( raw[1], 1, u - 1 )
    else
        t = raw[1]
        m = t
    end

    self.main = m:upper()
    self.sub = t:upper()
    self.key = raw[2]
    self.held = raw[3]
end

function KeyEvent:isKey( name )
    if keys[ name ] == self.key then return true end
end
