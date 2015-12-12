class "EventManager"
function EventManager:initialise( application, matrix )
    -- The matrix should contain a table of event -> event class: { ["mouse_up"] = MouseEvent }
    self.application = AssertClass( application, "Application", true, "EventManager instance requires an Application Instance, not: "..tostring( application ) )
    self.matrix = type( matrix ) == "table" and matrix or error("EventManager constructor (2) requires a table of event -> class types.", 2)

    self.register = {}
end

function EventManager:create( raw )
    local name = raw[1]

    local m  = self.matrix[ name ]
    if not class.isClass( m ) or not m.__event then
        return UnknownEvent( raw ) -- create a basic event structure. For events like timer, terminate and monitor events. Dev's can use the event name in caps with a sub of EVENT: {"timer", ID} -> Event.main == "SLEEP", Event.sub == "EVENT", Event.raw -> {"timer", ID}
    else
        return m( raw )
    end
end

function EventManager:registerEventHandler( ID, eventMain, eventSub, callback )
    local cat = eventMain .. "_" .. eventSub
    self.register[ cat ] = self.register[ cat ] or {}

    table.insert( self.register[ cat ], {
        ID,
        callback
    })
end

function EventManager:removeEventHandler( eventMain, eventSub, ID )
    local cat = eventMain .. "_" .. eventSub
    local register = self.register[ cat ]

    if not register then return false end

    for i = 1, #register do
        if register[i][1] == ID then
            table.remove( self.register[ cat ], i )
            return true
        end
    end
end

function EventManager:shipToRegistrations( event )
    local register = self.register[ event.main .. "_" .. event.sub ]

    if not register then return end

    for i = 1, #register do
        local r = register[i]

        r[2]( self, event )
    end
end
