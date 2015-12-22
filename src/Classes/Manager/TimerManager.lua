class "TimerManager" {
    timers = {};
}

-- Timers have an ID created by combining the current system time and the timer wait ( os.clock() + time ). This allows timers to be re-used rather than having multiple timer events for the same time.

function TimerManager:initialise( app )
    self.application = AssertClass( app, "Application", true, "TimerManager requires an application instance as its constructor argument. Not '"..tostring( app ).."'" )
end

function TimerManager:setTimer( name, secs, callback, repeatAmount ) -- repeatAmount can be "inf" or a number. Once reached will stop.
    if not ( type( name ) == "string" and type( secs ) == "number" and type( callback ) == "function" ) then
        return error("Expected string, number, function")
    end
    -- Run 'callback' in 'secs' seconds.
    local completeTime = os.clock() + secs -- os.clock() time when the timer completes
    local timerID

    -- Search for a timer that ends at the same time as this one.
    local timers = self.timers
    for i = 1, #timers do
        local timer = timers[i]
        if timer[1] == name then
            return error("Timer name '"..name.."' is already in use.")
        end

        if timer[3] == completeTime then
            -- this timer will finish at the same time, use its ID as ours (instead of a new os.startTimer() ID)
            timerID = timer[2]
        end
    end

    timerID = timerID or os.startTimer( secs )
    timers[ #timers + 1 ] = { name, timerID, completeTime, callback, secs, repeatAmount }

    return timerID
end

function TimerManager:removeTimer( name )
    -- Removes the timer with name 'name' from the schedule, cancels the timer event if its the only timer using it.

    local amount = 0
    local timers = self.timers
    local foundTimer
    local foundTimerID
    local foundTimerIndex

    local extra = {}

    for i = #timers, 1, -1 do
        local timer = timers[i]

        if timer[1] == name then
            foundTimer = timer
            foundTimerID = timer[2]
            foundTimerIndex = i
            amount = 1
        elseif foundTimer and timer[2] == foundTimerID then
            amount = amount + 1
        else
            -- these timers weren't checked, we will check these afterwards incase they use the same ID.
            extra[ #extra + 1 ] = timer
        end
    end
    if not foundTimer then return false end

    for i = 1, #extra do
        if extra[i][2] == foundTimerID then
            amount = amount + 1
        end
    end

    table.remove( self.timers, foundTimerIndex )
    if amount == 1 then
        os.cancelTimer( foundTimerID )
    else
        log( "w", (amount - 1) .. " timer(s) are still using the timer '"..foundTimerID.."'")
    end
end

function TimerManager:update( rawID ) -- rawID is from the second parameter of the timer event (from pullEvent)
    local timers = self.timers

    for i = #timers, 1, -1 do -- reverse so we can remove timers
        if timers[i][2] == rawID then
            local current = table.remove( self.timers, i )
            current[4]( rawID, current )

            local rep = current[6]
            local repT = type( rep )
            if rep and (repT == "string" and rep == "inf" or ( repT == "number" and rep > 1 )) then
                self:setTimer( current[1], current[5], current[4], repT == "number" and rep - 1 or "inf") -- name, secs, callback, repeating
            end
        end
    end
end
