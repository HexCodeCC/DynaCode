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

--[[local myPanel = stage + Panel( 2, 2, 16, 5 ) -- fixed order of arguments (in this case X, Y, width, height). Also no other arguments can be in here, only these.
myPanel.backgroundColour = colours.grey]]


-- this code could be used
local myPanel = stage + Panel({
    Y = 2, -- any order of arguments. Arguments not needed by the contructor can also be set (eg. backgroundColour)
    X = 2,
    height = 5,
    width = 16,
    backgroundColour = colours.red
})

local myButton = myPanel + Button( "Hello World", 3, 1, 9, 4 )
local myButton2 = myPanel + Button( "Hello Again", 3, 10, 9, 4 ) -- tables can also be used to specify arguments with buttons, maybe you should try it out. Hop on Gitter if you have troubles

app:run()
