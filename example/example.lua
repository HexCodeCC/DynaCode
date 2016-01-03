log:setLoggingEnabled( true )
log:setLoggingPath("DynaCode.log")

local app = Application( term.getSize() ) -- Application requires width, height
app.backgroundColour = colors.cyan

app:appendStagesFromDCML("example/main.dcml")

local mainStage = app:getStageByName( "TestStage" )

mainStage:addToController("close_app", function()
    app:finish()

    term.setBackgroundColour( 32768 )
    term.clear()
    term.setCursorPos(1, 1)
    print("Finished")
end)

app:run()
