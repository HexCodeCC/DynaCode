--[[
    DynaCode Build

    The following document was created via a makefile. The 'files' table
    contains minified versions of every file for DynaCode's default source.

    To view the un-minified code please visit GitHub (HexCodeCC/DynaCode)
]]

local files = {
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
local e,t,i,o,a=ParseClassArguments(self,{...},{{\"text\",\"string\"},{\"X\",\"number\"},{\"Y\",\"number\"},{\"width\",\"number\"},{\"height\",\"number\"}},true,true)\
self.super(t,i,o,a)\
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
end\
function Button:onMouseDrag(e)\
if self.focused then\
self.active=true\
end\
end\
function Button:onMouseMiss(e)\
if self.focused and e.sub==\"DRAG\"then\
self.active=false\
elseif e.sub==\"UP\"and(self.focused or self.active)then\
self.active=false\
self.focused=false\
end\
end\
function Button:onMouseUp(e)\
if self.active then\
if self.onTrigger then self:onTrigger(e)end\
self.active=false\
self.focused=false\
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
if class.typeOf(t,\"Panel\",true)then\
if class.isInstance(e)and e.__node then\
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
verticalScroll=0;\
horizontalScroll=0;\
verticalPadding=0;\
horizontalPadding=0;\
currentScrollbar=false;\
}\
function NodeScrollContainer:calculateDisplaySize(a,o)\
local e,t=self.width,self.height\
return(o and e-1 or e),(a and t-1 or t)\
end\
function NodeScrollContainer:calculateContentSize()\
local a,t=0,0\
local e=self.nodes\
for o=1,#e do\
local e=e[o]\
local o,e=e.X+e.width-1,e.Y+e.height-1\
t=o>t and o or t\
a=e>a and e or a\
end\
return t,a\
end\
function NodeScrollContainer:getScrollPositions(h,n,e,t,i,s)\
local a,o=math.floor(self.horizontalScroll/h*e-.5),math.ceil(self.verticalScroll/n*t+.5)\
if a+i-1>=e or self.horizontalScroll==h then\
if self.horizontalScroll==h-e then a=e-i+1 else a=e-i end\
end\
if o+s-1>=t or self.verticalScroll==n then\
if self.verticalScroll==n-t then o=t-s+1 else o=t-s end\
end\
return a,o\
end\
function NodeScrollContainer:getScrollSizes(e,t,a,o)\
return math.ceil(a/e*self.width-.5),math.ceil(o/t*self.height-.5)\
end\
function NodeScrollContainer:addNode(e)\
self.super:addNode(e)\
end\
function NodeScrollContainer:removeNode(e)\
self.super:removeNode(e)\
end\
function NodeScrollContainer:inView(e)\
local e,t,n,i=e.X,e.Y,e.width,e.height\
local o,a=self.horizontalScroll,self.verticalScroll\
return e+n-o>0 and e-o<self.width and t-a<self.height and t+i-a>0\
end\
local e={\
CLICK=\"onMouseDown\";\
UP=\"onMouseUp\";\
SCROLL=\"onMouseScroll\";\
DRAG=\"onMouseDrag\";\
}\
function NodeScrollContainer:onAnyEvent(e)\
local i,o=e.X,e.Y\
local a=e.main==\"MOUSE\"\
local t=self.nodes\
if a then\
e:convertToRelative(self)\
e.Y=e.Y+self.verticalScroll\
e.X=e.X+self.horizontalScroll\
end\
for a=1,#t do\
t[a]:handleEvent(e)\
end\
if a then\
e.X=i\
e.Y=o\
end\
end\
function NodeScrollContainer:onMouseScroll(e)\
local i,o=self:calculateContentSize()\
local a,t=self:getActiveScrollbars(i,o)\
local s,n=self:calculateDisplaySize(a,t)\
if t then\
self.verticalScroll=math.max(math.min(self.verticalScroll+e.misc,o-n),0)\
self.forceRedraw=true\
self.changed=true\
elseif a then\
self.horizontalScroll=math.max(math.min(self.horizontalScroll+e.misc,i-s),0)\
self.forceRedraw=true\
self.changed=true\
end\
end\
function NodeScrollContainer:getActiveScrollbars(e,t)\
return e>self.width,t>self.height\
end\
function NodeScrollContainer:draw(t,a,o)\
log(\"w\",\"Scroll Container Drawn. Force: \"..tostring(o))\
local e=self.nodes\
local n=o or self.forceRedraw\
local h=self.canvas\
h:clear()\
local a,i=t or 0,a or 0\
if self.preDraw then\
self:preDraw(a,i)\
end\
local r,s=-self.horizontalScroll,-self.verticalScroll\
local t\
for a=#e,1,-1 do\
local e=e[a]\
t=e.changed\
if self:inView(e)and t or n then\
e:draw(r,s,n or o)\
e.canvas:drawToCanvas(h,e.X+r,e.Y+s)\
if t then e.changed=false end\
end\
end\
self.forceRedraw=false\
if self.postDraw then\
self:postDraw(a,i)\
end\
self.changed=false\
self.canvas:drawToCanvas((self.parent or self.stage).canvas,self.X+a,self.Y+i)\
end\
function NodeScrollContainer:postDraw()\
local n,e=self:calculateContentSize()\
local a,t=self:getActiveScrollbars(n,e)\
if a or t then\
local i,o=self:calculateDisplaySize(a,t)\
local s,h=self:getScrollSizes(n,e,i,o)\
local l,d=self:getScrollPositions(n,e,i,o,s,h)\
local e=self.canvas\
local r=a and t\
local n=r and 1 or 0\
if a then\
e:drawArea(1,self.height,i,1,colours.red,colours.green)\
e:drawArea(l,self.height,s-n,1,colours.black,colours.grey)\
end\
if t then\
e:drawArea(self.width,1,1,o,colours.red,colours.green)\
e:drawArea(self.width,d,1,h-n,colours.black,colours.grey)\
end\
if r then e:drawArea(self.width,self.height,1,1,colours.lightGrey,colours.lightGrey)end\
end\
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
  [ "NodeContainer.lua" ] = "class\"NodeContainer\"abstract()extends\"Node\"{\
acceptMouse=true;\
acceptKeyboard=true;\
acceptMisc=true;\
nodes={};\
forceRedraw=true;\
}\
function NodeContainer:getNodeByType(a)\
local e,t={},self.nodes\
for o=1,#t do\
local t=t[o]\
if class.typeOf(t,a,true)then e[#e+1]=t end\
end\
return e\
end\
function NodeContainer:getNodeByName(o)\
local e,t={},self.nodes\
for a=1,#t do\
local t=t[a]\
if t.name==o then e[#e+1]=t end\
end\
return e\
end\
function NodeContainer:addNode(e)\
e.parent=self\
e.stage=self.stage\
self.nodes[#self.nodes+1]=e\
end\
function NodeContainer:removeNode(e)\
local t=self.nodes\
local o=not(class.isInstance(e)and class.__node)\
for a=1,#t do\
local t=t[a]\
if(o and t.name==e)or(not o and t==e)then\
t.parent=nil\
return table.remove(self.nodes,a)\
end\
end\
end\
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
  [ "ClassUtil.lua" ] = "local h=table.insert\
local o,d,r=string.len,string.sub,string.rep\
function ParseClassArguments(s,n,e,o,r)\
local i={}\
local function d(a,t)\
if type(e)~=\"table\"then return end\
local e=i[a]\
if e and type(t)~=e then\
if not class.typeOf(t,e,true)then\
return error(\"Expected type '\"..e..\"' for argument '\"..a..\"', got '\"..type(t)..\"' instead.\",2)\
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
local t={}\
if type(e)==\"table\"then\
for a,e in ipairs(e)do\
h(t,e[1])\
i[e[1]]=e[2]\
end\
end\
local o={}\
if#n==1 and type(n[1])==\"table\"then\
for e,t in pairs(n[1])do\
o[e]=d(e,t)\
a[e]=nil\
end\
else\
for i,n in ipairs(n)do\
local e=t[i]\
if not e then\
return error(\"Instance '\"..s:type()..\"' only supports a max of \"..(i-1)..\" unordered arguments. Consider using a key-pair table instead, check the wiki page for this class to find out more.\")\
end\
o[e]=d(e,n)\
a[e]=nil\
end\
end\
if next(a)then\
local t=\"Instance '\"..s:type()..\"' requires arguments:\\n\"\
for o,e in ipairs(e)do\
if a[e[1]]then\
t=t..\"- \"..e[1]..\" (\"..e[2]..\")\\n\"\
end\
end\
t=t..\"These arguments have not been defined.\"\
return error(t)\
end\
for e,t in pairs(o)do\
if(i[e]and not r)or not i[e]then\
print(\"Setting \"..e)\
s[e]=t\
end\
end\
local t={}\
if type(e)==\"table\"and r then\
for a,e in ipairs(e)do\
h(t,o[e[1]])\
end\
return unpack(t)\
end\
end\
function AssertClass(e,o,a,t)\
if not class.typeOf(e,o,a)then\
return error(t,2)\
end\
return e\
end\
function AssertEnum(e,t,i)\
local a\
for o=1,#t do\
if t[o]==e then\
a=true\
break\
end\
end\
if a then\
return e\
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
e=d(e,1,o(e)-t-3)..\"...\"\
else e=r(\".\",a)end\
else\
e=d(e,1,o(e)-t*2)..r(\".\",t)\
end\
end\
return e\
end\
function InArea(e,t,o,a,i,n)\
if e>=o and e<=i and t>=a and t<=n then\
return true\
end\
return false\
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
backgroundColour=1;\
old={};\
}\
function ApplicationCanvas:initialise(...)\
ParseClassArguments(self,{...},{{\"owner\",\"Application\"},{\"width\",\"number\"},{\"height\",\"number\"}},true)\
AssertClass(self.owner,\"Application\",true,\"Instance '\"..self:type()..\"' requires an Application Instance as the owner\")\
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
end\
function MyDaemon:stop(e)\
log(e and\"di\"or\"de\",\"MyDaemon detected application close. \"..(e and\"graceful\"or\"not graceful\")..\".\")\
local e=self.owner.event\
e:removeEventHandler(\"TERMINATE\",\"EVENT\",\"Terminate\")\
end",
  [ "TextContainer.lua" ] = "class\"TextContainer\"extends\"MultiLineTextDisplay\"\
function TextContainer:setText(e)\
self.text=e\
self.container.text=e\
end",
  [ "UnknownEvent.lua" ] = "class\"UnknownEvent\"mixin\"Event\"{\
main=false;\
sub=\"EVENT\";\
}\
function UnknownEvent:initialise(e)\
self.raw=e\
self.main=e[1]:upper()\
end",
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
local u=e.titleTextColour\
local l=e.titleBackgroundColour\
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
  [ "MultiLineTextDisplay.lua" ] = "class\"MultiLineTextDisplay\"abstract()extends\"NodeScrollContainer\"\
function MultiLineTextDisplay:initialise(...)\
ParseClassArguments(self,{...},{{\"text\",\"string\"},{\"X\",\"number\"},{\"Y\",\"number\"},{\"width\",\"number\"},{\"height\",\"number\"}},true,false)\
self.container=FormattedTextObject(self)\
end\
function MultiLineTextDisplay:parseIdentifiers()\
local e=self.text\
local s={}\
if not e then return error(\"Failed to parse identifiers. No text is set\")end\
local n,h,r,i=false,false,false,0\
while len(e)>0 do\
local a,t=find(e,\"%@%w-%-%w+[[%+%w-%-%w+]+]?\")\
if not a or not t then break end\
local o=sub(e,a,t)\
local d=t+i-len(o)\
i=i+a-2-(sub(e,a-1,a-1)==\" \"and 1 or 0)-(sub(e,t+1,t+1)==\" \"and 1 or 0)\
e=sub(e,t)\
for e in gmatch(o,\"([^%+]+)\")do\
e=sub(e,1,1)==\"@\"and sub(e,2)or e\
local t,a=match(e,\"(%w-)%-\"),match(e,\"%-(%w+)\")\
if not t or not a then error(\"identifier '\"..tostring(o)..\"' contains invalid syntax\")end\
if t==\"tc\"then n=parseColour(a)\
elseif t==\"bg\"then h=parseColour(a)\
elseif t==\"align\"then r=a else\
error(\"Unknown identifier target '\"..tostring(t)..\"' in identifier '\"..tostring(o)..\"' at part '\"..e..\"'\")\
end\
end\
s[d]={n,h,r}\
end\
local t=self.container\
t.segments,t.text=s,gsub(e,\"[ ]?%@%w-%-%w+[[%+%w-%-%w+]+]?[ ]?\",\"\")\
end\
function MultiLineTextDisplay:draw(e,t)\
local a=self.container\
if not a then return error(\"Failed to draw node '\"..self:type()..\"' because the MultiLineTextDisplay has no FormattedTextObject set\")end\
self.container:draw(e,t)\
end",
  [ "loadFirst.cfg" ] = "Logging.lua\
ClassUtil.lua\
TextUtil.lua\
DCMLParser.lua",
  [ "MDaemon.lua" ] = "class\"MDaemon\"abstract()\
function MDaemon:registerDaemon(e)\
if not class.isInstance(e)or not e.__daemon then\
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
local e=class.getClass(t)\
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
local i=n(false,e.instanceHandler)or class.getClass(t)\
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
function e:registerMode(e,t)\
i[e]=t\
end\
function e:setLoggingEnabled(e)\
a=e\
end\
function e:getEnabled()return a end\
function e:setLoggingPath(e)\
t=e\
self:clearLog(true)\
end\
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
  [ "FormattedTextObject.lua" ] = "local l,f,m=string.len,string.match,string.sub\
local function u(t)\
local a=l(t)\
local e=0\
return(function()\
e=e+1\
if e<=a then return m(t,e,e)end\
end)\
end\
class\"FormattedTextObject\"{\
segments={};\
cache={\
height=nil;\
text=nil;\
};\
}\
function FormattedTextObject:initialise(t,e)\
self.owner=class.isInstance(t)and t or error(\"Cannot set owner of FormattedTextObject to '\"..tostring(t)..\"'\",2)\
self.width=type(e)==\"number\"and e or error(\"Cannot set width of FormattedTextObject to '\"..tostring(e)..\"'\",2)\
end\
function FormattedTextObject:cacheSegmentInformation()\
if not text then self.owner:parseIdentifiers()text=self.text end\
if not self.text then return error(\"Failed to parse text identifiers. No new text received.\")end\
local w=self.segments\
local n,o,a,t,e=self.width,self.text,{},0,0\
local s,d,h=false,false,\"left\"\
local function i()\
e=1\
a[t][2]=AssertEnum(h,{\"left\",\"center\",\"centre\",\"right\"},\"Failed FormattedTextObject caching: '\"..tostring(h)..\"' is an invalid alignment setting.\")\
t=t+1\
a[t]={\
{},\
false\
}\
return a[t]\
end\
i()\
local c=0\
local function r()\
c=c+1\
local e=w[c]\
if e then\
s=e[1]or s\
d=e[2]or d\
h=e[3]or h\
end\
end\
local function h(o)\
a[t][e+1]={\
o,\
s,\
d\
}\
e=e+1\
end\
while l(o)>0 do\
local c=f(o,\"^[ \\t]+\")\
if c then\
local t=a[t]\
for a in u(c)do\
r()\
t[#t+1]={\
a,\
s,\
d\
}\
e=e+1\
if e>n then t=i()end\
end\
o=m(o,l(c)+1)\
end\
local t=f(o,\"^[^ \\t\\n]+\")\
local a=l(t)\
if e+a<=n then\
for e in u(t)do\
r()\
h(e)\
end\
elseif a<=n then\
i()\
for e in u(t)do\
r()\
h(e)\
end\
else\
if e>n then i()end\
for t in u(t)do\
r()\
h(t)\
if e>n then i()end\
end\
end\
end\
self:cacheAlignments(a)\
end\
function FormattedTextObject:cacheAlignments(e)\
local a=e or self.lines\
local o=self.width\
local e,t\
for i=1,#a do\
e=a[i]\
t=e[2]\
if t==\"left\"then\
e[3]=1\
elseif t==\"center\"then\
e[3]=math.ceil((o/2)-(#e/2))\
elseif t==\"right\"then\
e[3]=o-#e\
else return error(\"Invalid alignment property '\"..tostring(t)..\"'\")end\
end\
self.lines=a\
return self.lines\
end\
function FormattedTextObject:draw(e,e)\
local e=self.owner\
if class.isInstance(e)then\
return error(\"Cannot draw '\"..tostring(self:type())..\"'. The instance has no owner.\")\
end\
local e=e.canvas\
end\
function FormattedTextObject:getCache()\
if not self.cache then\
self:cacheText()\
end\
return self.cache\
end\
function FormattedTextObject:getHeight()\
return self.cache.height\
end",
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
  [ "scriptFiles.cfg" ] = "ClassUtil.lua\
TextUtil.lua\
DCMLParser.lua\
Logging.lua",
  [ "Application.lua" ] = "class\"Application\"alias\"COLOUR_REDIRECT\"mixin\"MDaemon\"{\
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
if class.typeOf(t,\"Application\",true)then\
if class.typeOf(e,\"Stage\",true)then\
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
local t=class.typeOf(e,\"Stage\",true)\
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
local function o()\
local a=self.hotkey\
local o=self.timer\
if self.onRun then self:onRun()end\
self:draw(true)\
log(\"s\",\"Engine start successful. Running in protected mode\")\
while self.running do\
if self.reorderRequest then\
log(\"i\",\"Reordering stage list\")\
local e=self.reorderRequest\
for t=1,#self.stages do\
if self.stages[t]==e then\
table.insert(self.stages,1,table.remove(self.stages,t))\
self:setStageFocus(e)\
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
a:handleKey(e)\
a:checkCombinations()\
elseif e.main==\"TIMER\"then\
o:update(e.raw[2])\
end\
for t=1,#self.stages do\
if self.stages[t]then\
self.stages[t]:handleEvent(e)\
end\
end\
end\
end\
log(\"i\",\"Trying to start daemon services\")\
local t,e=pcall(function()self:startDaemons()end)\
if e then\
log(\"f\",\"Failed to start daemon services. Reason '\"..tostring(e)..\"'\")\
if self.errorHandler then\
self:errorHandler(e,false)\
else\
if self.onError then self:onError(e)end\
error(\"Failed to start daemon service: \"..e)\
end\
elseif ok then\
log(\"s\",\"Daemon service started\")\
end\
log(\"i\",\"Starting engine\")\
local t,e=pcall(o)\
if not t and e then\
log(\"f\",\"Engine error: '\"..tostring(e)..\"'\")\
if self.errorHandler then\
self:errorHandler(e,true)\
else\
term.setTextColour(colours.yellow)\
print(\"DynaCode has crashed\")\
term.setTextColour(colours.red)\
print(e)\
print(\"\")\
local function i(a,e,s,h,i,n,o,t)\
term.setTextColour(a)\
print(e)\
local a,e=pcall(s)\
if e then\
term.setTextColour(h)\
print(i..e)\
else\
term.setTextColour(n)\
print(o)\
end\
term.setTextColour(t)\
end\
local t,a,o=colours.yellow,colours.red,colours.lime\
i(t,\"Attempting to stop daemon service and children\",function()self:stopDaemons(false)end,a,\"Failed to stop daemon service: \",o,\"Stopped daemon service\",1)\
print(\"\")\
i(t,\"Attempting to write crash information to log file\",function()\
log(\"f\",\"DynaCode crashed: \"..e)\
end,a,\"Failed to write crash information: \",o,\"Wrote crash information to file\",1)\
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
if type(e)==\"function\"then e()end\
end\
function Application:mapWindow(n,i,r,s)\
local e=self.stages\
local d=self.layerMap\
for t=#e,1,-1 do\
local e=e[t]\
local a,o=e.X,e.Y\
local u,h=e.canvas.width,e.canvas.height\
local l,t\
l=a+u\
t=o+h\
local u=e.visible\
local h=e.mappingID\
if not(a>r or o>s or n>l or i>t)then\
for s=math.max(o,i),math.min(t,s)do\
local i=self.width*(s-1)\
for t=math.max(a,n),math.min(l,r)do\
local n=d[i+t]\
if n~=h and u and(e:isPixel(t-a+1,s-o+1))then\
d[i+t]=h\
elseif n==h and not u then\
d[i+t]=false\
end\
end\
end\
end\
end\
local e=self.canvas.buffer\
local a=self.width\
local h=self.layerMap\
for t=i,s do\
local a=a*(t-1)\
for o=n,r do\
local t=a+o\
local a=h[a+o]\
if a==false then\
if e[t]then e[t]={false,false,false}end\
end\
end\
end\
end\
function Application:requestStageFocus(e)\
self.reorderRequest=e\
end\
function Application:setStageFocus(e)\
if not class.isInstance(e,\"Stage\")then return error(\"Expected Class Instance Stage, not \"..tostring(e))end\
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
local function e(e)\
return DCML.parse(DCML.loadFile(e))\
end\
function Application:appendStagesFromDCML(t)\
local e=e(t)\
for a=1,#e do\
local e=e[a]\
if class.typeOf(e,\"Stage\",true)then\
self:addStage(e)\
else\
return error(\"The DCML parser has created a \"..tostring(e)..\". This is not a stage and cannot be added as such. Please ensure the DCML file '\"..tostring(t)..\"' only creates stages with nodes inside of them, not nodes by themselves. Refer to the wiki for more information\")\
end\
end\
end",
  [ "Class.lua" ] = "local p,u=string.gsub,string.match\
local f={\
ENABLE=false;\
LOCATION=\"DynaCrash-Dump.crash\"\
}\
local y;\
local d={\
__type=true;\
__defined=true;\
__class=true;\
__extends=true;\
__instance=true;\
__alias=true;\
};\
local i=_G;\
local c\
local o\
local e\
local n={}\
local t={}\
local k=setmetatable({},{__index=function(a,e)\
local t=\"set\"..e:sub(1,1):upper()..e:sub(2)\
a[e]=t\
return t\
end})\
local m=setmetatable({},{__index=function(a,e)\
local t=\"get\"..e:sub(1,1):upper()..e:sub(2)\
a[e]=t\
return t\
end})\
local function h(e,t,...)\
if type(e)==\"function\"then\
return e(...)\
else\
return error(t)\
end\
end\
local function l(e)\
c=true\
local e=e:getRaw()\
c=false\
return e\
end\
local function s(a)\
local i=o\
local s,e\
s=h(y,\"MISSING_CLASS_LOADER method not defined. Cannot load missing target class '\"..tostring(a)..\"'\",a)\
e=n[a]\
if t.isClass(e)then\
if not e:isSealed()then e:seal()end\
else\
return error(\"Target class '\"..tostring(a)..\"' failed to load\")\
end\
o=i\
return e\
end\
local function w(a,o)\
local e=n[a]\
if t.isClass(e)then\
if e:isSealed()or not o then\
return e\
elseif o then\
return error(\"Failed to fetch target class '\"..a..\"'. Target isn't sealed.\")\
end\
else\
return s(a)\
end\
end\
local function r(e)\
if type(e)==\"table\"then\
for t,e in pairs(e)do\
if type(e)==\"function\"then return error(\"Cannot set function indexes in class properties!\")end\
o[t]=e\
end\
elseif type(e)~=\"nil\"then\
return error(\"Unknown object trailing class declaration '\"..tostring(e)..\" (\"..type(e)..\")'\")\
end\
end\
local function h(t,a)\
local o=type(t)\
local e\
if o=='table'then\
e={}\
for t,o in next,t,nil do\
if not a or(a and not d[t])then\
e[h(t)]=h(o)\
end\
end\
else\
e=t\
end\
return e\
end\
local function b(e)\
local t=u(e,\"abstract class (\\\"%w*\\\")\")\
if t then\
e=p(e,\"abstract class \"..t,\"class \"..t..\" abstract()\")\
end\
return e\
end\
local function v(h,i,e)\
local o\
local a\
local t,n,s=string.match(e,\"(.+)%:(%d+)%:(.*)\")\
if t and n and s then\
o=n\
a=s\
else\
a=e\
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
    File: ]==]..tostring(t or i or\"?\")..[==[\
\
    Line Number: ]==]..tostring(o or\"?\")..[==[\
\
    Error: ]==]..tostring(a or\"?\")..[==[\
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
    will not have any affect. Please edit the source file (]==]..tostring(t or i or\"?\")..[==[)\
]]]==]\
local e=fs.open(f.LOCATION,\"w\")\
e.write(h..\"-- END OF FILE --\")\
e.write(\"\\n\\n\"..t)\
e.close()\
end\
local function u(t,e,a)\
local s=a or{}\
local e=w(e,true)\
local e=h(l(e))\
local a,n={},{}\
local i\
for e,t in pairs(e)do\
if not s[e]and not d[e]then\
s[e]=t\
end\
end\
if e.__extends then\
local o\
a.super,o=u(t,e.__extends,s)\
i=true\
for t,a in pairs(o)do\
if not e.__defined[t]then e[t]=a end\
end\
i=false\
end\
local function d(o)\
local t=a\
while true do\
local e=t.super\
if e then\
if e.__defined[o]then return e[o]else t=e end\
else break end\
end\
end\
local function r(o,i)\
local e=t\
local t={}\
while true do\
if e.__defined[o]then\
return true\
else\
t[#t+1]=e\
if e.super~=a and e.super then e=e.super\
else\
for e=1,#t do t[e]:addSymbolicKey(o,i)end\
break\
end\
end\
end\
end\
local h={}\
function n:__index(o)\
if type(e[o])==\"function\"then\
if not h[o]then h[o]=function(i,...)\
local i=t.super\
t.super=a.super\
local e={e[o](t,...)}\
t.super=i\
return unpack(e)\
end end\
return h[o]\
else\
return e[o]\
end\
end\
function n:__newindex(a,t)\
e[a]=t==nil and d(a)or t\
if not i then e.__defined[a]=t~=nil or nil end\
r(a,t)\
end\
function n:__tostring()return\"[Super] \"..e.__type..\" of \"..tostring(t)end\
function n:__call(...)\
local a=(type(e.initialise)==\"function\"and\"initialise\"or(type(e.initialize)==\"function\"and\"initialize\"or false))\
if a then\
return e[a](t,...)\
end\
end\
function a:addSymbolicKey(t,e)\
i=true;self[t]=e;i=false\
end\
setmetatable(a,n)\
return a,s\
end\
local function g(e,...)\
local e=h(l(e))\
e.__instance=true\
local t,a={},{}\
local n=e.__alias or{}\
local o\
t.raw=e\
local function s(a)\
local t=t\
while true do\
local e=t.super\
if e then\
if e.__defined[a]then\
return e[a]\
else\
t=e\
end\
else\
return nil\
end\
end\
end\
local i\
if e.__extends then\
t.super,i=u(t,e.__extends)\
for t,a in pairs(i)do\
if not e.__defined[t]and not d[t]then\
e[t]=a\
end\
end\
end\
local i={}\
function a:__index(t)\
local t=n[t]or t\
local a=m[t]\
if type(e[a])==\"function\"and not i[t]then\
i[t]=true\
local e={e[a](self)}\
i[t]=nil\
return unpack(e)\
else\
return e[t]\
end\
end\
local i={}\
function a:__newindex(t,a)\
local t=n[t]or t\
local n=k[t]\
if type(e[n])==\"function\"and not i[t]then\
i[t]=true\
e[n](self,a)\
i[t]=nil\
else\
e[t]=a\
end\
if a==nil then\
e[t]=s(t)\
end\
if not o then\
e.__defined[t]=a~=nil or nil\
end\
end\
function a:__tostring()return\"[Instance] \"..e.__type end\
function t:type()return e.__type end\
function t:addSymbolicKey(e,t)\
o=true;self[e]=t;o=false\
end\
local o={\
[\"__index\"]=true;\
[\"__newindex\"]=true;\
}\
function t:__overrideMetaMethod(e,t)\
if o[e]then return error(\"Meta method '\"..tostring(e)..\"' cannot be overridden\")end\
a[e]=t\
end\
function t:__lockMetaMethod(e)o[e]=true end\
setmetatable(t,a)\
local a=(type(e.initialise)==\"function\"and\"initialise\"or(type(e.initialize)==\"function\"and\"initialize\"or false))\
if a then e[a](t,...)end\
return t\
end\
function t.forge(s)\
local t={}\
t.__class=true\
t.__type=s\
t.__defined={}\
local e={}\
local m,a,h,u=false,false,{},false\
function e:isSealed()return a end\
function e:isAbstract()return m end\
function e:seal()\
if a then return error(\"Class is already sealed\")end\
if#h>0 then\
for e=1,#h do\
local e=h[e]\
local e=w(e)\
local e=l(e)\
for e,a in pairs(e)do\
if not t[e]and not d[e]then\
t[e]=a\
end\
end\
end\
end\
local i=self.__alias or{}\
local t=self\
local e,n\
while true do\
e=t.__extends\
if e then\
n=l(w(e,true))\
local a=n.__alias\
if a then\
for e,t in pairs(a)do\
if not i[e]then i[e]=t end\
end\
end\
t=e\
else\
break\
end\
end\
self.__alias=i\
a=true\
if o==self then t=self o=nil end\
end\
function e:spawn(...)\
if not a then return error(\"Cannot spawn instance of '\"..s..\"'. Class is un-sealed\")end\
if m then return error(\"Cannot spawn instance of '\"..s..\"'. Class is abstract\")end\
return g(self,...)\
end\
function e:getRaw()\
if not c then return error(\"Cannot fetch raw content of class (DISABLED)\")end\
return t\
end\
function e:type()\
return self.__type\
end\
function e:symIndex(e,t)\
u=true;self[e]=t;u=false\
end\
function e:extend(e)\
if a then return error(\"Cannot extend base class after being sealed\")end\
self:symIndex(\"__extends\",e)\
end\
function e:mixin(e)\
if a then return error(\"Cannot add mixin targets to class base after being sealed\")end\
h[#h+1]=e\
end\
function e:abstract(e)\
if a then return error(\"Cannot modify abstract state of class base after being sealed\")end\
m=e\
end\
function e:alias(e)\
if a then return error(\"Cannot set alias table of class base after being sealed\")end\
if not t.__alias then\
t.__alias=e\
else\
for a,e in pairs(e)do\
t.__alias[a]=e\
end\
end\
end\
local h={}\
function h:__newindex(e,o)\
if a then return error(\"Cannot create new indexes on class base after being sealed\")end\
t[e]=o\
if not u then\
t.__defined[e]=o~=nil or nil\
end\
end\
h.__index=t\
function h:__tostring()\
return(a and\"[Sealed] \"or\"[Un-sealed] \")..s\
end\
function h:__call(...)return self:spawn(...)end\
setmetatable(e,h)\
o=e\
i[s]=e\
n[s]=e\
return r\
end\
function t.getClass(e)return n[e]end\
function t.setClassLoader(e)\
if type(e)~=\"function\"then return error(\"Cannot set missing class loader to variable of type '\"..type(e)..\"'\")end\
y=e\
end\
function t.isClass(e)\
return type(e)==\"table\"and type(e.type)==\"function\"and n[e:type()]and e.__class\
end\
function t.isInstance(e)\
return t.isClass(e)and e.__instance\
end\
function t.typeOf(e,a,o)\
if not t.isClass(e)or(o and not t.isInstance(e))then return false end\
return e:type()==a\
end\
function t.runClassString(t,e,h)\
local i=f.ENABLE and\" The file being loaded at the time of the crash has been saved to '\"..f.LOCATION..\"'\"or\"\"\
local t=b(t)\
local function o(a)\
v(t,e,a)\
error(\"Exception while loading class string for file '\"..e..\"': \"..a..\".\"..i,0)\
end\
local s,a=loadstring(t,e)\
if a then\
o(a)\
end\
local s,a=pcall(s)\
if a then\
o(a)\
end\
local o=p(e,\"%..*\",\"\")\
local a=n[o]\
if not h then\
if a then\
if not a:isSealed()then a:seal()end\
else\
v(t,e,\"Failed to load class '\"..o..\"'\")\
error(\"File '\"..e..\"' failed to load class '\"..o..\"'\"..i,0)\
end\
end\
end\
setmetatable(t,{\
__call=function(a,e)return t.forge(e)end\
})\
i.class=t\
i.extends=function(e)\
if type(e)~=\"string\"then return error(\"Failed to extend building class to target '\"..tostring(e)..\"'. Invalid target\")end\
o:extend(e)\
return r\
end\
i.mixin=function(e)\
if type(e)~=\"string\"then return error(\"Failed to mix target class '\"..tostring(e)..\"' into the building class. Invalid target\")end\
o:mixin(e)\
return r\
end\
i.abstract=function()\
o:abstract(true)\
return r\
end\
i.alias=function(e)\
if type(e)==\"string\"then\
if type(i[e])==\"table\"then\
e=i[e]\
else\
return error(\"Cannot load table for alias from WORK_ENV: \"..tostring(e))\
end\
elseif type(e)~=\"table\"then\
return error(\"Cannot set alias to '\"..tostring(e)..\"'. Invalid type\")\
end\
o:alias(e)\
return r\
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
eventConfig={\
[\"MouseEvent\"]={\
acceptAll=false\
};\
acceptAll=false;\
acceptMisc=false;\
acceptKeyboard=false;\
acceptMouse=false;\
manuallyHandle=false;\
}\
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
if e:inArea(self.X,self.Y,self.X+self.width-1,self.Y+self.height-1)then\
t(self,a[e.sub]or error(\"No click matrix entry for \"..tostring(e.sub)),e)\
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
  [ "NodeCanvas.lua" ] = "local o,h=string.len,string.sub\
class\"NodeCanvas\"extends\"Canvas\"{\
node=nil;\
}\
function NodeCanvas:initialise(...)\
local e,a,t=ParseClassArguments(self,{...},{{\"node\",\"table\"},{\"width\",\"number\"},{\"height\",\"number\"}},true,true)\
if not class.isInstance(e)then\
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
  [ "Stage.lua" ] = "local o=table.insert\
local s=string.sub\
DCML.registerTag(\"Stage\",{\
childHandler=function(e,t)\
e.nodesToAdd=DCML.parse(t.content)\
end;\
onDCMLParseComplete=function(t)\
local e=t.nodesToAdd\
if e then\
for a=1,#e do\
local e=e[a]\
t:addNode(e)\
if e.nodesToAdd and type(e.resolveDCMLChildren)==\"function\"then\
e:resolveDCMLChildren()\
end\
end\
t.nodesToAdd=nil\
end\
end;\
argumentType={\
X=\"number\";\
Y=\"number\";\
width=\"number\";\
height=\"number\";\
},\
})\
class\"Stage\"alias\"COLOUR_REDIRECT\"{\
X=1;\
Y=1;\
width=10;\
height=6;\
borderless=false;\
canvas=nil;\
application=nil;\
nodes={};\
name=nil;\
textColour=32768;\
backgroundColour=1;\
unfocusedTextColour=128;\
unfocusedBackgroundColour=256;\
shadow=true;\
shadowColour=colours.grey;\
focused=false;\
closeButton=true;\
closeButtonTextColour=1;\
closeButtonBackgroundColour=colours.red;\
titleBackgroundColour=128;\
titleTextColour=1;\
controller={};\
mouseMode=nil;\
visible=true;\
resizable=true;\
movable=true;\
closeable=true;\
}\
function Stage:initialise(...)\
local i,a,o,e,t=ParseClassArguments(self,{...},{{\"name\",\"string\"},{\"X\",\"number\"},{\"Y\",\"number\"},{\"width\",\"number\"},{\"height\",\"number\"}},true,true)\
self.X=a\
self.Y=o\
self.name=i\
self.canvas=StageCanvas({width=e;height=t;textColour=self.textColour;backgroundColour=self.backgroundColour,stage=self})\
self.width=e\
self.height=t\
self:__overrideMetaMethod(\"__add\",function(t,e)\
if class.typeOf(t,\"Stage\",true)then\
if class.isInstance(e)and e.__node then\
return self:addNode(e)\
else\
return error(\"Invalid right hand assignment. Should be instance of DynaCode node. \"..tostring(e))\
end\
else\
return error(\"Invalid left hand assignment. Should be instance of Stage. \"..tostring(e))\
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
local a=self.maxHeight\
local t=self.minHeight\
e=a and e>a and a or e\
e=t and e<t and t or e\
self.height=e>0 and e or 1\
self:updateCanvasSize()\
end\
function Stage:setWidth(e)\
local t=self.maxWidth\
local a=self.minWidth\
e=t and e>t and t or e\
e=a and e<a and a or e\
self.width=e>0 and e or 1\
self:updateCanvasSize()\
end\
function Stage:setApplication(e)\
AssertClass(e,\"Application\",true,\"Stage requires Application Instance as its application. Not '\"..tostring(e)..\"'\")\
self.application=e\
end\
function Stage:draw(e)\
local t=self.changed\
local a=e or self.forceRedraw\
if self.forceRedraw or a then\
log(\"i\",\"Stage is being forced to redraw!\")\
self.canvas:clear()\
self.canvas:redrawFrame()\
self.forceRedraw=false\
end\
log(\"i\",\"Drawing stage \"..tostring(name)..\". Force: \"..tostring(t)..\". Changed: \"..tostring(self.changed))\
local i=self.canvas\
if t or a then\
local e=self.nodes\
for o=#e,1,-1 do\
local e=e[o]\
if t and e.changed or a then\
e:draw(0,0,t or a)\
e.canvas:drawToCanvas(i,e.X,e.Y)\
e.changed=false\
end\
end\
self.changed=false\
end\
if self.visible then self.canvas:drawToCanvas(self.application.canvas,self.X,self.Y)end\
end\
function Stage:appDrawComplete()\
if self.currentKeyboardFocus and self.focused then\
local e,a,t,o=self.currentKeyboardFocus:getCursorInformation()\
if not e then return end\
term.setTextColour(o)\
term.setCursorPos(a,t)\
term.setCursorBlink(true)\
end\
end\
function Stage:addNode(e)\
e.stage=self\
o(self.nodes,e)\
return e\
end\
function Stage:hitTest(t,e)\
return InArea(t,e,self.X,self.Y,self.X+self.width-1,self.Y+self.height-(self.borderless and 1 or 0))\
end\
function Stage:isPixel(e,t)\
local a=self.canvas\
if self.shadow then\
if self.focused then\
if(e==self.width+1 and t==1)or(e==1 and t==self.height+(self.borderless and 0 or 1)+1)then\
return false\
end\
return true\
else\
if(e==self.width+1)or(t==self.height+(self.borderless and 0 or 1)+1)then return false end\
return true\
end\
elseif not self.shadow then return true end\
return false\
end\
function Stage:submitEvent(e)\
local t=self.nodes\
local o=e.main\
local i,a\
if o==\"MOUSE\"then\
i,a=e.X,e.Y\
e:convertToRelative(self)\
if not self.borderless then\
e.Y=e.Y-1\
end\
end\
for a=1,#t do\
t[a]:handleEvent(e)\
end\
if o==\"MOUSE\"then\
e.X,e.Y=i,a\
end\
end\
function Stage:move(e,t)\
e=e or self.X\
t=t or self.Y\
self:removeFromMap()\
self.X=e\
self.Y=t\
self:map()\
self.application.changed=true\
end\
function Stage:resize(e,t)\
newWidth=e or self.width\
newHeight=t or self.height\
self:removeFromMap()\
self.width=newWidth\
self.height=newHeight\
self.canvas:redrawFrame()\
self:map()\
self.forceRedraw=true\
self.application.changed=true\
end\
function Stage:handleMouse(e)\
local a,t=e.sub,self.mouseMode\
if a==\"CLICK\"then\
local t,a=e:getRelative(self)\
if a==1 then\
if t==self.width and self.closeButton and not self.borderless then\
self:removeFromMap()\
self.application:removeStage(self)\
else\
self.mouseMode=\"move\"\
self.lastX,self.lastY=e.X,e.Y\
end\
elseif a==self.height+(not self.borderless and 1 or 0)and t==self.width then\
self.mouseMode=\"resize\"\
end\
elseif a==\"UP\"and t then\
self.mouseMode=false\
elseif a==\"DRAG\"and t then\
if t==\"move\"then\
self:move(self.X+e.X-self.lastX,self.Y+e.Y-self.lastY)\
self.lastX,self.lastY=e.X,e.Y\
elseif t==\"resize\"then\
self:resize(e.X-self.X+1,e.Y-self.Y+(self.borderless and 1 or 0))\
end\
end\
end\
local function o(e)\
e.application:requestStageFocus(e)\
end\
function Stage:close()\
self:removeFromMap()\
self.application:removeStage(self)\
end\
function Stage:handleEvent(e)\
if e.handled then return end\
local t,a=e.main,e.sub\
if t==\"MOUSE\"then\
local i=e:inBounds(self)\
if a==\"CLICK\"then\
local t,s,h=false,e.X,e.Y\
e:convertToRelative(self)\
local a=self.width\
local t,n=e:getPosition()\
if n==1 then\
if t==a and self.closeable then\
self:close()\
elseif self.movable and t>=1 and t<=a then\
self.mouseMode=\"move\"\
o(self)\
e.handled=true\
elseif i then o(self)end\
elseif self.resizable and n==self.height+(not self.borderless and 1 or 0)and t==a then\
self.mouseMode=\"resize\"\
o(self)\
e.handled=true\
else\
if self.focused then\
if not self.borderless then\
e.Y=e.Y-1\
end\
local t=self.nodes\
for a=1,#t do\
local t=t[a]\
t:handleEvent(e)\
end\
elseif not self.focused and i then\
o(self)\
e.handled=true\
end\
end\
e:restore(s,h)\
elseif a==\"UP\"then\
self.mouseMode=nil\
if self.focused then self:submitEvent(e)end\
elseif a==\"SCROLL\"and self.focused then\
self:submitEvent(e)\
elseif a==\"DRAG\"and self.focused then\
self:submitEvent(e)\
end\
if self.focused and i then\
e.handled=true\
end\
else\
self:submitEvent(e)\
end\
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
local function t(e)\
return DCML.parse(DCML.loadFile(e))\
end\
function Stage:replaceWithDCML(e)\
local e=t(e)\
for e=1,#self.nodes do\
local t=self.nodes[e]\
t.stage=nil\
table.remove(self.nodes,e)\
end\
for t=1,#e do\
e[t].stage=self\
table.insert(self.nodes,e[t])\
end\
end\
function Stage:appendFromDCML(e)\
local e=t(e)\
for t=1,#e do\
e[t].stage=self\
table.insert(self.nodes,e[t])\
end\
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
e=s(e,2)\
return self.controller[e]\
end\
function Stage:executeCallback(t,...)\
local e=self:getCallback(t)\
if e then\
local t={...}\
return e(...)\
else\
return error(\"Failed to find callback \"..tostring(s(t,2))..\" on controller (node.stage): \"..tostring(self))\
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
function MouseEvent:inArea(a,o,n,i)\
local e,t=self.X,self.Y\
if e>=a and e<=n and t>=o and t<=i then\
return true\
end\
return false\
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
end\
function MouseEvent:restore(e,t)\
self.X,self.Y=e,t\
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
