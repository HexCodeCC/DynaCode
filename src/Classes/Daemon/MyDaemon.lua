class "MyDaemon" extends "Daemon"

function MyDaemon:start()
    local event = self.owner.event

    event:registerEventHandler("Terminate", "TERMINATE", "EVENT", function()
        error("DaemonService '"..self:type().."' named: '"..self.name.."' detected terminate event", 0)
    end)

    self.owner.timer:setTimer("MyDaemonTimer", 2, function( raw, timerEvent )
        log("di", "example check complete.")
    end, 5) -- set this timer a total of 5 times. ( the callback will be run 5 times over 10 seconds )
end

function MyDaemon:stop( graceful )
    log(graceful and "di" or "de", "MyDaemon detected application close. " .. (graceful and "graceful" or "not graceful") .. ".")

    -- remove event registers
    local event = self.owner.event
    event:removeEventHandler("TERMINATE", "EVENT", "Terminate")
end
