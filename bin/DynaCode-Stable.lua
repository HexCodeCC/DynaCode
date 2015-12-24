-- DynaCode - Class Edition

-- Files follow:
local files = {
  [ "Node.lua" ] = "abstract class \"Node\" alias \"COLOUR_REDIRECT\" {\
    X = 1;\
    Y = 1;\
\
    width = 1;\
    height = 1;\
\
    visible = true;\
    enabled = true;\
\
    changed = true;\
\
    stage = nil;\
\
    canvas = nil;\
\
    __node = true;\
}\
\
function Node:initialise( ... )\
    ParseClassArguments( self, { ... }, { { \"X\", \"number\" }, { \"Y\", \"number\" }, { \"width\", \"number\" }, { \"height\", \"number\" } }, false, false )\
\
    -- Creates a NodeCanvas\
    self.canvas = NodeCanvas( self, self.width, self.height )\
end\
\
function Node:draw( xO, yO )\
    -- Call any draw functions on the node (pre, post) and update its 'changed' state. Then draw the nodes canvas to the stages canvas\
    if self.preDraw then\
        self:preDraw( xO, yO )\
    end\
\
    -- Draw to the stageCanvas\
    self.canvas:drawToCanvas( self.stage.canvas, self.X - 1, self.Y - 1 )\
    self.changed = false\
\
    if self.postDraw then\
        self:postDraw( xO, yO )\
    end\
end\
\
function Node:setX( x )\
    self.X = x\
end\
\
function Node:setY( y )\
    self.Y = y\
end\
\
function Node:setWidth( width )\
    --TODO Update canvas width\
    self.width = width\
end\
\
function Node:setHeight( height )\
    --TODO set height on instance and canvas.\
end\
\
function Node:setBackgroundColour( col )\
    --TODO force update on children too (if they are using the nodes color as default)\
    self.backgroundColour = col\
end\
\
function Node:setTextColour( col )\
    --TODO force update on children too (if they are using the nodes color as default)\
    self.textColour = col\
end\
\
function Node:onParentChanged()\
    self.changed = true\
end\
\
function Node:handleEvent( event )\
    -- Automatically fires callbacks on the node depending on the event. For example onMouseMiss, onMouseDown, onMouseUp etc...\
end",
  [ "StageCanvas.lua" ] = "class \"StageCanvas\" extends \"Canvas\" {\
    frame = nil;\
}\
\
function StageCanvas:initialise( ... )\
    self.super:initialise( ... )\
    self:redrawFrame()\
end\
\
function StageCanvas:redrawFrame()\
    -- This function creates a table of pixels representing the background and shadow of the stage.\
    -- Function should only be executed during full clears, not every draw.\
    local stage = self.stage\
\
    local hasTitleBar = not stage.borderless\
    local title = OverflowText(stage.title or \"\", self.width - ( stage.closeButton and 1 or 0 ) ) or \"\"\
    local hasShadow = stage.shadow\
\
    local shadowColour = stage.shadowColour\
    local titleColour = stage.titleTextColour\
    local titleBackgroundColour = stage.titleBackgroundColour\
    local backgroundColour = self.backgroundColour\
    local textColour = self.textColour\
\
    local width = self.width --+ ( stage.shadow and 1 or 0 )\
    local height = self.height + ( stage.shadow and 1 or 0 )\
\
    local frame = {}\
    local max = 0\
    for y = 0, height do\
        local yPos = width * y\
        for x = 1, width do\
            max = x > max and x or max\
            -- Find out what goes here (title, shadow, background)\
            local pos = yPos + x\
            if hasTitleBar and y == 0 and ( hasShadow and x < width or not hasShadow ) then\
                -- Draw the correct part of the title bar here.\
                if x == width - 1 and stage.closeButton then\
                    frame[pos] = {\"X\", stage.closeButtonTextColour, stage.closeButtonBackgroundColour}\
                else\
                    local char = string.sub( title, x, x )\
                    frame[pos] = {char ~= \"\" and char or \" \", titleColour, titleBackgroundColour}\
                end\
            elseif hasShadow and ( ( x == width and y ~= 0 ) or ( x ~= 1 and y == height - 1 ) ) then\
                -- Draw the shadow\
                frame[pos] = {\" \", shadowColour, shadowColour}\
            else\
                local ok = true\
                if hasShadow and ( ( x == width and y == 0 ) or ( x == 1 and y == height - 1 ) ) then\
                    ok = false\
                end\
                if ok then\
                    frame[pos] = { false, false, false } -- background\
                end\
            end\
        end\
    end\
    --error(\"Max X reached: \"..max)\
    self.frame = frame\
end\
\
function StageCanvas:drawToCanvas( canvas, xO, yO )\
    local buffer = self.buffer\
    local frame = self.frame\
    local stage = self.stage\
\
    local xO = type( xO ) == \"number\" and xO or 0\
    local yO = type( yO ) == \"number\" and yO or 0\
\
    local width = self.width --+ ( stage.shadow and 1 or 0 )\
    local height = self.height - ( stage.shadow and 0 or 1 )\
\
    for y = 0, height do\
        local yPos = width * y\
        local yBPos = canvas.width * ( y + yO )\
        for x = 1, width do\
            local pos = yPos + x\
            local bPos = yBPos + (x + xO)\
\
            local pixel = buffer[ pos ]\
            if pixel then\
                if not pixel[1] then\
                    -- draw the frame\
                    local framePixel = frame[ pos ]\
                    if framePixel then\
                        canvas.buffer[ bPos ] = { framePixel[1], framePixel[2] or self.textColour, framePixel[3] or self.backgroundColour }\
                    end\
                    --canvas.buffer[ bPos ] = framePixel\
                else\
                    -- draw the node pixel\
                    canvas.buffer[ bPos ] = { pixel[1] or \" \", pixel[2] or self.textColour or false, pixel[3] or self.backgroundColour or false }\
                end\
            else\
                canvas.buffer[ bPos ] = { false, false, false }\
            end\
        end\
    end\
end",
  [ "KeyEvent.lua" ] = "class \"KeyEvent\" extends \"Event\"",
  [ "Event.lua" ] = "class \"Event\" {\
    data = nil;\
    raw = nil;\
\
    handled = false;\
\
    __event = true;\
}\
\
function Event:initialise( raw )\
    self.raw = raw\
end\
\
function Event:isType( main, sub )\
    if main == self.main and sub == self.sub then\
        return true\
    end\
    return false\
end",
  [ "EventManager.lua" ] = "class \"EventManager\"\
function EventManager:initialise( application, matrix )\
    -- The matrix should contain a table of event -> event class: { [\"mouse_up\"] = MouseEvent }\
    self.matrix = type( matrix ) == \"table\" and matrix or error(\"EventManager constructor (2) requires a table of event -> class types.\", 2)\
end\
\
function EventManager:create( raw )\
    local name = raw[1]\
\
    local m  = self.matrix[ name ]\
    if not class.isClass( m ) or not m.__event then\
        return Event( raw ) -- create a basic event structure. For events like sleep, terminate and monitor events.\
    else\
        return m( raw )\
    end\
end",
  [ "Stage.lua" ] = "local insert = table.insert\
-- Stages have shadows when focused, these shadows are stored in the same buffer as the window. Because of this when a stage gains/looses a buffer the buffer should be resized accordingly.\
\
local function submitEvent( event )\
    -- sends event to nodes\
end\
\
local function handleClick( click )\
\
end\
\
local shadowB = false\
class \"Stage\" alias \"COLOUR_REDIRECT\" {\
    X = 1;\
    Y = 1;\
\
    width = 10;\
    height = 6;\
\
    --TODO: Proper borderless property.\
    borderless = false;\
\
    canvas = nil;\
\
    application = nil;\
\
    nodes = nil;\
\
    name = nil;\
\
    textColour = 1;\
    backgroundColour = 32768;\
\
    shadow = true;\
    focused = false;\
\
    closeButton = true;\
    closeButtonTextColour = 1;\
    closeButtonBackgroundColour = colours.red;\
}\
\
function Stage:initialise( ... )\
    -- Every stage has a unique ID used to find it afterwards, this removes the need to loop every stage looking for the correct object.\
    --TODO: Stage IDs\
\
    local name, X, Y, width, height = ParseClassArguments( self, { ... }, { {\"name\", \"string\"}, {\"X\", \"number\"}, {\"Y\", \"number\"}, {\"width\", \"number\"}, {\"height\", \"number\"}}, true, true )\
\
    self.canvas = StageCanvas( {width = width; height = height; textColour = self.textColour; backgroundColour = self.backgroundColour, stage = self} )\
\
    self.X = X\
    self.Y = Y\
    self.name = name\
\
    self.width = width\
    self.height = height\
\
    self:__overrideMetaMethod(\"__add\", function( a, b )\
        if class.typeOf(a, \"Stage\", true) then\
            if class.isInstance( b ) and b.__node then\
                -- add b (node) to a (stage)\
                return self:addNode( b )\
            else\
                return error(\"Invalid right hand assignment. Should be instance of DynaCode node. \"..tostring( b ))\
            end\
        else\
            return error(\"Invalid left hand assignment. Should be instance of Stage. \"..tostring( b ))\
        end\
    end)\
\
    self.nodes = {}\
    self:shadowUpdated()\
end\
\
function Stage:shadowUpdated()\
    -- if shadow is true and shadowB is false, expand the buffer\
    if self.shadow and not shadowB then\
        self.canvas.width = self.width + 1\
        self.canvas:redrawFrame()\
        shadowB = true\
    elseif not self.shadow and shadowB then\
        self.canvas.width = self.width\
        self.canvas:redrawFrame()\
        shadowB = false\
    end\
end\
\
function Stage:setApplication( app )\
    AssertClass( app, \"Application\", true, \"Stage requires Application Instance as its application. Not '\"..tostring( app )..\"'\")\
    self.application = app\
end\
\
function Stage:draw()\
    -- Firstly, clear the stage buffer and re-draw it.\
    self.canvas:redrawFrame()\
    -- order all nodes to re-draw themselves\
    for i = 1, #self.nodes do\
        self.nodes[ i ]:draw()\
    end\
\
    -- draw this stages contents to the application canvas\
    self.canvas:drawToCanvas( self.application.canvas, self.X, self.Y )\
end\
\
function Stage:addNode( node )\
    -- add this node\
    node.stage = self\
    insert( self.nodes, node )\
    return node\
end\
\
function Stage:setFocused( bool )\
\
end\
\
function Stage:handleEvent( event )\
    submitEvent( event )\
    --error( event )\
    if event:isType(\"MOUSE\", \"CLICK\") and not event.handled then\
        -- is this on this stage?\
\
        --TODO click detection, stage focusing, stage movement and resizing.\
        if self:onPoint( event.X, event.Y ) then\
            -- this click was on the stages hit area (not shadow)\
            event.handled = true -- stop other stages from reacting to this event (or any other class actually)\
            handleClick( event )\
        end\
    end\
end",
  [ "ApplicationCanvas.lua" ] = "local paint = { -- converts decimal to paint colors during draw time.\
    [1] = \"0\";\
    [2] = \"1\";\
    [4] = \"2\";\
    [8] = \"3\";\
    [16] = \"4\";\
    [32] = \"5\";\
    [64] = \"6\";\
    [128] = \"7\";\
    [256] = \"8\";\
    [512] = \"9\";\
    [1024] = \"a\";\
    [2048] = \"b\";\
    [4096] = \"c\";\
    [8192] = \"d\";\
    [16384] = \"e\";\
    [32768] = \"f\";\
}\
\
class \"ApplicationCanvas\" extends \"Canvas\" {\
    textColour = colors.red;\
    backgroundColour = 1;\
}\
\
function ApplicationCanvas:initialise( ... )\
    ParseClassArguments( self, { ... }, { {\"owner\", \"Application\"}, {\"width\", \"number\"}, {\"height\", \"number\"} }, true )\
    AssertClass( self.owner, \"Application\", true, \"Instance '\"..self:type()..\"' requires an Application Instance as the owner\" )\
\
    self.super:initialise( self.width, self.height )\
end\
\
function ApplicationCanvas:drawToScreen()\
    local xOffset = tonumber( xOffset ) and xOffset or 0\
    local yOffset = tonumber( yOffset ) and yOffset or 0\
\
    local width, height = self.width, self.height\
    local buffer = self.buffer\
\
    local oldT, oldB = 1, 32768\
    term.setBackgroundColor( 32768 )\
    term.setTextColor( 1 )\
\
    local printPixel\
    if term.blit then\
        printPixel = function( pixel )\
            term.blit( pixel[1] or \" \", paint[ pixel[2] or self.textColour ], paint[ pixel[3] or self.backgroundColour ] )\
        end\
    else\
        printPixel = function( pixel )\
            local tc, bg = pixel[2], pixel[3]\
            if oldT ~= tc then term.setTextColor( tc ) oldT = tc end\
            if oldB ~= bg then term.setBackgroundColor( bg ) oldB = bg end\
            term.write( pixel[1] )\
        end\
    end\
\
    for y = 1, height do\
        for x = 1, width do\
            if x + xOffset > 0 and x - xOffset <= width then\
                local pos = ( width * (y - 1 + yOffset) ) + x\
\
                term.setCursorPos( x, y )\
                if not buffer[pos] then\
                    printPixel { \" \", self.textColour, self.backgroundColour }\
                else\
                    printPixel( buffer[ pos ] )\
                end\
            end\
        end\
    end\
end",
  [ "loadFirst.cfg" ] = "ClassUtil.lua",
  [ "NodeCanvas.lua" ] = "local len, sub = string.len, string.sub\
\
class \"NodeCanvas\" extends \"Canvas\" {\
    node = nil;\
}\
\
function NodeCanvas:initialise( ... )\
    local node, width, height = ParseClassArguments( self, { ... }, { {\"node\", \"table\"}, {\"width\", \"number\"}, {\"height\", \"number\"} }, true, true )\
\
    if not class.isInstance( node ) then\
        return error(\"Node argument (first unordered) is not a class instance! Should be a node class instance. '\" .. tostring( node ) .. \"'\")\
    elseif not node.__node then\
        return error(\"Node argument (first unordered) is an invalid class instance. '\"..tostring( node )..\"'\")\
    end\
\
    self.super:initialise( width, height )\
end\
\
\
-- Methods for drawing geometry shapes into canvas.\
function NodeCanvas:drawTextLine( text, x, y, tc, bg, width, overflow )\
    -- draws a text line at the co-ordinates.\
    if overflow and width then text = OverflowText( text, width ) end\
\
    local yPos = self.width * (y - 1)\
    for i = 1, width or len( text ) do\
        if x + i + 1 < 0 or x + i - 1 > self.width then return end\
        local char = sub( text, i, i )\
        self.buffer[ yPos + i + x - 1 ] = { char ~= \"\" and char or \" \", tc, bg }\
    end\
end\
\
function NodeCanvas:drawXCenteredTextLine( text, y, tc, bg, overflow )\
    -- calculate the best X ordinate based on the length of the text and width of the node.\
end\
\
function NodeCanvas:drawYCenteredTextLine( text, x, tc, bg, overflow )\
\
end\
\
function NodeCanvas:drawCenteredTextLine( text, tc, bg, overflow )\
\
end",
  [ "Canvas.lua" ] = "abstract class \"Canvas\" alias \"COLOUR_REDIRECT\" {\
    width = 10;\
    height = 6;\
\
    buffer = nil;\
}\
\
function Canvas:initialise( ... )\
    local width, height = ParseClassArguments( self, { ... }, { {\"width\", \"number\"}, {\"height\", \"number\"} }, true, true )\
    self.width = width\
    self.height = height\
\
    if self:type() == \"StageCanvas\" then\
        width = width + 1\
        height = height + 1\
    end\
\
    local buffer = {}\
    for i = 1, width * height do\
        buffer[ i ] = { false, false, false }\
    end\
\
    self.buffer = buffer\
end\
\
function Canvas:drawToCanvas( canvas, xO, yO )\
    if not canvas then return error(\"Requires canvas to draw to\") end\
    local buffer = self.buffer\
\
    local xO = type( xO ) == \"number\" and xO or 0\
    local yO = type( yO ) == \"number\" and yO or 0\
\
\
    for y = 0, self.height - 1 do\
        local yPos = self.width * y\
        local yBPos = canvas.width * ( y + yO )\
        for x = 1, self.width do\
            local pos = yPos + x\
            local bPos = yBPos + (x + xO)\
\
            local pixel = buffer[ pos ]\
            canvas.buffer[ bPos ] = { pixel[1] or \" \", pixel[2] or self.textColour or false, pixel[3] or self.backgroundColour or false }\
        end\
    end\
end",
  [ "ClassUtil.lua" ] = "local insert = table.insert\
local len, sub, rep = string.len, string.sub, string.rep\
\
_G.ParseClassArguments = function( instance, args, order, require, raw )\
    -- 'instance' is the class instance (self) that is calling the ParseClassArguments function.\
    -- 'args' should be an array of the properties passed to the constructor.\
    -- 'order' is an optional array that specifies the required arguments and the order in which they should be returned to the caller (see raw)\
    -- 'require' is an optional boolean, if true all arguments specified in order must be defined, if false they are all optional.\
    -- 'raw' is an optional boolean, if true the 'order' table results will be returned to the caller, if false the required arguments will be set like normal settings.\
\
    local types = {}\
    local function checkType( key, value )\
        -- get the required type from the order table.\
        if type( order ) ~= \"table\" then return end\
        local _type = types[ key ]\
\
        if _type and type( value ) ~= _type then\
            if not class.typeOf( value, _type, true ) then\
                return error(\"Expected type '\".._type..\"' for argument '\"..key..\"', got '\"..type( value )..\"' instead.\")\
            end\
        end\
        return value\
    end\
\
    -- First, compile a list of required arguments using order and or require.\
    -- Any required arguments that are defined must be added to a constructor return table.\
    local argsToBeDefined = {}\
    if type( order ) == \"table\" and require then\
        for key, value in ipairs( order ) do\
            argsToBeDefined[ value[1] ] = true\
        end\
    end\
    local names = {}\
    if type( order ) == \"table\" then\
        for key, value in ipairs( order ) do\
            insert( names, value[1] )\
            types[ value[1] ] = value[2]\
        end\
    end\
\
    local provided = {}\
    if #args == 1 and type( args[1] ) == \"table\" then\
        -- If the args table contains a single table then parse the table\
        for key, value in pairs( args[1] ) do\
            provided[ key ] = checkType( key, value )\
            argsToBeDefined[ key ] = nil\
        end\
    else\
        -- If the args table is an array of properties then parse accordingly.\
        for key, value in ipairs( args ) do\
            local name = names[ key ]\
            if not name then\
                return error(\"Instance '\"..instance:type()..\"' only supports a max of \".. (key-1) ..\" unordered arguments. Consider using a key-pair table instead, check the wiki page for this class to find out more.\")\
            end\
            provided[ name ] = checkType( name, value )\
            argsToBeDefined[ name ] = nil\
        end\
    end\
\
    -- If argsToBeDefined has any values left, display those as missing arguments.\
    if next( argsToBeDefined ) then\
        local err = \"Instance '\"..instance:type()..\"' requires arguments:\\n\"\
\
        for key, value in ipairs( order ) do\
            if argsToBeDefined[ value[1] ] then\
                err = err .. \"- \"..value[1]..\" (\"..value[2]..\")\\n\"\
            end\
        end\
        err = err .. \"These arguments have not been defined.\"\
        return error( err )\
    end\
\
    -- set all settings\
    for key, value in pairs( provided ) do\
        if (types[ key ] and not raw) or not types[ key ] then\
            -- set the value\
            print(\"Setting \"..key)\
            instance[ key ] = value\
        end\
    end\
\
    local constructor = {}\
    if type( order ) == \"table\" and raw then\
        for key, value in ipairs( order ) do\
            insert( constructor, provided[ value[1] ] )\
        end\
        return unpack( constructor )\
    end\
end\
\
_G.AssertClass = function( _class, _type, _instance, err )\
    if not class.typeOf( _class, _type, _instance ) then\
        return error( err, 2 )\
    end\
    return _class\
end\
\
_G.AssertEnum = function( input, possible, err )\
    local ok\
    for i = 1, #possible do\
        if possible[ i ] == input then\
            ok = true\
            break\
        end\
    end\
\
    if ok then\
        return input\
    else\
        return error( err, 2 )\
    end\
end\
\
_G.COLOUR_REDIRECT = {\
    textColor = \"textColour\";\
    backgroundColor = \"backgroundColour\";\
\
    disabledTextColor = \"disabledTextColour\";\
    disabledBackgroundColor = \"disabledBackgroundColour\"\
}\
\
_G.OverflowText = function( text, max )\
    if len( text ) > max then\
        local diff = len( text ) - max\
        if diff > 3 then\
            if len( text ) - diff - 3 >= 1 then\
                text = sub( text, 1, len( text ) - diff - 3 ) .. \"...\"\
            else text = rep( \".\", max ) end\
        else\
            text = sub( text, 1, len( text ) - diff*2 ) .. rep( \".\", diff )\
        end\
    end\
    return text\
end",
  [ "Label.lua" ] = "class \"Label\" extends \"Node\" {\
    text = \"Label\";\
}\
\
function Label:preDraw()\
    -- draw the text to the canvas\
    local draw = self.canvas\
\
    draw:drawTextLine( self.text, 1, 1, self.textColour, self.backgroundColour, self.width, true )\
end",
  [ "MouseEvent.lua" ] = "local sub = string.sub\
\
class \"MouseEvent\" extends \"Event\" {\
    main = \"MOUSE\";\
    sub = nil;\
    X = nil;\
    Y = nil;\
    misc = nil; -- scroll direction, mouse button\
}\
\
function MouseEvent:initialise( raw )\
    self.super:initialise( raw )\
    local t = sub( raw[1], -string.find( raw[1], \"_\" ) + 1 )\
\
    self.sub = t:upper()\
    self.misc = raw[2]\
    self.X = raw[3]\
    self.Y = raw[4]\
end\
\
function MouseEvent:inArea( x1, y1, x2, y2 )\
    local x, y = self.X, self.Y\
    if x >= x1 and x <= x2 and y >= y1 and y <= y2 then\
        return true\
    end\
    return false\
end\
\
function MouseEvent:onPoint( x, y )\
    if self.X == x and self.Y == y then\
        return true\
    end\
    return false\
end",
  [ "Application.lua" ] = "local running\
local debug = true -- Allows reboot and application exit using keys. (\\ for reboot, / for application close)\
\
class \"Application\" alias \"COLOUR_REDIRECT\" {\
    canvas = nil;\
    hotkey = nil;\
    schedule = nil;\
    timer = nil;\
    event = nil;\
\
    stages = nil;\
    name = nil;\
\
    changed = true\
}\
\
function Application:initialise( ... )\
    -- Classes can be called with either a single table of arguments, or a series of required arguments. The latter only allows certain arguments.\
    -- Here, we use the classUtil.lua functionality to parse the arguments passed to the application.\
\
    ParseClassArguments( self, { ... }, { { \"name\", \"string\" }, { \"width\", \"number\" }, {\"height\", \"number\"} }, true )\
\
    self.canvas = ApplicationCanvas( self, self.width, self.height )\
    self.hotkey = HotkeyManager( self )\
    self.event = EventManager( self, {\
        [\"mouse_up\"] = MouseEvent;\
        [\"mouse_click\"] = MouseEvent;\
        [\"mouse_scroll\"] = MouseEvent;\
        [\"mouse_drag\"] = MouseEvent;\
\
        [\"key\"] = KeyEvent;\
        [\"key_up\"] = KeyEvent;\
        [\"char\"] = KeyEvent;\
    })\
    --[[self.schedule = ApplicationScheduler( self )\
    self.timer = TimeManager( self )]]\
\
    self.stages = {}\
    self:__overrideMetaMethod( \"__add\", function( a, b ) -- only allows overriding certain metamethods.\
        if class.typeOf( a, \"Application\", true ) then\
            -- allows stages to be added into the instance via the sugar of (app + stage)\
            if class.typeOf( b, \"Stage\", true ) then\
                return self:addStage( b )\
            else\
                return error(\"Invalid right hand assignment (\"..tostring( b )..\")\")\
            end\
        else\
            return error(\"Invalid left hand assignment (\" .. tostring( a ) .. \")\")\
        end\
    end)\
end\
\
function Application:setTextColour( col )\
    self.canvas.textColour = col\
    self.textColour = col\
end\
\
function Application:setBackgroundColour( col )\
    self.canvas.backgroundColour = col\
    self.backgroundColour = col\
end\
\
function Application:addStage( stage )\
    stage.application = self\
\
    self.stages[ #self.stages + 1 ] = stage\
    return stage\
end\
\
function Application:removeStage( stageOrName )\
    local isStage = class.typeOf( stageOrName, \"Stage\", true )\
    for i = 1, #self.stages do\
        local stage = self.stages[ i ]\
        if ( isStage and stage == stageOrName ) or ( not isStage and stage.name and stage.name == stageOrName ) then\
            table.remove( self.stages, i )\
        end\
    end\
end\
\
function Application:draw()\
    -- orders all stages to draw to the application canvas\
    --if not self.changed then return end\
\
    for i = 1, #self.stages do\
        self.stages[ i ]:draw()\
    end\
\
    -- Then draw the application to screen\
    self.canvas:drawToScreen()\
    self.changed = false\
end\
\
function Application:run( thread )\
    -- If present, exectute the callback thread in parallel with the main event loop.\
    running = true\
\
    local function engine()\
        -- DynaCode main runtime loop\
        while running do\
            self:draw()\
            local ev = { coroutine.yield() } -- more direct version of os.pullEventRaw\
            local event = self.event:create( ev )\
            if debug then if ev[1] == \"char\" and ev[2] == \"\\\\\" then os.reboot() elseif ev[1] == \"char\" and ev[2] == \"/\" then self:finish() end end\
\
            -- Pass the event to stages and process through any application daemons\
            for i = 1, #self.stages do\
                self.stages[i]:handleEvent( event )\
            end\
        end\
    end\
\
    if type(thread) == \"function\" then\
        ok, err = pcall( function() parallel.waitForAll( engine, thread ) end )\
    else\
        ok, err = pcall( engine )\
    end\
\
    if not ok and err then\
        -- crashed\
        term.setTextColour( colours.yellow )\
        print(\"DynaCode has crashed\")\
        term.setTextColour( colours.red )\
        print( err )\
        term.setTextColour( 1 )\
    end\
end\
\
function Application:finish( thread )\
    running = false\
    os.queueEvent(\"stop\") -- if the engine is waiting for an event give it one so it can realise 'running' is false -> while loop finished -> exit and return.\
    if type( thread ) == \"function\" then thread() end\
end\
\
class \"Test\"",
  [ "scriptFiles.cfg" ] = "ClassUtil.lua",
  [ "HotkeyManager.lua" ] = "local insert, remove, sub, len = table.insert, table.remove, string.sub, string.len\
\
class \"HotkeyManager\" {\
    keys = nil;\
    combinations = nil;\
\
    application = nil;\
}\
\
function HotkeyManager:initialise( application )\
    self.application = AssertClass( application, \"Application\", true, \"HotkeyManager requires an Application Instance as its constructor argument, not '\"..tostring( application )..\"'\")\
\
    self.keys, self.combinations = {}, {}\
end\
\
local function matchCombination()\
\
end\
\
function HotkeyManager:assignKey()\
    -- A key has been pressed\
end\
\
function HotkeyManager:relieveKey()\
    -- A key has been un-pressed (key up/relieved)\
end\
\
function HotkeyManager:checkCombination()\
    -- A program wants to know if a combination of keys has been met\
end\
\
function HotkeyManager:registerCombination()\
    -- Register this combination with a specified callback to be executed when its met.\
end\
\
function HotkeyManager:removeCombination()\
    -- Remove a combination by name.\
end\
\
function HotkeyManager:checkCombinations()\
    -- Checks every combinations matching requirements against the pressed keys.\
end",
  [ "class.lua" ] = "--[[\
    ComputerCraft Class Iteration - 3\
    Copyright Harry Felton (HexCodeCC) 2015\
\
    This class system is still a heavy work in progress\
    It should be assumed that certain features may be missing\
    or do not function as they should.\
\
    Please report any bugs you find to the hbomb79/DynaCode repo on GitHub\
\
    Refer to file '/plan.md' for info on class\
]]\
\
local match, gsub = string.match, string.gsub\
\
local class = {} -- Class API\
local classes = {}\
\
local lastSealed\
local currentlyBuilding\
\
local ENV = _G\
local CUSTOM_CLASS_LOADER\
local CUSTOM_SOURCE_VIEWER\
local DUMP_CRASHED_FILES = true\
local DUMP_LOCATION = \"DynaCode-Crash.crash\"\
local SOURCE_DIRECTORY = \"src/Classes\"\
local OVERWRITE_GLOBALS = false\
\
\
--[[ Local Helper Functions ]]--\
\
local setters = setmetatable( {}, {__index = function( self, key )\
    -- This will be called when a setter we need is not cached. Create the name and change the name.\
    local setter = \"set\" .. key:sub( 1,1 ):upper() .. key:sub( 2 )\
    self[ key ] = setter\
\
    return setter\
end})\
local getters = setmetatable( {}, {__index = function( self, key )\
    local getter = \"get\" .. key:sub( 1,1 ):upper() .. key:sub( 2 )\
    self[ key ] = getter\
\
    return getter\
end})\
\
local blacklist = { -- these are class functions or reserved properties that shouldn't be taken accross to the instance from inheritance etc...\
    [\"__mixes\"] = true;\
    [\"__implements\"] = true;\
    [\"type\"] = true;\
    [\"seal\"] = true;\
    [\"__extends\"] = true;\
    [\"spawn\"] = true;\
    [\"setAbstract\"] = true;\
    [\"setAlias\"] = true;\
    [\"isSealed\"] = true;\
}\
\
local function deepCopy( source )\
    local orig_type = type(source)\
    local copy\
    if orig_type == 'table' then\
        copy = {}\
        for key, value in next, source, nil do\
            copy[ deepCopy( key ) ] = deepCopy( value )\
        end\
    else\
        copy = source\
    end\
    return copy\
end\
local function getCurrent( ignore )\
    return currentlyBuilding or ( not ignore and error(\"No class being built\") or false )\
end\
local function getCurrentUnsealed( ignore )\
    if not currentlyBuilding then\
        return ignore and false or error(\"No class being built\")\
    else\
        if currentlyBuilding:isSealed() then\
            return error(\"Class is sealed\")\
        else\
            return currentlyBuilding\
        end\
    end\
end\
local function propertyCatch( caught )\
    if type( caught ) == \"table\" then\
        for key, value in pairs( caught ) do\
            if type( value ) == \"function\" then\
                return error(\"Cannot set function in property list of class\")\
            else\
                currentlyBuilding:addProperty( key, value )\
            end\
        end\
    elseif type( caught ) ~= \"nil\" then\
        return error(\"Unknown trailing property value: \"..tostring(caught)..\" (\"..type( caught )..\")\")\
    end\
end\
local function setupSupersForInstance( instance, _super )\
    -- Each super is basically an instance, it requires its own set of definedIndexes and Variables.\
    local super = deepCopy( _super ) -- Create a copy of the super that is seperate from the base class.\
    local new = {}\
    local newMt = {}\
\
    local function applyKeyValue( key, value )\
        -- Search the instance supers for the key, return true if another super/the actual instance defines the key.\
        local last = instance\
        local isInstance = true\
\
        local supers = {}\
\
        while true do\
            if last.__defined[ key ] then\
                return true\
            else\
                supers [ #supers + 1 ] = last\
                if last.super ~= new then\
                    last = last.super\
                else\
                    -- set the key-value pair in all prior supers\
                    for i = 1, #supers do\
                        local super = supers[ i ]\
                        if isInstance then\
                            super:symIndex( key, value )\
                            isInstance = false\
                        else\
                            super[ key ] = value\
                        end\
                    end\
                    break\
                end -- no super or its this super...\
            end\
        end\
    end\
\
\
    local function getKeyFromSuper( key )\
        local last = new\
        while true do\
            local super = last.super\
            if super then\
                if super.__defined[ key ] then\
                    return super[ key ]\
                else\
                    last = super\
                end\
            else\
                break\
            end\
        end\
    end\
\
    -- If the super has a super as well, create a super for that\
    if super.__extends then new.super = setupSupersForInstance( instance, super.__extends ) end\
\
    -- Now, setup the interface\
    local cache = {}\
    function newMt:__index( k )\
        if type( super[ k ] ) == \"function\" then\
            if not cache[ k ] then\
                -- Cache the return function\
                cache[ k ] = function( self, ... )\
                    local old = instance.super\
                    instance.super = new.super\
\
                    local v = { super[ k ]( instance, ... ) }\
\
                    instance.super = old\
                    return unpack( v )\
                end\
            end\
            return cache[ k ]\
        else\
            return super[ k ]\
        end\
    end\
    function newMt:__newindex( k, v )\
        -- A new index! Set the value on the super and then check if the instance can have it too.\
        -- Super\
        super[ k ] = v == nil and getKeyFromSuper( k ) or v -- if nil fetch a replacement via inheritance.\
\
        local t = type( v )\
        super.__defined[ k ] = t ~= \"nil\"\
        super.__definedProperty[ k ] = t ~= \"function\"\
        super.__definedFunction[ k ] = t == \"function\"\
\
        -- Instance\
        applyKeyValue( k, v )\
    end\
    function newMt:__tostring()\
        return \"Super '\"..super:type()..\"' of instance '\"..instance:type()..\"'\"\
    end\
    setmetatable( new, newMt )\
\
    return new\
end\
\
local function preprocess( data )\
    local name = match( data, \"abstract class (\\\"%w*\\\")\")\
    if name then\
        data = gsub( data, \"abstract class \"..name, \"class \"..name..\" abstract()\")\
    end\
    return data\
end\
\
local function export( data, _file, EX )\
\
    -- Parse the error\
    local EX_LINE\
    local EX_MESSAGE\
    -- Errors usually follow the format of: FILE:LINE: EXCEPTION. Or EXCEPTION alone. If we cannot find a line number we will declare it unknown\
    local file, line, message = string.match( EX, \"(.+)%:(%d+)%:(.*)\" )\
\
    if file and line and message then\
        -- We parsed the data\
        EX_LINE = line\
        EX_MESSAGE = message\
    else\
        -- Maybe an error with no file name/line (error with level zero)\
        EX_MESSAGE = EX\
    end\
\
    local footer = [==[\
--[[\
    DynaCode Crash Report (0.1)\
    =================\
\
    This file was generated because DynaCode's class system\
    ran into a fatal exception while running this file.\
\
    Exception Details\
    -----------------\
    File: ]==] .. tostring( file or _file or \"?\" ) .. [==[\
\
    Line Number: ]==] .. tostring( EX_LINE or \"?\" ) .. [==[\
\
    Error: ]==] .. tostring( EX_MESSAGE or \"?\" ) .. [==[\
\
\
    Raw: ]==] .. tostring( EX or \"?\" ) .. [==[\
\
    -----------------\
    The file that was being loaded when DynaCode crashed\
    has been inserted above.\
\
    The file was pre-processed before loading, so as a result\
    the code above may not match your original source\
    exactly.\
\
    NOTE: This file is purely a crash report, editing this file\
    will not have any affect. Please edit the source file (]==] .. tostring( file or _file or \"?\" ) .. [==[)\
]]]==]\
\
    local f = fs.open(DUMP_LOCATION, \"w\")\
    f.write( data ..\"-- END OF FILE --\" )\
    f.write(\"\\n\\n\"..footer)\
    f.close()\
end\
\
local function loadRequiredClass( class )\
    if not class then return error(\"Class nil\") end\
    -- Search the source dir for the class.\
    local path = fs.combine( SOURCE_DIRECTORY, class..\".lua\" )\
\
    local pre = \"Failed to load class '\"..class..\"' because the file '\"..path..\"'\"\
    if not fs.exists( path ) then\
        return error( pre .. \" doesn't exist\")\
    elseif fs.isDir( path ) then\
        return error( pre .. \" is a directory, expected a file\")\
    end\
\
    -- Run the file and load the class\
    dofile( path )\
end\
\
local function getRequiredClass( class )\
    print(\"Class '\"..tostring( class )..\"' required by class '\"..currentlyBuilding:type()..\"'\")\
    -- Class 'class' is required by another DynaCode task. Load it if not already loaded.\
    if classes[ class ] then\
        return classes[ class ]\
    else\
        -- Load the class\
        local fn = CUSTOM_CLASS_LOADER or loadRequiredClass\
\
        local oldBuild = currentlyBuilding\
        local ok, err = pcall( function() fn( class ) end ) -- pcall so that oldBuild can still be restored.\
        currentlyBuilding = oldBuild\
\
        if err then\
            return error(\"Failed to load required class '\"..class..\"' due to an exception: \"..err)\
        end\
        return classes[ class ] or error(\"Failed to load class '\"..class..\"' because the file didn't define the class\")\
    end\
end\
\
\
--[[ Class Static Functions ]]--\
\
class.preprocess = preprocess\
function class.getClasses() return classes end\
\
function class.setCustomViewer( fn )\
    if type( fn ) ~= \"function\" then return error(\"Expected function\") end\
\
    CUSTOM_SOURCE_VIEWER = fn\
end\
\
function class.viewSource( _class )\
    -- finds the source of the class\
    if not CUSTOM_SOURCE_VIEWER then\
        return error(\"Cannot load source of class because no source viewer has been defined.\")\
    end\
\
    CUSTOM_SOURCE_VIEWER( _class )\
end\
\
function class.getLast() return lastSealed end\
function class.resolveSeal()\
    -- Seal the currently building class\
    if not currentlyBuilding then\
        return error(\"No class is being built\")\
    else\
        currentlyBuilding:seal()\
    end\
end\
function class.setCustomLoader( fn )\
    if type( fn ) ~= \"function\" then return error(\"Expected function\") end\
\
    CUSTOM_CLASS_LOADER = fn\
end\
function class.runClassString( str, file, ignore )\
    -- str -> class data\
    -- file --> Name used for loadString\
    local ext = DUMP_CRASHED_FILES and \" The file being loaded at the time of the crash has been saved to '\"..DUMP_LOCATION..\"'\" or \"\"\
\
    -- Preprocess the string\
    local data = preprocess( str )\
\
    local function errAndExport( err )\
        export( data, file, err )\
        error(\"Exception while loading class string for file '\"..file..\"': \"..err..\".\"..ext, 0 )\
    end\
\
    -- Run the string\
    local fn, exception = loadstring( data, file )\
    if exception then\
        errAndExport(exception)\
    end\
\
    local ok, err = pcall( fn )\
    if err then\
        errAndExport(err)\
    end\
    -- Load complete, seal the class if one was created.\
    local name = gsub( file, \"%..*\", \"\" )\
    local class = classes[ name ]\
    if not ignore then\
        if class then\
            if not class:isSealed() then class:seal() end\
        else\
            -- The file didn't set a class, throw an error.\
            export( data, file, \"Failed to load class '\"..name..\"'\" )\
            error(\"File '\"..file..\"' failed to load class '\"..name..\"'\"..ext, 0)\
        end\
    end\
end\
\
function class:forge( name, ... )\
    -- Instance Local Variables --\
    local isAbstract = false\
    local sealed = false\
    -- Instance Variables --\
    local new = { __mixes = {}, __alias = {}, __implements = {}, __defined = {}, __definedProperty = {}, __definedFunction = {}, __class = true}\
    local mixes, alias, implements, defined, definedProperty, definedFunction = new.__mixes, new.__alias, new.__implements, new.__defined, new.__definedProperty, new.__definedFunction\
    local newMt = {}\
\
    local function releaseClass()\
        if classes[ name ] then\
            return error(\"Class '\"..name..\"' is already defined\")\
        end\
        if ENV[ name ] and not OVERWRITE_GLOBALS then\
            return error(\"'\"..name..\"' already exists is the working environment\")\
        end\
        classes[ name ] = new\
        ENV[ name ] = new\
    end\
\
    function new:seal()\
        -- Seal the class\
        if sealed then return error(\"Class '\"..name..\"' has already been sealed\") end\
        if isAbstract then\
            function self:spawn() return error(\"Cannot spawn instance of abstract class '\"..name..\"'\") end\
        else\
            function self:spawn( ... )\
                local raw = deepCopy( self ) -- Literally copy the base class, no inheritance needed here as we do not care what happens to the base class after instantiation.\
                local instanceMT = {}\
                local instance = {}\
\
                raw.__instance = true\
\
                local mixes, alias, implements, defined, definedProperty, definedFunction = raw.__mixes, raw.__alias, raw.__implements, raw.__defined, raw.__definedProperty, raw.__definedFunction\
\
                local function seekFromSuper( key )\
                    local last = instance\
                    while true do\
                        local super = last.super\
                        if super then\
                            -- Check the super\
                            if super.__defined[ key ] then\
                                -- This super owns a property with this key name\
                                return super[ key ]\
                            else\
                                last = super\
                            end\
                        else\
                            return nil\
                        end\
                    end\
                end\
\
                -- Instance is the ComputerCraft interface, raw contains all the variables/methods and instanceMT is the bridge between the two.\
\
                -- Setup the bridge\
                local getting = {}\
                function instanceMT:__index( k )\
\
                    -- If this key is aliased, then change the key to the redirect\
                    local k = alias[ k ] or k\
\
                    -- Search raw for a getter\
                    local getter = getters[ k ]\
                    if type(raw[ getter ]) == \"function\" and not getting[ k ] then\
                        getting[ k ] = true\
                        local v = { raw[ getter ]( self ) }\
                        getting[ k ] = nil\
\
                        return unpack( v )\
                    else\
                        return raw[ k ]\
                    end\
                end\
\
                local setting = {}\
                local sym = false\
                function instanceMT:__newindex( k, v )\
                    -- The setter is a little more complex. We must ensure that the instance definedIndex is updated when a new key is defined.\
                    -- If the new value is nil, remove the key from the instance table completely and fetch a super alternative\
                    -- If the new value is not nil, add the key to the appropiatte tables.\
\
                    -- Because some variables may be 'symbolic', only update the definedIndex tables if the value is not symbolic\
                    local k = alias[ k ] or k\
\
                    local setter = setters[ k ]\
                    if type( raw[ setter ] ) == \"function\" and not setting[ k ] then\
                        setting[ k ] = true\
                        raw[ setter ]( self, v )\
                        setting[ k ] = nil\
                    else\
                        -- simply set\
                        raw[ k ] = v\
                    end\
                    -- If the new value is nil, then grab an inherited version from the supers\
                    if v == nil then raw[ k ] = seekFromSuper( k ) end\
                    if not sym then\
                        local t = type( v )\
\
                        self.__defined[ k ] = t ~= \"nil\" or nil\
                        self.__definedProperty[ k ] = t ~= \"function\" or nil\
                        self.__definedFunction[ k ] = t == \"function\" or nil\
                    end\
                end\
\
                function instanceMT:__tostring()\
                    return \"Class Instance '\"..name..\"'\"\
                end\
\
                -- Setup any instance methods\
                function instance:symIndex( key, value )\
                    sym = true\
                    self[ key ] = value\
                    sym = false\
                end\
\
                local overridable = {\
                    [\"__add\"] = true\
                }\
                function instance:__overrideMetaMethod( method, fn )\
                    if not overridable[method] then\
                        return error(\"Meta method '\"..tostring( method )..\"' cannot be overridden\")\
                    end\
\
                    instanceMT[ method ] = fn\
                end\
\
                function instance:__lockMetaMethod( method ) overridable[ method ] = nil end\
\
                if raw.__extends then\
                    instance.super = setupSupersForInstance( instance, raw.__extends )\
                end\
\
                setmetatable( instance, instanceMT )\
\
                -- execute constructor\
                local name = (type( instance[ \"initialise\" ] ) == \"function\" and instance.initialise or ( type( instance[ \"initialize\" ] ) == \"function\" and instance.initialize ) or false )\
                if name then\
                    name( instance, ... )\
                end\
\
                return instance\
            end\
        end\
\
        local function importTable( tbl, sym )\
            for key, value in pairs( tbl ) do\
                if not blacklist[ key ] and not self[ key ] then\
                    self[ key ] = value\
\
                    if not sym then\
                        local t = type( value )\
                        defined[ key ] = t ~= \"nil\" or nil\
                        definedProperty[ key ] = t ~= \"function\" or nil\
                        definedFunction[ key ] = t == \"function\" or nil\
                    end\
                elseif key == \"__alias\" and type( value ) == \"table\" and #value == 0 then\
                    -- move the supers __alias table to this one.\
                    self[ key ] = value\
                end\
            end\
        end\
\
        -- Initiate class\
        importTable( self )\
\
        -- Setup inheritance\
        if self.__extends then\
            -- copy keys accross raw\
            importTable( self.__extends, true )\
        end\
\
        -- Copy mixins\
        for i = 1, #mixes do\
            importTable( mixes[i] ) -- order of mixes relates to importance\
        end\
\
        -- Check implements\
        for i = 1, #implements do\
            local implement = implements[ i ]\
\
            for key, value in pairs( implement ) do\
                if not blacklist[ key ] then\
                    local t = type( value )\
                    local tv = type( self[key] )\
                    if t == \"function\" and tv ~= \"function\" then\
                        return error(\"Cannot seal class because function \"..key..\" is missing as per implement '\"..implement:type()..\"'\")\
                    elseif t ~= \"nil\" and tv == \"nil\" then\
                        return error(\"Cannot seal class because property \"..key..\" is missing as per implement '\"..implement:type()..\"'\")\
                    end\
                end\
            end\
        end\
\
        sealed = true\
\
        lastSealed = currentlyBuilding\
        currentlyBuilding = nil\
    end\
    function new:type()\
        return tostring( name )\
    end\
    function new:isSealed() return sealed end\
    function new:setAbstract( bool )\
        if sealed then return error(\"Cannot change class abstract type after seal\") end\
        isAbstract = bool\
    end\
    function new:setAlias( tbl )\
        if sealed then return error(\"Cannot set alias of class after seal\") end\
        if type( tbl ) ~= \"table\" and type( tbl ) ~= \"string\" then\
            return error(\"Cannot set alias of class '\"..name..\"' to type '\"..type( tbl )..\"'\")\
        end\
\
        if type( tbl ) == \"string\" then\
            if ENV[ tbl ] then\
                tbl = ENV[ tbl ]\
            else\
                return error(\"Cannot set alias to global variable '\"..tbl..\"'. The value doesn't exist in the class environment\")\
            end\
        end\
        self.__alias = tbl\
    end\
\
    function newMt:__tostring()\
        return ( sealed and \"Sealed\" or \"Un-sealed\" ) .. \" Class '\"..self:type()..\"'\"\
    end\
\
    newMt.__call = function( t, ... )\
        if sealed then\
            return t:spawn( ... )\
        else\
            return error(\"Cannot spawn instance of class '\"..t:type()..\"' because the class is not sealed\")\
        end\
    end\
\
    function new:addProperty( k, v )\
        if sealed then\
            return error(\"Class has already been sealed, new settings cannot be added to this class via the base instance.\")\
        end\
        local k = alias[ k ] or k\
\
        local t = type( v )\
        new[ k ] = v\
        new.__defined[ k ] = t ~= \"nil\" or nil\
        new.__definedProperty[ k ] = t ~= \"function\" or nil\
        new.__definedFunction[ k ] = t == \"function\" or nil\
    end\
\
    setmetatable( new, newMt )\
\
    releaseClass() -- Allows use of class. Should only be released once sealed.\
    currentlyBuilding = new\
\
    return propertyCatch\
end\
\
function class.isClass( _class ) return (type( _class ) == \"table\" and _class.__class) or false end\
\
function class.isInstance( _class ) return (type( _class ) == \"table\" and _class.__instance) or false end\
\
function class.typeOf( _class, _type, strict )\
    -- is this even a class?\
    if type( _class ) == \"table\" and _class.__class then\
        if _class:type() ~= _type then return false end\
\
        return ( strict and ( _class.__instance ) ) or not strict\
    end\
    return false\
end\
\
setmetatable( class, {\
    __call = class.forge\
})\
\
--[[ Global Functions ]]--\
ENV.class = class\
ENV.extends = function( _target )\
    local class = getCurrentUnsealed()\
\
    -- Extends to class\
    if class.__extends then\
        return error(\"Cannot extend class '\"..class:type()..\"' to super '\".._target..\"' because the class already extends to '\"..class.__extends..\"'\")\
    end\
    local target = getRequiredClass( _target )\
    class.__extends = target\
\
    return propertyCatch\
end\
ENV.abstract = function()\
    -- set the currently building class to abstract\
    local class = getCurrent()\
    class:setAbstract( true )\
\
    return propertyCatch\
end\
ENV.alias = function( alias )\
    local class = getCurrent()\
    class:setAlias( alias )\
\
    return propertyCatch\
end\
ENV.implements = function( target )\
    local class = getCurrentUnsealed()\
\
    class.__implements[ #class.__implements + 1 ] = getRequiredClass( target )\
\
    return propertyCatch\
end\
ENV.mixin = function( target )\
    local class = getCurrentUnsealed()\
\
    class.__mixes[ #class.__mixes + 1 ] = getRequiredClass( target )\
\
    return propertyCatch\
end",
}
-- Start of unpacker. This script will load all packed files and verify their classes were created correctly.

--[[
    Files checked (in order):
    - scriptFiles.cfg - Files in here are assumed to not load any classes, therefore the class will not be verified. (IGNORE FILE)
    - loadFirst.cfg - Files in here will be loaded before other classes
]]

local ignore = {
    ["class.lua"] = true
}
local loaded = {}

local function executeString( name )
    -- Load this lua chunk from string.
    local fn, err = loadstring( files[ name ], name )
    if err then
        return error("Failed to load file '"..name.."'. Exception: "..err, 0)
    end

    -- Execute the Lua chunk if the loadstring was successful.
    local ok, err = pcall( fn )
    if err then
        return error("Error occured while running chunk '"..name.."': "..err, 0)
    end
end

-- Load the class library now!
if files[ "class.lua" ] then
    executeString( "class.lua" )
    loaded[ "class.lua" ] = true
else
    return error("Cannot unpack DynaCode because the class library is missing (class.lua)")
end

local function getHandleFromPack( file )
    if not files[ file ] then return false, 404 end
    return files[ file ]
end

local function loadFromPack( name )
    print( name )
    if loaded[ name ] then return end

    local ignoreFile = ignore[ name ]

    if not files[ name ] then
        return error("Cannot load file '"..name.."' from packed files because it cannot be found. Please check your DynaCode installation")
    end

    -- Execution complete, check class validity
    class.runClassString( files[ name ], name, ignoreFile )
    loaded[ name ] = true
end

class.setCustomLoader( function( _c )
    loadFromPack( _c..".lua" )
end )

-- First, compile a list of files to be ignored.
local content, err = getHandleFromPack( "scriptFiles.cfg" )
if content then
    for name in content:gmatch( "[^\n]+" ) do
		ignore[ name ] = true
	end
    loaded[ "scriptFiles.cfg" ] = true
end

local content, err = getHandleFromPack( "loadFirst.cfg" )
if content then
    for name in content:gmatch( "[^\n]+" ) do
		loadFromPack( name )
	end
    loaded[ "loadFirst.cfg" ] = true
end

for name, _ in pairs( files ) do
    loadFromPack( name )
end

class.setCustomViewer(function(_class)
    if class.isClass( _class ) then
        local t = _class:type()
        local file = t..".lua"

        if files[ file ] then
            local h = fs.open("tempSource.lua", "w")
            h.write( files[ file ] )
            h.close()

            shell.run("edit", "tempSource.lua")
        else
            return error("Class originates from unknown source")
        end
    else return error("Unknown object to anaylyse '" .. tostring( _class ) .. "'") end
end)
