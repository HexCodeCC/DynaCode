abstract class "MSubscriber" {
    handlers = {}
}

function MSubscriber:on( event, callback, ID )
    if not ( type( event ) == "string" and type( callback ) == "function" ) then
        return ParameterException("Event subscriptions require a string event type to listen for and a callback to use when caught")
    end

    if not self.handlers[ event ] then self.handlers[ event ] = {} end

    table.insert( self.handlers[ event ], {
        callback,
        ID
    })
end

function MSubscriber:offType( event )
    handlers[ event ] = nil
end

function MSubscriber:offID( ID )
    if type( ID ) ~= "string" then
        return ParameterException("Cannot unsubscribe from events with '"..tostring( ID ).."' ID.")
    end

    local total = self.handlers

    for event, handlers in pairs( total ) do
        for i = #handlers, 1, -1 do
            if type( handlers[ 2 ] ) == "string" and handlers[ 2 ] == ID then
                table.remove( handlers, i )
            end
        end
    end
end

function MSubscriber:call( event, ... )
    local handlers = self.handlers

    local total
    if handlers[ event ] then
        total = handlers[ event ]

        local handler
        for i = 1, #total do
            total[ i ][ 1 ]( self, ... )
        end
    end
end
