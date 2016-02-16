local insert = table.insert
abstract class "MTimerManager" {
    timers = {}
}

function MTimerManager:setTimer( name, time, callback, repeatAmount )
    if not ( type( name ) == "string" and type( time ) == "number" and type( callback ) == "function" ) then
        return ParameterException("Expected string, number, function to create timer")
    end

    local finishTime = os.clock() + time
    local timers, timer, timerID = self.timers

    for i = 1, #timers do
        timer = timers[ i ]
        if timer[ 1 ] == name then
            return ParameterException("Failed to create timer. A timer with name '"..name.."' is already running.")
        elseif timer[ 3 ] == finishTime and not timerID then
            timerID = timer[2]
        end
    end

    insert( timers, {
        name,
        timerID or os.startTimer( time ),
        finishTime,
        callback,
        time,
        repeatAmount
    })
end

function MTimerManager:removeTimer( name )
    local timers, timer = self.timers
    local canDispose, foundTimer, timerIndex

    local timerIDs = {}

    for i = 1, #timers do
        timer = timers[ i ]

        if not foundTimer and timer[ 1 ] == name then
            foundTimer, timerIndex = timer, i
        end

        if not foundTimer or timer[ 2 ] == foundTimer[ 2 ] then
            local ids = timerIDs[ timer[ 2 ] ]
            timerIDs[ timer[ 2 ] ] = ids and ids + 1 or 1
        end
    end
    if not foundTimer then return end
    table.remove( timers, timerIndex )

    if timerIDs[ foundTimer[ 2 ] ] <= 1 then
        os.cancelTimer( foundTimer[ 2 ] )
        log("w", "Cancelled timer")
    end
end

function MTimerManager:scanTimers( id )
    local timers, timer = self.timers

    for i = #timers, 1, -1 do
        timer = timers[ i ]

        if timer[ 2 ] == id then
            local old = table.remove( timers, i )
            old[4]( self )

            local repeatAmount, repeatType = old[ 6 ], type( old[ 6 ] )
            if (repeatType == "string" and repeatAmount == "inf") or (repeatType == "number" and repeatAmount > 0) then
                self:setTimer( current[1], current[5], current[4], repeatType == "number" and repeatAmount - 1 or repeatAmount )
            elseif repeatAmount then
                ParameterException("Unknown repeat amount of '"..tostring( repeatAmount ).." of type "..repeatType.."'. Only numbers above zero and 'inf' are allowed.")
            end
        end
    end
end
