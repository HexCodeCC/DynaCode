-- DynaCode - Class Edition

-- Files follow:
local files = {
  [ "Button.lua" ] = "DCML.registerTag(\"Button\", {\
    contentCanBe = \"text\";\
    argumentType = {\
        X = \"number\";\
        Y = \"number\";\
        width = \"number\";\
        height = \"number\";\
        backgroundColour = \"colour\";\
        textColour = \"colour\";\
        activeTextColour = \"colour\";\
        activeBackgroundColour = \"colour\";\
    };\
    callbacks = {\
        onTrigger = \"onTrigger\" -- called after moused down and up again on the button.\
    };\
    callbackGenerator = \"#generateNodeCallback\"; -- \"#\" signifies relative function (on the instance.) @ Node.generateNodeCallback\
    aliasHandler = true\
})\
\
class \"Button\" extends \"Node\" alias \"ACTIVATABLE\" {\
    text = nil;\
\
    yCenter = false;\
    xCenter = false;\
\
    active = false;\
    focused = false;\
\
    -- colours\
    textColour = 1;\
    backgroundColour = colours.cyan;\
\
    activeTextColour = 1;\
    activeBackgroundColour = colours.lightBlue;\
\
    acceptMouse = true;\
}\
\
function Button:initialise( ... )\
    local text, X, Y, width, height = ParseClassArguments( self, { ... }, { {\"text\", \"string\"}, {\"X\", \"number\"}, {\"Y\", \"number\"}, {\"width\", \"number\"}, {\"height\", \"number\"} }, true, true )\
\
    self.super( X, Y, width, height )\
    self.text = text\
end\
\
function Button:updateLines()\
    if not self.text then return end -- stops line updates during instantiation (the super:init sets width, however text is set afterwards (see Button:initialise))\
    self.lines = self.canvas:wrapText( self.text, self.width )\
end\
\
function Button:setText( text )\
    -- set the raw text, also generate a wrapped version.\
    self.text = text\
    self:updateLines()\
end\
\
function Button:setWidth( width )\
    self.width = width\
    self:updateLines()\
end\
\
function Button:preDraw()\
    self.canvas:drawWrappedText( 1, 1, self.width, self.height, self.lines, \"center\", \"center\", self.active and self.activeBackgroundColour or self.backgroundColour, self.active and self.activeTextColour or self.textColour )\
end\
\
function Button:onMouseDown( event ) -- initial click, set focus to this button and highlight it.\
    if event.misc ~= 1 then return end\
    self.focused = true\
    self.active = true\
end\
\
function Button:onMouseDrag( event )\
    if self.focused then\
        self.active = true -- mouse dragged onto node after dragging off, re-highlight it\
    end\
end\
\
function Button:onMouseMiss( event )\
    if self.focused and event.sub == \"DRAG\" then -- dragged off of node, set colour back to normal\
        self.active = false\
    elseif event.sub == \"UP\" and ( self.focused or self.active ) then -- mouse up off of the node, set its colour back to normal and remove focus\
        self.active = false\
        self.focused = false\
    end\
end\
\
function Button:onMouseUp( event ) -- mouse up on node, trigger callback and reset colours and focus\
    if self.active then\
        -- clicked\
        if self.onTrigger then self:onTrigger( event ) end\
\
        self.active = false\
        self.focused = false\
    end\
end\
\
function Button:setActive( active )\
    self.active = active\
    self.changed = true\
end\
\
function Button:setFocused( focus )\
    self.focused = focus\
    self.changed = true\
end",
  [ "Panel.lua" ] = "DCML.registerTag(\"Panel\", {\
    childHandler = function( self, element )\
        self.nodesToAdd = DCML.parse( element.content )\
    end;\
    argumentType = {\
        X = \"number\";\
        Y = \"number\";\
        width = \"number\";\
        height = \"number\";\
        backgroundColour = \"colour\";\
        textColour = \"colour\";\
    },\
    callbackGenerator = \"#generateNodeCallback\";\
})\
\
class \"Panel\" extends \"NodeScrollContainer\" {\
    width = 2;\
    height = 2;\
}\
\
function Panel:initialise( ... )\
    local X, Y, width, height = ParseClassArguments( self, { ... }, {\
        { \"X\", \"number\" },\
        { \"Y\", \"number\" },\
        { \"width\", \"number\" },\
        { \"height\", \"number\" }\
    }, false, true )\
\
    self.super( X, Y, width or self.width, height or self.height ) -- this will call the Node.initialise because the super inherits that from the other super and so on...\
\
    self:__overrideMetaMethod(\"__add\", function( a, b )\
        if class.typeOf(a, \"Panel\", true) then\
            if class.isInstance( b ) and b.__node then\
                return self:addNode( b )\
            else\
                return error(\"Invalid right hand assignment. Should be instance of DynaCode node. \"..tostring( b ))\
            end\
        else\
            return error(\"Invalid left hand assignment. Should be instance of Panel. \"..tostring( a ))\
        end\
    end)\
end",
  [ "NodeScrollContainer.lua" ] = "abstract class \"NodeScrollContainer\" extends \"NodeContainer\" {\
    verticalScroll = 0;\
    horizontalScroll = 0;\
\
    verticalPadding = 0;\
    horizontalPadding = 0;\
\
    currentScrollbar = false;\
}\
\
function NodeScrollContainer:calculateDisplaySize( h, v ) -- h, v (horizontal, vertical)\
    -- if a scroll bar is in use the size will be decreased as the scroll bar will be inside the node.\
    local width, height = self.width, self.height\
    return ( v and width - 1 or width ), ( h and height - 1 or height )\
end\
\
function NodeScrollContainer:calculateContentSize()\
    -- get total height of the content (excludes padding)\
    local h, w = 0, 0\
    local nodes = self.nodes\
\
    for i = 1, #nodes do\
        local node = nodes[i]\
        local nodeX2, nodeY2 = node.X + node.width - 1, node.Y + node.height - 1\
\
        w = nodeX2 > w and nodeX2 or w\
        h = nodeY2 > h and nodeY2 or h\
    end\
\
    return w, h\
end\
\
function NodeScrollContainer:getScrollPositions( contentWidth, contentHeight, dWidth, dHeight, hSize, vSize )\
    local h, v = math.floor( self.horizontalScroll / contentWidth * dWidth - .5 ), math.ceil( self.verticalScroll / contentHeight * dHeight + .5 )\
\
    --return (h <= 1 and ( self.horizontalScroll ~= 0 and 2 or 1 ) or h), (v <= 1 and ( self.verticalScroll ~= 0 and 2 or 1 ) or v)\
    if h + hSize - 1 >= dWidth or self.horizontalScroll == contentWidth then\
        -- should be or is at the end of the run\
        if self.horizontalScroll == contentWidth - dWidth then h = dWidth - hSize + 1 else h = dWidth - hSize end\
    end\
\
    if v + vSize - 1 >= dHeight or self.verticalScroll == contentHeight then\
        -- should be or is at the end of the run\
        if self.verticalScroll == contentHeight - dHeight then v = dHeight - vSize + 1 else v = dHeight - vSize end\
    end\
    return h, v\
end\
\
function NodeScrollContainer:getScrollSizes( contentWidth, contentHeight, dWidth, dHeight )\
    return math.ceil( dWidth / contentWidth * self.width - .5 ), math.ceil( dHeight / contentHeight * self.height - .5 )\
end\
\
function NodeScrollContainer:addNode( node )\
    self.super:addNode( node )\
\
    --self:updateScrollSizes()\
    --self:updateScrollPositions()\
end\
\
function NodeScrollContainer:removeNode( node )\
    self.super:removeNode( node )\
\
    --self:updateScrollSizes()\
    --self:updateScrollPositions()\
end\
\
function NodeScrollContainer:inView( node )\
    local nodeX, nodeY, nodeWidth, nodeHeight = node.X, node.Y, node.width, node.height\
    local hOffset, vOffset = self.horizontalScroll, self.verticalScroll\
\
    return nodeX + nodeWidth - hOffset > 0 and nodeX - hOffset < self.width and nodeY - vOffset < self.height and nodeY + nodeHeight - vOffset > 0\
end\
\
local clickMatrix = {\
    CLICK = \"onMouseDown\";\
    UP = \"onMouseUp\";\
    SCROLL = \"onMouseScroll\";\
    DRAG = \"onMouseDrag\";\
}\
\
function NodeScrollContainer:onAnyEvent( event )\
    -- submit this event to our children. First, make the event relative\
    local oX, oY = event.X, event.Y\
    local isMouseEvent = event.main == \"MOUSE\"\
\
    local nodes = self.nodes\
\
    if isMouseEvent then\
        event:convertToRelative( self )\
\
        -- Also, apply any offsets caused by scrolling.\
        event.Y = event.Y + self.verticalScroll\
        event.X = event.X + self.horizontalScroll\
    end\
\
    for i = 1, #nodes do\
        nodes[i]:handleEvent( event )\
    end\
\
    if isMouseEvent then\
        event.X = oX\
        event.Y = oY\
    end\
end\
\
function NodeScrollContainer:onMouseScroll( event )\
    local contentWidth, contentHeight = self:calculateContentSize()\
    local h, v = self:getActiveScrollbars( contentWidth, contentHeight )\
\
    local dWidth, dHeight = self:calculateDisplaySize( h, v )\
\
    if v then\
\009\009self.verticalScroll = math.max( math.min( self.verticalScroll + event.misc, contentHeight - dHeight ), 0 )\
        self.forceRedraw = true\
        self.changed = true\
\009elseif h then\
\009\009self.horizontalScroll = math.max( math.min( self.horizontalScroll + event.misc, contentWidth - dWidth ), 0 )\
        self.forceRedraw = true\
        self.changed = true\
\009end\
end\
\
function NodeScrollContainer:getActiveScrollbars( contentWidth, contentHeight )\
    return contentWidth > self.width, contentHeight > self.height\
end\
\
function NodeScrollContainer:draw( xO, yO, force )\
    log(\"w\", \"Scroll Container Drawn. Force: \"..tostring( force ))\
    local nodes = self.nodes\
    local manDraw = force or self.forceRedraw\
    local canvas = self.canvas\
\
    canvas:clear()\
\
    local xO, yO = xO or 0, yO or 0\
\
    if self.preDraw then\
        self:preDraw( xO, yO )\
    end\
\
    -- draw the content\
    local hO, vO = -self.horizontalScroll, -self.verticalScroll\
    local nC\
\
    for i = #nodes, 1, -1 do\
        local node = nodes[i]\
        nC = node.changed\
\
        if self:inView( node ) and nC or manDraw then\
            -- draw the node using our offset\
            node:draw( hO, vO, manDraw or force )\
            node.canvas:drawToCanvas( canvas, node.X + hO, node.Y + vO )\
\
            if nC then node.changed = false end\
        end\
    end\
    self.forceRedraw = false\
\
    if self.postDraw then\
        self:postDraw( xO, yO )\
    end\
\
\
    self.changed = false\
    self.canvas:drawToCanvas( ( self.parent or self.stage ).canvas, self.X + xO, self.Y + yO )\
end\
\
function NodeScrollContainer:postDraw()\
    -- draw the scroll bars\
\
    local contentWidth, contentHeight = self:calculateContentSize()\
    local isH, isV = self:getActiveScrollbars( contentWidth, contentHeight ) -- uses the content size to determine which scroll bars are active.\
    if isH or isV then\
        local dWidth, dHeight = self:calculateDisplaySize( isH, isV )\
\
        local hSize, vSize = self:getScrollSizes( contentWidth, contentHeight, dWidth, dHeight )\
        local hPos, vPos = self:getScrollPositions( contentWidth, contentHeight, dWidth, dHeight, hSize, vSize )\
\
        local canvas = self.canvas\
\
        -- draw the scroll bars now. If both are active at the same time adjust the size slightly and fill the gap at the intersect\
        local bothActive = isH and isV\
        local bothOffset = bothActive and 1 or 0\
\
        if isH then\
            -- draw the scroll bar background mixed in with the actual bar.\
            canvas:drawArea( 1, self.height, dWidth, 1, colours.red, colours.green )\
            canvas:drawArea( hPos, self.height, hSize - bothOffset, 1, colours.black, colours.grey )\
        end\
        if isV then\
            canvas:drawArea( self.width, 1, 1, dHeight, colours.red, colours.green )\
            canvas:drawArea( self.width, vPos, 1, vSize - bothOffset, colours.black, colours.grey )\
        end\
\
        if bothActive then canvas:drawArea( self.width, self.height, 1, 1, colours.lightGrey, colours.lightGrey ) end\
    end\
end",
  [ "HotkeyManager.lua" ] = "local insert, remove, sub, len = table.insert, table.remove, string.sub, string.len\
\
local cache = {}\
local heldSupport = true\
local redirects = {\
    leftShift = \"shift\";\
    rightShift = \"shift\";\
\
    leftCtrl = \"ctrl\";\
}\
\
class \"HotkeyManager\" {\
    keys = {};\
    combinations = {};\
\
    application = nil;\
}\
\
function HotkeyManager:initialise( application )\
    self.application = AssertClass( application, \"Application\", true, \"HotkeyManager requires an Application Instance as its constructor argument, not '\"..tostring( application )..\"'\")\
end\
\
local function matchCombination( self, combination, pressOnly )\
    local parts = {}\
    if cache[ combination ] then\
        parts = cache[ combination ]\
    else\
        -- seperate into parts\
        for word in string.gmatch(combination, '([^-]+)') do\
            parts[#parts+1] = word\
        end\
        cache[ combination ] = parts\
    end\
\
    -- Check if each key is pressed\
    local ok = true\
    for i = 1, #parts do\
        if not self.keys[ parts[i] ] or ( pressOnly and self.keys[ parts[i]].held ) then\
            -- if the key is not being pressed or the key is being held and the combination needs an un-pressed key.\
            ok = false\
            break\
        end\
    end\
\
    return ok\
end\
\
function HotkeyManager:assignKey( event, noRedirect )\
    -- A key has been pressed\
    if event.main == \"KEY\" then\
        -- set key\
        if event.held == nil then\
            -- doesn't support\
            heldSupport = false\
        end\
        local name = keys.getName( event.key )\
        local keyData = { held = event.held, keyID = event.key }\
\
        if not name then return end\
\
        self.keys[ name ] = keyData\
        if not noRedirect then\
            -- if the key has a redirect, create that redirect too\
            local re = redirects[ name ]\
            if re then\
                self.keys[ re ] = keyData\
            end\
        end\
    end\
end\
\
function HotkeyManager:relieveKey( event, noRedirect )\
    -- A key has been un-pressed (key up/relieved)\
    if event.main == \"KEY\" then\
        local name = keys.getName( event.key )\
        if not name then return end\
\
        self.keys[ name ] = nil\
\
        if not noRedirect then\
            local re = redirects[ name ]\
            if re then\
                self.keys[ re ] = nil\
            end\
        end\
    end\
end\
\
function HotkeyManager:handleKey( event )\
    if event.sub == \"UP\" then\
        self:relieveKey( event )\
    else\
        self:assignKey( event )\
    end\
end\
\
function HotkeyManager:matches( combination )\
    -- A program wants to know if a combination of keys has been met\
    return matchCombination( self, combination )\
end\
\
function HotkeyManager:registerCombination( name, combination, callback, mode )\
    -- Register this combination with a specified callback to be executed when its met.\
    if not name or not combination or not type( callback ) == \"function\" then return error(\"Expected string name, string combination, function callback\") end\
\
    self.combinations[ #self.combinations + 1 ] = { name, combination, mode or \"normal\", callback }\
end\
\
function HotkeyManager:removeCombination( name )\
    -- Remove a combination by name.\
    if not name then return error(\"Requires name to search\") end\
\
    for i = 1, #self.combinations do\
        local c = self.combinations[i]\
        if c[1] == name then\
            table.remove( self.combinations, i )\
            break\
        end\
    end\
end\
\
function HotkeyManager:checkCombinations()\
    -- Checks every combinations matching requirements against the pressed keys.\
    for i = 1, #self.combinations do\
        local c = self.combinations[i]\
        if matchCombination( self, c[2], c[3] == \"strict\" ) then\
            c[4]( self.application )\
        end\
    end\
end\
\
function HotkeyManager:reset()\
    -- if the app is restarted clear the currently held keys\
    self.keys = {}\
end",
  [ "NodeContainer.lua" ] = "abstract class \"NodeContainer\" extends \"Node\" {\
    acceptMouse = true;\
    acceptKeyboard = true;\
    acceptMisc = true;\
\
    nodes = {};\
    forceRedraw = true;\
}\
\
function NodeContainer:getNodeByType( _type )\
    local results, nodes = {}, self.nodes\
\
    for i = 1, #nodes do\
        local node = nodes[i]\
        if class.typeOf( node, _type, true ) then results[ #results + 1 ] = node end\
    end\
    return results\
end\
\
function NodeContainer:getNodeByName( name )\
    local results, nodes = {}, self.nodes\
\
    for i = 1, #nodes do\
        local node = nodes[i]\
        if node.name == name then results[ #results + 1 ] = node end\
    end\
    return results\
end\
\
function NodeContainer:addNode( node )\
    node.parent = self\
    node.stage = self.stage\
\
    self.nodes[ #self.nodes + 1 ] = node\
end\
\
function NodeContainer:removeNode( nodeOrName )\
    local nodes = self.nodes\
\
    local isName = not ( class.isInstance( nodeOrName ) and class.__node )\
\
    for i = 1, #nodes do\
        local node = nodes[i]\
        if (isName and node.name == nodeOrName) or ( not isName and node == nodeOrName ) then\
            node.parent = nil\
            return table.remove( self.nodes, i )\
        end\
    end\
end\
\
function NodeContainer:resolveDCMLChildren()\
    -- If this was defined using DCML then any children will be placed in a table ready to be added to the actual 'nodes' table. This is because the parent node is not properly configured right away.\
\
    local nodes = self.nodesToAdd\
    for i = 1, #nodes do\
        local node = nodes[i]\
\
        self:addNode( node )\
        if node.nodesToAdd and type( node.resolveDCMLChildren ) == \"function\" then\
            node:resolveDCMLChildren()\
        end\
    end\
    self.nodesToAdd = {}\
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
                return error(\"Expected type '\".._type..\"' for argument '\"..key..\"', got '\"..type( value )..\"' instead.\", 2)\
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
_G.ACTIVATABLE = {\
    activeTextColor = \"activeTextColour\";\
    activeBackgroundColor = \"activeBackgroundColour\"\
}\
\
_G.SELECTABLE = {\
    selectedTextColor = \"selectedTextColour\";\
    selectedBackgroundColor = \"selectedBackgroundColour\"\
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
end\
\
_G.InArea = function( x, y, x1, y1, x2, y2 )\
    if x >= x1 and x <= x2 and y >= y1 and y <= y2 then\
        return true\
    end\
    return false\
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
local blit = type( term.blit ) == \"function\" and term.blit or nil\
local write = term.write\
local setCursorPos = term.setCursorPos\
local concat = table.concat\
\
\
local setTextColour, setBackgroundColour = term.setTextColour, term.setBackgroundColour\
\
class \"ApplicationCanvas\" extends \"Canvas\" {\
    textColour = colors.red;\
    backgroundColour = 1;\
\
    old = {};\
}\
\
function ApplicationCanvas:initialise( ... )\
    ParseClassArguments( self, { ... }, { {\"owner\", \"Application\"}, {\"width\", \"number\"}, {\"height\", \"number\"} }, true )\
    AssertClass( self.owner, \"Application\", true, \"Instance '\"..self:type()..\"' requires an Application Instance as the owner\" )\
\
    self.super( self.width, self.height )\
end\
\
\
function ApplicationCanvas:drawToScreen( force )\
    -- MUCH faster drawing! Tearing almost completely eliminated\
\
    local pos = 1\
    local buffer = self.buffer\
    local width, height = self.width, self.height\
    local old = self.old\
\
    -- local definitions (faster than repeatedly defining the local inside the loop )\
    local tT, tC, tB, tChanged\
    local pixel, oPixel\
\
    local tc, bg = self.textColour or 1, self.backgroundColour or 1\
    if blit then\
        for y = 1, height do\
            tT, tC, tB, tChanged = {}, {}, {}, false -- text, textColour, textBackground\
\
            for x = 1, width do\
                -- get the pixel content, add it to the text buffers\
                pixel = buffer[ pos ]\
                oPixel = old[ pos ]\
\
                tT[ #tT + 1 ] = pixel[1] or \" \"\
                tC[ #tC + 1 ] = paint[ pixel[2] or tc ]\
                tB[ #tB + 1 ] = paint[ pixel[3] or bg ]\
\
                -- Set tChanged to true if this pixel is different to the last.\
                if not oPixel or pixel[1] ~= oPixel[1] or pixel[2] ~= oPixel[2] or pixel[3] ~= oPixel[3] then\
                    tChanged = true\
                    old[ pos ] = { pixel[1], pixel[2], pixel[3] }\
                end\
\
                pos = pos + 1\
            end\
            if tChanged then\
                setCursorPos( 1, y )\
                blit( concat( tT, \"\" ), concat( tC, \"\" ), concat( tB, \"\" ) ) -- table.concat comes with a major speed advantage compared to tT = tT .. pixel[1] or \" \". Same goes for term.blit\
            end\
        end\
    else\
        local oldPixel\
        local old = self.old\
\
        local oldTc, oldBg = 1, 32768\
        setTextColour( oldTc )\
        setBackgroundColour( oldBg )\
\
        for y = 1, height do\
            for x = 1, width do\
                pixel = buffer[ pos ]\
                oldPixel = old[ pos ]\
\
                if force or not oldPixel or not ( oldPixel[1] == pixel[1] and oldPixel[2] == pixel[2] and oldPixel[3] == pixel[3] ) then\
\
                    setCursorPos( x, y )\
\
                    local t = pixel[2] or tc\
                    if t ~= oldTc then setTextColour( t ) oldTc = t end\
\
                    local b = pixel[3] or bg\
                    if b ~= oldBg then setBackgroundColour( b ) oldBg = b end\
\
                    write( pixel[1] or \" \" )\
\
                    old[ pos ] = { pixel[1], pixel[2], pixel[3] }\
                end\
                pos = pos + 1\
            end\
        end\
    end\
end",
  [ "TextUtil.lua" ] = "local TextHelper = {}\
function TextHelper.leadingTrim( text )\
    return (text:gsub(\"^%s*\", \"\"))\
end\
function TextHelper.trailingTrim( text )\
    local n = #text\
    while n > 0 and text:find(\"^%s\", n) do\
        n = n - 1\
    end\
    return text:sub(1, n)\
end\
\
function TextHelper.whitespaceTrim( text ) -- both trailing and leading.\
    return (text:gsub(\"^%s*(.-)%s*$\", \"%1\"))\
end\
_G.TextHelper = TextHelper",
  [ "MyDaemon.lua" ] = "class \"MyDaemon\" extends \"Daemon\"\
\
function MyDaemon:start()\
    local event = self.owner.event\
\
    event:registerEventHandler(\"Terminate\", \"TERMINATE\", \"EVENT\", function()\
        error(\"DaemonService '\"..self:type()..\"' named: '\"..self.name..\"' detected terminate event\", 0)\
    end)\
\
    event:registerEventHandler(\"ContextMenuHandler\", \"MOUSE\", \"CLICK\", function( handle, event )\
        if event.misc == 2 then\
            log(\"di\", \"context popup\")\
        end\
    end)\
\
    --[[self.owner.timer:setTimer(\"MyDaemonTimer\", 2, function( raw, timerEvent )\
        log(\"di\", \"example check complete.\")\
    end, 5) -- set this timer a total of 5 times. ( the callback will be run 5 times over 10 seconds )]]\
end\
\
function MyDaemon:stop( graceful )\
    log(graceful and \"di\" or \"de\", \"MyDaemon detected application close. \" .. (graceful and \"graceful\" or \"not graceful\") .. \".\")\
\
    -- remove event registers\
    local event = self.owner.event\
    event:removeEventHandler(\"TERMINATE\", \"EVENT\", \"Terminate\")\
end",
  [ "UnknownEvent.lua" ] = "class \"UnknownEvent\" mixin \"Event\" {\
    main = false;\
    sub = \"EVENT\";\
}\
\
function UnknownEvent:initialise( raw )\
    self.raw = raw\
\
    self.main = raw[1]:upper()\
end",
  [ "Label.lua" ] = "DCML.registerTag(\"Label\", {\
    contentCanBe = \"text\";\
    argumentType = {\
        X = \"number\";\
        Y = \"number\";\
        backgroundColour = \"colour\";\
        textColour = \"colour\";\
    };\
    aliasHandler = true\
})\
\
local len = string.len\
\
class \"Label\" extends \"Node\" {\
    text = \"Label\";\
}\
\
function Label:initialise( ... )\
    ParseClassArguments( self, { ... }, { {\"text\", \"string\"}, {\"X\", \"number\"}, {\"Y\", \"number\"} }, true, false )\
\
    if not self.__defined.width then\
        self.width = \"auto\"\
    end\
    self.super( self.X, self.Y, self.width, 1 )\
\
    self.canvas.width = self.width\
end\
\
function Label:preDraw()\
    -- draw the text to the canvas\
    local draw = self.canvas\
\
    draw:drawTextLine( self.text, 1, 1, self.textColour, self.backgroundColour, self.width ) -- text, X, Y, textColour, backgroundColour, maxWidth(optional)\
end\
\
function Label:getWidth()\
    return self.width == \"auto\" and len( self.text ) or self.width\
end\
\
function Label:setWidth( width )\
    self.width = width\
\
    if not self.canvas then return end\
    self.canvas.width = self.width\
end\
\
function Label:setText( text )\
    self.text = text\
\
    if not self.canvas then return end\
    self.canvas.width = self.width\
end",
  [ "StageCanvas.lua" ] = "local GREYSCALE_FILTER = {\
    [1] = 256;\
    [2] = 256;\
    [4] = 256;\
    [8] = 1;\
    [16] = 256;\
    [32] = 128;\
    [64] = 256;\
    [128] = 128;\
    [256] = 128;\
    [512] = 256;\
    [1024] = 128;\
    [2048] = 128;\
    [4096] = 128;\
    [8192] = 256;\
    [16384] = 128;\
    [32768] = 128;\
}\
\
class \"StageCanvas\" extends \"Canvas\" {\
    frame = nil;\
\
    filter = nil;\
\
    cache = {};\
    greyOutWhenNotFocused = true;\
}\
\
function StageCanvas:initialise( ... )\
    local width, height = ParseClassArguments( self, { ... }, { {\"width\", \"number\"}, {\"height\", \"number\"} }, true, true )\
    AssertClass( self.stage, \"Stage\", true, \"StageCanvas requires stage to be a Stage instance, not: \"..tostring( self.stage ) )\
\
    self.super( width, height )\
\
    self:updateFilter()\
end\
\
function StageCanvas:updateFilter()\
    if self.stage.focused or not self.greyOutWhenNotFocused then\
        self.filter = \"NONE\"\
    else\
        self.filter = \"GREYSCALE\"\
    end\
end\
\
function StageCanvas:setFilter( fil )\
    -- clear the cache\
    self.filter = fil\
    --self:redrawFrame()\
end\
\
function StageCanvas:getColour( col )\
    if self.filter == \"NONE\" then return col end\
\
    if self.filter == \"GREYSCALE\" then\
        return GREYSCALE_FILTER[ col ]\
    end\
end\
\
function StageCanvas:redrawFrame()\
    -- This function creates a table of pixels representing the background and shadow of the stage.\
    -- Function should only be executed during full clears, not every draw.\
    local stage = self.stage\
    local gc = self.getColour\
\
    local hasTitleBar = not stage.borderless\
    local title = OverflowText(stage.title or \"\", stage.width - ( stage.closeButton and 1 or 0 ) ) or \"\"\
    local hasShadow = stage.shadow and stage.focused\
\
    local shadowColour = stage.shadowColour\
    local titleColour = stage.titleTextColour\
    local titleBackgroundColour = stage.titleBackgroundColour\
\
    local width = self.width --+ ( stage.shadow and 0 or 0 )\
    local height = self.height --+ ( stage.shadow and 1 or 0 )\
\
    local frame = {}\
    for y = 0, height - 1 do\
        local yPos = width * y\
        for x = 1, width do\
            -- Find out what goes here (title, shadow, background)\
            local pos = yPos + x\
            if hasTitleBar and y == 0 and ( hasShadow and x < width or not hasShadow ) then\
                -- Draw the correct part of the title bar here.\
                if x == stage.width and stage.closeButton then\
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
    self.frame = frame\
end\
\
function StageCanvas:drawToCanvas( canvas, xO, yO, ignoreMap )\
    local buffer = self.buffer\
    local frame = self.frame\
    local stage = self.stage\
    local gc = self.getColour\
\
    local mappingID = self.stage.mappingID\
\
    local xO = type( xO ) == \"number\" and xO - 1 or 0\
    local yO = type( yO ) == \"number\" and yO - 1 or 0\
\
    local width = self.width --+ ( stage.shadow and 0 or 0 )\
    local height = self.height -- ( stage.shadow and 1 or 1 )\
\
    local map = self.stage.application.layerMap\
\
    local cHeight, cWidth = canvas.height, canvas.width\
    local cBuffer = canvas.buffer\
    local tc, bg = self.textColour, self.backgroundColour\
\
    for y = 0, height - 1 do\
        local yPos = width * y\
        local yBPos = canvas.width * ( y + yO )\
        if y + yO + 1 > 0 and y + yO - 1 < cHeight then\
\
            for x = 1, width do\
                if x + xO > 0 and x + xO - 1 < cWidth then\
\
                    local bPos = yBPos + (x + xO)\
\
                    if map[ bPos ] == mappingID then\
\
                        local pos = yPos + x\
                        local pixel = buffer[ pos ]\
                        if pixel then\
                            if not pixel[1] then\
                                -- draw the frame\
                                local framePixel = frame[ pos ]\
                                if framePixel then\
                                    local fP = framePixel[1]\
                                    if x == width and y == 0 and not stage.borderless and stage.closeButton and self.greyOutWhenNotFocused then -- keep the closeButton coloured.\
                                        cBuffer[ bPos ] = { fP, framePixel[2] or tc, framePixel[3] or bg}\
                                    else\
                                        cBuffer[ bPos ] = { fP, gc( self, framePixel[2] or tc ), gc( self, framePixel[3] or bg ) }\
                                    end\
                                end\
                            else\
                                -- draw the node pixel\
                                cBuffer[ bPos ] = { pixel[1] or \" \", gc( self, pixel[2] or tc ), gc( self, pixel[3] or bg ) }\
                            end\
                        else\
                            cBuffer[ bPos ] = { false, false, false }\
                        end\
                    end\
                end\
            end\
        end\
    end\
end",
  [ "Canvas.lua" ] = "local insert = table.insert\
local remove = table.remove\
\
abstract class \"Canvas\" alias \"COLOUR_REDIRECT\" {\
    width = 10;\
    height = 6;\
\
    buffer = nil;\
}\
\
function Canvas:initialise( ... )\
    local width, height = ParseClassArguments( self, { ... }, { {\"width\", \"number\"}, {\"height\", \"number\"} }, true, true )\
\
    self.width = width\
    self.height = height\
\
    self:clear()\
end\
\
function Canvas:clear( w, h )\
    local width = w or self.width\
    local height = h or self.height\
\
    --if not width or not height then return end\
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
    local xO = xO or 0\
    local yO = yO or 0\
\
    local pos, yPos, yBPos, bPos, pixel\
\
    for y = 0, self.height - 1 do\
        yPos = self.width * y\
        yBPos = canvas.width * ( y + yO )\
        for x = 1, self.width do\
            pos = yPos + x\
            bPos = yBPos + (x + xO)\
\
            pixel = buffer[ pos ]\
            canvas.buffer[ bPos ] = { pixel[1] or \" \", pixel[2] or self.textColour, pixel[3] or self.backgroundColour }\
        end\
    end\
end\
\
function Canvas:setWidth( width )\
    if not self.buffer then self.width = width return end\
\
    local height, buffer = self.height, self.buffer\
    if not self.width then error(\"found on \"..tostring( self )..\". Current width: \"..tostring( self.width )..\", new width: \"..tostring( width )) end\
    while self.width < width do\
        -- Insert pixels at the end of each line to make up for the increase in width\
        for i = 1, height do\
            insert( buffer, ( self.width + 1 ) * i, {\"\", self.textColor, self.textColour} )\
        end\
        self.width = self.width + 1\
    end\
    while self.width > width do\
        for i = 1, width do\
            remove( buffer, self.width * i )\
        end\
        self.width = self.width - 1\
    end\
    --self:clear()\
end\
\
function Canvas:setHeight( height )\
    if not self.buffer then self.height = height return end\
    local width, buffer, cHeight = self.width, self.buffer, self.height\
\
\009while self.height < height do\
\009\009for i = 1, width do\
\009\009\009buffer[#buffer + 1] = px\
\009\009end\
\009\009self.height = self.height + 1\
\009end\
\
\009while self.height > height do\
\009\009for i = 1, width do\
\009\009\009remove( buffer, #buffer )\
\009\009end\
\009\009self.height = self.height - 1\
\009end\
    --self:clear()\
end",
  [ "DCMLParser.lua" ] = "local sub = string.sub\
local function readData( data )\
    function parseargs(s)\
        local arg = {}\
        string.gsub(s, \"([%-%w]+)=([\\\"'])(.-)%2\", function (w, _, a)\
            arg[w] = a\
        end)\
        return arg\
    end\
\
    function collect(s)\
        local stack = {}\
        local top = {}\
        table.insert(stack, top)\
        local ni,c,label,xarg, empty\
        local i, j = 1, 1\
        while true do\
            ni,j,c,label,xarg, empty = string.find(s, \"<(%/?)([%w:]+)(.-)(%/?)>\", i)\
            if not ni then break end\
            local text = string.sub(s, i, ni-1)\
            if not string.find(text, \"^%s*$\") then\
                --table.insert(top, text)\
                top[ \"content\" ] = text\
            end\
            if empty == \"/\" then  -- empty element tag\
                table.insert(top, {label=label, xarg=parseargs(xarg), empty=1})\
            elseif c == \"\" then   -- start tag\
                top = {label=label, xarg=parseargs(xarg)}\
                table.insert(stack, top)   -- new level\
            else  -- end tag\
                local toclose = table.remove(stack)  -- remove top\
                top = stack[#stack]\
                if #stack < 1 then\
                    error(\"nothing to close with \"..label)\
                end\
                if toclose.label ~= label then\
                    error(\"trying to close \"..toclose.label..\" with \"..label)\
                end\
                --table.insert(top, toclose)\
                if #stack > 1 then\
                    if type(top.content) ~= \"table\" then\
                        top.content = {}\
                    end\
\
                    top.content[ #top.content + 1 ] = toclose\
                    top.hasChildren = true\
                else\
                    table.insert(top, toclose)\
                end\
            end\
            i = j+1\
        end\
        local text = string.sub(s, i)\
        if not string.find(text, \"^%s*$\") then\
            table.insert(stack[#stack], text)\
        end\
        if #stack > 1 then\
            error(\"unclosed \"..stack[#stack].label)\
        end\
        return stack[1]\
    end\
    return collect( data )\
end\
\
local DCMLMatrix = {}\
local Parser = {}\
\
function Parser.registerTag( name, config )\
    if type( name ) ~= \"string\" or type( config ) ~= \"table\" then return error(\"Expected string, table\") end\
\
    DCMLMatrix[ name ] = config\
end\
\
function Parser.removeTag( name )\
    DCMLMatrix[ name ] = nil\
end\
\
function Parser.setMatrix( tbl )\
    if type( tbl ) ~= \"table\" then\
        return error(\"Expected table\")\
    end\
end\
\
function Parser.loadFile( path )\
    if not fs.exists( path ) then\
        return error(\"Cannot load DCML content from path '\"..tostring( path )..\"' because the file doesn't exist\")\
    elseif fs.isDir( path ) then\
        return error(\"Cannot load DCML content from path '\"..tostring( path )..\"' because the path is a directory\")\
    end\
    local h = fs.open( path, \"r\" )\
    local data = h.readAll()\
    h.close()\
\
    return readData( data )\
end\
\
local function getFunction( instance, f )\
    if type( f ) == \"function\" then\
        return f\
    elseif type( f ) == \"string\" and sub( f, 1, 1 ) == \"#\" then\
        if not instance then\
            return false\
        else\
            local fn = instance[ sub( f, 2 ) ]\
            if type( fn ) == \"function\" then\
                return fn\
            end\
        end\
    end\
end\
\
local function convertToType( alias, value, key, matrix )\
    if type( matrix.argumentType ) ~= \"table\" then matrix.argumentType = {} end\
\
    key = alias and alias[ key ] or key\
    -- if the target classes re-directes this key elsewhere then use that key in the argumentType table\
    local toType = matrix.argumentType[ key ]\
    local fromType = type( value )\
\
    local rValue\
\
    if fromType == toType or not toType then\
        rValue = value\
    else\
        -- Convert\
        if toType == \"string\" then\
            rValue = tostring( value )\
        elseif toType == \"number\" then\
            local temp = tonumber( value )\
            if not temp then\
                return error(\"Failed to convert '\"..tostring( value )..\"' from type '\"..fromType..\"' to number when parsing DCML\")\
            end\
            rValue = temp\
        elseif toType == \"boolean\" then\
            rValue = value:lower() == \"true\"\
        elseif toType == \"color\" or toType == \"colour\" then\
            -- convert to a decimal colour\
            local temp = colours[ value ] or colors[ value ]\
            if not temp then\
                return error(\"Failed to convert '\"..tostring( value )..\"' from type '\"..fromType..\"' to colour when parsing DCML\")\
            end\
            rValue = temp\
        else\
            -- invalid/un-supported type\
            return error(\"Cannot parse type '\"..tostring( toType )..\"' using DCML\")\
        end\
    end\
\
    return rValue\
end\
\
local aliasCache = {}\
function Parser.parse( data )\
    -- Loop the data, create instances of any tags (default class name is the tag name) OR use the XML handler (function)\
    --[[\
        Matrix can have:\
\
        childHandler - If the tag has children this will be called with the parent tag and its children\
        customHandler - If the tag is found the tag content will be passed here and no further processing will occur\
        instanceHandler - When the tag instance is ready to be created this function/class will be called and any DCML arguments will be passed\
        contentCanBe - If the content of the tag is present and the node has no children the content will be assigned this key (contentCanBe = \"text\". The content will be set as text)\
        argumentHandler - If the tag has any arguments, this function will be called and passed the tag (args are in tag.xarg).\
        argumentType - This table will be used to convert arguments to their correct types. ( X = \"number\". X will be converted to a number if possible, else error )\
        callbacks - This table specifies the key name and controller function\
        callbackGenerator - Required function used generate callbacks. Expected to return a function that on call will execute the callback from its controller.\
\
        If the function entry is a normal function/class, then it will be called normally. However if the entry is a string starting with a '#' symbol then the function with a matching name will be called on the instance.\
\
        e.g: #callback (instance.callback)\
    ]]\
    local parsed = {}\
    for i = 1, #data do\
        local element = data[i]\
        local label = element.label\
\
        local matrix = DCMLMatrix[ label ]\
        if type( matrix ) ~= \"table\" then\
            return error(\"No DCMLMatrix for tag with label '\"..tostring(label)..\"'\")\
        end\
\
        local custom = getFunction( false, matrix.customHandler )\
        if custom then\
            table.insert( parsed, custom( element, DCMLMatrix ) )\
        else\
            local alias = {}\
            local handle = matrix.aliasHandler\
\
            if type( handle ) == \"table\" then\
                alias = handle\
            elseif type( handle ) == \"function\" then\
                alias = handle()\
            elseif handle == true then\
                -- simply use the tag name as the class and fetch from that\
                if not aliasCache[ label ] then\
                    log(\"i\", \"DCMLMatrix for \"..label..\" has instructed that DCML parsing should alias with the class '\"..label..\"'.__alias\")\
\
                    local c = class.getClass( label )\
                    if not c then\
                        error(\"Failed to fetch class for '\"..label..\"' while fetching alias information\")\
                    end\
\
                    aliasCache[ label ] = c.__alias\
                end\
\
                alias = aliasCache[ label ]\
            end\
            -- Compile arguments to be passed to the instance constructor.\
            local args = {}\
            local handler = getFunction( false, matrix.argumentHandler )\
\
            if handler then\
                args = handler( element )\
            else\
                local callbacks = matrix.callbacks or {}\
                for key, value in pairs( element.xarg ) do\
                    if not callbacks[ key ] then\
                        -- convert argument to correct type.\
                        args[ key ] = convertToType( alias, value, key, matrix )\
                    end\
                end\
\
                if element.content and not element.hasChildren and matrix.contentCanBe then\
                    args[ matrix.contentCanBe ] = convertToType( alias, element.content, matrix.contentCanBe, matrix )\
                end\
            end\
\
\
            -- Create an instance of the tag\
            local instanceFn = getFunction( false, matrix.instanceHandler ) or class.getClass(label)\
\
            local instance\
            if instanceFn then\
                instance = instanceFn( args )\
            end\
\
            if not instance then\
                return error(\"Failed to generate instance for DCML tag '\"..label..\"'\")\
            end\
\
            if element.hasChildren and matrix.childHandler then\
                local childHandler = getFunction( instance, matrix.childHandler )\
                if childHandler then\
                    childHandler( instance, element )\
                end\
            end\
\
            -- Handle callbacks here.\
            local generate = getFunction( instance, matrix.callbackGenerator )\
            if generate and type( matrix.callbacks ) == \"table\" then\
                for key, value in pairs( matrix.callbacks ) do\
                    if element.xarg[ key ] then\
                        instance[ value ] = generate( instance, key, element.xarg[ key ] ) -- name, callback link (#<callback>)\
                    end\
                end\
            elseif matrix.callbacks then\
                log(\"w\", \"Couldn't generate callbacks for '\"..label..\"' during DCML parse. Callback generator not defined\")\
            end\
\
            if matrix.onDCMLParseComplete then\
                matrix.onDCMLParseComplete( instance )\
            end\
\
            table.insert( parsed, instance )\
        end\
    end\
    return parsed\
end\
_G.DCML = Parser",
  [ "Daemon.lua" ] = "abstract class \"Daemon\" {\
    acceptMouse = false;\
    acceptMisc = false;\
    acceptKeyboard = false;\
\
    owner = nil;\
\
    __daemon = true;\
}\
\
function Daemon:initialise( name )\
    if not name then return error(\"Daemon '\"..self:type()..\"' cannot initialise without name\") end\
\
    self.name = name\
end\
\
function Daemon:start() log(\"d\", \"WARNING: Daemon '\"..self.name..\"' (\"..self:type()..\") has no start function declared\") end\
function Daemon:stop() log(\"d\", \"WARNING: Daemon '\"..self.name..\"' (\"..self:type()..\") has no end function declared\") end",
  [ "loadFirst.cfg" ] = "Logging.lua\
ClassUtil.lua\
TextUtil.lua\
DCMLParser.lua",
  [ "MDaemon.lua" ] = "abstract class \"MDaemon\" -- this class is used for mixin(s) only.\
\
function MDaemon:registerDaemon( service )\
    -- name -> string\
    -- service -> daemonService (class extending Daemon)\
    if not class.isInstance( service ) or not service.__daemon then\
        return error(\"Cannot register daemon '\"..tostring( service )..\"' (\"..type( service )..\")\")\
    end\
\
    if not service.name then return error(\"Daemon '\"..service:type()..\"' has no name!\") end\
    log(\"di\", \"Registered daemon of type '\"..service:type()..\"' (name \"..service.name..\") to \"..self:type())\
\
    service.owner = self\
    table.insert( self.__daemons, service )\
end\
\
function MDaemon:removeDaemon( name )\
    if not name then return error(\"Cannot un-register daemon with no name to search\") end\
    local daemons = self.__daemons\
\
    for i = 1, #daemons do\
        local daemon = daemons[i]\
        if daemon.name == name then\
            log(\"di\", \"Removed daemon of type '\"..daemon:type()..\"' (name \"..daemon.name..\") from \"..self:type()..\". Index \"..i)\
            table.remove( self.__daemons, i )\
        end\
    end\
end\
\
function MDaemon:get__daemons()\
    if type( self.__daemons ) ~= \"table\" then\
        self.__daemons = {}\
    end\
    return self.__daemons\
end\
\
function MDaemon:startDaemons()\
    local daemons = self.__daemons\
\
    for i = 1, #daemons do\
        daemons[i]:start()\
    end\
end\
\
function MDaemon:stopDaemons( graceful )\
    local daemons = self.__daemons\
\
    for i = 1, #daemons do\
        daemons[i]:stop( graceful )\
    end\
end",
  [ "Logging.lua" ] = "local loggingEnabled\
local loggingPath\
local loggingModes = {\
    i = \"Information\";\
    w = \"Warning\";\
    e = \"Error\";\
    f = \"FATAL\";\
    s = \"Success\";\
\
\
    di = \"Daemon Information\";\
    dw = \"Daemon Warning\";\
    de = \"Daemon Error\";\
    df = \"Daemon Fatal\";\
    ds = \"Daemon Success\";\
}\
local clearWhenLow = true\
local clearWhen = 50000\
\
local loggingIntroString = [[\
--@@== DynaCode Logging ==@@--\
\
\
Log Start >\
]]\
\
local log = {}\
function log:log( mode, message )\
    if not (loggingEnabled and loggingPath and mode and message) then return end\
\
    if clearWhenLow and fs.getSize( loggingPath ) >= clearWhen then\
        self:clearLog()\
\
        local f = fs.open( loggingPath, \"w\" )\
        f.write([[\
--@@== DynaCode Logging ==@@--\
\
This file was cleared at os time ']] .. os.clock() .. [[' to reduce file size.\
\
\
Log Resume >\
]])\
        f.close()\
    end\
\
    local f = fs.open( loggingPath, \"a\" )\
    f.write( \"[\"..os.clock()..\"][\".. ( loggingModes[ mode ] or mode ) ..\"] > \" .. message .. \"\\n\" )\
    f.close()\
end\
\
function log:registerMode( short, long )\
    loggingModes[ short ] = long\
end\
\
function log:setLoggingEnabled( bool )\
    loggingEnabled = bool\
end\
\
function log:getEnabled() return loggingEnabled end\
\
function log:setLoggingPath( path )\
    -- clear the path\
    loggingPath = path\
    self:clearLog( true )\
end\
\
function log:clearLog( intro )\
    if not loggingPath then return end\
\
    local f = fs.open( loggingPath, \"w\" )\
    if intro then\
        f.write( loggingIntroString )\
    end\
    f.close()\
end\
\
setmetatable( log, {__call = log.log})\
_G.log = log",
  [ "Input.lua" ] = "DCML.registerTag(\"Input\", {\
    argumentType = {\
        X = \"number\";\
        Y = \"number\";\
        width = \"number\";\
        height = \"number\";\
        backgroundColour = \"colour\";\
        textColour = \"colour\";\
        selectedTextColour = \"colour\";\
        selectedBackgroundColour = \"colour\";\
        activeTextColour = \"colour\";\
        activeBackgroundColour = \"colour\";\
    };\
    callbacks = {\
        onSubmit = \"onSubmit\"\
    };\
    callbackGenerator = \"#generateNodeCallback\"; -- \"#\" signifies relative function (on the instance.) @ Node.generateNodeCallback\
    aliasHandler = true\
})\
\
local len = string.len\
local sub = string.sub\
\
class \"Input\" extends \"Node\" alias \"ACTIVATABLE\" alias \"SELECTABLE\" {\
    acceptMouse = true;\
    acceptKeyboard = false;\
\
    content = false;\
    selected = nil;\
    cursorPosition = 0;\
\
    selectedTextColour = 1;\
    selectedBackgroundColour = colors.blue;\
\
    textColour = 32768;\
    backgroundColour = 128;\
\
    activeBackgroundColour = 256;\
    activeTextColour = 32768;\
\
    placeholder = \"Input\";\
}\
\
function Input:initialise( ... )\
    self.super( ... )\
\
    self.content = \"\"\
    self.selected = 0 -- from the cursor ( negative <, positive > )\
end\
\
\
function Input:preDraw()\
    local content, text = self.content, \"\"\
    local canvas = self.canvas\
\
    -- cache anything we will need to use/calculate often\
    local offset, width, content, contentLength, selected, selectionStart, selectionStop, selectionOffset, cursorPos = 0, self.width, self.content, len( self.content ), self.selected, 0, false, false, self.cursorPosition\
    local isCursorGreater = cursorPos >= width\
    local o = 0\
\
    local selectionUsedAsStart = false\
\
    if contentLength >= width then\
        if selected <= 0 and isCursorGreater then\
            offset = math.min(cursorPos - width, cursorPos + selected - 1) - contentLength\
            o = contentLength - width + ( cursorPos - contentLength )\
\
            if offset + contentLength == cursorPos + selected - 1 and math.abs( offset ) > width + ( contentLength - cursorPos ) then selectionUsedAsStart = true end\
        elseif selected > 0 and cursorPos + selected > width then\
            offset = ( math.max( cursorPos, cursorPos + selected - 1 ) ) - contentLength - self.width\
        end\
    end\
\
    selectionStart = math.min( cursorPos + selected, cursorPos ) - o + ( isCursorGreater and 0 or 1 )\
    selectionStop = math.max( cursorPos + selected, cursorPos ) - o - ( (isCursorGreater and not selectionUsedAsStart) and 1 or 0 )\
\
    local buffer = self.canvas.buffer\
    local hasSelection = selected ~= 0\
\
    -- take manual control of the buffer to draw the way we want to with minimal performance hits\
    for w = 1, self.width do\
        -- our drawing space, from here we figure out any offsets needed when drawing text\
        local index = w + offset\
        local isSelected = hasSelection and w >= selectionStart and w <= selectionStop\
\
        local char = sub( content, index, index )\
        char = char ~= \"\" and char or \" \"\
\
        if isSelected then\
            buffer[ w ] = { char, 1, colours.blue }\
        else\
            buffer[ w ] = { char, colours.red, colors.lightGray }\
        end\
    end\
    self.canvas.buffer = buffer\
end\
\
function Input:onMouseDown()\
    self.stage:redirectKeyboardFocus( self )\
end\
\
local function checkSelection( self )\
    local selected = self.selected\
    if selected < 0 then\
        -- check if the selection goes back too far\
        local limit = -len(self.content) + ( self.cursorPosition - len( self.content ) )\
        if selected < limit then\
            self.selected = limit\
        end\
    elseif selected > 0 then\
        local limit = len( self.content ) - self.cursorPosition\
        if selected > limit then self.selected = limit end\
    end\
end\
\
local function checkPosition( self )\
    if self.cursorPosition < 0 then self.cursorPosition = 0 elseif self.cursorPosition > len( self.content ) then self.cursorPosition = len( self.content ) end\
    self.selected = 0\
end\
\
local function adjustContent( self, content, offsetPre, offsetPost, cursorAdjust )\
    local text = self.content\
    text = sub( text, 1, self.cursorPosition + offsetPre ) .. content .. sub( text, self.cursorPosition + offsetPost )\
\
    self.content = text\
    self.cursorPosition = self.cursorPosition + cursorAdjust\
\
    checkPosition( self )\
end\
\
function Input:onKeyDown( event )\
    -- check what key was pressed and act accordingly\
    local key = keys.getName( event.key )\
    local hk = self.stage.application.hotkey\
\
    local cursorPos, selection = self.cursorPosition, self.selected\
\
    if hk.keys.shift then\
        -- the shift key is being pressed\
        -- adjust selection\
        if key == \"left\" then\
            selection = selection - 1\
        elseif key == \"right\" then\
            selection = selection + 1\
        elseif key == \"home\" then\
            -- select from cursor to start\
            selection = -(self.cursorPosition)\
        elseif key == \"end\" then\
            -- select from cursor to end\
            selection = len( self.content ) - self.cursorPosition\
        end\
    elseif hk.keys.ctrl then\
        -- move selection/cursor\
        if key == \"left\" then\
            cursorPos = cursorPos - 1\
        elseif key == \"right\" then\
            cursorPos = cursorPos + 1\
        end\
    else\
        if key == \"left\" then\
            cursorPos = cursorPos - 1\
            selection = 0\
        elseif key == \"right\" then\
            cursorPos = cursorPos + 1\
            selection = 0\
        elseif key == \"home\" then\
            cursorPos = 0\
            selection = 0\
        elseif key == \"end\" then\
            cursorPos = len( self.content )\
            selection = 0\
        elseif key == \"backspace\" then\
            if self.cursorPosition == 0 then return end\
            adjustContent( self, \"\", -1, 1, -1 )\
        elseif key == \"delete\" then\
            if self.cursorPosition == #self.content then return end\
            adjustContent( self, \"\", 0, 2, 0 )\
        elseif key == \"enter\" then\
            if self.onTrigger then self:onTrigger( event ) end\
        end\
    end\
    self.cursorPosition = cursorPos\
    self.selected = selection\
end\
\
function Input:setContent( content )\
    self.content = content\
    self.changed = true\
end\
\
function Input:setCursorPosition( pos )\
    self.cursorPosition = pos\
    checkPosition( self )\
    self.changed = true\
end\
\
function Input:setSelected( s )\
    self.selected = s\
    checkSelection( self )\
    self.changed = true\
end\
\
function Input:onChar( event )\
    adjustContent( self, event.key, 0, 1, 1 )\
end\
\
function Input:onMouseMiss( event )\
    if event.sub == \"UP\" then return end\
    -- if a mouse event occurs off of the input, remove focus from the input.\
    self.stage:removeKeyboardFocus( self )\
end\
\
function Input:getCursorInformation()\
    local x, y = self:getTotalOffset()\
\
    local cursorPos\
    if self.cursorPosition < self.width then\
        cursorPos = self.cursorPosition\
    else\
        cursorPos = self.width - 1\
    end\
\
    return self.selected == 0, x + cursorPos - 1, y, self.activeTextColour\
end\
\
function Input:onFocusLost() self.focused = false; self.acceptKeyboard = false; self.changed = true end\
function Input:onFocusGain() self.focused = true; self.acceptKeyboard = true; self.changed = true end",
  [ "scriptFiles.cfg" ] = "ClassUtil.lua\
TextUtil.lua\
DCMLParser.lua\
Logging.lua",
  [ "Application.lua" ] = "class \"Application\" alias \"COLOUR_REDIRECT\" mixin \"MDaemon\" {\
    canvas = nil;\
    hotkey = nil;\
    timer = nil;\
    event = nil;\
\
    stages = {};\
\
    changed = true;\
    running = false;\
\
    lastID = 0;\
}\
\
function Application:initialise( ... )\
    -- Classes can be called with either a single table of arguments, or a series of required arguments. The latter only allows certain arguments.\
    -- Here, we use the classUtil.lua functionality to parse the arguments passed to the application.\
\
    ParseClassArguments( self, { ... }, { { \"width\", \"number\" }, {\"height\", \"number\"} }, true )\
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
    });\
    self.timer = TimerManager( self )\
\
    --self.stages = {}\
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
\
    self:clearLayerMap()\
end\
\
function Application:clearLayerMap()\
    local layerMap = {}\
    for i = 1, self.width * self.height do\
        layerMap[ i ] = false\
    end\
\
    self.layerMap = layerMap\
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
    stage.mappingID = self.lastID + 1\
\
    self.lastID = self.lastID + 1\
\
    self.stages[ #self.stages + 1 ] = stage\
\
    stage:map()\
    return stage\
end\
\
function Application:removeStage( stageOrName )\
    local isStage = class.typeOf( stageOrName, \"Stage\", true )\
    for i = 1, #self.stages do\
        local stage = self.stages[ i ]\
        if ( isStage and stage == stageOrName ) or ( not isStage and stage.name == stageOrName ) then\
            table.remove( self.stages, i )\
            self.changed = true\
        end\
    end\
end\
\
function Application:draw( force )\
    -- orders all stages to draw to the application canvas\
    --if not self.changed then return end\
\
    for i = #self.stages, 1, -1 do\
        self.stages[ i ]:draw( force )\
    end\
\
    -- Then draw the application to screen\
    self.canvas:drawToScreen( force )\
    self.changed = false\
end\
\
\
function Application:run( thread )\
    -- If present, execute the callback thread in parallel with the main event loop.\
    log(\"i\", \"Attempting to start application\")\
    self.running = true\
    self.hotkey:reset()\
\
    local function engine()\
        -- DynaCode main runtime loop\
        local hk = self.hotkey\
        local tm = self.timer\
\
        if self.onRun then self:onRun() end\
\
        self:draw( true )\
        log(\"s\", \"Engine start successful. Running in protected mode\")\
        while self.running do\
\
            -- If there is an outstanding stage re-order request then handle this now (move the new stage to the top of the stage table)\
            if self.reorderRequest then\
                log(\"i\", \"Reordering stage list\")\
                -- remove this stage from the table and re-insert it at the beggining.\
                local stage = self.reorderRequest\
                for i = 1, #self.stages do\
                    if self.stages[i] == stage then\
                        table.insert( self.stages, 1, table.remove( self.stages, i ) )\
                        self:setStageFocus( stage )\
                        break\
                    end\
                end\
                self.reorderRequest = nil\
            end\
\
\
            term.setCursorBlink( false )\
            self:draw()\
\
            for i = 1, #self.stages do --< temporary 'for' loop\
                self.stages[i]:appDrawComplete() -- stages may want to add a cursor blink on screen etc..\
            end\
\
            local event = self.event:create( { coroutine.yield() } )\
            self.event:shipToRegistrations( event )\
\
            if event.main == \"KEY\" then\
                hk:handleKey( event )\
                hk:checkCombinations()\
            elseif event.main == \"TIMER\" then\
                tm:update( event.raw[2] )\
            end\
\
            for i = 1, #self.stages do\
                if self.stages[i] then\
                    self.stages[i]:handleEvent( event )\
                end\
            end\
        end\
    end\
\
    log(\"i\", \"Trying to start daemon services\")\
    local _, err = pcall( function() self:startDaemons() end ) -- daemons started before anything else.\
    if err then\
        log(\"f\", \"Failed to start daemon services. Reason '\" .. tostring( err ) .. \"'\")\
        if self.errorHandler then\
            self:errorHandler( err, false )\
        else\
            if self.onError then self:onError( err ) end\
            error(\"Failed to start daemon service: \"..err)\
        end\
    elseif ok then\
        log(\"s\", \"Daemon service started\")\
    end\
\
    log(\"i\", \"Starting engine\")\
    local ok, err = pcall( engine )\
    if not ok and err then\
        log(\"f\", \"Engine error: '\"..tostring( err )..\"'\")\
        if self.errorHandler then\
            self:errorHandler( err, true )\
        else\
            -- crashed\
            term.setTextColour( colours.yellow )\
            print(\"DynaCode has crashed\")\
            term.setTextColour( colours.red )\
            print( err )\
            print(\"\")\
\
            local function crashProcess( preColour, pre, fn, errColour, errPre, okColour, okMessage, postColour )\
                term.setTextColour( preColour )\
                print( pre )\
\
                local ok, err = pcall( fn )\
                if err then\
                    term.setTextColour( errColour )\
                    print( errPre .. err )\
                else\
                    term.setTextColour( okColour )\
                    print( okMessage )\
                end\
\
                term.setTextColour( postColour )\
            end\
\
            local YELLOW, RED, LIME = colours.yellow, colours.red, colours.lime\
\
            crashProcess( YELLOW, \"Attempting to stop daemon service and children\", function() self:stopDaemons( false ) end, RED, \"Failed to stop daemon service: \", LIME, \"Stopped daemon service\", 1 )\
            print(\"\")\
\
            crashProcess( YELLOW, \"Attempting to write crash information to log file\", function()\
                log(\"f\", \"DynaCode crashed: \"..err)\
            end, RED, \"Failed to write crash information: \", LIME, \"Wrote crash information to file\", 1 )\
            if self.onError then self:onError( err ) end\
        end\
    end\
end\
\
function Application:finish( thread )\
    log(\"i\", \"Stopping Daemons\")\
    self:stopDaemons( true )\
\
    log(\"i\", \"Stopping Application\")\
    self.running = false\
    os.queueEvent(\"stop\") -- if the engine is waiting for an event give it one so it can realise 'running' is false -> while loop finished -> exit and return.\
    if type( thread ) == \"function\" then thread() end\
end\
\
function Application:mapWindow( x1, y1, x2, y2 )\
    -- Updates drawing map for windows. Prevents windows that aren't visible from drawing themselves (if they are covered by other windows)\
    -- Also clears the area used by the window if the current window is not visible.\
\
\
    local stages = self.stages\
    local layers = self.layerMap\
\
    for i = #stages, 1, -1 do -- This loop works backwards, meaning the stage at the top of the stack is ontop during drawing and mapping also.\
        local stage = stages[ i ]\
\
        local stageX, stageY = stage.X, stage.Y\
        local stageWidth, stageHeight = stage.canvas.width, stage.canvas.height\
\
        local stageX2, stageY2\
        stageX2 = stageX + stageWidth\
        stageY2 = stageY + stageHeight\
\
        local stageVisible = stage.visible\
        local ID = stage.mappingID\
\
        if not (stageX > x2 or stageY > y2 or x1 > stageX2 or y1 > stageY2) then\
            for y = math.max(stageY, y1), math.min(stageY2, y2) do\
                local yPos = self.width * ( y - 1 )\
\
                for x = math.max(stageX, x1), math.min(stageX2, x2) do\
                    local layer = layers[ yPos + x ]\
\
                    if layer ~= ID and stageVisible and ( stage:isPixel( x - stageX + 1 , y - stageY + 1 ) ) then\
                        layers[ yPos + x ] = ID\
                    elseif layer == ID and not stageVisible then\
                        layers[ yPos + x ] = false\
                    end\
                end\
            end\
        end\
    end\
\
    local buffer = self.canvas.buffer\
    local width = self.width\
    local layers = self.layerMap\
    for y = y1, y2 do\
        -- clear the unused pixels back to background colours.\
        local yPos = width * ( y - 1 )\
\
        for x = x1, x2 do\
            local pos = yPos + x\
            local layer = layers[ yPos + x ]\
            if layer == false then\
                if buffer[ pos ] then buffer[ pos ] = { false, false, false } end -- bg pixel. Anything may draw in this space.\
            end\
        end\
    end\
end\
\
function Application:requestStageFocus( stage )\
    -- queue a re-order of the stages.\
    self.reorderRequest = stage\
end\
\
function Application:setStageFocus( stage )\
    if not class.isInstance( stage, \"Stage\" ) then return error(\"Expected Class Instance Stage, not \"..tostring( stage )) end\
\
    -- remove the current stage focus (if one)\
    self:unSetStageFocus()\
\
    stage:onFocus()\
    self.focusedStage = stage\
end\
\
function Application:unSetStageFocus( stage )\
    local stage = stage or self.focusedStage\
\
    if self.focusedStage and self.focusedStage == stage then\
        self.focusedStage:onBlur()\
        self.focusedStage = nil\
    end\
end\
\
function Application:getStageByName( name )\
    local stages = self.stages\
\
    for i = 1, #stages do\
        local stage = stages[i]\
\
        if stage.name == name then return stage end\
    end\
end\
\
local function getFromDCML( path )\
    return DCML.parse( DCML.loadFile( path ) )\
end\
function Application:appendStagesFromDCML( path )\
    local data = getFromDCML( path )\
\
    for i = 1, #data do\
        local stage = data[i]\
        if class.typeOf( stage, \"Stage\", true ) then\
            self:addStage( stage )\
        else\
            return error(\"The DCML parser has created a \"..tostring( stage )..\". This is not a stage and cannot be added as such. Please ensure the DCML file '\"..tostring( path )..\"' only creates stages with nodes inside of them, not nodes by themselves. Refer to the wiki for more information\")\
        end\
    end\
end",
  [ "Class.lua" ] = "local gsub, match = string.gsub, string.match\
\
-- Define Class Settings\
local CRASH_DUMP = {\
    ENABLE = false;\
    LOCATION = \"DynaCrash-Dump.crash\"\
}\
\
local MISSING_CLASS_LOADER;\
local RESERVED = {\
    __type = true;\
    __defined = true;\
    __class = true;\
    __extends = true;\
    __instance = true;\
    __alias = true;\
};\
local WORK_ENV = _G;\
\
-- Define Class Variables\
local raw_access\
\
local current\
local last\
local classes = {}\
\
local class = {}\
\
local setters = setmetatable( {}, {__index = function( self, key )\
    -- This will be called when a setter we need is not cached. Create the name and change the name.\
    local setter = \"set\" .. key:sub( 1,1 ):upper() .. key:sub( 2 )\
    self[ key ] = setter\
\
    return setter\
end})\
\
local getters = setmetatable( {}, {__index = function( self, key )\
    local getter = \"get\" .. key:sub( 1,1 ):upper() .. key:sub( 2 )\
    self[ key ] = getter\
\
    return getter\
end})\
\
--[[\
    @local\
    @desc Will try to execute 'method' passing arg 3+ to the call. If failed to execute 'err' will be thrown.\
    @param\
        @var method\
        @string err\
        @args ...\
    @return methodCall OR error\
]]\
local function exec( method, err, ... )\
    if type( method ) == \"function\" then\
        return method( ... )\
    else\
        return error( err )\
    end\
end\
\
\
--[[\
    @local\
    @desc Enables accessing of class raw content, grabs the raw content and disables access again. Returns content\
    @param\
        @class target\
    @return table\
]]\
local function getRawContent( target )\
    raw_access = true\
    local c = target:getRaw()\
    raw_access = false\
\
    return c\
end\
\
\
--[[\
    @local\
    @desc Attempts to load 'target' via use of the custom class loader.\
    @param\
        @string target\
    @return class OR error\
]]\
local function loadRequiredClass( target )\
    -- Target class is required by another class. Store current configuration settings and load this class.\
    local oCurrent = current\
    local c, _c\
\
    c = exec( MISSING_CLASS_LOADER, \"MISSING_CLASS_LOADER method not defined. Cannot load missing target class '\"..tostring(target)..\"'\", target )\
\
    _c = classes[ target ]\
    if class.isClass( _c ) then\
        if not _c:isSealed() then _c:seal() end\
    else\
        return error(\"Target class '\"..tostring( target )..\"' failed to load\")\
    end\
\
    current = oCurrent -- restore old current (continue olding the class that required this class) AFTER the new class has been sealed (the target class may also require a class)\
    return _c\
end\
\
\
local function fetchClass( target, mustBeSealed )\
    local _c = classes[ target ]\
    if class.isClass( _c ) then\
        if _c:isSealed() or not mustBeSealed then\
            return _c\
        elseif mustBeSealed then\
            return error(\"Failed to fetch target class '\"..target..\"'. Target isn't sealed.\")\
        end\
    else\
        return loadRequiredClass( target )\
    end\
end\
\
\
--[[\
    @local\
    @desc Returned by class functions when a table of arguments may be expected to trail the call. The contents of the table will be added to the current class\
    @param\
        @table t\
    @return nil OR error\
]]\
local function propertyCatch( t )\
    if type( t ) == \"table\" then\
        for key, value in pairs( t ) do\
            if type( value ) == \"function\" then return error(\"Cannot set function indexes in class properties!\") end\
\
            current[ key ] = value\
        end\
    elseif type( t ) ~= \"nil\" then\
        return error(\"Unknown object trailing class declaration '\"..tostring( t )..\" (\" .. type( t ) .. \")'\")\
    end\
end\
\
--[[\
    @local\
    @desc Creates a completely independant table that contains all the same information as the 'source'\
    @param\
        @var source\
    @return var\
]]\
local function deepCopy( source, useB )\
    local orig_type = type( source )\
    local copy\
    if orig_type == 'table' then\
        copy = {}\
        for key, value in next, source, nil do\
            if not useB or ( useB and not RESERVED[ key ] ) then\
                copy[ deepCopy( key ) ] = deepCopy( value )\
            end\
        end\
    else\
        copy = source\
    end\
    return copy\
end\
\
\
local function preprocess( data )\
    local name = match( data, \"abstract class (\\\"%w*\\\")\")\
    if name then\
        data = gsub( data, \"abstract class \"..name, \"class \"..name..\" abstract()\")\
    end\
    return data\
end\
\
\
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
    local f = fs.open(CRASH_DUMP.LOCATION, \"w\")\
    f.write( data ..\"-- END OF FILE --\" )\
    f.write(\"\\n\\n\"..footer)\
    f.close()\
end\
\
--[[\
    @local\
    @desc Creates a matrix of super methods\
    @param\
        @class instance\
        @string target\
    @return table\
]]\
local function formSuper( instance, target, total )\
    -- Find the class, load if it is required and not already loaded.\
    local totalKeyPairs = total or {}\
\
    local super = fetchClass( target, true )\
    local superRaw = deepCopy( getRawContent( super ) )\
    local superProxy, superProxyMt = {}, {}\
\
    local sym\
\
    for key, value in pairs( superRaw ) do\
        if not totalKeyPairs[ key ] and not RESERVED[ key ] then\
            totalKeyPairs[ key ] = value\
        end\
    end\
\
    if superRaw.__extends then\
        local keys\
        superProxy.super, keys = formSuper( instance, superRaw.__extends, totalKeyPairs )\
\
        sym = true\
        for key, value in pairs( keys ) do\
            if not superRaw.__defined[ key ] then superRaw[ key ] = value end\
        end\
        sym = false\
    end\
\
    local function getKeyFromSuper( k )\
        local last = superProxy\
\
        while true do\
            local _super = last.super\
            if _super then\
                if _super.__defined[ k ] then return _super[ k ] else last = _super end\
            else break end\
        end\
    end\
\
    local function applyKeyValue( k, v )\
        local last = instance\
        local supers = {}\
\
        while true do\
            if last.__defined[ k ] then\
                return true\
            else\
                supers[ #supers + 1 ] = last\
                if last.super ~= superProxy and last.super then last = last.super\
                else\
                    for i = 1, #supers do supers[i]:addSymbolicKey( k, v ) end\
                    break\
                end\
            end\
        end\
    end\
\
    local cache = {}\
    function superProxyMt:__index( k )\
        -- search for the method on the supers raw\
        if type( superRaw[ k ] ) == \"function\" then\
            if not cache[ k ] then cache[ k ] = function( self, ... )\
                local old = instance.super\
                instance.super = superProxy.super\
\
                local v = { superRaw[ k ]( instance, ... ) }\
                instance.super = old\
\
                return unpack( v )\
            end end\
            return cache[ k ]\
        else\
            return superRaw[ k ]\
        end\
    end\
\
    function superProxyMt:__newindex( k, v )\
        superRaw[ k ] = v == nil and getKeyFromSuper( k ) or v\
\
        if not sym then superRaw.__defined[ k ] = v ~= nil or nil end\
        applyKeyValue( k, v )\
    end\
\
    function superProxyMt:__tostring() return \"[Super] \"..superRaw.__type..\" of \"..tostring( instance ) end\
\
    function superProxyMt:__call( ... )\
        -- if a super table is called run the constructor.\
        local initName = ( type( superRaw.initialise ) == \"function\" and \"initialise\" or ( type( superRaw.initialize ) == \"function\" and \"initialize\" or false ) )\
        if initName then\
            return superRaw[ initName ]( instance, ... )\
        end\
    end\
\
    function superProxy:addSymbolicKey( k, v )\
        sym = true; self[ k ] = v; sym = false\
    end\
\
\
    setmetatable( superProxy, superProxyMt )\
    return superProxy, totalKeyPairs\
end\
\
--[[\
    @local\
    @desc Creates a new instance of class 'obj'\
    @param\
        @class obj\
    @return class instance\
]]\
local function new( obj, ... )\
    -- create instance tables\
    local instanceRaw = deepCopy( getRawContent( obj ) )\
    instanceRaw.__instance = true\
\
    local instance, instanceMt = {}, {}\
    local alias = instanceRaw.__alias or {}\
    local sym\
\
    instance.raw = instanceRaw\
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
    local keys\
    if instanceRaw.__extends then\
        instance.super, keys = formSuper( instance, instanceRaw.__extends )\
\
        for key, value in pairs( keys ) do\
            if not instanceRaw.__defined[ key ] and not RESERVED[ key ] then\
                instanceRaw[ key ] = value\
            end\
        end\
    end\
\
    -- create instance proxies\
\
    local getting = {}\
    function instanceMt:__index( k )\
        local k = alias[ k ] or k\
\
        local getter = getters[ k ]\
        if type(instanceRaw[ getter ]) == \"function\" and not getting[ k ] then\
            getting[ k ] = true\
            local v = { instanceRaw[ getter ]( self ) }\
            getting[ k ] = nil\
\
            return unpack( v )\
        else\
            return instanceRaw[ k ]\
        end\
    end\
\
    local setting = {}\
    function instanceMt:__newindex( k, v )\
        local k = alias[ k ] or k\
\
        local setter = setters[ k ]\
        if type( instanceRaw[ setter ] ) == \"function\" and not setting[ k ] then\
            setting[ k ] = true\
            instanceRaw[ setter ]( self, v )\
            setting[ k ] = nil\
        else\
            instanceRaw[ k ] = v\
        end\
        if v == nil then\
            instanceRaw[ k ] = seekFromSuper( k )\
        end\
        if not sym then\
            instanceRaw.__defined[ k ] = v ~= nil or nil\
        end\
    end\
\
    function instanceMt:__tostring() return \"[Instance] \"..instanceRaw.__type end\
\
    -- additional instance methods\
    function instance:type() return instanceRaw.__type end\
\
    function instance:addSymbolicKey( k, v )\
        sym = true; self[ k ] = v; sym = false\
    end\
\
    local locked = {\
        [\"__index\"] = true;\
        [\"__newindex\"] = true;\
    }\
    function instance:__overrideMetaMethod( method, fn )\
        if locked[ method ] then return error(\"Meta method '\"..tostring( method )..\"' cannot be overridden\") end\
\
        instanceMt[ method ] = fn\
    end\
\
    function instance:__lockMetaMethod( method ) locked[ method ] = true end\
\
    setmetatable( instance, instanceMt )\
\
    local initName = ( type( instanceRaw.initialise ) == \"function\" and \"initialise\" or ( type( instanceRaw.initialize ) == \"function\" and \"initialize\" or false ) )\
    if initName then instanceRaw[ initName ]( instance, ... ) end\
\
    return instance\
end\
\
\
--[[\
    @static\
    @desc Creates a new class base\
    @param\
        @string name\
    @return function\
]]\
function class.forge( name )\
    -- Class definition\
    local raw = {}\
    raw.__class = true\
    raw.__type = name\
    raw.__defined = {}\
\
    local proxy = {}\
\
    -- Class private settings\
    local isAbstract, isSealed, mixinTargets, rawMode = false, false, {}, false\
\
    function proxy:isSealed() return isSealed end\
    function proxy:isAbstract() return isAbstract end\
\
    function proxy:seal()\
        if isSealed then return error(\"Class is already sealed\") end\
\
        if #mixinTargets > 0 then\
            -- implement these mixin targets\
            for i = 1, #mixinTargets do\
                local mixin = mixinTargets[ i ]\
\
                local _class = fetchClass( mixin )\
\
                local cnt = getRawContent( _class )\
                for key, value in pairs( cnt ) do\
                    if not raw[ key ] and not RESERVED[ key ] then\
                        raw[ key ] = value\
                    end\
                end\
            end\
        end\
\
        -- Compile the alias NOW! This is needed because DCML parsing gets the alias settings from the base class (because the instance isn't ready when DCML is parsing).\
        local tAlias = self.__alias or {}\
        local last = self\
\
        local super, cnt\
        while true do\
            super = last.__extends\
            if super then\
                cnt = getRawContent( fetchClass( super, true ) )\
\
                local _alias = cnt.__alias\
                if _alias then\
                    -- add these keys\
                    for key, value in pairs( _alias ) do\
                        if not tAlias[ key ] then tAlias[ key ] = value end\
                    end\
                end\
                last = super\
            else\
                break\
            end\
        end\
\
        self.__alias = tAlias\
\
        isSealed = true\
        if current == self then last = self current = nil end\
    end\
\
    function proxy:spawn( ... )\
        if not isSealed then return error(\"Cannot spawn instance of '\"..name..\"'. Class is un-sealed\") end\
        if isAbstract then return error(\"Cannot spawn instance of '\"..name..\"'. Class is abstract\") end\
\
        return new( self, ... )\
    end\
\
    function proxy:getRaw()\
        if not raw_access then return error(\"Cannot fetch raw content of class (DISABLED)\") end\
\
        return raw\
    end\
\
    function proxy:type()\
        return self.__type\
    end\
\
    function proxy:symIndex( k, v )\
        rawMode = true; self[ k ] = v; rawMode = false\
    end\
\
    function proxy:extend( target )\
        if isSealed then return error(\"Cannot extend base class after being sealed\") end\
\
        self:symIndex( \"__extends\", target )\
    end\
\
    function proxy:mixin( target )\
        if isSealed then return error(\"Cannot add mixin targets to class base after being sealed\") end\
\
        mixinTargets[ #mixinTargets + 1 ] = target\
    end\
\
    function proxy:abstract( bool )\
        if isSealed then return error(\"Cannot modify abstract state of class base after being sealed\") end\
\
        isAbstract = bool\
    end\
\
    function proxy:alias( tbl )\
        if isSealed then return error(\"Cannot set alias table of class base after being sealed\") end\
\
        if not raw.__alias then\
            raw.__alias = tbl\
        else\
            for key, value in pairs( tbl ) do\
                raw.__alias[ key ] = value -- override any others with the same key.\
            end\
        end\
    end\
\
    local proxyMt = {}\
    function proxyMt:__newindex( k, v )\
        if isSealed then return error(\"Cannot create new indexes on class base after being sealed\") end\
\
        raw[ k ] = v\
        if not rawMode then\
            raw.__defined[ k ] = v ~= nil or nil\
        end\
    end\
    proxyMt.__index = raw\
\
    function proxyMt:__tostring()\
        return (isSealed and \"[Sealed] \" or \"[Un-sealed] \") .. name\
    end\
\
    function proxyMt:__call( ... ) return self:spawn( ... ) end\
\
    setmetatable( proxy, proxyMt )\
\
    current = proxy\
    WORK_ENV[ name ] = proxy\
    classes[ name ] = proxy\
\
    return propertyCatch\
end\
\
\
-- Util functions\
function class.getClass( name ) return classes[ name ] end\
function class.setClassLoader( fn )\
    if type( fn ) ~= \"function\" then return error(\"Cannot set missing class loader to variable of type '\"..type( fn )..\"'\") end\
\
    MISSING_CLASS_LOADER = fn\
end\
function class.isClass( target )\
    return type( target ) == \"table\" and type( target.type ) == \"function\" and classes[ target:type() ] and target.__class\
end\
function class.isInstance( target )\
    return class.isClass( target ) and target.__instance\
end\
function class.typeOf( target, _type, strict )\
    if not class.isClass( target ) or ( strict and not class.isInstance( target ) ) then return false end\
\
    return target:type() == _type\
end\
\
function class.runClassString( str, file, ignore )\
    local ext = CRASH_DUMP.ENABLE and \" The file being loaded at the time of the crash has been saved to '\"..CRASH_DUMP.LOCATION..\"'\" or \"\"\
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
setmetatable( class, {\
    __call = function( self, name ) return class.forge( name ) end\
})\
\
WORK_ENV.class = class\
WORK_ENV.extends = function( target )\
    if type( target ) ~= \"string\" then return error(\"Failed to extend building class to target '\"..tostring( target )..\"'. Invalid target\") end\
\
    current:extend( target )\
    return propertyCatch\
end\
WORK_ENV.mixin = function( target )\
    if type( target ) ~= \"string\" then return error(\"Failed to mix target class '\"..tostring( target )..\"' into the building class. Invalid target\") end\
\
    current:mixin( target )\
    return propertyCatch\
end\
WORK_ENV.abstract = function()\
    current:abstract( true )\
\
    return propertyCatch\
end\
WORK_ENV.alias = function( tbl )\
    if type( tbl ) == \"string\" then\
        if type( WORK_ENV[ tbl ] ) == \"table\" then\
            tbl = WORK_ENV[ tbl ]\
        else\
            return error(\"Cannot load table for alias from WORK_ENV: \"..tostring( tbl ))\
        end\
    elseif type( tbl ) ~= \"table\" then\
        return error(\"Cannot set alias to '\"..tostring( tbl )..\"'. Invalid type\")\
    end\
\
    current:alias( tbl )\
    return propertyCatch\
end",
  [ "Node.lua" ] = "abstract class \"Node\" alias \"COLOUR_REDIRECT\" {\
    X = 1;\
    Y = 1;\
\
    width = 0;\
    height = 0;\
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
\
    eventConfig = {\
        [\"MouseEvent\"] = {\
            acceptAll = false\
        };\
        acceptAll = false;\
        acceptMisc = false;\
        acceptKeyboard = false;\
        acceptMouse = false;\
        manuallyHandle = false;\
    }\
}\
\
function Node:initialise( ... )\
    local X, Y, width, height = ParseClassArguments( self, { ... }, { { \"X\", \"number\" }, { \"Y\", \"number\" }, { \"width\", \"number\" }, { \"height\", \"number\" } }, false, true )\
\
    -- Creates a NodeCanvas\
    self.canvas = NodeCanvas( self, width or 1, height - 1 or 0 )\
\
    self.X = X\
    self.Y = Y\
    self.width = width or 1\
    self.height = height or 1\
end\
\
function Node:draw( xO, yO )\
    -- Call any draw functions on the node (pre, post) and update its 'changed' state. Then draw the nodes canvas to the stages canvas\
    if self.preDraw then\
        self:preDraw( xO, yO )\
    end\
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
    --TODO Update canvas width *job release-0*\
    self.width = width\
end\
\
function Node:setHeight( height )\
    --TODO set height on instance and canvas. *job release-0*\
    self.height = height\
end\
\
function Node:setBackgroundColour( col )\
    --TODO force update on children too (if they are using the nodes color as default) *job release-0*\
    self.backgroundColour = col\
end\
\
function Node:setTextColour( col )\
    --TODO force update on children too (if they are using the nodes color as default) *job release-0*\
    self.textColour = col\
end\
\
function Node:onParentChanged()\
    self.changed = true\
end\
\
local function call( self, callback, ... )\
    if type( self[ callback ] ) == \"function\" then\
        self[ callback ]( self, ... )\
    end\
end\
\
local clickMatrix = {\
    CLICK = \"onMouseDown\";\
    UP = \"onMouseUp\";\
    SCROLL = \"onMouseScroll\";\
    DRAG = \"onMouseDrag\";\
}\
function Node:handleEvent( event )\
    -- Automatically fires callbacks on the node depending on the event. For example onMouseMiss, onMouseDown, onMouseUp etc...\
    if event.handled then return end\
\
    if not self.manuallyHandle then\
        if event.main == \"MOUSE\" and self.acceptMouse then\
            if event:inArea( self.X, self.Y, self.X + self.width - 1, self.Y + self.height - 1 ) then\
                call( self, clickMatrix[ event.sub ] or error(\"No click matrix entry for \"..tostring( event.sub )), event )\
            else\
                call( self, \"onMouseMiss\", event )\
            end\
        elseif event.main == \"KEY\" and self.acceptKeyboard then\
            call( self, event.sub == \"UP\" and \"onKeyUp\" or \"onKeyDown\", event )\
        elseif event.main == \"CHAR\" and self.acceptKeyboard then\
            call( self, \"onChar\", event )\
        elseif self.acceptMisc then\
            -- unknown main event\
            call( self, \"onUnknownEvent\", event )\
        end\
\
        call( self, \"onAnyEvent\", event )\
    else\
        call( self, \"onEvent\", event )\
    end\
end\
\
function Node:setChanged( bool )\
    self.changed = bool\
\
    if bool then\
        local parent = self.parent or self.stage\
        if parent then\
            parent.changed = true\
        end\
    end\
end\
\
function Node:getTotalOffset()\
    -- goes up through every parent and returns the total X, Y offset.\
    local X, Y = 0, 0\
    if self.parent then\
        -- get the offset from the parent, add this to the total\
        local pX, pY = self.parent:getTotalOffset()\
        X = X + pX - 1\
        Y = Y + pY - 1\
    elseif self.stage then\
        X = X + self.stage.X\
        Y = Y + self.stage.Y\
    end\
\
    X = X + self.X\
    Y = Y + self.Y\
    return X, Y\
end\
\
-- STATIC\
function Node.generateNodeCallback( node, a, b )\
    return (function( ... )\
        local stage = node.stage\
        if not stage then\
            return error(\"Cannot link to node '\"..node:type()..\"' stage.\")\
        end\
        stage:executeCallback( b, ... )\
    end)\
end",
  [ "EventManager.lua" ] = "class \"EventManager\"\
function EventManager:initialise( application, matrix )\
    -- The matrix should contain a table of event -> event class: { [\"mouse_up\"] = MouseEvent }\
    self.application = AssertClass( application, \"Application\", true, \"EventManager instance requires an Application Instance, not: \"..tostring( application ) )\
    self.matrix = type( matrix ) == \"table\" and matrix or error(\"EventManager constructor (2) requires a table of event -> class types.\", 2)\
\
    self.register = {}\
end\
\
function EventManager:create( raw )\
    local name = raw[1]\
\
    local m = self.matrix[ name ]\
    if not m then\
        return UnknownEvent( raw ) -- create a basic event structure. For events like timer, terminate and monitor events. Dev's can use the event name in caps with a sub of EVENT: {\"timer\", ID} -> Event.main == \"SLEEP\", Event.sub == \"EVENT\", Event.raw -> {\"timer\", ID}\
    else\
        return m( raw )\
    end\
end\
\
function EventManager:registerEventHandler( ID, eventMain, eventSub, callback )\
    local cat = eventMain .. \"_\" .. eventSub\
    self.register[ cat ] = self.register[ cat ] or {}\
\
    table.insert( self.register[ cat ], {\
        ID,\
        callback\
    })\
end\
\
function EventManager:removeEventHandler( eventMain, eventSub, ID )\
    local cat = eventMain .. \"_\" .. eventSub\
    local register = self.register[ cat ]\
\
    if not register then return false end\
\
    for i = 1, #register do\
        if register[i][1] == ID then\
            table.remove( self.register[ cat ], i )\
            return true\
        end\
    end\
end\
\
function EventManager:shipToRegistrations( event )\
    local register = self.register[ event.main .. \"_\" .. event.sub ]\
\
    if not register then return end\
\
    for i = 1, #register do\
        local r = register[i]\
\
        r[2]( self, event )\
    end\
end",
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
    self.node = node\
\
    self.super( width, height )\
end\
\
function NodeCanvas:drawToCanvas( canvas, xO, yO )\
    local buffer = self.buffer\
    --local frame = self.frame\
    local stage = self.node.stage\
    local hasNodeParent = self.node.parent and true or false\
\
    local borderOffset = stage.borderless and not hasNodeParent and 2 or 1\
\
    local xO = type( xO ) == \"number\" and xO - 1 or 0\
    local yO = type( yO ) == \"number\" and yO - (not hasNodeParent and borderOffset or 2) or 0\
\
    local width = self.width\
    local height = self.height\
\
    local sOffset = (stage.shadow and not hasNodeParent and 1) or 0\
\
    local cHeight = canvas.height - sOffset\
    local cWidth = canvas.width - sOffset\
\
    local yPos, yBPos, pos, bPos, pixel\
\
    local yOO = yO + (hasNodeParent and 2 or borderOffset)\
    local yOS = yO + sOffset\
\
    local tc, bg = self.node.textColour, self.node.backgroundColour\
\
\
    for y = 0, height do\
        yPos = width * y\
        yBPos = canvas.width * ( y + yO + 1 )\
        if y + yOO > 0 and y + yOS < cHeight then\
            for x = 1, width do\
                if x + xO > 0 and x + xO - 1 < cWidth then\
                    pos = yPos + x\
                    bPos = yBPos + (x + xO)\
\
                    pixel = buffer[ pos ]\
                    if pixel then\
                        -- draw the node pixel\
                        canvas.buffer[ bPos ] = { pixel[1] or \" \", pixel[2] or tc, pixel[3] or bg }\
                    else\
                        canvas.buffer[ bPos ] = { \" \", tc, bg }\
                    end\
                end\
            end\
        end\
    end\
end\
\
-- Methods for drawing geometry shapes into canvas.\
\
-- BASIC SHAPES\
function NodeCanvas:drawArea( x1, y1, width, height, tc, bg )\
    for y = y1, (y1 + height - 1) do\
        local yPos = self.width * ( y - 1 )\
        for x = x1, (x1 + width - 1) do\
            self.buffer[ yPos + x ] = { \" \", tc, bg }\
        end\
    end\
end\
\
\
-- TEXT\
function NodeCanvas:drawTextLine( text, x, y, tc, bg, width, overflow )\
    -- draws a text line at the co-ordinates.\
    if width and overflow then text = OverflowText( text, width ) end\
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
end\
\
\
--TODO improve this code (little messy) *job release-0*\
function NodeCanvas:wrapText( text, width )\
    -- returns a table of text lines, the table can be drawn by nodes using alignment settings\
    if type( text ) ~= \"string\" or type( width ) ~= \"number\" then\
        return error(\"Expected string, number\")\
    end\
    local lines = {}\
    local lineIndex = 1\
    local position = 1\
    local run = true\
    local function newline()\
        -- strip all whitespace from the end of the line.\
        lines[ lineIndex ] = TextHelper.whitespaceTrim( lines[ lineIndex ] )\
        -- move to the next line\
        lineIndex = lineIndex + 1\
        position = 1\
    end\
    while len( text ) > 0 do\
        local whitespace = string.match( text, \"^[ \\t]+\" )\
        if whitespace then\
            -- print the whitespace, even over other lines.\
            for i = 1, len( whitespace ) do\
                lines[ lineIndex ] = not lines[ lineIndex ] and sub( whitespace, i, i ) or lines[ lineIndex ] .. sub( whitespace, i, i )\
                position = position + 1\
                if position > width then newline() end\
            end\
            text = sub( text, len(whitespace) + 1 )\
        end\
        local word = string.match( text, \"^[^ \\t\\n]+\" )\
        if word then\
            if len( word ) > width then\
                local line\
                for i = 1, len( word ) do\
                    lines[ lineIndex ] = not lines[ lineIndex ] and \"\" or lines[ lineIndex ]\
                    line = lines[ lineIndex ]\
                    -- attach the character\
                    lines[ lineIndex ] = line .. sub( word, i, i )\
                    position = position + 1\
                    if position > width then newline() end\
                end\
            elseif len( word ) <= width then\
                if len( word ) + position - 1 > width then newline() end\
                local line = lines[ lineIndex ]\
                lines[ lineIndex ] = line and line .. word or word\
                position = position + #word\
                if position > width then newline() end\
            end\
            text = sub( text, len( word ) + 1 )\
        else return lines end\
    end\
    return lines\
end\
function NodeCanvas:drawWrappedText( x1, y1, width, height, text, vAlign, hAlign, bgc, tc )\
    -- The text is a table of lines returned by wrapText, draw into the canvas the text (raw)\
    if type( text ) ~= \"table\" then\
        return error(\"drawWrappedText: text argument (5th) must be a table of lines\")\
    end\
    local drawX, drawY\
    if vAlign then\
        -- use the total lines to calculate the position of this line.\
        if vAlign == \"top\" then\
            drawY = 0\
        elseif vAlign == \"center\" then\
            drawY = (height / 2) - ( #text / 2 ) + 1\
        elseif vAlign == \"bottom\" then\
            drawY = math.floor( height - #text )\
        else return error(\"Unknown vAlign mode\") end\
    else return error(\"Unknown vAlign mode\") end\
\
    self:drawArea( x1, y1, width, height, tc, bgc )\
    if height < #text then\
        self:drawTextLine( \"...\", 1, 1, tc, bgc )\
        return\
    end\
\
    for lineIndex = 1, #text do\
        local line = text[ lineIndex ]\
        if hAlign then\
            if hAlign == \"left\" then\
                drawX = 1\
            elseif hAlign == \"center\" then\
                drawX = math.ceil((width / 2) - (len( line ) / 2) + .5 )\
            elseif hAlign == \"right\" then\
                drawX = math.floor( width - len( line ) )\
            else return error(\"Unknown hAlign mode\") end\
        else return error(\"Unknown hAlign mode\") end\
        local y = math.ceil(drawY + lineIndex - .5)\
        if y1 + y - 2 >= y1 then\
            self:drawTextLine( line, drawX + x1 - 1, y + y1 - 2, tc, bgc )\
        end\
    end\
end",
  [ "Stage.lua" ] = "local insert = table.insert\
local sub = string.sub\
\
DCML.registerTag(\"Stage\", {\
    childHandler = function( self, element ) -- self = instance (new)\
        -- the stage has children, create them using the DCML parser and add them to the instance.\
        self.nodesToAdd = DCML.parse(element.content)\
    end;\
    onDCMLParseComplete = function( self )\
        local nodes = self.nodesToAdd\
\
        if nodes then\
            for i = 1, #nodes do\
                local node = nodes[i]\
\
                self:addNode( node )\
                if node.nodesToAdd and type( node.resolveDCMLChildren ) == \"function\" then\
                    node:resolveDCMLChildren()\
                end\
            end\
\
            self.nodesToAdd = nil\
        end\
    end;\
    argumentType = {\
        X = \"number\";\
        Y = \"number\";\
        width = \"number\";\
        height = \"number\";\
    },\
})\
\
class \"Stage\" alias \"COLOUR_REDIRECT\" {\
    X = 1;\
    Y = 1;\
\
    width = 10;\
    height = 6;\
\
    borderless = false;\
\
    canvas = nil;\
\
    application = nil;\
\
    nodes = {};\
\
    name = nil;\
\
    textColour = 32768;\
    backgroundColour = 1;\
\
    unfocusedTextColour = 128;\
    unfocusedBackgroundColour = 256;\
\
    shadow = true;\
    shadowColour = colours.grey;\
\
    focused = false;\
\
    closeButton = true;\
    closeButtonTextColour = 1;\
    closeButtonBackgroundColour = colours.red;\
\
    titleBackgroundColour = 128;\
    titleTextColour = 1;\
\
    controller = {};\
\
    mouseMode = nil;\
\
    visible = true;\
\
    resizable = true;\
    movable = true;\
    closeable = true;\
}\
\
function Stage:initialise( ... )\
    -- Every stage has a unique ID used to find it afterwards, this removes the need to loop every stage looking for the correct object.\
    local name, X, Y, width, height = ParseClassArguments( self, { ... }, { {\"name\", \"string\"}, {\"X\", \"number\"}, {\"Y\", \"number\"}, {\"width\", \"number\"}, {\"height\", \"number\"} }, true, true )\
\
    self.X = X\
    self.Y = Y\
    self.name = name\
\
    self.canvas = StageCanvas( {width = width; height = height; textColour = self.textColour; backgroundColour = self.backgroundColour, stage = self} )\
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
    self:updateCanvasSize()\
    --self.canvas:redrawFrame()\
\
    self.mouseMode = false\
end\
\
function Stage:updateCanvasSize()\
    if not self.canvas then return end\
    local offset = 0\
    if self.shadow and self.focused then offset = 1 end\
\
    self.canvas.width = self.width + offset\
    self.canvas.height = self.height + offset + ( not self.borderless and 1 or 0 )\
\
    self.canvas:clear()\
end\
\
function Stage:setShadow( bool )\
    self.shadow = bool\
    self:updateCanvasSize()\
end\
\
function Stage:setBorderless( bool )\
    self.borderless = bool\
    self:updateCanvasSize()\
end\
\
function Stage:setHeight( height )\
    local mH = self.maxHeight\
    local bH = self.minHeight\
\
    height = mH and height > mH and mH or height\
    height = bH and height < bH and bH or height\
\
    self.height = height > 0 and height or 1\
    self:updateCanvasSize()\
end\
\
function Stage:setWidth( width )\
    local mW = self.maxWidth\
    local bW = self.minWidth\
\
    width = mW and width > mW and mW or width\
    width = bW and width < bW and bW or width\
    self.width = width > 0 and width or 1\
    self:updateCanvasSize()\
end\
\
function Stage:setApplication( app )\
    AssertClass( app, \"Application\", true, \"Stage requires Application Instance as its application. Not '\"..tostring( app )..\"'\")\
    self.application = app\
end\
\
function Stage:draw( _force )\
    -- Firstly, clear the stage buffer and re-draw it.\
    local changed = self.changed\
    local force = _force or self.forceRedraw\
\
    if self.forceRedraw or force then\
        log(\"i\", \"Stage is being forced to redraw!\")\
\
        self.canvas:clear()\
        self.canvas:redrawFrame()\
        self.forceRedraw = false\
    end\
\
    log(\"i\", \"Drawing stage \"..tostring( name )..\". Force: \"..tostring( changed )..\". Changed: \"..tostring( self.changed ) )\
\
    local canvas = self.canvas\
    -- order all nodes to re-draw themselves\
\
    if changed or force then\
        local nodes = self.nodes\
        for i = #nodes, 1, -1 do\
            local node = nodes[i]\
            if changed and node.changed or force then\
                node:draw( 0, 0, changed or force )\
                node.canvas:drawToCanvas( canvas, node.X, node.Y )\
\
                node.changed = false\
            end\
        end\
        self.changed = false\
    end\
\
    -- draw this stages contents to the application canvas\
    if self.visible then self.canvas:drawToCanvas( self.application.canvas, self.X, self.Y ) end\
end\
\
function Stage:appDrawComplete()\
    if self.currentKeyboardFocus and self.focused then\
        local enabled, X, Y, tc = self.currentKeyboardFocus:getCursorInformation()\
        if not enabled then return end\
\
        term.setTextColour( tc )\
        term.setCursorPos( X, Y )\
        term.setCursorBlink( true )\
    end\
end\
\
function Stage:addNode( node )\
    -- add this node\
    node.stage = self\
    insert( self.nodes, node )\
    return node\
end\
\
function Stage:hitTest( x, y )\
    return InArea( x, y, self.X, self.Y, self.X + self.width - 1, self.Y + self.height - ( self.borderless and 1 or 0 ) )\
end\
\
function Stage:isPixel( x, y )\
    local canvas = self.canvas\
\
    if self.shadow then\
        if self.focused then\
            if ( x == self.width + 1 and y == 1 ) or ( x == 1 and y == self.height + ( self.borderless and 0 or 1 ) + 1 ) then\
                return false -- pixel on corner of shadow\
            end\
            return true\
        else\
            if ( x == self.width + 1 ) or ( y == self.height + ( self.borderless and 0 or 1 ) + 1 ) then return false end\
\
            return true\
        end\
    elseif not self.shadow then return true end\
\
    return false\
end\
\
function Stage:submitEvent( event )\
    local nodes = self.nodes\
    local main = event.main\
\
    local oX, oY\
    if main == \"MOUSE\" then\
        -- convert X and Y to relative co-ords.\
        oX, oY = event.X, event.Y\
        event:convertToRelative( self ) -- convert to relative, but revert this later so other stages aren't using relative co-ords.\
        if not self.borderless then\
            event.Y = event.Y - 1\
        end\
    end\
\
    for i = 1, #nodes do\
        nodes[ i ]:handleEvent( event )\
    end\
    if main == \"MOUSE\" then\
        event.X, event.Y = oX, oY -- convert back to global because other stages may need to use this event.\
    end\
end\
\
function Stage:move( newX, newY )\
    newX = newX or self.X\
    newY = newY or self.Y\
\
    self:removeFromMap()\
    self.X = newX\
    self.Y = newY\
    self:map()\
\
    self.application.changed = true\
end\
\
function Stage:resize( nW, nH )\
    newWidth = nW or self.width\
    newHeight = nH or self.height\
\
    self:removeFromMap()\
\
    self.width = newWidth\
    self.height = newHeight\
    self.canvas:redrawFrame()\
\
    self:map()\
\
    self.forceRedraw = true\
    self.application.changed = true\
end\
\
function Stage:handleMouse( event )\
\
    local sub, mouseMode = event.sub, self.mouseMode\
\
\
    if sub == \"CLICK\" then\
        local X, Y = event:getRelative( self )\
        if Y == 1 then\
            if X == self.width and self.closeButton and not self.borderless then\
                -- close stage\
                self:removeFromMap()\
                self.application:removeStage( self )\
            else\
                -- set stage moveable\
                self.mouseMode = \"move\"\
                self.lastX, self.lastY = event.X, event.Y\
            end\
        elseif Y == self.height + ( not self.borderless and 1 or 0 ) and X == self.width then\
            -- resize\
            self.mouseMode = \"resize\"\
        end\
    elseif sub == \"UP\" and mouseMode then\
        self.mouseMode = false\
    elseif sub == \"DRAG\" and mouseMode then\
        if mouseMode == \"move\" then\
            self:move( self.X + event.X - self.lastX, self.Y + event.Y - self.lastY )\
            self.lastX, self.lastY = event.X, event.Y\
        elseif mouseMode == \"resize\" then\
            self:resize( event.X - self.X + 1, event.Y - self.Y + ( self.borderless and 1 or 0 ) )\
        end\
    end\
end\
\
local function focus( self )\
    self.application:requestStageFocus( self )\
end\
\
function Stage:close()\
    self:removeFromMap()\
    self.application:removeStage( self )\
end\
\
function Stage:handleEvent( event )\
    if event.handled then return end\
\
    local main, sub = event.main, event.sub\
\
    if main == \"MOUSE\" then\
        local inBounds = event:inBounds( self )\
        if sub == \"CLICK\" then\
            -- if the click was on the top bar, close button or resize location then act accordingly\
            local ignore, oX, oY = false, event.X, event.Y\
            event:convertToRelative( self )\
\
            local width = self.width\
\
            local X, Y = event:getPosition()\
            if Y == 1 then\
                if X == width and self.closeable then\
                    self:close()\
                elseif self.movable and X >= 1 and X <= width then\
                    self.mouseMode = \"move\"\
                    focus( self )\
                    event.handled = true\
                elseif inBounds then focus( self ) end\
            elseif self.resizable and Y == self.height + ( not self.borderless and 1 or 0 ) and X == width then\
                self.mouseMode = \"resize\"\
                focus( self )\
                event.handled = true\
            else\
                if self.focused then\
                    if not self.borderless then\
                        event.Y = event.Y - 1\
                    end\
                    -- submit the event\
                    local nodes = self.nodes\
\
                    for i = 1, #nodes do\
                        local node = nodes[i]\
                        node:handleEvent( event )\
                    end\
                elseif not self.focused and inBounds then\
                    -- focus the stage\
                    focus( self )\
                    event.handled = true\
                end\
            end\
\
            event:restore( oX, oY )\
        elseif sub == \"UP\" then\
            self.mouseMode = nil\
            if self.focused then self:submitEvent( event ) end\
        elseif sub == \"SCROLL\" and self.focused then\
            self:submitEvent( event )\
        elseif sub == \"DRAG\" and self.focused then\
            self:submitEvent( event )\
        end\
\
        if self.focused and inBounds then\
            event.handled = true\
        end\
    else\
        self:submitEvent( event )\
    end\
end\
\
function Stage:mapNode( x1, y1, x2, y2 )\
    -- functions similarly to Application:mapWindow.\
end\
\
function Stage:map()\
    local canvas = self.canvas\
\
    self.application:mapWindow( self.X, self.Y, self.X + canvas.width - 1, self.Y + canvas.height - 1 )\
end\
\
function Stage:removeFromMap()\
    local oV = self.visible\
\
    self.visible = false\
    self:map()\
    self.visible = oV\
end\
\
local function getFromDCML( path )\
    return DCML.parse( DCML.loadFile( path ) )\
end\
function Stage:replaceWithDCML( path )\
    local data = getFromDCML( path )\
\
    for i = 1, #self.nodes do\
        local node = self.nodes[i]\
        node.stage = nil\
\
        table.remove( self.nodes, i )\
    end\
\
    for i = 1, #data do\
        data[i].stage = self\
        table.insert( self.nodes, data[i] )\
    end\
end\
\
function Stage:appendFromDCML( path )\
    local data = getFromDCML( path )\
\
    for i = 1, #data do\
        data[i].stage = self\
        table.insert( self.nodes, data[i] )\
    end\
end\
\
function Stage:removeKeyboardFocus( from )\
    local current = self.currentKeyboardFocus\
    if current and current == from then\
        if current.onFocusLost then current:onFocusLost( self, node ) end\
\
        self.currentKeyboardFocus = false\
    end\
end\
\
function Stage:redirectKeyboardFocus( node )\
    self:removeKeyboardFocus( self.currentKeyboardFocus )\
\
    self.currentKeyboardFocus = node\
    if node.onFocusGain then self.currentKeyboardFocus:onFocusGain( self ) end\
end\
\
--[[ Controller ]]--\
function Stage:addToController( name, fn )\
    if type( name ) ~= \"string\" or type( fn ) ~= \"function\" then\
        return error(\"Expected string, function\")\
    end\
    self.controller[ name ] = fn\
end\
\
function Stage:removeFromController( name )\
    self.controller[ name ] = nil\
end\
\
function Stage:getCallback( name )\
    name = sub( name, 2 )\
    return self.controller[ name ]\
end\
\
function Stage:executeCallback( name, ... )\
    local cb = self:getCallback( name )\
    if cb then\
        local args = { ... }\
        return cb( ... )\
    else\
        return error(\"Failed to find callback \"..tostring( sub(name, 2) )..\" on controller (node.stage): \"..tostring( self ))\
    end\
end\
\
function Stage:onFocus()\
    self.forceRedraw = true\
    -- the application has granted focus to this stage. Create a shadow if required and update colour sheet.\
    self.focused = true\
    self.changed = true\
\
    self:removeFromMap()\
    self:updateCanvasSize()\
\
    self:map()\
    self.canvas:updateFilter()\
    self.canvas:redrawFrame()\
end\
\
function Stage:onBlur()\
    self.forceRedraw = true\
    -- the application revoked focus, remove any shadows and grey out stage\
    self.focused = false\
    self.changed = true\
\
    self:removeFromMap()\
    self:updateCanvasSize()\
\
    self:map()\
    self.canvas:updateFilter()\
    self.canvas:redrawFrame()\
end\
\
function Stage:setChanged( bool )\
    self.changed = bool\
    if bool then self.application.changed = true end\
end",
  [ "Event.lua" ] = "class \"Event\" {\
    raw = nil;\
\
    handled = false;\
\
    __event = true;\
}\
\
function Event:isType( main, sub )\
    if main == self.main and sub == self.sub then\
        return true\
    end\
    return false\
end",
  [ "MouseEvent.lua" ] = "local sub = string.sub\
\
class \"MouseEvent\" mixin \"Event\" {\
    main = \"MOUSE\";\
    sub = nil;\
    X = nil;\
    Y = nil;\
    misc = nil; -- scroll direction or mouse button\
\
    inParentBounds = false;\
}\
\
function MouseEvent:initialise( raw )\
    self.raw = raw\
    local t = sub( raw[1], string.find( raw[1], \"_\" ) + 1, raw[1]:len() )\
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
end\
\
function MouseEvent:getPosition() return self.X, self.Y end\
\
function MouseEvent:convertToRelative( parent )\
    self.X, self.Y = self:getRelative( parent )\
end\
\
function MouseEvent:getRelative( parent )\
    -- similar to convertToRelative, however this leaves the event unchanged\
    return self.X - parent.X + 1, self.Y - parent.Y + 1\
end\
\
function MouseEvent:inBounds( parent )\
    local X, Y = parent.X, parent.Y\
    return self:inArea( X, Y, X + parent.width - 1, Y + parent.height - 1 )\
end\
\
function MouseEvent:restore( x, y )\
    self.X, self.Y = x, y\
end",
  [ "KeyEvent.lua" ] = "local sub = string.sub\
\
class \"KeyEvent\" mixin \"Event\" {\
    main = nil;\
    sub = nil;\
    key = nil;\
    held = nil;\
}\
\
function KeyEvent:initialise( raw )\
    self.raw = raw\
    local u = string.find( raw[1], \"_\" )\
\
    local t, m\
    if u then\
        t = sub( raw[1], u + 1, raw[1]:len() )\
        m = sub( raw[1], 1, u - 1 )\
    else\
        t = raw[1]\
        m = t\
    end\
\
    self.main = m:upper()\
    self.sub = t:upper()\
    self.key = raw[2]\
    self.held = raw[3]\
end\
\
function KeyEvent:isKey( name )\
    if keys[ name ] == self.key then return true end\
end",
  [ "TimerManager.lua" ] = "class \"TimerManager\" {\
    timers = {};\
}\
\
-- Timers have an ID created by combining the current system time and the timer wait ( os.clock() + time ). This allows timers to be re-used rather than having multiple timer events for the same time.\
\
function TimerManager:initialise( app )\
    self.application = AssertClass( app, \"Application\", true, \"TimerManager requires an application instance as its constructor argument. Not '\"..tostring( app )..\"'\" )\
end\
\
function TimerManager:setTimer( name, secs, callback, repeatAmount ) -- repeatAmount can be \"inf\" or a number. Once reached will stop.\
    if not ( type( name ) == \"string\" and type( secs ) == \"number\" and type( callback ) == \"function\" ) then\
        return error(\"Expected string, number, function\")\
    end\
    -- Run 'callback' in 'secs' seconds.\
    local completeTime = os.clock() + secs -- os.clock() time when the timer completes\
    local timerID\
\
    -- Search for a timer that ends at the same time as this one.\
    local timers = self.timers\
    for i = 1, #timers do\
        local timer = timers[i]\
        if timer[1] == name then\
            return error(\"Timer name '\"..name..\"' is already in use.\")\
        end\
\
        if timer[3] == completeTime then\
            -- this timer will finish at the same time, use its ID as ours (instead of a new os.startTimer() ID)\
            timerID = timer[2]\
        end\
    end\
\
    timerID = timerID or os.startTimer( secs )\
    timers[ #timers + 1 ] = { name, timerID, completeTime, callback, secs, repeatAmount }\
\
    return timerID\
end\
\
function TimerManager:removeTimer( name )\
    -- Removes the timer with name 'name' from the schedule, cancels the timer event if its the only timer using it.\
\
    local amount = 0\
    local timers = self.timers\
    local foundTimer\
    local foundTimerID\
    local foundTimerIndex\
\
    local extra = {}\
\
    for i = #timers, 1, -1 do\
        local timer = timers[i]\
\
        if timer[1] == name then\
            foundTimer = timer\
            foundTimerID = timer[2]\
            foundTimerIndex = i\
            amount = 1\
        elseif foundTimer and timer[2] == foundTimerID then\
            amount = amount + 1\
        else\
            -- these timers weren't checked, we will check these afterwards incase they use the same ID.\
            extra[ #extra + 1 ] = timer\
        end\
    end\
    if not foundTimer then return false end\
\
    for i = 1, #extra do\
        if extra[i][2] == foundTimerID then\
            amount = amount + 1\
        end\
    end\
\
    table.remove( self.timers, foundTimerIndex )\
    if amount == 1 then\
        os.cancelTimer( foundTimerID )\
    else\
        log( \"w\", (amount - 1) .. \" timer(s) are still using the timer '\"..foundTimerID..\"'\")\
    end\
end\
\
function TimerManager:update( rawID ) -- rawID is from the second parameter of the timer event (from pullEvent)\
    local timers = self.timers\
\
    for i = #timers, 1, -1 do -- reverse so we can remove timers\
        if timers[i][2] == rawID then\
            local current = table.remove( self.timers, i )\
            current[4]( rawID, current )\
\
            local rep = current[6]\
            local repT = type( rep )\
            if rep and (repT == \"string\" and rep == \"inf\" or ( repT == \"number\" and rep > 1 )) then\
                self:setTimer( current[1], current[5], current[4], repT == \"number\" and rep - 1 or \"inf\") -- name, secs, callback, repeating\
            end\
        end\
    end\
end",
}
-- Start of unpacker. This script will load all packed files and verify their classes were created correctly.

--[[
    Files checked (in order):
    - scriptFiles.cfg - Files in here are assumed to not load any classes, therefore the class will not be verified. (IGNORE FILE)
    - loadFirst.cfg - Files in here will be loaded before other classes
]]

local ignore = {
    ["Class.lua"] = true
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
if files[ "Class.lua" ] then
    executeString( "Class.lua" )
    loaded[ "Class.lua" ] = true
else
    return error("Cannot unpack DynaCode because the class library is missing (Class.lua)")
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

class.setClassLoader( function( _c )
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

--[[class.setCustomViewer(function(_class)
    if class.isClass( _class ) then
        local t = _class:type()
        local file = t..".lua"

        if files[ file ] then
            if fs.exists( "tempSource.lua" ) then error("Cannot open source, tempSource.lua already exists (this should've been removed)", 0) end
            local h = fs.open("tempSource.lua", "w")
            h.write( files[ file ] )
            h.close()

            shell.run("edit", "tempSource.lua")
            fs.delete("tempSource.lua")

            print("Temporary source file removed (tempSource.lua)")
        else
            return error("Class originates from unknown source")
        end
    else return error("Unknown object to anaylyse '" .. tostring( _class ) .. "'") end
end)]]

local path = shell.getRunningProgram() or DYNACODE_PATH
_G.DynaCode = {}
function DynaCode.checkForUpdate()

end

function DynaCode.installUpdateData()

end

function DynaCode.checkForAndInstallUpdate()

end
