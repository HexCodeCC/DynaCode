class "MyDaemon" extends "Daemon"

function MyDaemon:start()
    local event = self.owner.event

    
    event:registerEventHandler("ExampleHandler", "TIMER", "EVENT", function()
        log("dw", "Timer event found from application event handler.")
    end)

    event:registerEventHandler("Terminate", "TERMINATE", "EVENT", function()
        error("DaemonService detected terminate event", 0)
    end)
end

function MyDaemon:stop( graceful )
    log(graceful and "di" or "de", "MyDaemon detected application close. " .. (graceful and "graceful" or "not graceful") .. ".")

    -- remove event registers
    local event = self.owner.event
    event:removeEventHandler("TIMER", "EVENT", "ExampleHandler")
    event:removeEventHandler("TERMINATE", "EVENT", "Terminate")
end
