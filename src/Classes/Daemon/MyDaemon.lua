class "MyDaemon" extends "Daemon"

function MyDaemon:start()
    local event = self.owner.event

    event:registerEventHandler("Terminate", "TERMINATE", "EVENT", function()
        error("DaemonService '"..self:type().."' named: '"..self.name.."' detected terminate event", 0)
    end)

    event:registerEventHandler("ContextMenuHandler", "MOUSE", "CLICK", function( handle, event )
        if event.misc == 2 then
            log("di", "context popup")
        end
    end)

    self.owner.timer:setTimer("MyDaemonTimer", 2, function( raw, timerEvent )
        para.text = [[
@align-center+tc-grey Hello my good man!

@tc-lightGrey I see you have found out how to use daemons and timers. You also seem to have un-commented the block of code that makes me appear.

Want to know how I do it? Head over to @tc-blue  src/Classes/Daemon/MyDaemon.lua @tc-lightGrey  to see the source code of... me!
]]
    end)
end

function MyDaemon:stop( graceful )
    log(graceful and "di" or "de", "MyDaemon detected application close. " .. (graceful and "graceful" or "not graceful") .. ".")

    -- remove event registers
    local event = self.owner.event
    event:removeEventHandler("TERMINATE", "EVENT", "Terminate")
end
