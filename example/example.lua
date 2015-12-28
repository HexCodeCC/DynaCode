local app = Application( term.getSize() ) -- Application requires width, height
app.backgroundColour = colors.cyan

local stage = app + Stage({
    name = "TestStage";
    X = 5;
    Y = 5;
    width = 20;
    height = 7;
    title = "Test Window";
})

-- this or

--[[local myPanel = stage + Panel( 2, 2, 16, 5 )
myPanel.backgroundColour = colours.grey]]


-- this code could be used
local myPanel = stage + Panel({
    Y = 2, -- any order of arguments
    X = 2,
    height = 5,
    width = 16,
    backgroundColour = colours.red
})

local myButton = myPanel + Button( "Hello World", 3, 1, 9, 4 )
local myButton2 = myPanel + Button( "Hello Again", 3, 10, 9, 4 )

app:run()
