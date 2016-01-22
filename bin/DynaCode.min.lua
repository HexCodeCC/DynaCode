--[[
    DynaCode Build

    The following document was created via a makefile. The 'files' table
    contains minified versions of every file for DynaCode's default source.

    To view the un-minified code please visit GitHub (HexCodeCC/DynaCode)
]]

local files = {
  [ "Panel.lua" ] = "DCML.registerTag(\"Panel\",{\
childHandler=function(t,e)\
t.nodesToAdd=DCML.parse(e.content)\
end;\
argumentType={\
X=\"number\";\
Y=\"number\";\
width=\"number\";\
height=\"number\";\
backgroundColour=\"colour\";\
textColour=\"colour\";\
},\
callbackGenerator=\"#generateNodeCallback\";\
})\
class\"Panel\"extends\"NodeScrollContainer\"{\
width=2;\
height=2;\
__drawChildrenToCanvas=true;\
}\
function Panel:initialise(...)\
local o,a,t,e=ParseClassArguments(self,{...},{\
{\"X\",\"number\"},\
{\"Y\",\"number\"},\
{\"width\",\"number\"},\
{\"height\",\"number\"}\
},false,true)\
self.super(o,a,t or self.width,e or self.height)\
self:__overrideMetaMethod(\"__add\",function(t,e)\
if classLib.typeOf(t,\"Panel\",true)then\
if classLib.isInstance(e)and e.__node then\
return self:addNode(e)\
else\
return error(\"Invalid right hand assignment. Should be instance of DynaCode node. \"..tostring(e))\
end\
else\
return error(\"Invalid left hand assignment. Should be instance of Panel. \"..tostring(t))\
end\
end)\
end",
  [ "NodeScrollContainer.lua" ] = "class\"NodeScrollContainer\"abstract()extends\"NodeContainer\"{\
yOffset=0;\
xOffset=0;\
cache={\
nodeHeight=0;\
nodeWidth=0;\
xScrollPosition=0;\
yScrollPosition=0;\
xScrollSize=0;\
yScrollSize=0;\
xDisplayPosition=0;\
yDisplayPosition=0;\
xActive=false;\
yActive=false;\
lastMouse=0;\
};\
horizontalPadding=0;\
verticalPadding=0;\
currentScrollbar=false;\
autoDraw=true;\
trackColour=128;\
barColour=256;\
activeBarColour=colours.lightBlue;\
}\
function NodeScrollContainer:cacheAllInformation()\
self:cacheNodeSizes()\
self:cacheScrollbarInformation()\
end\
function NodeScrollContainer:cacheScrollbarInformation()\
self:cacheRequiredScrollbars()\
self:cacheDisplaySize()\
self:cacheScrollSizes()\
self:cacheScrollPositions()\
end\
function NodeScrollContainer:cacheDisplaySize()\
local e=self.cache\
local a,t=e.xActive,e.yActive\
e.displayWidth,e.displayHeight=self.width-(t and 1 or 0),self.height-(a and 1 or 0)\
end\
function NodeScrollContainer:cacheNodeSizes()\
local a,t=0,0\
local o=self.nodes\
local e\
for i=1,#o do\
e=o[i]\
a=math.max(a,e.X+e.width-1)\
t=math.max(t,e.Y+e.height-1)\
end\
local e=self.cache\
e.nodeWidth=a\
e.nodeHeight=t\
end\
function NodeScrollContainer:cacheRequiredScrollbars()\
local e=self.cache\
local a,t=e.nodeWidth>self.width,e.nodeHeight>self.height\
e.xActive=a or(t and e.nodeWidth>self.width-1)\
e.yActive=t or(a and e.nodeHeight>self.height-1)\
end\
function NodeScrollContainer:cacheScrollSizes()\
local e=self.cache\
local t,a=e.displayWidth,e.displayHeight\
local t=math.ceil(t/e.nodeWidth*t-.5)\
local a=math.ceil(a/e.nodeHeight*a-.5)\
e.xScrollSize,e.yScrollSize=t,a\
end\
function NodeScrollContainer:cacheScrollPositions()\
local e=self.cache\
if e.xActive then\
local a\
local t=math.ceil(self.xOffset/e.nodeWidth*e.displayWidth)\
if t<1 then\
a=1\
elseif t==1 and self.xOffset~=0 then\
a=2\
else\
a=t\
end\
if self.xOffset==0 then\
e.xDisplayPosition=1\
elseif self.xOffset==e.nodeWidth-e.displayWidth then\
e.xDisplayPosition=e.displayWidth-e.xScrollSize+1\
else e.xDisplayPosition=t end\
e.xScrollPosition=a\
end\
if e.yActive then\
local t\
local a=math.ceil(self.yOffset/e.nodeHeight*e.displayHeight)\
if a<1 then\
t=1\
elseif a==1 and self.yOffset~=0 then\
t=2\
else\
t=a\
end\
if self.yOffset==0 then\
e.yDisplayPosition=1\
elseif self.yOffset==e.nodeHeight-e.displayHeight then\
e.yDisplayPosition=e.displayHeight-e.yScrollSize+1\
else e.yDisplayPosition=a end\
e.yScrollPosition=t\
end\
end\
function NodeScrollContainer:drawScrollbars()\
local a=self.canvas\
local e=self.cache\
local t,i,i,o=self.trackColour,self.activeBarColour,self.barColour,self.width\
if e.xActive then\
local o=self.currentScrollbar==\"x\"and self.activeBarColour or self.barColour\
a:drawArea(1,self.height,e.displayWidth,1,self.trackColour,t)\
a:drawArea(e.xDisplayPosition,self.height,e.xScrollSize,1,o,o)\
end\
if e.yActive then\
local i=self.currentScrollbar==\"y\"and self.activeBarColour or self.barColour\
a:drawArea(o,1,1,e.displayHeight,t,t)\
a:drawArea(o,e.yDisplayPosition,1,e.yScrollSize,i,i)\
end\
if e.xActive and e.yActive then\
a:drawArea(o,self.height,1,1,t,t)\
end\
end\
function NodeScrollContainer:drawContent(a)\
local o=self.nodes\
local t=self.canvas\
t:clear()\
local i,n=-self.xOffset,-self.yOffset\
local h=a or self.forceRedraw\
local r=self.autoDraw\
local e\
for s=1,#o do\
e=o[s]\
if e.changed or e.forceRedraw or h then\
e:draw(i,n,a)\
if r then\
e.canvas:drawToCanvas(t,e.X+i,e.Y+n)\
end\
end\
end\
end\
function NodeScrollContainer:draw(t,t,e)\
if self.recacheAllNextDraw then\
self:cacheAllInformation()\
self.recacheAllNextDraw=false\
else\
if self.recacheNodeInformationNextDraw then\
self:cacheNodeSizes()\
self.recacheNodeInformationNextDraw=false\
end\
if self.recacheScrollInformationNextDraw then\
self:cacheScrollbarInformation()\
self.recacheScrollInformationNextDraw=false\
end\
end\
self:drawContent(e)\
self:drawScrollbars(e)\
end\
function NodeScrollContainer:onAnyEvent(t)\
local e,a,o=self.cache\
if t.main==\"MOUSE\"then a,o=t:getRelative(self)end\
if not((a or o)and t.sub==\"CLICK\"and(e.xActive and o==self.height or e.yActive and a==self.width))then\
self:submitEvent(t)\
end\
if not t.handled then\
local i=self.stage.application\
local n=i.hotkey\
if t.main==\"MOUSE\"then\
local i=t.sub\
if t:isInNode(self)then\
self.stage:redirectKeyboardFocus(self)\
if i==\"CLICK\"then\
if e.xActive then\
if o==self.height then\
t.handled=true\
if a>=e.xScrollPosition and a<=e.xScrollPosition+e.xScrollSize then\
self.currentScrollbar=\"x\"\
self.lastMouse=a\
self.changed=true\
end\
end\
end\
if e.yActive then\
if a==self.width then\
t.handled=true\
if o>=e.yScrollPosition and o<=e.yScrollPosition+e.yScrollSize-1 then\
self.currentScrollbar=\"y\"\
self.lastMouse=o\
self.changed=true\
end\
end\
end\
elseif i==\"SCROLL\"then\
if e.xActive and(not e.yActive or n.keys.shift)then\
self.xOffset=math.max(math.min(self.xOffset+t.misc,e.nodeWidth-e.displayWidth),0)\
self.changed=true\
self:cacheScrollPositions()\
elseif e.yActive then\
self.yOffset=math.max(math.min(self.yOffset+t.misc,e.nodeHeight-e.displayHeight),0)\
self.changed=true\
self:cacheScrollPositions()\
end\
end\
else\
if self.focused then\
self.stage:removeKeyboardFocus(self)\
end\
end\
if t.handled then return end\
if i==\"DRAG\"then\
local i=self.currentScrollbar\
if i==\"x\"then\
local o,t=e.xScrollPosition+(a<self.lastMouse and-1 or 1)\
log(\"w\",\"Last mouse location: \"..tostring(self.lastMouse)..\", Current mouse location: \"..tostring(a)..\", Current position: \"..tostring(e.xScrollPosition)..\", new position: \"..tostring(o))\
if o<=1 then t=0 else\
t=math.max(math.min(math.floor((o)*((e.nodeWidth-.5)/e.displayWidth)),e.nodeWidth-e.displayWidth),0)\
end\
log(\"w\",\"New offset from position: \"..tostring(t))\
self.xOffset=t\
self.lastMouse=a\
elseif i==\"y\"then\
local a=e.yScrollPosition+(o-self.lastMouse)\
local t\
if a<=1 then t=0 else\
t=math.max(math.min(math.floor((a)*((e.nodeHeight-.5)/e.displayHeight)),e.nodeHeight-e.displayHeight),0)\
end\
self.yOffset=t\
self.lastMouse=o\
end\
self.changed=true\
self:cacheScrollPositions()\
elseif i==\"UP\"then\
self.currentScrollbar=nil\
self.lastMouse=nil\
self.changed=true\
end\
elseif self.focused and t.main==\"KEY\"then\
if t.sub==\"KEY\"and n.keys.shift then\
local function a(e,t)\
self[e..\"Offset\"]=t\
self.changed=true\
self:cacheScrollPositions()\
end\
if t.key==keys.up then\
a(\"y\",math.max(self.yOffset-self.height,0))\
elseif t.key==keys.down then\
a(\"y\",math.min(self.yOffset+self.height,e.nodeHeight-e.displayHeight))\
elseif t.key==keys.left then\
a(\"x\",math.max(self.xOffset-self.width,0))\
elseif t.key==keys.right then\
a(\"x\",math.min(self.xOffset+self.width,e.nodeWidth-e.displayWidth))\
end\
end\
end\
end\
end\
function NodeScrollContainer:submitEvent(e)\
local i=e.main\
local a,o,t\
if i==\"MOUSE\"then\
t=e.inParentBounds\
e.inParentBounds=e:isInNode(self)\
a,o=e:getPosition()\
e:convertToRelative(self)\
e.X=e.X+self.xOffset\
e.Y=e.Y+self.yOffset\
end\
local n,s=self.nodes\
for t=1,#n do\
n[t]:handleEvent(e)\
end\
if i==\"MOUSE\"then e.X,e.Y,e.inParentBounds=a,o,t end\
end\
function NodeScrollContainer:onFocusLost()\
self.focused=false;\
self.acceptKeyboard=false;\
end\
function NodeScrollContainer:onFocusGain()\
self.focused=true;\
self.acceptKeyboard=true;\
end\
function NodeScrollContainer:getCursorInformation()return false end\
function NodeScrollContainer:addNode(e)\
self.super:addNode(e)\
self.recacheAllNextDraw=true\
end\
function NodeScrollContainer:removeNode(e)\
self.super:removeNode(e)\
self.recacheAllNextDraw=true\
end",
  [ "Template.lua" ] = "class\"Template\"extends\"MNodeManager\"{\
nodes={};\
owner=nil;\
name=nil;\
}\
function Template:initialise(a,t,e)\
self.name=type(a)==\"string\"and a or ParameterException(\"Failed to initialise template. Name '\"..tostring(a)..\"' is invalid.\")\
self.owner=classLib.isInstance(t)and t or ParameterException(\"Failed to initialise template. Owner '\"..tostring(t)..\"' is invalid.\")\
self.isStageTemplate=self.owner.__type==\"Stage\"\
if e then\
if type(e)==\"table\"then\
for t=1,#e do\
self:appendFromDCML(e[t])\
end\
elseif type(e)==\"string\"then\
self:appendFromDCML(e)\
else\
ParameterException(\"Failed to initialise template. DCML content '\"..tostring(e)..\"' is invalid type '\"..type(e)..\"'\")\
end\
end\
self:__overrideMetaMethod(\"__add\",function(t,e)\
if t==self then\
if classLib.isInstance(e)and e.__node then\
return self:addNode(e)\
else\
return error(\"Invalid right hand assignment. Should be instance of DynaCode node. \"..tostring(e))\
end\
end\
end)\
end\
function Template:addNode(e)\
if self.isStageTemplate then\
e.stage=self.owner\
else\
e.stage=self.owner.stage or ParameterException(\"Failed to add node to template. Couldn't find 'stage' parameter on owner '\"..tostring(self.owner)..\"'\")\
e.parent=self.owner\
end\
table.insert(self.nodes,e)\
return e\
end",
  [ "TimerManager.lua" ] = "class\"TimerManager\"{\
timers={};\
}\
function TimerManager:initialise(e)\
self.application=AssertClass(e,\"Application\",true,\"TimerManager requires an application instance as its constructor argument. Not '\"..tostring(e)..\"'\")\
end\
function TimerManager:setTimer(a,t,i,s)\
if not(type(a)==\"string\"and type(t)==\"number\"and type(i)==\"function\")then\
return error(\"Expected string, number, function\")\
end\
local n=os.clock()+t\
local e\
local o=self.timers\
for t=1,#o do\
local t=o[t]\
if t[1]==a then\
return error(\"Timer name '\"..a..\"' is already in use.\")\
end\
if t[3]==n then\
e=t[2]\
end\
end\
e=e or os.startTimer(t)\
o[#o+1]={a,e,n,i,t,s}\
return e\
end\
function TimerManager:removeTimer(h)\
local e=0\
local a=self.timers\
local i\
local t\
local s\
local o={}\
for n=#a,1,-1 do\
local a=a[n]\
if a[1]==h then\
i=a\
t=a[2]\
s=n\
e=1\
elseif i and a[2]==t then\
e=e+1\
else\
o[#o+1]=a\
end\
end\
if not i then return false end\
for a=1,#o do\
if o[a][2]==t then\
e=e+1\
end\
end\
table.remove(self.timers,s)\
if e==1 then\
os.cancelTimer(t)\
else\
log(\"w\",(e-1)..\" timer(s) are still using the timer '\"..t..\"'\")\
end\
end\
function TimerManager:update(a)\
local t=self.timers\
for e=#t,1,-1 do\
if t[e][2]==a then\
local e=table.remove(self.timers,e)\
e[4](a,e)\
local t=e[6]\
local a=type(t)\
if t and(a==\"string\"and t==\"inf\"or(a==\"number\"and t>1))then\
self:setTimer(e[1],e[5],e[4],a==\"number\"and t-1 or\"inf\")\
end\
end\
end\
end",
  [ "Application.lua" ] = "local e\
class\"Application\"alias\"COLOUR_REDIRECT\"mixin\"MDaemon\"{\
canvas=nil;\
hotkey=nil;\
timer=nil;\
event=nil;\
stages={};\
changed=true;\
running=false;\
lastID=0;\
}\
function Application:initialise(...)\
if not exceptionHook.isHooked()then\
log(\"i\",\"Creating exception hook\")\
exceptionHook.hook()\
end\
ParseClassArguments(self,{...},{{\"width\",\"number\"},{\"height\",\"number\"}},true)\
self.canvas=ApplicationCanvas(self,self.width,self.height)\
self.hotkey=HotkeyManager(self)\
self.event=EventManager(self,{\
[\"mouse_up\"]=MouseEvent;\
[\"mouse_click\"]=MouseEvent;\
[\"mouse_scroll\"]=MouseEvent;\
[\"mouse_drag\"]=MouseEvent;\
[\"key\"]=KeyEvent;\
[\"key_up\"]=KeyEvent;\
[\"char\"]=KeyEvent;\
});\
self.timer=TimerManager(self)\
self:__overrideMetaMethod(\"__add\",function(t,e)\
if classLib.typeOf(t,\"Application\",true)then\
if classLib.typeOf(e,\"Stage\",true)then\
return self:addStage(e)\
else\
return error(\"Invalid right hand assignment (\"..tostring(e)..\")\")\
end\
else\
return error(\"Invalid left hand assignment (\"..tostring(t)..\")\")\
end\
end)\
self:clearLayerMap()\
end\
function Application:clearLayerMap()\
local e={}\
for t=1,self.width*self.height do\
e[t]=false\
end\
self.layerMap=e\
end\
function Application:setTextColour(e)\
self.canvas.textColour=e\
self.textColour=e\
end\
function Application:setBackgroundColour(e)\
self.canvas.backgroundColour=e\
self.backgroundColour=e\
end\
function Application:addStage(e)\
e.application=self\
e.mappingID=self.lastID+1\
self.lastID=self.lastID+1\
self.stages[#self.stages+1]=e\
e:map()\
return e\
end\
function Application:removeStage(e)\
local t=classLib.typeOf(e,\"Stage\",true)\
for a=1,#self.stages do\
local o=self.stages[a]\
if(t and o==e)or(not t and o.name==e)then\
table.remove(self.stages,a)\
self.changed=true\
end\
end\
end\
function Application:draw(e)\
for t=#self.stages,1,-1 do\
self.stages[t]:draw(e)\
end\
self.canvas:drawToScreen(e)\
self.changed=false\
end\
function Application:run(e)\
log(\"i\",\"Attempting to start application\")\
self.running=true\
self.hotkey:reset()\
local function a()\
local t=self.hotkey\
local a=self.timer\
if self.onRun then self:onRun()end\
self:draw(true)\
log(\"s\",\"Engine start successful. Running in protected mode\")\
while self.running do\
if self.reorderRequest then\
log(\"i\",\"Reordering stage list\")\
local t=self.reorderRequest\
for e=1,#self.stages do\
if self.stages[e]==t then\
table.insert(self.stages,1,table.remove(self.stages,e))\
self:setStageFocus(t)\
break\
end\
end\
self.reorderRequest=nil\
end\
term.setCursorBlink(false)\
self:draw()\
for e=1,#self.stages do\
self.stages[e]:appDrawComplete()\
end\
local e=self.event:create({coroutine.yield()})\
self.event:shipToRegistrations(e)\
if e.main==\"KEY\"then\
t:handleKey(e)\
t:checkCombinations()\
elseif e.main==\"TIMER\"then\
a:update(e.raw[2])\
end\
for t=1,#self.stages do\
if self.stages[t]then\
self.stages[t]:handleEvent(e)\
end\
end\
end\
end\
log(\"i\",\"Trying to start daemon services\")\
local e,t=xpcall(function()self:startDaemons()end,function(e)\
log(\"f\",\"Failed to start daemon services. Reason '\"..tostring(e)..\"'\")\
if self.errorHandler then\
self:errorHandler(e,false)\
else\
if self.onError then self:onError(e)end\
error(\"Failed to start daemon service: \"..e)\
end\
end)\
if e then\
log(\"s\",\"Daemon service started\")\
end\
log(\"i\",\"Starting engine\")\
local t,e=xpcall(a,function(e)\
log(\"f\",\"Engine error: '\"..tostring(e)..\"'\")\
local t=exceptionHook.getLastThrownException()\
if t then\
log(\"eh\",\"Error '\"..e..\"' has been previously hooked by the trace system.\")\
else\
log(\"eh\",\"Error '\"..e..\"' has not been hooked by the trace system. Last hook: \"..tostring(t and t.rawException or nil))\
exceptionHook.spawnException(LuaVMException(e,4,true))\
end\
log(\"eh\",\"Gathering currently loaded classes\")\
local t=\"\"\
local a,o=pcall(function()\
for e,a in pairs(classLib.getClasses())do\
t=t..\"- \"..e..\"\\n\"\
end\
end)\
if a then\
log(\"eh\",\"Loaded classes at the time of crash: \\n\"..tostring(t))\
else\
log(\"eh\",\"ERROR: Failed to gather currently loaded classes (error: \"..tostring(o)..\")\")\
end\
if exceptionHook.isHooked()then\
log(\"eh\",\"Unhooking traceback\")\
exceptionHook.unhook()\
end\
return e\
end)\
if e then\
if self.errorHandler then\
self:errorHandler(e,true)\
else\
local t=exceptionHook.getLastThrownException()\
term.setTextColour(colours.yellow)\
print(\"DynaCode has crashed\")\
term.setTextColour(colours.red)\
print(t and t.displayName or e)\
print(\"\")\
local function n(e,s,h,i,n,t,o,a)\
term.setTextColour(e)\
print(s)\
local s,e=pcall(h)\
if e then\
term.setTextColour(i)\
print(n..e)\
else\
term.setTextColour(t)\
print(o)\
end\
term.setTextColour(a)\
end\
local i,o,a=colours.yellow,colours.red,colours.lime\
n(i,\"Attempting to stop daemon service and children\",function()self:stopDaemons(false)end,o,\"Failed to stop daemon service: \",a,\"Stopped daemon service\",1)\
print(\"\")\
n(i,\"Attempting to write crash information to log file\",function()\
log(\"f\",\"DynaCode crashed: \"..e)\
if t then log(\"f\",t.stacktrace)end\
end,o,\"Failed to write crash information: \",a,\"Wrote crash information to file (stacktrace)\",1)\
if self.onError then self:onError(e)end\
end\
end\
end\
function Application:finish(e)\
log(\"i\",\"Stopping Daemons\")\
self:stopDaemons(true)\
log(\"i\",\"Stopping Application\")\
self.running=false\
os.queueEvent(\"stop\")\
if type(e)==\"function\"then return e()end\
end\
function Application:mapWindow(r,s,n,d)\
local e=self.stages\
local l=self.layerMap\
for t=#e,1,-1 do\
local e=e[t]\
local o,a=e.X,e.Y\
local i,u=e.canvas.width,e.canvas.height\
local t,h\
t=o+i\
h=a+u\
local u=e.visible\
local i=e.mappingID\
if not(o>n or a>d or r>t or s>h)then\
for h=math.max(a,s),math.min(h,d)do\
local s=self.width*(h-1)\
for t=math.max(o,r),math.min(t,n)do\
local n=l[s+t]\
if n~=i and u and(e:isPixel(t-o+1,h-a+1))then\
l[s+t]=i\
elseif n==i and not u then\
l[s+t]=false\
end\
end\
end\
end\
end\
local e=self.canvas.buffer\
local a=self.width\
local i=self.layerMap\
for t=s,d do\
local o=a*(t-1)\
for t=r,n do\
local a=o+t\
local t=i[o+t]\
if t==false then\
if e[a]then e[a]={false,false,false}end\
end\
end\
end\
end\
function Application:requestStageFocus(e)\
self.reorderRequest=e\
end\
function Application:setStageFocus(e)\
if not classLib.typeOf(e,\"Stage\",true)then return error(\"Expected Class Instance Stage, not \"..tostring(e))end\
self:unSetStageFocus()\
e:onFocus()\
self.focusedStage=e\
end\
function Application:unSetStageFocus(e)\
local e=e or self.focusedStage\
if self.focusedStage and self.focusedStage==e then\
self.focusedStage:onBlur()\
self.focusedStage=nil\
end\
end\
function Application:getStageByName(a)\
local e=self.stages\
for t=1,#e do\
local e=e[t]\
if e.name==a then return e end\
end\
end\
local function a(e)\
return DCML.parse(DCML.loadFile(e))\
end\
function Application:appendStagesFromDCML(t)\
local e=a(t)\
for a=1,#e do\
local e=e[a]\
if classLib.typeOf(e,\"Stage\",true)then\
self:addStage(e)\
else\
return error(\"The DCML parser has created a \"..tostring(e)..\". This is not a stage and cannot be added as such. Please ensure the DCML file '\"..tostring(t)..\"' only creates stages with nodes inside of them, not nodes by themselves. Refer to the wiki for more information\")\
end\
end\
end",
  [ "StageCanvas.lua" ] = "local a={\
[1]=256;\
[2]=256;\
[4]=256;\
[8]=1;\
[16]=256;\
[32]=128;\
[64]=256;\
[128]=128;\
[256]=128;\
[512]=256;\
[1024]=128;\
[2048]=128;\
[4096]=128;\
[8192]=256;\
[16384]=128;\
[32768]=128;\
}\
class\"StageCanvas\"extends\"Canvas\"{\
frame=nil;\
filter=nil;\
cache={};\
greyOutWhenNotFocused=true;\
}\
function StageCanvas:initialise(...)\
local e,t=ParseClassArguments(self,{...},{{\"width\",\"number\"},{\"height\",\"number\"}},true,true)\
AssertClass(self.stage,\"Stage\",true,\"StageCanvas requires stage to be a Stage instance, not: \"..tostring(self.stage))\
self.super(e,t)\
self:updateFilter()\
end\
function StageCanvas:updateFilter()\
if self.stage.focused or not self.greyOutWhenNotFocused then\
self.filter=\"NONE\"\
else\
self.filter=\"GREYSCALE\"\
end\
end\
function StageCanvas:setFilter(e)\
self.filter=e\
end\
function StageCanvas:getColour(e)\
if self.filter==\"NONE\"then return e end\
if self.filter==\"GREYSCALE\"then\
return a[e]\
end\
end\
function StageCanvas:redrawFrame()\
local e=self.stage\
local t=self.getColour\
local d=not e.borderless\
local c=OverflowText(e.title or\"\",e.width-(e.closeButton and 1 or 0))or\"\"\
local s=e.shadow and e.focused\
local r=e.shadowColour\
local u=e.mouseMode and e.activeTitleTextColour or e.titleTextColour\
local l=e.mouseMode and e.activeTitleBackgroundColour or e.titleBackgroundColour\
local i=self.width\
local h=self.height\
local o={}\
for a=0,h-1 do\
local n=i*a\
for t=1,i do\
local n=n+t\
if d and a==0 and(s and t<i or not s)then\
if t==e.width and e.closeButton then\
o[n]={\"X\",e.closeButtonTextColour,e.closeButtonBackgroundColour}\
else\
local e=string.sub(c,t,t)\
o[n]={e~=\"\"and e or\" \",u,l}\
end\
elseif s and((t==i and a~=0)or(t~=1 and a==h-1))then\
o[n]={\" \",r,r}\
else\
local e=true\
if s and((t==i and a==0)or(t==1 and a==h-1))then\
e=false\
end\
if e then\
o[n]={false,false,false}\
end\
end\
end\
end\
self.frame=o\
end\
function StageCanvas:drawToCanvas(e,t,o,a)\
local f=self.buffer\
local m=self.frame\
local l=self.stage\
local n=self.getColour\
local y=self.stage.mappingID\
local a=type(t)==\"number\"and t-1 or 0\
local t=type(o)==\"number\"and o-1 or 0\
local r=self.width\
local i=self.height\
local w=self.stage.application.layerMap\
local o,u=e.height,e.width\
local s=e.buffer\
local d,h=self.textColour,self.backgroundColour\
for i=0,i-1 do\
local c=r*i\
local e=e.width*(i+t)\
if i+t+1>0 and i+t-1<o then\
for o=1,r do\
if o+a>0 and o+a-1<u then\
local t=e+(o+a)\
if w[t]==y then\
local e=c+o\
local a=f[e]\
if a then\
if not a[1]then\
local e=m[e]\
if e then\
local a=e[1]\
if o==r and i==0 and not l.borderless and l.closeButton and self.greyOutWhenNotFocused then\
s[t]={a,e[2]or d,e[3]or h}\
else\
s[t]={a,n(self,e[2]or d),n(self,e[3]or h)}\
end\
end\
else\
s[t]={a[1]or\" \",n(self,a[2]or d),n(self,a[3]or h)}\
end\
else\
s[t]={false,false,false}\
end\
end\
end\
end\
end\
end\
end",
  [ "Button.lua" ] = "DCML.registerTag(\"Button\",{\
contentCanBe=\"text\";\
argumentType={\
X=\"number\";\
Y=\"number\";\
width=\"number\";\
height=\"number\";\
backgroundColour=\"colour\";\
textColour=\"colour\";\
activeTextColour=\"colour\";\
activeBackgroundColour=\"colour\";\
};\
callbacks={\
onTrigger=\"onTrigger\"\
};\
callbackGenerator=\"#generateNodeCallback\";\
aliasHandler=true\
})\
class\"Button\"extends\"Node\"alias\"ACTIVATABLE\"{\
text=nil;\
yCenter=false;\
xCenter=false;\
active=false;\
focused=false;\
textColour=1;\
backgroundColour=colours.cyan;\
activeTextColour=1;\
activeBackgroundColour=colours.lightBlue;\
acceptMouse=true;\
}\
function Button:initialise(...)\
local e,t,o,a,i=ParseClassArguments(self,{...},{{\"text\",\"string\"},{\"X\",\"number\"},{\"Y\",\"number\"},{\"width\",\"number\"},{\"height\",\"number\"}},true,true)\
self.super(t,o,a,i)\
self.text=e\
end\
function Button:updateLines()\
if not self.text then return end\
self.lines=self.canvas:wrapText(self.text,self.width)\
end\
function Button:setText(e)\
self.text=e\
self:updateLines()\
end\
function Button:setWidth(e)\
self.width=e\
self:updateLines()\
end\
function Button:preDraw()\
self.canvas:drawWrappedText(1,1,self.width,self.height,self.lines,\"center\",\"center\",self.active and self.activeBackgroundColour or self.backgroundColour,self.active and self.activeTextColour or self.textColour)\
end\
function Button:onMouseDown(e)\
if e.misc~=1 then return end\
self.focused=true\
self.active=true\
e.handled=true\
end\
function Button:onMouseDrag(e)\
if self.focused then\
self.active=true\
e.handled=true\
end\
end\
function Button:onMouseMiss(e)\
if self.focused and e.sub==\"DRAG\"then\
self.active=false\
e.handled=true\
elseif e.sub==\"UP\"and(self.focused or self.active)then\
self.active=false\
self.focused=false\
e.handled=true\
end\
end\
function Button:onMouseUp(e)\
if self.active then\
if self.onTrigger then self:onTrigger(e)end\
self.active=false\
self.focused=false\
e.handled=true\
end\
end\
function Button:setActive(e)\
self.active=e\
self.changed=true\
end\
function Button:setFocused(e)\
self.focused=e\
self.changed=true\
end",
  [ "HotkeyManager.lua" ] = "local e,e,e,e=table.insert,table.remove,string.sub,string.len\
local a={}\
local n=true\
local o={\
leftShift=\"shift\";\
rightShift=\"shift\";\
leftCtrl=\"ctrl\";\
}\
class\"HotkeyManager\"{\
keys={};\
combinations={};\
application=nil;\
}\
function HotkeyManager:initialise(e)\
self.application=AssertClass(e,\"Application\",true,\"HotkeyManager requires an Application Instance as its constructor argument, not '\"..tostring(e)..\"'\")\
end\
local function i(o,t,i)\
local e={}\
if a[t]then\
e=a[t]\
else\
for t in string.gmatch(t,'([^-]+)')do\
e[#e+1]=t\
end\
a[t]=e\
end\
local t=true\
for a=1,#e do\
if not o.keys[e[a]]or(i and o.keys[e[a]].held)then\
t=false\
break\
end\
end\
return t\
end\
function HotkeyManager:assignKey(e,a)\
if e.main==\"KEY\"then\
if e.held==nil then\
n=false\
end\
local t=keys.getName(e.key)\
local e={held=e.held,keyID=e.key}\
if not t then return end\
self.keys[t]=e\
if not a then\
local t=o[t]\
if t then\
self.keys[t]=e\
end\
end\
end\
end\
function HotkeyManager:relieveKey(e,t)\
if e.main==\"KEY\"then\
local e=keys.getName(e.key)\
if not e then return end\
self.keys[e]=nil\
if not t then\
local e=o[e]\
if e then\
self.keys[e]=nil\
end\
end\
end\
end\
function HotkeyManager:handleKey(e)\
if e.sub==\"UP\"then\
self:relieveKey(e)\
else\
self:assignKey(e)\
end\
end\
function HotkeyManager:matches(e)\
return i(self,e)\
end\
function HotkeyManager:registerCombination(a,t,e,o)\
if not a or not t or not type(e)==\"function\"then return error(\"Expected string name, string combination, function callback\")end\
self.combinations[#self.combinations+1]={a,t,o or\"normal\",e}\
end\
function HotkeyManager:removeCombination(t)\
if not t then return error(\"Requires name to search\")end\
for e=1,#self.combinations do\
local a=self.combinations[e]\
if a[1]==t then\
table.remove(self.combinations,e)\
break\
end\
end\
end\
function HotkeyManager:checkCombinations()\
for e=1,#self.combinations do\
local e=self.combinations[e]\
if i(self,e[2],e[3]==\"strict\")then\
e[4](self.application)\
end\
end\
end\
function HotkeyManager:reset()\
self.keys={}\
end",
  [ "TextContainer.lua" ] = "class\"TextContainer\"extends\"MultiLineTextDisplay\"\
function TextContainer:initialise(...)\
local i,a,o,t,e=ParseClassArguments(self,{...},{{\"text\",\"string\"},{\"X\",\"number\"},{\"Y\",\"number\"},{\"width\",\"number\"},{\"height\",\"number\"}},true,true)\
self.super(a,o,t,e)\
self.text=i\
self.container=FormattedTextObject(self,self.width)\
self:addNode(self.container)\
self:cacheNodeSizes()\
self:cacheDisplaySize()\
end\
function TextContainer:setText(e)\
self.text=e\
if self.__init_complete then\
self:parseIdentifiers()\
self.container:cacheSegmentInformation()\
self.verticalScroll=math.max(math.min(self.verticalScroll,self.container.height-1),0)\
self.changed=true\
end\
end\
function TextContainer:setWidth(e)\
self.super:setWidth(e)\
if self.container then self.container:cacheSegmentInformation()end\
end",
  [ "scriptFiles.cfg" ] = "ClassUtil.lua\
TextUtil.lua\
DCMLParser.lua\
Logging.lua\
ExceptionHook.lua",
  [ "Class.lua" ] = "local w,h=string.gsub,string.match\
local a\
local n={}\
local c\
local m={\
ENABLE=false;\
LOCATION=\"DynaCode-Dump.crash\"\
}\
local o\
local s={\
__class=true;\
__instance=true;\
__defined=true;\
__definedProperties=true;\
__definedMethods=true;\
__extends=true;\
__interfaces=true;\
__type=true;\
__mixins=true;\
__super=true;\
__initialSuperValues=true;\
__alias=true;\
}\
local g=setmetatable({},{__index=function(a,e)\
local t=\"set\"..e:sub(1,1):upper()..e:sub(2)\
a[e]=t\
return t\
end})\
local v=setmetatable({},{__index=function(a,e)\
local t=\"get\"..e:sub(1,1):upper()..e:sub(2)\
a[e]=t\
return t\
end})\
local function e(e,t)\
local t=type(t)==\"number\"and t+1 or 2\
local e=e:sub(-1)~=\".\"and e..\".\"or e\
return error(\"Class Exception: \"..e,t)\
end\
local function i(t)\
local i=a\
local o,e\
o=c(t)\
e=n[t]\
if classLib.isClass(e)then\
if not e:isSealed()then e:seal()end\
else\
return error(\"Target class '\"..tostring(t)..\"' failed to load\")\
end\
a=i\
return e\
end\
local function f(t,a,o,s)\
local a=n[t]\
if not a or not classLib.isClass(a)then\
if c then\
return i(t)\
else\
e(o or\"Failed to fetch class '\"..tostring(t)..\"'. Class doesn't exist\",2)\
end\
elseif not a:isSealed()then\
e(s or\"Failed to fetch class '\"..tostring(t)..\"'. Class is not compiled\",2)\
end\
return a\
end\
local function u(e)\
o=true\
local e=e:getRaw()\
o=false\
return e\
end\
local function l(t)\
local a=type(t)\
local e\
if a=='table'then\
e={}\
for a,t in next,t,nil do\
e[l(a)]=l(t)\
end\
else\
e=t\
end\
return e\
end\
local function b(e)\
local t=h(e,\"abstract class (\\\"%w*\\\")\")\
if t then\
e=w(e,\"abstract class \"..t,\"class \"..t..\" abstract()\")\
end\
return e\
end\
local function y(h,i,e)\
local s\
local t\
local a,n,o=string.match(e,\"(.+)%:(%d+)%:(.*)\")\
if a and n and o then\
s=n\
t=o\
else\
t=e\
end\
local t=[==[\
--[[\
    DynaCode Crash Report (0.1)\
    =================\
\
    This file was generated because DynaCode's class system\
    ran into a fatal exception while running this file.\
\
    Exception Details\
    -----------------\
    File: ]==]..tostring(a or i or\"?\")..[==[\
\
    Line Number: ]==]..tostring(s or\"?\")..[==[\
\
    Error: ]==]..tostring(t or\"?\")..[==[\
\
\
    Raw: ]==]..tostring(e or\"?\")..[==[\
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
    will not have any affect. Please edit the source file (]==]..tostring(a or i or\"?\")..[==[)\
]]]==]\
local e=fs.open(m.LOCATION,\"w\")\
e.write(h..\"-- END OF FILE --\")\
e.write(\"\\n\\n\"..t)\
e.close()\
end\
local function r(t)\
if not a then\
e(\"Failed to catch property table, no class is being built.\")\
end\
if type(t)==\"table\"then\
for e,t in pairs(t)do\
a[e]=t\
end\
elseif t~=nil then\
e(\"Failed to catch property table, got: '\"..tostring(t)..\"'.\")\
end\
end\
local function p(w,d,t,a,o)\
local r,i={},{}\
local n=t or{}\
local h=a or{}\
local c=o or 1\
local a=u(f(d,true))\
local function y(e,o,a,i)\
local e=e\
local t={}\
while true do\
if e.__defined[a]then\
return true\
else\
t[#t+1]=e\
if e.super~=o and e.super then e=e.super\
else\
for e=1,#t do t[e]:addSymbolicKey(a,i)end\
break\
end\
end\
end\
end\
local function m(e,a)\
local t=e\
while true do\
local e=t.super\
if e then\
if e.__defined[a]then return e[a]else t=e end\
else break end\
end\
end\
local i={}\
for t,o in pairs(a)do\
if not s[t]then\
if type(o)==\"function\"then\
if i[t]then\
e(\"A factory for key '\"..t..\"' on super '\"..d.__type..\"' for '\"..w.__type..\"' already exists.\")\
end\
i[t]=function(a,o,...)\
if not o then\
e(\"Failed to fetch raw content for factory '\"..t..\"'\")\
end\
local i=a.super\
local e=a:seekSuper(c+1)\
a.super=e~=nil and e~=\"nil\"and e or nil\
local e={o[t](a,...)}\
a.super=i\
return unpack(e)\
end\
if n[t]==nil then n[t]=i[t]end\
else\
if n[t]==nil then n[t]=o end\
end\
elseif t==\"__alias\"then\
for e,t in pairs(o)do\
if not h[e]then h[e]=t end\
end\
end\
end\
local u={}\
if a.__extends then\
local e,o\
r.super,e,o=p(w,a.__extends,n,h,c+1)\
sym=true\
for e,t in pairs(e)do\
if not a[e]and not s[e]then\
if type(t)==\"function\"then\
u[e]=t\
else\
a[e]=t\
end\
end\
end\
for e,t in pairs(o)do\
if not h[e]then\
h[e]=t\
end\
end\
sym=false\
end\
function r:create(h)\
local a=l(a)\
local o,n={},{}\
local d\
if r.super then\
o.super=r.super:create(h)\
end\
d=true\
for e,t in pairs(u)do\
if not a[e]then a[e]=m(o,e)end\
end\
d=false\
function o:addSymbolicKey(e,t)\
d=true\
a[e]=t\
d=false\
end\
local r={}\
local f=a.__defined\
local l={}\
function n:__index(t)\
if type(a[t])==\"function\"then\
if not l[t]then\
l[t]=f[t]and i[t]or a[t]\
end\
local o=l[t]\
if not o then\
if f[t]then\
e(\"Failed to create factory for key '\"..t..\"'. This error wasn't caught at compile time, please report immediately\")\
else\
e(\"Failed to find factory for key '\"..t..\"' on super '\"..tostring(self)..\"'. Was this function illegally created after compilation?\",0)\
end\
end\
if not r[t]then\
r[t]=function(e,...)\
local e={...}\
local e\
if u[t]then\
e={o(h,...)}\
else\
e={o(h,a,...)}\
end\
return unpack(e)\
end\
end\
return r[t]\
else\
return a[t]\
end\
end\
function n:__newindex(t,i)\
if t==nil then\
e(\"Failed to set nil key with value '\"..tostring(i)..\"'. Key names must have a value.\")\
elseif s[t]then\
e(\"Failed to set key '\"..t..\"'. Key is reserved.\")\
end\
a[t]=i==nil and m(self,t)or i\
if not d then\
local e=type(i)\
a.__defined[t]=i~=nil or nil\
a.__definedProperties[t]=i and e~=\"function\"or nil\
a.__definedMethods[t]=i and e==\"function\"or nil\
end\
y(h,o,t,i)\
end\
function n:__tostring()\
return\"Super #\"..c..\" '\"..a.__type..\"' of '\"..h:type()..\"'\"\
end\
function n:__call(...)\
local e=type(o.initialise)==\"function\"and\"initialise\"or\"initialize\"\
local t=o[e]\
if type(t)==\"function\"then\
o[e](o,...)\
end\
end\
setmetatable(o,n)\
return o\
end\
return r,n,h\
end\
local function k()\
local t=u(a)\
if not a then\
e(\"Cannot compile class because no classes are being built.\")\
end\
local o=t.__mixins\
local e\
for t=1,#o do\
local t=o[t]\
e=\"Failed to mixin target '\"..tostring(t)..\"' into '\"..a.__type..\"'. \"\
local e=f(t,true,e..\"The class doesn't exist\",e..\"The class has not been compiled.\")\
if e then\
for e,t in pairs(u(e))do\
if not a[e]then\
a[e]=t\
end\
end\
end\
end\
if a.__extends then\
local o,i,a=p(a,a.__extends)\
local e=t.__alias\
for a,o in pairs(a)do\
if not e[a]then\
e[a]=o\
end\
end\
t.__super=o\
t.__initialSuperValues=i\
end\
end\
local function p(t,...)\
local r\
if type(t)~=\"string\"then\
e(\"Failed to spawn class. Invalid name provided '\"..tostring(t)..\"'\")\
elseif a then\
e(\"Cannot spawn class '\"..t..\"' because a class is currently being built.\")\
end\
local a=f(t,true,\"Failed to spawn class '\"..t..\"'. The class doesn't exist\",\"Failed to spawn class '\"..t..\"'. The class is not compiled.\")\
local o,i,t={},{}\
t=l(u(a))\
t.__instance=true\
local l=t.__alias or{}\
local function d(a)\
local t=t\
while true do\
local e=t.super\
if e then\
if e.__defined[a]then return e[a]else t=e end\
else return nil end\
end\
end\
local a={}\
function o:seekSuper(e)\
return a[e]\
end\
local h\
if t.__super then\
t.super=t.__super:create(o)\
h=t.super\
local e=t.__initialSuperValues\
for e,a in pairs(e)do\
if not t.__defined[e]and not s[e]then\
t[e]=d(e)\
end\
end\
t.__initialSuperValues=nil\
t.__super=nil\
local e=t\
local t=1\
while true do\
if not e.super then break end\
a[t]=e.super\
e=e.super\
t=t+1\
end\
end\
local n={}\
function i:__index(a)\
local a=l[a]or a\
if a==nil then\
e(\"Failed to get 'nil' key. Key names must have a value.\")\
end\
local e=v[a]\
if type(t[e])==\"function\"and not n[a]then\
local o=t.super\
t.super=h\
n[a]=true\
local e={t[e](self)}\
n[a]=nil\
t.super=o\
return unpack(e)\
else\
return t[a]\
end\
end\
local n={}\
function i:__newindex(a,o)\
local a=l[a]or a\
if a==nil then\
e(\"Failed to set 'nil' key with value '\"..tostring(o)..\"'. Key names must have a value.\")\
elseif s[a]then\
e(\"Failed to set key '\"..a..\"'. Key is reserved.\")\
elseif isSealed then\
e(\"Failed to set key '\"..a..\"'. This class base is compiled.\")\
end\
local e=g[a]\
if type(t[e])==\"function\"and not n[a]then\
local i=t.super\
t.super=h\
n[a]=true\
t[e](self,o)\
n[a]=nil\
t.super=i\
else\
t[a]=o\
end\
if o==nil then\
t[a]=d(a)\
end\
if not r then\
t.__defined[a]=o~=nil or nil\
end\
end\
function i:__tostring()return\"[Instance] \"..t.__type end\
function o:type()return t.__type end\
function o:addSymbolicKey(e,t)\
r=true;self[e]=t;r=false\
end\
local a={\
[\"__index\"]=true;\
[\"__newindex\"]=true;\
}\
function o:__overrideMetaMethod(e,t)\
if a[e]then return error(\"Meta method '\"..tostring(e)..\"' cannot be overridden\")end\
i[e]=t\
end\
function o:__lockMetaMethod(e)a[e]=true end\
setmetatable(o,i)\
local e=type(t.initialise)==\"function\"and\"initialise\"or\"initialize\"\
if type(t[e])==\"function\"then\
o[e](o,...)\
end\
return o\
end\
_G.class=function(t)\
local l\
local o=t:sub(1,1)\
if o:upper()~=o then\
e(\"Class name '\"..t..\"' is invalid. Class names must begin with a uppercase character.\")\
end\
if n[t]then\
e(\"Class name '\"..t..\"' is already in use.\")\
end\
local h,d=false,false\
local i={__defined={},__definedMethods={},__definedProperties={},__class=true,__mixins={},__alias={}}\
i.__type=t\
local o={}\
local u,c,m=i.__defined,i.__definedMethods,i.__definedProperties\
function o:seal()\
if h then\
e(\"Failed to seal class '\"..t..\"'. The class is already sealed.\")\
end\
k()\
h=true\
a=nil\
end\
function o:isSealed()\
return h\
end\
function o:abstract(a)\
if h then e(\"Cannot modify abstract state of sealed class '\"..t..\"'\")end\
d=a\
end\
function o:isAbstract()\
return d\
end\
function o:alias(t)\
local a\
if type(t)==\"table\"then\
a=t\
elseif type(t)==\"string\"and type(_G[t])==\"table\"then\
a=_G[t]\
end\
local o=i.__alias\
for t,a in pairs(a)do\
if not s[t]then\
o[t]=a\
else\
e(\"Cannot set redirects for reserved keys\")\
end\
end\
end\
function o:mixin(e)\
i.__mixins[#i.__mixins+1]=e\
end\
function o:extend(a)\
if type(a)~=\"string\"then\
e(\"Failed to extend class '\"..t..\"'. Target '\"..tostring(a)..\"' is not valid.\")\
elseif i.__extends then\
e(\"Failed to extend class '\"..t..\"' to target '\"..a..\"'. The base class already extends '\"..i.__extends..\"'\")\
end\
i.__extends=a\
end\
function o:spawn(...)\
if not h then\
e(\"Failed to spawn class '\"..t..\"'. The class is not sealed\")\
elseif d then\
e(\"Failed to spawn class '\"..t..\"'. The class is abstract\")\
end\
return p(t,...)\
end\
function o:getRaw()\
return i\
end\
function o:addSymbolicKey(t,e)\
l=true\
self[t]=e\
l=false\
end\
local d={}\
function d:__newindex(t,a)\
if t==nil then\
e(\"Failed to set nil key with value '\"..tostring(a)..\"'. Key names must have a value.\")\
elseif s[t]then\
e(\"Failed to set key '\"..t..\"'. Key is reserved.\")\
elseif h then\
e(\"Failed to set key '\"..t..\"'. This class base is compiled.\")\
end\
i[t]=a\
if not l then\
local e=type(a)\
u[t]=a~=nil or nil\
m[t]=a and e~=\"function\"or nil\
c[t]=a and e==\"function\"or nil\
end\
end\
d.__call=o.spawn\
d.__tostring=function()return\"[Class Base] \"..t end\
d.__index=i\
setmetatable(o,d)\
a=o\
n[t]=o\
_G[t]=o\
return r\
end\
_G.extends=function(t)\
if not a then\
e(\"Failed to extend currently building class to target '\"..tostring(t)..\"'. No class is being built.\")\
end\
a:extend(t)\
return r\
end\
_G.abstract=function()\
if not a then\
e(\"Failed to set abstract state of currently building class because no class is being built.\")\
end\
a:abstract(true)\
return r\
end\
_G.mixin=function(t)\
if not a then\
e(\"Failed to mixin target class '\"..tostring(t)..\"' to currently building class because no class is being built.\")\
end\
a:mixin(t)\
return r\
end\
_G.alias=function(t)\
if not a then\
e(\"Failed to add alias redirects because no class is being built.\")\
end\
a:alias(t)\
return r\
end\
local e={}\
function e.isClass(e)\
return type(e)==\"table\"and e.__type and n[e.__type]and n[e.__type].__class\
end\
function e.isInstance(t)\
return e.isClass(t)and t.__instance\
end\
function e.typeOf(t,o,a)\
return((a and e.isInstance(t))or(not a and e.isClass(t)))and t.__type==o\
end\
function e.getClass(e)return n[e]end\
function e.getClasses()return n end\
function e.setClassLoader(e)\
if type(e)~=\"function\"then return error(\"Cannot set missing class loader to variable of type '\"..type(e)..\"'\")end\
c=e\
end\
function e.runClassString(t,e,h)\
local i=m.ENABLE and\" The file being loaded at the time of the crash has been saved to '\"..m.LOCATION..\"'\"or\"\"\
local a=b(t)\
local function o(t)\
y(a,e,t)\
error(\"Exception while loading class string for file '\"..e..\"': \"..t..\".\"..i,0)\
end\
local s,t=loadstring(a,e)\
if t then\
o(t)\
end\
local s,t=pcall(s)\
if t then\
o(t)\
end\
local t=w(e,\"%..*\",\"\")\
local o=n[t]\
if not h then\
if o then\
if not o:isSealed()then o:seal()end\
else\
y(a,e,\"Failed to load class '\"..t..\"'\")\
error(\"File '\"..e..\"' failed to load class '\"..t..\"'\"..i,0)\
end\
end\
end\
_G.classLib=e",
  [ "EventManager.lua" ] = "class\"EventManager\"\
function EventManager:initialise(e,t)\
self.application=AssertClass(e,\"Application\",true,\"EventManager instance requires an Application Instance, not: \"..tostring(e))\
self.matrix=type(t)==\"table\"and t or error(\"EventManager constructor (2) requires a table of event -> class types.\",2)\
self.register={}\
end\
function EventManager:create(e)\
local t=e[1]\
local t=self.matrix[t]\
if not t then\
return UnknownEvent(e)\
else\
return t(e)\
end\
end\
function EventManager:registerEventHandler(t,e,a,o)\
local e=e..\"_\"..a\
self.register[e]=self.register[e]or{}\
table.insert(self.register[e],{\
t,\
o\
})\
end\
function EventManager:removeEventHandler(t,e,o)\
local a=t..\"_\"..e\
local e=self.register[a]\
if not e then return false end\
for t=1,#e do\
if e[t][1]==o then\
table.remove(self.register[a],t)\
return true\
end\
end\
end\
function EventManager:shipToRegistrations(e)\
local t=self.register[e.main..\"_\"..e.sub]\
if not t then return end\
for a=1,#t do\
local t=t[a]\
t[2](self,e)\
end\
end",
  [ "ConstructorException.lua" ] = "class\"ConstructorException\"extends\"ExceptionBase\"{\
title=\"Constructor Exception\";\
subTitle=\"This exception was raised due to a problem during instance construction. This may be because of an invalid or missing value required by initialisation.\";\
}",
  [ "Label.lua" ] = "DCML.registerTag(\"Label\",{\
contentCanBe=\"text\";\
argumentType={\
X=\"number\";\
Y=\"number\";\
backgroundColour=\"colour\";\
textColour=\"colour\";\
};\
aliasHandler=true\
})\
local e=string.len\
class\"Label\"extends\"Node\"{\
text=\"Label\";\
}\
function Label:initialise(...)\
ParseClassArguments(self,{...},{{\"text\",\"string\"},{\"X\",\"number\"},{\"Y\",\"number\"}},true,false)\
if not self.__defined.width then\
self.width=\"auto\"\
end\
self.super(self.X,self.Y,self.width,1)\
self.canvas.width=self.width\
end\
function Label:preDraw()\
local e=self.canvas\
e:drawTextLine(self.text,1,1,self.textColour,self.backgroundColour,self.width)\
end\
function Label:getWidth()\
return self.width==\"auto\"and e(self.text)or self.width\
end\
function Label:setWidth(e)\
self.width=e\
if not self.canvas then return end\
self.canvas.width=self.width\
end\
function Label:setText(e)\
self.text=e\
if not self.canvas then return end\
self.canvas.width=self.width\
end",
  [ "KeyEvent.lua" ] = "local i=string.sub\
class\"KeyEvent\"mixin\"Event\"{\
main=nil;\
sub=nil;\
key=nil;\
held=nil;\
}\
function KeyEvent:initialise(e)\
self.raw=e\
local o=string.find(e[1],\"_\")\
local t,a\
if o then\
t=i(e[1],o+1,e[1]:len())\
a=i(e[1],1,o-1)\
else\
t=e[1]\
a=t\
end\
self.main=a:upper()\
self.sub=t:upper()\
self.key=e[2]\
self.held=e[3]\
end\
function KeyEvent:isKey(e)\
if keys[e]==self.key then return true end\
end",
  [ "ExceptionHook.lua" ] = "local e\
local t\
_G.exceptionHook={}\
function exceptionHook.hook()\
if e then\
Exception(\"Failed to create exception hook. A hook is already in use.\")\
end\
e=_G.error\
_G.error=function(t,e)\
Exception(t,type(e)==\"number\"and(e==0 and 0 or e+1)or 2)\
end\
log(\"s\",\"Exception hook created\")\
end\
function exceptionHook.unhook()\
if not e then\
Exception(\"Failed to unhook exception hook. The hook doesn't exist.\")\
end\
_G.error=e\
log(\"s\",\"Exception hook removed\")\
end\
function exceptionHook.isHooked()\
return type(e)==\"function\"\
end\
function exceptionHook.getRawError()\
return e or _G.error\
end\
function exceptionHook.setRawError(t)\
if type(t)==\"function\"then\
e=t\
else\
Exception(\"Failed to set exception hook raw error. The function is not valid\")\
end\
end\
function exceptionHook.throwSystemException(e)\
t=e\
local t=exceptionHook.getRawError()\
t(e.displayName or\"?\",0)\
end\
function exceptionHook.spawnException(e)\
t=e\
end\
function exceptionHook.getLastThrownException()\
return t\
end",
  [ "Logging.lua" ] = "local a\
local t\
local i={\
i=\"Information\";\
w=\"Warning\";\
e=\"Error\";\
f=\"FATAL\";\
s=\"Success\";\
di=\"Daemon Information\";\
dw=\"Daemon Warning\";\
de=\"Daemon Error\";\
df=\"Daemon Fatal\";\
ds=\"Daemon Success\";\
eh=\"Exception Handling\";\
}\
local h=true\
local s=5e4\
local n=[[\
--@@== DynaCode Logging ==@@--\
\
\
Log Start >\
]]\
local e={}\
function e:log(e,o)\
if not(a and t and e and o)then return end\
if h and fs.getSize(t)>=s then\
self:clearLog()\
local e=fs.open(t,\"w\")\
e.write([[\
--@@== DynaCode Logging ==@@--\
\
This file was cleared at os time ']]..os.clock()..[[' to reduce file size.\
\
\
Log Resume >\
]])\
e.close()\
end\
local t=fs.open(t,\"a\")\
t.write(\"[\"..os.clock()..\"][\"..(i[e]or e)..\"] > \"..o..\"\\n\")\
t.close()\
end\
function e:registerMode(t,e)\
i[t]=e\
end\
function e:setLoggingEnabled(e)\
a=e\
end\
function e:getEnabled()return a end\
function e:setLoggingPath(e)\
t=e\
self:clearLog(true)\
end\
function e:getLoggingPath()return t end\
function e:clearLog(a)\
if not t then return end\
local e=fs.open(t,\"w\")\
if a then\
e.write(n)\
end\
e.close()\
end\
setmetatable(e,{__call=e.log})\
_G.log=e",
  [ "TextUtil.lua" ] = "local t={}\
function t.leadingTrim(e)\
return(e:gsub(\"^%s*\",\"\"))\
end\
function t.trailingTrim(t)\
local e=#t\
while e>0 and t:find(\"^%s\",e)do\
e=e-1\
end\
return t:sub(1,e)\
end\
function t.whitespaceTrim(e)\
return(e:gsub(\"^%s*(.-)%s*$\",\"%1\"))\
end\
_G.TextHelper=t",
  [ "Input.lua" ] = "DCML.registerTag(\"Input\",{\
argumentType={\
X=\"number\";\
Y=\"number\";\
width=\"number\";\
height=\"number\";\
backgroundColour=\"colour\";\
textColour=\"colour\";\
selectedTextColour=\"colour\";\
selectedBackgroundColour=\"colour\";\
activeTextColour=\"colour\";\
activeBackgroundColour=\"colour\";\
};\
callbacks={\
onSubmit=\"onSubmit\"\
};\
callbackGenerator=\"#generateNodeCallback\";\
aliasHandler=true\
})\
local o=string.len\
local h=string.sub\
class\"Input\"extends\"Node\"alias\"ACTIVATABLE\"alias\"SELECTABLE\"{\
acceptMouse=true;\
acceptKeyboard=false;\
content=false;\
selected=nil;\
cursorPosition=0;\
selectedTextColour=1;\
selectedBackgroundColour=colors.blue;\
textColour=32768;\
backgroundColour=128;\
activeBackgroundColour=256;\
activeTextColour=32768;\
placeholder=\"Input\";\
}\
function Input:initialise(...)\
self.super(...)\
self.content=\"\"\
self.selected=0\
end\
function Input:preDraw()\
local e,e=self.content,\"\"\
local e=self.canvas\
local i,o,u,a,t,r,d,n,e=0,self.width,self.content,o(self.content),self.selected,0,false,false,self.cursorPosition\
local n=e>=o\
local s=0\
local l=false\
if a>=o then\
if t<=0 and n then\
i=math.min(e-o,e+t-1)-a\
s=a-o+(e-a)\
if i+a==e+t-1 and math.abs(i)>o+(a-e)then l=true end\
elseif t>0 and e+t>o then\
i=(math.max(e,e+t-1))-a-self.width\
end\
end\
r=math.min(e+t,e)-s+(n and 0 or 1)\
d=math.max(e+t,e)-s-((n and not l)and 1 or 0)\
local a=self.canvas.buffer\
local o=t~=0\
for e=1,self.width do\
local t=e+i\
local o=o and e>=r and e<=d\
local t=h(u,t,t)\
t=t~=\"\"and t or\" \"\
if o then\
a[e]={t,1,colours.blue}\
else\
a[e]={t,colours.red,colors.lightGray}\
end\
end\
self.canvas.buffer=a\
end\
function Input:onMouseDown()\
self.stage:redirectKeyboardFocus(self)\
end\
local function d(e)\
local t=e.selected\
if t<0 then\
local a=-o(e.content)+(e.cursorPosition-o(e.content))\
if t<a then\
e.selected=a\
end\
elseif t>0 then\
local a=o(e.content)-e.cursorPosition\
if t>a then e.selected=a end\
end\
end\
local function r(e)\
if e.cursorPosition<0 then e.cursorPosition=0 elseif e.cursorPosition>o(e.content)then e.cursorPosition=o(e.content)end\
e.selected=0\
end\
local function i(e,o,a,n,i)\
local t=e.content\
t=h(t,1,e.cursorPosition+a)..o..h(t,e.cursorPosition+n)\
e.content=t\
e.cursorPosition=e.cursorPosition+i\
r(e)\
end\
function Input:onKeyDown(n)\
local e=keys.getName(n.key)\
local s=self.stage.application.hotkey\
local t,a=self.cursorPosition,self.selected\
if s.keys.shift then\
if e==\"left\"then\
a=a-1\
elseif e==\"right\"then\
a=a+1\
elseif e==\"home\"then\
a=-(self.cursorPosition)\
elseif e==\"end\"then\
a=o(self.content)-self.cursorPosition\
end\
elseif s.keys.ctrl then\
if e==\"left\"then\
t=t-1\
elseif e==\"right\"then\
t=t+1\
end\
else\
if e==\"left\"then\
t=t-1\
a=0\
elseif e==\"right\"then\
t=t+1\
a=0\
elseif e==\"home\"then\
t=0\
a=0\
elseif e==\"end\"then\
t=o(self.content)\
a=0\
elseif e==\"backspace\"then\
if self.cursorPosition==0 then return end\
i(self,\"\",-1,1,-1)\
elseif e==\"delete\"then\
if self.cursorPosition==#self.content then return end\
i(self,\"\",0,2,0)\
elseif e==\"enter\"then\
if self.onTrigger then self:onTrigger(n)end\
end\
end\
self.cursorPosition=t\
self.selected=a\
end\
function Input:setContent(e)\
self.content=e\
self.changed=true\
end\
function Input:setCursorPosition(e)\
self.cursorPosition=e\
r(self)\
self.changed=true\
end\
function Input:setSelected(e)\
self.selected=e\
d(self)\
self.changed=true\
end\
function Input:onChar(e)\
i(self,e.key,0,1,1)\
end\
function Input:onMouseMiss(e)\
if e.sub==\"UP\"then return end\
self.stage:removeKeyboardFocus(self)\
end\
function Input:getCursorInformation()\
local a,t=self:getTotalOffset()\
local e\
if self.cursorPosition<self.width then\
e=self.cursorPosition\
else\
e=self.width-1\
end\
return self.selected==0,a+e-1,t,self.activeTextColour\
end\
function Input:onFocusLost()self.focused=false;self.acceptKeyboard=false;self.changed=true end\
function Input:onFocusGain()self.focused=true;self.acceptKeyboard=true;self.changed=true end",
  [ "MouseEvent.lua" ] = "local t=string.sub\
class\"MouseEvent\"mixin\"Event\"{\
main=\"MOUSE\";\
sub=nil;\
X=nil;\
Y=nil;\
misc=nil;\
inParentBounds=false;\
}\
function MouseEvent:initialise(e)\
self.raw=e\
local t=t(e[1],string.find(e[1],\"_\")+1,e[1]:len())\
self.sub=t:upper()\
self.misc=e[2]\
self.X=e[3]\
self.Y=e[4]\
end\
function MouseEvent:inArea(a,n,o,i)\
local t,e=self.X,self.Y\
if t>=a and t<=o and e>=n and e<=i then\
return true\
end\
return false\
end\
function MouseEvent:isInNode(e)\
return self:inArea(e.X,e.Y,e.X+e.width-1,e.Y+e.height-1)\
end\
function MouseEvent:onPoint(e,t)\
if self.X==e and self.Y==t then\
return true\
end\
return false\
end\
function MouseEvent:getPosition()return self.X,self.Y end\
function MouseEvent:convertToRelative(e)\
self.X,self.Y=self:getRelative(e)\
end\
function MouseEvent:getRelative(e)\
return self.X-e.X+1,self.Y-e.Y+1\
end\
function MouseEvent:inBounds(e)\
local t,a=e.X,e.Y\
return self:inArea(t,a,t+e.width-1,a+e.height-1)\
end",
  [ "NodeContainer.lua" ] = "class\"NodeContainer\"abstract()extends\"Node\"mixin\"MTemplateHolder\"mixin\"MNodeManager\"{\
acceptMouse=true;\
acceptKeyboard=true;\
acceptMisc=true;\
forceRedraw=true;\
}\
function NodeContainer:resolveDCMLChildren()\
local e=self.nodesToAdd\
for t=1,#e do\
local e=e[t]\
self:addNode(e)\
if e.nodesToAdd and type(e.resolveDCMLChildren)==\"function\"then\
e:resolveDCMLChildren()\
end\
end\
self.nodesToAdd={}\
end",
  [ "UnknownEvent.lua" ] = "class\"UnknownEvent\"mixin\"Event\"{\
main=false;\
sub=\"EVENT\";\
}\
function UnknownEvent:initialise(e)\
self.raw=e\
self.main=e[1]:upper()\
end",
  [ "loadFirst.cfg" ] = "Logging.lua\
ClassUtil.lua\
TextUtil.lua\
DCMLParser.lua",
  [ "MTemplateHolder.lua" ] = "class\"MTemplateHolder\"abstract(){\
templates={};\
activeTemplate=nil;\
}\
function MTemplateHolder:registerTemplate(e)\
if classLib.typeOf(e,\"Template\",true)then\
if not e.owner then\
if not self:getTemplateByName(e.name)then\
e.owner=self\
table.insert(self.templates,e)\
return true\
else\
ParameterException(\"Failed to register template '\"..tostring(e)..\"'. A template with the name '\"..e.name..\"' is already registered on this object (\"..tostring(self)..\").\")\
end\
else\
ParameterException(\"Failed to register template '\"..tostring(e)..\"'. The template belongs to '\"..tostring(e.owner)..\"'\")\
end\
else\
ParameterException(\"Failed to register object '\"..tostring(e)..\"' as template. The object is an invalid type.\")\
end\
return false\
end\
function MTemplateHolder:unregisterTemplate(t)\
local i=type(t)==\"string\"\
local a=self.templates\
local e\
for o=1,#a do\
e=a[o]\
if(i and e.name==t)or(not i and e==t)then\
e.owner=nil\
table.remove(a,o)\
return true\
end\
end\
return false\
end\
function MTemplateHolder:getTemplateByName(o)\
local t=self.templates\
local e\
for a=1,#t do\
e=t[a]\
if e.name==o then\
return e\
end\
end\
return false\
end\
function MTemplateHolder:setActiveTemplate(e)\
if type(e)==\"string\"then\
local t=self:getTemplateByName(name)\
if t then\
self.activeTemplate=t\
else\
ParameterException(\"Failed to set active template of '\"..tostring(self)..\"' to template with name '\"..e..\"'. The template could not be found.\")\
end\
elseif classLib.typeOf(e,\"Template\",true)then\
self.activeTemplate=e\
self.changed=true\
self.forceRedraw=true\
else\
ParameterException(\"Failed to set active template of '\"..tostring(self)..\"'. The target object is invalid: \"..tostring(e))\
end\
end\
function MTemplateHolder:getNodes()\
if self.activeTemplate then\
return self.activeTemplate.nodes\
end\
return self.nodes\
end",
  [ "MultiLineTextDisplay.lua" ] = "local s,a,t,c,y,o=string.len,string.find,string.sub,string.match,string.gmatch,string.gsub\
local function m(e)\
return colours[e]or colors[e]or error(\"Invalid colour '\"..e..\"'\")\
end\
class\"MultiLineTextDisplay\"abstract()extends\"NodeScrollContainer\"{\
lastHorizontalStatus=false;\
lastVerticalStatus=false;\
}\
function MultiLineTextDisplay:initialise(...)\
self.super(...)\
self.autoDraw=false\
self.cache.displayWidth=self.width\
end\
function MultiLineTextDisplay:parseIdentifiers()\
local f={}\
local e=self.text\
local n=0\
local w=o(e,\"[ ]?%@%w-%-%w+[[%+%w-%-%w+]+]?[ ]?\",\"\")\
local l,u,d=false,false,false\
while s(e)>0 do\
local i,a=a(e,\"%@%w-%-%w+[[%+%w-%-%w+]+]?\")\
local r,h,o\
if not i or not a then break end\
r=t(e,i-1,i-1)==\" \"\
h=t(e,a+1,a+1)==\" \"\
o=t(e,i,a)\
local s=a+n-s(o)\
n=n+i-2-(r and 1 or 0)-(h and 1 or 0)\
e=t(e,a)\
for e in y(o,\"([^%+]+)\")do\
if t(e,1,1)==\"@\"then\
e=t(e,2)\
end\
local t,a=c(e,\"(%w-)%-\"),c(e,\"%-(%w+)\")\
if not t or not a then error(\"identifier '\"..tostring(o)..\"' contains invalid syntax\")end\
if t==\"tc\"then\
l=m(a)\
elseif t==\"bg\"then\
u=m(a)\
elseif t==\"align\"then\
d=a\
else\
error(\"Unknown identifier target '\"..tostring(t)..\"' in identifier '\"..tostring(o)..\"' at part '\"..e..\"'\")\
end\
end\
f[s]={l,u,d}\
end\
local e=self.container\
e.segments,e.text=f,w\
end\
function MultiLineTextDisplay:cacheRequiredScrollbars()\
self.super:cacheRequiredScrollbars()\
self.cache.xActive=false\
end\
function MultiLineTextDisplay:cacheDisplaySize()\
self.super:cacheDisplaySize()\
self.container:cacheSegmentInformation()\
end",
  [ "ApplicationCanvas.lua" ] = "local f={\
[1]=\"0\";\
[2]=\"1\";\
[4]=\"2\";\
[8]=\"3\";\
[16]=\"4\";\
[32]=\"5\";\
[64]=\"6\";\
[128]=\"7\";\
[256]=\"8\";\
[512]=\"9\";\
[1024]=\"a\";\
[2048]=\"b\";\
[4096]=\"c\";\
[8192]=\"d\";\
[16384]=\"e\";\
[32768]=\"f\";\
}\
local c=type(term.blit)==\"function\"and term.blit or nil\
local b=term.write\
local u=term.setCursorPos\
local h=table.concat\
local p,w=term.setTextColour,term.setBackgroundColour\
class\"ApplicationCanvas\"extends\"Canvas\"{\
textColour=colors.red;\
backgroundColour=colours.cyan;\
old={};\
}\
function ApplicationCanvas:initialise(...)\
ParseClassArguments(self,{...},{{\"owner\",\"Application\"},{\"width\",\"number\"},{\"height\",\"number\"}},true)\
AssertClass(self.owner,\"Application\",true,\"Instance '\"..self:type()..\"' requires an Application Instance as the owner\")\
print(tostring(self.width)..\", \"..tostring(self.height))\
self.super(self.width,self.height)\
end\
function ApplicationCanvas:drawToScreen(g)\
local t=1\
local y=self.buffer\
local v,r=self.width,self.height\
local l=self.old\
local n,i,o,s\
local e,a\
local m,d=self.textColour or 1,self.backgroundColour or 1\
if c then\
for r=1,r do\
n,i,o,s={},{},{},false\
for h=1,v do\
e=y[t]\
a=l[t]\
n[#n+1]=e[1]or\" \"\
i[#i+1]=f[e[2]or m]\
o[#o+1]=f[e[3]or d]\
if not a or e[1]~=a[1]or e[2]~=a[2]or e[3]~=a[3]then\
s=true\
l[t]={e[1],e[2],e[3]}\
end\
t=t+1\
end\
if s then\
u(1,r)\
c(h(n,\"\"),h(i,\"\"),h(o,\"\"))\
end\
end\
else\
local a\
local n=self.old\
local o,i=1,32768\
p(o)\
w(i)\
for h=1,r do\
for s=1,v do\
e=y[t]\
a=n[t]\
if g or not a or not(a[1]==e[1]and a[2]==e[2]and a[3]==e[3])then\
u(s,h)\
local a=e[2]or m\
if a~=o then p(a)o=a end\
local a=e[3]or d\
if a~=i then w(a)i=a end\
b(e[1]or\" \")\
n[t]={e[1],e[2],e[3]}\
end\
t=t+1\
end\
end\
end\
end",
  [ "MDaemon.lua" ] = "class\"MDaemon\"abstract()\
function MDaemon:registerDaemon(e)\
if not classLib.isInstance(e)or not e.__daemon then\
return error(\"Cannot register daemon '\"..tostring(e)..\"' (\"..type(e)..\")\")\
end\
if not e.name then return error(\"Daemon '\"..e:type()..\"' has no name!\")end\
log(\"di\",\"Registered daemon of type '\"..e:type()..\"' (name \"..e.name..\") to \"..self:type())\
e.owner=self\
table.insert(self.__daemons,e)\
end\
function MDaemon:removeDaemon(a)\
if not a then return error(\"Cannot un-register daemon with no name to search\")end\
local e=self.__daemons\
for t=1,#e do\
local e=e[t]\
if e.name==a then\
log(\"di\",\"Removed daemon of type '\"..e:type()..\"' (name \"..e.name..\") from \"..self:type()..\". Index \"..t)\
table.remove(self.__daemons,t)\
end\
end\
end\
function MDaemon:get__daemons()\
if type(self.__daemons)~=\"table\"then\
self.__daemons={}\
end\
return self.__daemons\
end\
function MDaemon:startDaemons()\
local e=self.__daemons\
for t=1,#e do\
e[t]:start()\
end\
end\
function MDaemon:stopDaemons(t)\
local e=self.__daemons\
for a=1,#e do\
e[a]:stop(t)\
end\
end",
  [ "FormattedTextObject.lua" ] = "local n,f,m=string.len,string.match,string.sub\
local function u(t)\
local a=n(t)\
local e=0\
return(function()\
e=e+1\
if e<=a then return m(t,e,e)end\
end)\
end\
class\"FormattedTextObject\"extends\"Node\"{\
segments={};\
cache={\
height=nil;\
text=nil;\
};\
}\
function FormattedTextObject:initialise(e,t)\
self.owner=classLib.isInstance(e)and e or error(\"Cannot set owner of FormattedTextObject to '\"..tostring(e)..\"'\",2)\
self.width=type(t)==\"number\"and t or error(\"Cannot set width of FormattedTextObject to '\"..tostring(t)..\"'\",2)\
end\
function FormattedTextObject:cacheSegmentInformation()\
log(\"i\",\"Parsing segment information with width: \"..tostring(self.owner.cache.displayWidth))\
if not text then self.owner:parseIdentifiers()text=self.text end\
if not self.text then return error(\"Failed to parse text identifiers. No new text received.\")end\
local w=self.segments\
local s,e,o,t,a=self.owner.cache.displayWidth,self.text,{},1,1\
local l,c,i=false,false,\"left\"\
local function r()\
a=1\
o[t].align=AssertEnum(i,{\"left\",\"center\",\"centre\",\"right\"},\"Failed FormattedTextObject caching: '\"..tostring(i)..\"' is an invalid alignment setting.\")\
t=t+1\
o[t]={\
align=i\
}\
return o[t]\
end\
o[t]={\
align=i\
}\
local h=0\
local function d()\
local e=w[h]\
if e then\
l=e[1]or l\
c=e[2]or c\
i=e[3]or i\
end\
h=h+1\
end\
local function w(e)\
local i=o[t]\
o[t][#i+1]={\
e,\
l,\
c\
}\
a=a+1\
end\
while n(e)>0 do\
local i=f(e,\"^[\\n]+\")\
if i then\
for t=1,n(i)do\
r()\
h=h+1\
end\
e=m(e,n(i)+1)\
end\
local i=f(e,\"^[ \\t]+\")\
if i then\
local t=o[t]\
for o in u(i)do\
d()\
t[#t+1]={\
o,\
l,\
c\
}\
a=a+1\
if a>s then t=r()end\
end\
e=m(e,n(i)+1)\
end\
local t=f(e,\"%S+\")\
if t then\
local o=n(t)\
e=m(e,o+1)\
if a+o<=s then\
for e in u(t)do\
d()\
w(e)\
end\
elseif o<=s then\
r()\
for e in u(t)do\
d()\
w(e)\
end\
else\
if a>s then r()end\
for e in u(t)do\
d()\
w(e)\
if a>s then r()end\
end\
end\
else break end\
end\
o[t].align=i\
self:cacheAlignments(o)\
end\
function FormattedTextObject:cacheAlignments(e)\
local a=e or self.lines\
local o=self.owner.cache.displayWidth\
local e,t\
for i=1,#a do\
e=a[i]\
t=e.align\
if t==\"left\"then\
e.X=1\
elseif t==\"center\"then\
e.X=math.ceil((o/2)-(#e/2))+1\
elseif t==\"right\"then\
e.X=o-#e+1\
else return error(\"Invalid alignment property '\"..tostring(t)..\"'\")end\
end\
self.lines=a\
return self.lines\
end\
function FormattedTextObject:draw(e,s)\
local t=self.owner\
if not classLib.isInstance(t)then\
return error(\"Cannot draw '\"..tostring(self:type())..\"'. The instance has no owner.\")\
end\
local e=t.canvas\
if not e then return error(\"Object '\"..tostring(t)..\"' has no canvas\")end\
local n=e.buffer\
if not self.lines then\
self:cacheSegmentInformation()\
end\
local t=self.lines\
local a=self.owner.width\
local o,a,a\
for a=1,#t do\
local t=t[a]\
local i=t.X\
o=e.width*(a-0)\
for o=1,#t do\
local t=t[o]or{\" \",colours.red,colours.red}\
if t then\
n[(e.width*(a-1+s))+(o+i-1)]={t[1],t[2],t[3]}\
end\
end\
end\
end\
function FormattedTextObject:getCache()\
if not self.cache then\
self:cacheText()\
end\
return self.cache\
end\
function FormattedTextObject:getHeight()\
if not self.lines then\
self:cacheSegmentInformation()\
self.owner.recacheAllNextDraw=true\
end\
return#self.lines\
end\
function FormattedTextObject:getCanvas()\
return self.owner.canvas\
end",
  [ "Canvas.lua" ] = "local h=table.insert\
local s=table.remove\
class\"Canvas\"abstract()alias\"COLOUR_REDIRECT\"{\
width=10;\
height=6;\
buffer=nil;\
}\
function Canvas:initialise(...)\
local t,e=ParseClassArguments(self,{...},{{\"width\",\"number\"},{\"height\",\"number\"}},true,true)\
self.width=t\
self.height=e\
self:clear()\
end\
function Canvas:clear(e,t)\
local a=e or self.width\
local t=t or self.height\
local e={}\
for t=1,a*t do\
e[t]={false,false,false}\
end\
self.buffer=e\
end\
function Canvas:drawToCanvas(t,a,e)\
if not t then return error(\"Requires canvas to draw to\")end\
local r=self.buffer\
local d=a or 0\
local h=e or 0\
local i,o,n,s,e\
for a=0,self.height-1 do\
o=self.width*a\
n=t.width*(a+h)\
for a=1,self.width do\
i=o+a\
s=n+(a+d)\
e=r[i]\
t.buffer[s]={e[1]or\" \",e[2]or self.textColour,e[3]or self.backgroundColour}\
end\
end\
end\
function Canvas:setWidth(e)\
if not self.buffer then self.width=e return end\
local a,t=self.height,self.buffer\
if not self.width then error(\"found on \"..tostring(self)..\". Current width: \"..tostring(self.width)..\", new width: \"..tostring(e))end\
while self.width<e do\
for e=1,a do\
h(t,(self.width+1)*e,{\"\",self.textColor,self.textColour})\
end\
self.width=self.width+1\
end\
while self.width>e do\
for e=1,e do\
s(t,self.width*e)\
end\
self.width=self.width-1\
end\
end\
function Canvas:setHeight(t)\
if not self.buffer then self.height=t return end\
local a,e,o=self.width,self.buffer,self.height\
while self.height<t do\
for t=1,a do\
e[#e+1]=px\
end\
self.height=self.height+1\
end\
while self.height>t do\
for t=1,a do\
s(e,#e)\
end\
self.height=self.height-1\
end\
end",
  [ "Stage.lua" ] = "local e=table.insert\
local n=string.sub\
local o=true\
class\"Stage\"mixin\"MTemplateHolder\"alias\"COLOUR_REDIRECT\"{\
X=1;\
Y=1;\
width=10;\
height=6;\
borderless=false;\
canvas=nil;\
application=nil;\
scenes={};\
activeScene=nil;\
name=nil;\
textColour=32768;\
backgroundColour=1;\
shadow=true;\
shadowColour=colours.grey;\
focused=false;\
closeButton=true;\
closeButtonTextColour=1;\
closeButtonBackgroundColour=colours.red;\
titleBackgroundColour=128;\
titleTextColour=1;\
activeTitleBackgroundColour=colours.lightBlue;\
activeTitleTextColour=1;\
controller={};\
mouseMode=nil;\
visible=true;\
resizable=true;\
movable=true;\
closeable=true;\
}\
function Stage:initialise(...)\
local o,a,i,t,e=ParseClassArguments(self,{...},{{\"name\",\"string\"},{\"X\",\"number\"},{\"Y\",\"number\"},{\"width\",\"number\"},{\"height\",\"number\"}},true,true)\
self.X=a\
self.Y=i\
self.name=o\
self.canvas=StageCanvas({width=t;height=e;textColour=self.textColour;backgroundColour=self.backgroundColour,stage=self})\
self.width=t\
self.height=e\
self:__overrideMetaMethod(\"__add\",function(t,e)\
if classLib.typeOf(t,\"Stage\",true)then\
if classLib.typeOf(e,\"Scene\",true)then\
return self:addScene(e)\
else\
error(\"Invalid right hand assignment. Should be instance of Scene \"..tostring(e))\
end\
else\
error(\"Invalid left hand assignment. Should be instance of Stage. \"..tostring(t))\
end\
end)\
self:updateCanvasSize()\
self.mouseMode=false\
end\
function Stage:updateCanvasSize()\
if not self.canvas then return end\
local e=0\
if self.shadow and self.focused then e=1 end\
self.canvas.width=self.width+e\
self.canvas.height=self.height+e+(not self.borderless and 1 or 0)\
self.canvas:clear()\
end\
function Stage:setShadow(e)\
self.shadow=e\
self:updateCanvasSize()\
end\
function Stage:setBorderless(e)\
self.borderless=e\
self:updateCanvasSize()\
end\
function Stage:setHeight(e)\
local t=self.maxHeight\
local a=self.minHeight\
e=t and e>t and t or e\
e=a and e<a and a or e\
self.height=e>0 and e or 1\
self:updateCanvasSize()\
end\
function Stage:setWidth(e)\
local a=self.maxWidth\
local t=self.minWidth\
e=a and e>a and a or e\
e=t and e<t and t or e\
self.width=e>0 and e or 1\
self:updateCanvasSize()\
end\
function Stage:setApplication(e)\
AssertClass(e,\"Application\",true,\"Stage requires Application Instance as its application. Not '\"..tostring(e)..\"'\")\
self.application=e\
end\
function Stage:draw(e)\
if not self.visible then return end\
local a=self.changed\
local t=e or self.forceRedraw\
local e=self.mouseMode\
if t then\
self.canvas:clear()\
self.canvas:redrawFrame()\
self.forceRedraw=false\
end\
local i=self.canvas\
if(a or t)and(o and not e or not o)then\
local e=self.nodes\
for o=#e,1,-1 do\
local e=e[o]\
if a and e.changed or t then\
e:draw(0,0,t)\
e.canvas:drawToCanvas(i,e.X,e.Y)\
e.changed=false\
end\
end\
self.changed=false\
end\
self.canvas:drawToCanvas(self.application.canvas,self.X,self.Y)\
end\
function Stage:appDrawComplete()\
if self.currentKeyboardFocus and self.focused then\
local o,a,e,t=self.currentKeyboardFocus:getCursorInformation()\
if not o then return end\
term.setTextColour(t)\
term.setCursorPos(a,e)\
term.setCursorBlink(true)\
end\
end\
function Stage:hitTest(e,t)\
return InArea(e,t,self.X,self.Y,self.X+self.width-1,self.Y+self.height-(self.borderless and 1 or 0))\
end\
function Stage:isPixel(t,e)\
local a=self.canvas\
if self.shadow then\
if self.focused then\
return not(t==self.width+1 and e==1)or(t==1 and e==self.height+(self.borderless and 0 or 1)+1)\
else\
return not(t==self.width+1)or(e==self.height+(self.borderless and 0 or 1)+1)\
end\
elseif not self.shadow then return true end\
return false\
end\
function Stage:submitEvent(e)\
local i=self.nodes\
local a=e.main\
local t,o\
if a==\"MOUSE\"then\
t,o=e.X,e.Y\
e:convertToRelative(self)\
if not self.borderless then\
e.Y=e.Y-1\
end\
end\
for t=1,#i do\
i[t]:handleEvent(e)\
end\
if a==\"MOUSE\"then\
e.X,e.Y=t,o\
end\
end\
function Stage:move(e,t)\
self:removeFromMap()\
self.X=e\
self.Y=t\
self:map()\
self.application.changed=true\
end\
function Stage:resize(e,t)\
self:removeFromMap()\
self.width=e\
self.height=t\
self.canvas:redrawFrame()\
self:map()\
self.forceRedraw=true\
self.application.changed=true\
end\
function Stage:focus()\
if self.focused then return end\
self.application:requestStageFocus(self)\
end\
function Stage:close()\
self:removeFromMap()\
self.application:removeStage(self)\
end\
function Stage:handleEvent(e)\
if e.handled then return end\
local o=self.borderless and 0 or 1\
if e.main==\"MOUSE\"then\
if e.sub==\"CLICK\"then\
if e:inArea(self.X,self.Y,self.X+self.width-1,self.Y+self.height-(self.borderless and 1 or 0))then\
local t,a=e:getRelative(self)\
self:focus()\
if a==1 then\
if t==self.width then\
return self:close()\
else\
self.mouseMode=\"move\"\
self.lastX,self.lastY=e.X,e.Y\
return\
end\
elseif a==self.height+o and t==self.width then\
self.mouseMode=\"resize\"\
return\
end\
end\
elseif e.sub==\"UP\"and self.mouseMode then\
self.mouseMode=false\
return\
elseif e.sub==\"DRAG\"and self.mouseMode then\
if self.mouseMode==\"move\"then\
self:move(self.X+(e.X-self.lastX),self.Y+(e.Y-self.lastY))\
self.lastMouseEvent=os.clock()\
self.lastX,self.lastY=e.X,e.Y\
elseif self.mouseMode==\"resize\"then\
self:resize(e.X-self.X+1,e.Y-self.Y+(self.borderless and 1 or 0))\
self.lastMouseEvent=os.clock()\
end\
end\
self:submitEvent(e)\
else self:submitEvent(e)end\
end\
function Stage:setMouseMode(e)\
self.mouseMode=e\
self.canvas:redrawFrame()\
end\
function Stage:mapNode(e,e,e,e)\
end\
function Stage:map()\
local e=self.canvas\
self.application:mapWindow(self.X,self.Y,self.X+e.width-1,self.Y+e.height-1)\
end\
function Stage:removeFromMap()\
local e=self.visible\
self.visible=false\
self:map()\
self.visible=e\
end\
function Stage:removeKeyboardFocus(t)\
local e=self.currentKeyboardFocus\
if e and e==t then\
if e.onFocusLost then e:onFocusLost(self,node)end\
self.currentKeyboardFocus=false\
end\
end\
function Stage:redirectKeyboardFocus(e)\
self:removeKeyboardFocus(self.currentKeyboardFocus)\
self.currentKeyboardFocus=e\
if e.onFocusGain then self.currentKeyboardFocus:onFocusGain(self)end\
end\
function Stage:addToController(e,t)\
if type(e)~=\"string\"or type(t)~=\"function\"then\
return error(\"Expected string, function\")\
end\
self.controller[e]=t\
end\
function Stage:removeFromController(e)\
self.controller[e]=nil\
end\
function Stage:getCallback(e)\
return self.controller[n(e,2)]\
end\
function Stage:executeCallback(e,...)\
local t=self:getCallback(e)\
if t then return t(...)else\
return error(\"Failed to find callback \"..tostring(n(e,2))..\" on controller (node.stage): \"..tostring(self))\
end\
end\
function Stage:onFocus()\
self.forceRedraw=true\
self.focused=true\
self.changed=true\
self:removeFromMap()\
self:updateCanvasSize()\
self:map()\
self.canvas:updateFilter()\
self.canvas:redrawFrame()\
end\
function Stage:onBlur()\
self.forceRedraw=true\
self.focused=false\
self.changed=true\
self:removeFromMap()\
self:updateCanvasSize()\
self:map()\
self.canvas:updateFilter()\
self.canvas:redrawFrame()\
end\
function Stage:setChanged(e)\
self.changed=e\
if e then self.application.changed=true end\
end",
  [ "Event.lua" ] = "class\"Event\"{\
raw=nil;\
handled=false;\
__event=true;\
}\
function Event:isType(e,t)\
if e==self.main and t==self.sub then\
return true\
end\
return false\
end",
  [ "Daemon.lua" ] = "class\"Daemon\"abstract(){\
acceptMouse=false;\
acceptMisc=false;\
acceptKeyboard=false;\
owner=nil;\
__daemon=true;\
}\
function Daemon:initialise(e)\
if not e then return error(\"Daemon '\"..self:type()..\"' cannot initialise without name\")end\
self.name=e\
end\
function Daemon:start()log(\"d\",\"WARNING: Daemon '\"..self.name..\"' (\"..self:type()..\") has no start function declared\")end\
function Daemon:stop()log(\"d\",\"WARNING: Daemon '\"..self.name..\"' (\"..self:type()..\") has no end function declared\")end",
  [ "LuaVMException.lua" ] = "class\"LuaVMException\"extends\"ExceptionBase\"{\
title=\"Virtual Machine Exception\";\
subTitle=\"This exception has been raised because the Lua VM has crashed.\\nThis is usually caused by errors like 'attempt to index nil', or 'attempt to perform __add on nil and number' etc...\";\
useMessageAsRaw=true;\
}",
  [ "ParameterException.lua" ] = "class\"ParameterException\"extends\"ExceptionBase\"{\
title=\"DynaCode Parameter Exception\";\
subTitle=\"This exception was caused because a parameter was not available or was invalid. This problem likely occurred at runtime.\";\
}",
  [ "NodeCanvas.lua" ] = "local o,h=string.len,string.sub\
class\"NodeCanvas\"extends\"Canvas\"{\
node=nil;\
}\
function NodeCanvas:initialise(...)\
local e,a,t=ParseClassArguments(self,{...},{{\"node\",\"table\"},{\"width\",\"number\"},{\"height\",\"number\"}},true,true)\
if not classLib.isInstance(e)then\
return error(\"Node argument (first unordered) is not a class instance! Should be a node class instance. '\"..tostring(e)..\"'\")\
elseif not e.__node then\
return error(\"Node argument (first unordered) is an invalid class instance. '\"..tostring(e)..\"'\")\
end\
self.node=e\
self.super(a,t)\
end\
function NodeCanvas:drawToCanvas(e,o,i)\
local w=self.buffer\
local t=self.node.stage\
local a=self.node.parent and true or false\
local l=t.borderless and not a and 2 or 1\
local o=type(o)==\"number\"and o-1 or 0\
local n=type(i)==\"number\"and i-(not a and l or 2)or 0\
local r=self.width\
local p=self.height\
local i=(t.shadow and not a and 1)or 0\
local y=e.height-i\
local f=e.width-i\
local h,d,u,s,t\
local m=n+(a and 2 or l)\
local c=n+i\
local l,i=self.node.textColour,self.node.backgroundColour\
for a=0,p do\
h=r*a\
d=e.width*(a+n+1)\
if a+m>0 and a+c<y then\
for a=1,r do\
if a+o>0 and a+o-1<f then\
u=h+a\
s=d+(a+o)\
t=w[u]\
if t then\
e.buffer[s]={t[1]or\" \",t[2]or l,t[3]or i}\
else\
e.buffer[s]={\" \",l,i}\
end\
end\
end\
end\
end\
end\
function NodeCanvas:drawArea(e,t,a,o,i,n)\
for t=t,(t+o-1)do\
local t=self.width*(t-1)\
for e=e,(e+a-1)do\
self.buffer[t+e]={\" \",i,n}\
end\
end\
end\
function NodeCanvas:drawTextLine(t,a,r,n,i,e,s)\
if e and s then t=OverflowText(t,e)end\
local s=self.width*(r-1)\
for e=1,e or o(t)do\
if a+e+1<0 or a+e-1>self.width then return end\
local t=h(t,e,e)\
self.buffer[s+e+a-1]={t~=\"\"and t or\" \",n,i}\
end\
end\
function NodeCanvas:drawXCenteredTextLine(e,e,e,e,e)\
end\
function NodeCanvas:drawYCenteredTextLine(e,e,e,e,e)\
end\
function NodeCanvas:drawCenteredTextLine(e,e,e,e)\
end\
function NodeCanvas:wrapText(n,s)\
if type(n)~=\"string\"or type(s)~=\"number\"then\
return error(\"Expected string, number\")\
end\
local e={}\
local t=1\
local a=1\
local i=true\
local function r()\
e[t]=TextHelper.whitespaceTrim(e[t])\
t=t+1\
a=1\
end\
while o(n)>0 do\
local i=string.match(n,\"^[ \\t]+\")\
if i then\
for o=1,o(i)do\
e[t]=not e[t]and h(i,o,o)or e[t]..h(i,o,o)\
a=a+1\
if a>s then r()end\
end\
n=h(n,o(i)+1)\
end\
local i=string.match(n,\"^[^ \\t\\n]+\")\
if i then\
if o(i)>s then\
local n\
for o=1,o(i)do\
e[t]=not e[t]and\"\"or e[t]\
n=e[t]\
e[t]=n..h(i,o,o)\
a=a+1\
if a>s then r()end\
end\
elseif o(i)<=s then\
if o(i)+a-1>s then r()end\
local o=e[t]\
e[t]=o and o..i or i\
a=a+#i\
if a>s then r()end\
end\
n=h(n,o(i)+1)\
else return e end\
end\
return e\
end\
function NodeCanvas:drawWrappedText(u,t,l,a,e,n,i,r,d)\
if type(e)~=\"table\"then\
return error(\"drawWrappedText: text argument (5th) must be a table of lines\")\
end\
local s,h\
if n then\
if n==\"top\"then\
h=0\
elseif n==\"center\"then\
h=(a/2)-(#e/2)+1\
elseif n==\"bottom\"then\
h=math.floor(a-#e)\
else return error(\"Unknown vAlign mode\")end\
else return error(\"Unknown vAlign mode\")end\
self:drawArea(u,t,l,a,d,r)\
if a<#e then\
self:drawTextLine(\"...\",1,1,d,r)\
return\
end\
for a=1,#e do\
local e=e[a]\
if i then\
if i==\"left\"then\
s=1\
elseif i==\"center\"then\
s=math.ceil((l/2)-(o(e)/2)+.5)\
elseif i==\"right\"then\
s=math.floor(l-o(e))\
else return error(\"Unknown hAlign mode\")end\
else return error(\"Unknown hAlign mode\")end\
local a=math.ceil(h+a-.5)\
if t+a-2>=t then\
self:drawTextLine(e,s+u-1,a+t-2,d,r)\
end\
end\
end",
  [ "MyDaemon.lua" ] = "class\"MyDaemon\"extends\"Daemon\"\
function MyDaemon:start()\
local e=self.owner.event\
e:registerEventHandler(\"Terminate\",\"TERMINATE\",\"EVENT\",function()\
error(\"DaemonService '\"..self:type()..\"' named: '\"..self.name..\"' detected terminate event\",0)\
end)\
e:registerEventHandler(\"ContextMenuHandler\",\"MOUSE\",\"CLICK\",function(t,e)\
if e.misc==2 then\
log(\"di\",\"context popup\")\
end\
end)\
self.owner.timer:setTimer(\"MyDaemonTimer\",2,function(e,e)\
para.text=[[\
@align-center+tc-grey Hello my good man!\
\
@tc-lightGrey I see you have found out how to use daemons and timers. You also seem to have un-commented the block of code that makes me appear.\
\
Want to know how I do it? Head over to @tc-blue  src/Classes/Daemon/MyDaemon.lua @tc-lightGrey  to see the source code of... me!\
]]\
end)\
end\
function MyDaemon:stop(e)\
log(e and\"di\"or\"de\",\"MyDaemon detected application close. \"..(e and\"graceful\"or\"not graceful\")..\".\")\
local e=self.owner.event\
e:removeEventHandler(\"TERMINATE\",\"EVENT\",\"Terminate\")\
end",
  [ "MNodeManager.lua" ] = "class\"MNodeManager\"abstract(){\
nodes={};\
}\
function MNodeManager:addNode(e)\
e.parent=self\
e.stage=self.stage\
table.insert(self.nodes,e)\
return e\
end\
function MNodeManager:removeNode(a)\
local o=type(a)==\"string\"\
local e=self.nodes\
local t\
for i=1,#e do\
t=e[i]\
if(o and t.name==a)or(not o and t==a)then\
table.remove(e,i)\
return true\
end\
end\
return false\
end\
function MNodeManager:getNode(a)\
local t=self.nodes\
local e\
for o=1,#t do\
e=t[o]\
if e.name==a then\
return e\
end\
end\
return false\
end\
function MNodeManager:clearNodes()\
for e=#self.nodes,1,-1 do\
self:removeNode(self.nodes[e])\
end\
end\
function MNodeManager:appendFromDCML(e)\
local e=DCML.parse(DCML.readFile(e))\
if e then for t=1,#e do\
self:addNode(e[t])\
end end\
end\
function MNodeManager:replaceWithDCML(e)\
self:clearNodes()\
self:appendFromDCML(e)\
end",
  [ "ExceptionBase.lua" ] = "local e\
class\"ExceptionBase\"abstract(){\
exceptionOffset=1;\
levelOffset=1;\
title=\"UNKNOWN_EXCEPTION\";\
subTitle=false;\
message=nil;\
level=1;\
raw=nil;\
useMessageAsRaw=false;\
stacktrace=\"\\nNo stacktrace has been generated\\n\"\
}\
function ExceptionBase:initialise(e,t,a)\
if t then self.level=t end\
self.level=self.level~=0 and(self.level+(self.exceptionOffset*3)+self.levelOffset)or self.level\
self.message=e or\"No error message provided\"\
if self.useMessageAsRaw then\
self.raw=e\
else\
local a,t=pcall(exceptionHook.getRawError(),e,self.level==0 and 0 or self.level+1)\
self.raw=t or e\
end\
self:generateStack(self.level==0 and 0 or self.level+4)\
self:generateDisplayName()\
if not a then\
exceptionHook.throwSystemException(self)\
end\
end\
function ExceptionBase:generateDisplayName()\
local e=self.raw\
local a=self.title\
local n,t,o,i=e:find(\"(%w+%.?.-):(%d+).-[%s*]?[:*]?\")\
if not t then self.displayName=a..\" (?): \"..e return end\
self.displayName=a..\" (\"..(o or\"?\")..\":\"..(i or\"?\")..\"):\"..tostring(e:sub(t+1))\
end\
function ExceptionBase:generateStack(t)\
local o=exceptionHook.getRawError()\
if t==0 then\
log(\"w\",\"Cannot generate stacktrace for exception '\"..tostring(self)..\"'. Its level is zero\")\
return\
end\
local e=\"\\n'\"..tostring(self.title)..\"' details\\n##########\\n\\nError: \\n\"..self.message..\" (Level: \"..self.level..\", pcall: \"..tostring(self.raw)..\")\\n##########\\n\\nStacktrace: \\n\"\
local a=t\
local t=self.message\
while true do\
local o,t=pcall(o,t,a)\
if t:find(\"bios[%.lua]?.-:\")or t:find(\"shell.-:\")or t:find(\"xpcall.-:\")then\
e=e..\"-- End --\\n\"\
break\
end\
local o,t=t:match(\"(%w+%.?.-):(%d+).-\")\
e=e..\"> \"..(o or\"?\")..\":\"..(t or\"?\")..\"\\n\"\
a=a+1\
end\
if self.subTitle then\
e=e..\"\\n\"..self.subTitle\
end\
self.stacktrace=e\
end",
  [ "Node.lua" ] = "class\"Node\"abstract()alias\"COLOUR_REDIRECT\"{\
X=1;\
Y=1;\
width=0;\
height=0;\
visible=true;\
enabled=true;\
changed=true;\
stage=nil;\
canvas=nil;\
__node=true;\
acceptMisc=false;\
acceptKeyboard=false;\
acceptMouse=false;\
manuallyHandle=false;\
}\
function Node:initialise(...)\
local o,a,t,e=ParseClassArguments(self,{...},{{\"X\",\"number\"},{\"Y\",\"number\"},{\"width\",\"number\"},{\"height\",\"number\"}},false,true)\
self.canvas=NodeCanvas(self,t or 1,e and(e-1)or 0)\
self.X=o\
self.Y=a\
self.width=t or 1\
self.height=e or 1\
end\
function Node:draw(e,t)\
if self.preDraw then\
self:preDraw(e,t)\
end\
if self.postDraw then\
self:postDraw(e,t)\
end\
end\
function Node:setX(e)\
self.X=e\
end\
function Node:setY(e)\
self.Y=e\
end\
function Node:setWidth(e)\
self.width=e\
end\
function Node:setHeight(e)\
self.height=e\
end\
function Node:setBackgroundColour(e)\
self.backgroundColour=e\
end\
function Node:setTextColour(e)\
self.textColour=e\
end\
function Node:onParentChanged()\
self.changed=true\
end\
local function t(e,t,...)\
if type(e[t])==\"function\"then\
e[t](e,...)\
end\
end\
local a={\
CLICK=\"onMouseDown\";\
UP=\"onMouseUp\";\
SCROLL=\"onMouseScroll\";\
DRAG=\"onMouseDrag\";\
}\
function Node:handleEvent(e)\
if e.handled then return end\
if not self.manuallyHandle then\
if e.main==\"MOUSE\"and self.acceptMouse then\
if e.inParentBounds or self.ignoreEventParentBounds then\
if e:inArea(self.X,self.Y,self.X+self.width-1,self.Y+self.height-1)then\
t(self,a[e.sub]or error(\"No click matrix entry for \"..tostring(e.sub)),e)\
else\
t(self,\"onMouseMiss\",e)\
end\
else\
t(self,\"onMouseMiss\",e)\
end\
elseif e.main==\"KEY\"and self.acceptKeyboard then\
t(self,e.sub==\"UP\"and\"onKeyUp\"or\"onKeyDown\",e)\
elseif e.main==\"CHAR\"and self.acceptKeyboard then\
t(self,\"onChar\",e)\
elseif self.acceptMisc then\
t(self,\"onUnknownEvent\",e)\
end\
t(self,\"onAnyEvent\",e)\
else\
t(self,\"onEvent\",e)\
end\
end\
function Node:setChanged(e)\
self.changed=e\
if e then\
local e=self.parent or self.stage\
if e then\
e.changed=true\
end\
end\
end\
function Node:getTotalOffset()\
local e,t=0,0\
if self.parent then\
local a,o=self.parent:getTotalOffset()\
e=e+a-1\
t=t+o-1\
elseif self.stage then\
e=e+self.stage.X\
t=t+self.stage.Y\
end\
e=e+self.X\
t=t+self.Y\
return e,t\
end\
function Node.generateNodeCallback(e,t,a)\
return(function(...)\
local t=e.stage\
if not t then\
return error(\"Cannot link to node '\"..e:type()..\"' stage.\")\
end\
t:executeCallback(a,...)\
end)\
end",
  [ "DCMLParser.lua" ] = "local h=string.sub\
local function l(l)\
function parseargs(t)\
local e={}\
string.gsub(t,\"([%-%w]+)=([\\\"'])(.-)%2\",function(t,o,a)\
e[t]=a\
end)\
return e\
end\
function collect(s)\
local e={}\
local t={}\
table.insert(e,t)\
local o,h,a,n,r\
local i,d=1,1\
while true do\
o,d,h,a,n,r=string.find(s,\"<(%/?)([%w:]+)(.-)(%/?)>\",i)\
if not o then break end\
local o=string.sub(s,i,o-1)\
if not string.find(o,\"^%s*$\")then\
t[\"content\"]=o\
end\
if r==\"/\"then\
table.insert(t,{label=a,xarg=parseargs(n),empty=1})\
elseif h==\"\"then\
t={label=a,xarg=parseargs(n)}\
table.insert(e,t)\
else\
local o=table.remove(e)\
t=e[#e]\
if#e<1 then\
error(\"nothing to close with \"..a)\
end\
if o.label~=a then\
error(\"trying to close \"..o.label..\" with \"..a)\
end\
if#e>1 then\
if type(t.content)~=\"table\"then\
t.content={}\
end\
t.content[#t.content+1]=o\
t.hasChildren=true\
else\
table.insert(t,o)\
end\
end\
i=d+1\
end\
local t=string.sub(s,i)\
if not string.find(t,\"^%s*$\")then\
table.insert(e[#e],t)\
end\
if#e>1 then\
error(\"unclosed \"..e[#e].label)\
end\
return e[1]\
end\
return collect(l)\
end\
local o={}\
local i={}\
function i.registerTag(e,t)\
if type(e)~=\"string\"or type(t)~=\"table\"then return error(\"Expected string, table\")end\
o[e]=t\
end\
function i.removeTag(e)\
o[e]=nil\
end\
function i.setMatrix(e)\
if type(e)~=\"table\"then\
return error(\"Expected table\")\
end\
end\
function i.loadFile(e)\
if not fs.exists(e)then\
return error(\"Cannot load DCML content from path '\"..tostring(e)..\"' because the file doesn't exist\")\
elseif fs.isDir(e)then\
return error(\"Cannot load DCML content from path '\"..tostring(e)..\"' because the path is a directory\")\
end\
local e=fs.open(e,\"r\")\
local t=e.readAll()\
e.close()\
return l(t)\
end\
local function n(t,e)\
if type(e)==\"function\"then\
return e\
elseif type(e)==\"string\"and h(e,1,1)==\"#\"then\
if not t then\
return false\
else\
local e=t[h(e,2)]\
if type(e)==\"function\"then\
return e\
end\
end\
end\
end\
local function r(o,e,t,a)\
if type(a.argumentType)~=\"table\"then a.argumentType={}end\
t=o and o[t]or t\
local t=a.argumentType[t]\
local o=type(e)\
local a\
if o==t or not t then\
a=e\
else\
if t==\"string\"then\
a=tostring(e)\
elseif t==\"number\"then\
local t=tonumber(e)\
if not t then\
return error(\"Failed to convert '\"..tostring(e)..\"' from type '\"..o..\"' to number when parsing DCML\")\
end\
a=t\
elseif t==\"boolean\"then\
a=e:lower()==\"true\"\
elseif t==\"color\"or t==\"colour\"then\
local t=colours[e]or colors[e]\
if not t then\
return error(\"Failed to convert '\"..tostring(e)..\"' from type '\"..o..\"' to colour when parsing DCML\")\
end\
a=t\
else\
return error(\"Cannot parse type '\"..tostring(t)..\"' using DCML\")\
end\
end\
return a\
end\
local s={}\
function i.parse(e)\
local h={}\
for t=1,#e do\
local a=e[t]\
local t=a.label\
local e=o[t]\
if type(e)~=\"table\"then\
return error(\"No DCMLMatrix for tag with label '\"..tostring(t)..\"'\")\
end\
local i=n(false,e.customHandler)\
if i then\
table.insert(h,i(a,o))\
else\
local i={}\
local o=e.aliasHandler\
if type(o)==\"table\"then\
i=o\
elseif type(o)==\"function\"then\
i=o()\
elseif o==true then\
if not s[t]then\
log(\"i\",\"DCMLMatrix for \"..t..\" has instructed that DCML parsing should alias with the class '\"..t..\"'.__alias\")\
local e=classLib.getClass(t)\
if not e then\
error(\"Failed to fetch class for '\"..t..\"' while fetching alias information\")\
end\
s[t]=e.__alias\
end\
i=s[t]\
end\
local s={}\
local o=n(false,e.argumentHandler)\
if o then\
s=o(a)\
else\
local o=e.callbacks or{}\
for t,a in pairs(a.xarg)do\
if not o[t]then\
s[t]=r(i,a,t,e)\
end\
end\
if a.content and not a.hasChildren and e.contentCanBe then\
s[e.contentCanBe]=r(i,a.content,e.contentCanBe,e)\
end\
end\
local i=n(false,e.instanceHandler)or classLib.getClass(t)\
local o\
if i then\
o=i(s)\
end\
if not o then\
return error(\"Failed to generate instance for DCML tag '\"..t..\"'\")\
end\
if a.hasChildren and e.childHandler then\
local e=n(o,e.childHandler)\
if e then\
e(o,a)\
end\
end\
local i=n(o,e.callbackGenerator)\
if i and type(e.callbacks)==\"table\"then\
for e,t in pairs(e.callbacks)do\
if a.xarg[e]then\
o[t]=i(o,e,a.xarg[e])\
end\
end\
elseif e.callbacks then\
log(\"w\",\"Couldn't generate callbacks for '\"..t..\"' during DCML parse. Callback generator not defined\")\
end\
if e.onDCMLParseComplete then\
e.onDCMLParseComplete(o)\
end\
table.insert(h,o)\
end\
end\
return h\
end\
_G.DCML=i",
  [ "ClassUtil.lua" ] = "local s=table.insert\
local o,r,d=string.len,string.sub,string.rep\
function ParseClassArguments(i,t,e,o,d)\
local t=t\
_G.ARGS=t\
local n={}\
local function r(a,t)\
if type(e)~=\"table\"then return end\
local e=n[a]\
if e and type(t)~=e then\
if not classLib.typeOf(t,e,true)then\
_G.parseError={a,t}\
return ParameterException(\"Expected type '\"..e..\"' for argument '\"..a..\"', got '\"..type(t)..\"' instead while initialising '\"..tostring(i)..\"'.\",4)\
end\
end\
return t\
end\
local a={}\
if type(e)==\"table\"and o then\
for t,e in ipairs(e)do\
a[e[1]]=true\
end\
end\
local h={}\
if type(e)==\"table\"then\
for t,e in ipairs(e)do\
s(h,e[1])\
n[e[1]]=e[2]\
end\
end\
local o={}\
if#t==1 and type(t[1])==\"table\"then\
for e,t in pairs(t[1])do\
o[e]=r(e,t)\
a[e]=nil\
end\
else\
for t,n in ipairs(t)do\
local e=h[t]\
if not e then\
return error(\"Instance '\"..i:type()..\"' only supports a max of \"..(t-1)..\" unordered arguments. Consider using a key-pair table instead, check the wiki page for this class to find out more.\")\
end\
o[e]=r(e,n)\
a[e]=nil\
end\
end\
if next(a)then\
local t=\"Instance '\"..i:type()..\"' requires arguments:\\n\"\
for o,e in ipairs(e)do\
if a[e[1]]then\
t=t..\"- \"..e[1]..\" (\"..e[2]..\")\\n\"\
end\
end\
t=t..\"These arguments have not been defined.\"\
return error(t)\
end\
for e,t in pairs(o)do\
if(n[e]and not d)or not n[e]then\
print(\"Setting \"..e)\
i[e]=t\
end\
end\
local t={}\
if type(e)==\"table\"and d then\
for a,e in ipairs(e)do\
s(t,o[e[1]])\
end\
return unpack(t)\
end\
end\
function AssertClass(e,o,a,t)\
if not classLib.typeOf(e,o,a)then\
return error(t,2)\
end\
return e\
end\
function AssertEnum(t,a,i)\
local e\
for o=1,#a do\
if a[o]==t then\
e=true\
break\
end\
end\
if e then\
return t\
else\
return error(i,2)\
end\
end\
_G.COLOUR_REDIRECT={\
textColor=\"textColour\";\
backgroundColor=\"backgroundColour\";\
disabledTextColor=\"disabledTextColour\";\
disabledBackgroundColor=\"disabledBackgroundColour\"\
}\
_G.ACTIVATABLE={\
activeTextColor=\"activeTextColour\";\
activeBackgroundColor=\"activeBackgroundColour\"\
}\
_G.SELECTABLE={\
selectedTextColor=\"selectedTextColour\";\
selectedBackgroundColor=\"selectedBackgroundColour\"\
}\
function OverflowText(e,a)\
if o(e)>a then\
local t=o(e)-a\
if t>3 then\
if o(e)-t-3>=1 then\
e=r(e,1,o(e)-t-3)..\"...\"\
else e=d(\".\",a)end\
else\
e=r(e,1,o(e)-t*2)..d(\".\",t)\
end\
end\
return e\
end\
function InArea(t,e,a,o,i,n)\
if t>=a and t<=i and e>=o and e<=n then\
return true\
end\
return false\
end",
  [ "Exception.lua" ] = "class\"Exception\"extends\"ExceptionBase\"{\
title=\"DynaCode Exception\";\
}",
}
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
    classLib.runClassString( files[ name ], name, ignoreFile )
    loaded[ name ] = true
end

classLib.setClassLoader( function( _c )
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
