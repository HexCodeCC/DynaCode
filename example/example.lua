local app = Application( term.getSize() ) -- Application requires width, height
app.backgroundColour = colors.cyan

local stage = app + Stage({
    name = "TestStage";
    X = 5;
    Y = 5;
    width = 15;
    height = 7;
    textColour = colors.lightGray;
    titleTextColour = colors.white;
    titleBackgroundColour = 128;
    backgroundColour = colors.white;
    title = "Test Window";
})

stage:replaceWithDCML( "example/main.dcml" )

stage:addToController("submit", function( self, event )
    event:convertToRelative( self )
    error("Button '"..tostring( self ) .. "' has been clicked. Position: "..event.X..", "..event.Y)
end)

app:run()
