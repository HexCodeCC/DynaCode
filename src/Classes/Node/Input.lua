local len = string.len
local sub = string.sub

class "Input" extends "Node" implements "ICursorInteractable" {
    acceptMouse = true;
    acceptKeyboard = false;

    content = false;
    selected = nil;
    cursorPosition = 0;

    selectedTextColour = 1;
    selectedBackgroundColour = colors.blue;

    textColour = 32768;
    backgroundColour = 128;

    activeBackgroundColour = 256;
    activeTextColour = 32768;

    placeholder = "Input";
}

function Input:initialise( ... )
    self.super:initialise( ... )

    self.content = ""
    self.selected = 0 -- from the cursor ( negative <, positive > )
end

function Input:preDraw()
    --self.canvas:drawArea( 1, 1, self.width, self.height, self.backgroundColour, self.textColour )
    self.canvas:drawTextLine( self.content, 1, 1, self.focused and self.activeTextColour or self.textColour, self.focused and self.activeBackgroundColour or self.backgroundColour, self.width )
end

function Input:onMouseDown()
    self.stage:redirectKeyboardFocus( self )
end

local function checkSelection( self )
    local selected = self.selected
    if selected < 0 then
        -- check if the selection goes back too far
        local limit = -(self.cursorPosition + 1)
        if selected < limit then
            selected = limit + 1
        end
    elseif selected > 0 then
        local limit = len( self.content ) - self.cursorPosition
        if selected > limit then selected = limit end
    end
end

local function checkPosition( self )
    if self.cursorPosition < 0 then self.cursorPosition = 0 elseif self.cursorPosition > len( self.content ) then self.cursorPosition = len( self.content ) end
end

local function adjustContent( self, content, offsetPre, offsetPost, cursorAdjust )
    local text = self.content
    text = sub( text, 1, self.cursorPosition + offsetPre ) .. content .. sub( text, self.cursorPosition + offsetPost )

    self.content = text
    self.cursorPosition = self.cursorPosition + cursorAdjust

    checkPosition( self )
end

function Input:onKeyDown( event )
    -- check what key was pressed and act accordingly
    local key = keys.getName( event.key )
    local app = self.stage.application
    local hk = app.hotkey

    if hk:matches "shift-left" then
        -- expand selection
        self.selected = self.selected - 1
        checkSelection( self )
    elseif hk:matches "shift-right" then
        -- expand selection
        self.selected = self.selected + 1
        checkSelection( self )
    elseif key == "left" then
        -- move position
        self.cursorPosition = self.cursorPosition - 1
        checkPosition( self )
    elseif key == "right" then
        -- move position
        self.cursorPosition = self.cursorPosition + 1
        checkPosition( self )
    elseif key == "home" then
        -- move position to start
        self.cursorPosition = 0
        checkPosition( self )
    elseif key == "end" then
        -- move position to end
        self.cursorPosition = #self.content
        checkPosition( self )
    elseif key == "backspace" then
        if self.cursorPosition == 0 then return end
        adjustContent( self, "", -1, 1, -1 )
    elseif key == "delete" then
        if self.cursorPosition == #self.content then return end
        adjustContent( self, "", 0, 2, 0 )
    elseif key == "enter" then
        error("submitted")
    end
end

function Input:onChar( event )
    adjustContent( self, event.key, 0, 1, 1)
end

function Input:onMouseMiss( event )
    -- if a mouse event occurs off of the input, remove focus from the input.
    self.stage:removeKeyboardFocus( self )
end

function Input:getCursorInformation()
    local x, y = self:getTotalOffset()
    
    return x + self.cursorPosition - 1, y, self.activeTextColour
end

function Input:onFocusLost() self.focused = false; self.acceptKeyboard = false end
function Input:onFocusGain() self.focused = true; self.acceptKeyboard = true end
