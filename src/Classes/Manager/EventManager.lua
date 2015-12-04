class "EventManager"
function EventManager:initialise( application, matrix )
    -- The matrix should contain a table of event -> event class: { ["mouse_up"] = MouseEvent }
    self.matrix = type( matrix ) == "table" and matrix or error("EventManager constructor (2) requires a table of event -> class types.", 2)
end

function EventManager:create( raw )
    local name = raw[1]

    local m  = self.matrix[ name ]
    if not class.isClass( m ) or not m.__event then
        return Event( raw ) -- create a basic event structure. For events like sleep, terminate and monitor events.
    else
        return m( raw )
    end
end
