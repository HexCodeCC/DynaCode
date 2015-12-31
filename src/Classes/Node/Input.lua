DCML.registerTag("Input", {
    argumentType = {
        X = "number";
        Y = "number";
        width = "number";
        height = "number";
        backgroundColour = "colour";
        textColour = "colour";
        selectedTextColour = "colour";
        selectedBackgroundColour = "colour";
        activeTextColour = "colour";
        activeBackgroundColour = "colour";
    };
    callbacks = {
        onSubmit = "onSubmit"
    };
    callbackGenerator = "#generateNodeCallback"; -- "#" signifies relative function (on the instance.) @ Node.generateNodeCallback
    aliasHandler = true
})

local len = string.len
local sub = string.sub

class "Input" extends "Node" alias "ACTIVATABLE" alias "SELECTABLE" {
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
    self.super( ... )

    self.content = ""
    self.selected = 0 -- from the cursor ( negative <, positive > )
end


function Input:preDraw()
    local content, text = self.content, ""
    local canvas = self.canvas

    -- cache anything we will need to use/calculate often
    local offset, width, content, contentLength, selected, selectionStart, selectionStop, selectionOffset, cursorPos = 0, self.width, self.content, len( self.content ), self.selected, 0, false, false, self.cursorPosition
    local isCursorGreater = cursorPos >= width
    local o = 0

    local selectionUsedAsStart = false

    if contentLength >= width then
        if selected <= 0 and isCursorGreater then
            offset = math.min(cursorPos - width, cursorPos + selected - 1) - contentLength
            o = contentLength - width + ( cursorPos - contentLength )

            if offset + contentLength == cursorPos + selected - 1 and math.abs( offset ) > width + ( contentLength - cursorPos ) then selectionUsedAsStart = true end
        elseif selected > 0 and cursorPos + selected > width then
            offset = ( math.max( cursorPos, cursorPos + selected - 1 ) ) - contentLength - self.width
        end
    end

    selectionStart = math.min( cursorPos + selected, cursorPos ) - o + ( isCursorGreater and 0 or 1 )
    selectionStop = math.max( cursorPos + selected, cursorPos ) - o - ( (isCursorGreater and not selectionUsedAsStart) and 1 or 0 )

    local buffer = self.canvas.buffer
    local hasSelection = selected ~= 0

    -- take manual control of the buffer to draw the way we want to with minimal performance hits
    for w = 1, self.width do
        -- our drawing space, from here we figure out any offsets needed when drawing text
        local index = w + offset
        local isSelected = hasSelection and w >= selectionStart and w <= selectionStop

        local char = sub( content, index, index )
        char = char ~= "" and char or " "

        if isSelected then
            buffer[ w ] = { char, 1, colours.blue }
        else
            buffer[ w ] = { char, colours.red, colors.lightGray }
        end
    end
    self.canvas.buffer = buffer
end

function Input:onMouseDown()
    self.stage:redirectKeyboardFocus( self )
end

local function checkSelection( self )
    local selected = self.selected
    if selected < 0 then
        -- check if the selection goes back too far
        local limit = -len(self.content) + ( self.cursorPosition - len( self.content ) )
        if selected < limit then
            self.selected = limit
        end
    elseif selected > 0 then
        local limit = len( self.content ) - self.cursorPosition
        if selected > limit then self.selected = limit end
    end
end

local function checkPosition( self )
    if self.cursorPosition < 0 then self.cursorPosition = 0 elseif self.cursorPosition > len( self.content ) then self.cursorPosition = len( self.content ) end
    self.selected = 0
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
    local hk = self.stage.application.hotkey

    local cursorPos, selection = self.cursorPosition, self.selected

    if hk.keys.shift then
        -- the shift key is being pressed
        -- adjust selection
        if key == "left" then
            selection = selection - 1
        elseif key == "right" then
            selection = selection + 1
        elseif key == "home" then
            -- select from cursor to start
            selection = -(self.cursorPosition)
        elseif key == "end" then
            -- select from cursor to end
            selection = len( self.content ) - self.cursorPosition
        end
    elseif hk.keys.ctrl then
        -- move selection/cursor
        if key == "left" then
            cursorPos = cursorPos - 1
        elseif key == "right" then
            cursorPos = cursorPos + 1
        end
    else
        if key == "left" then
            cursorPos = cursorPos - 1
            selection = 0
        elseif key == "right" then
            cursorPos = cursorPos + 1
            selection = 0
        elseif key == "home" then
            cursorPos = 0
            selection = 0
        elseif key == "end" then
            cursorPos = len( self.content )
            selection = 0
        elseif key == "backspace" then
            if self.cursorPosition == 0 then return end
            adjustContent( self, "", -1, 1, -1 )
        elseif key == "delete" then
            if self.cursorPosition == #self.content then return end
            adjustContent( self, "", 0, 2, 0 )
        elseif key == "enter" then
            if self.onTrigger then self:onTrigger( event ) end
        end
    end
    self.cursorPosition = cursorPos
    self.selected = selection
end

function Input:setContent( content )
    self.content = content
    self.changed = true
end

function Input:setCursorPosition( pos )
    self.cursorPosition = pos
    checkPosition( self )
    self.changed = true
end

function Input:setSelected( s )
    self.selected = s
    checkSelection( self )
    self.changed = true
end

function Input:onChar( event )
    adjustContent( self, event.key, 0, 1, 1 )
end

function Input:onMouseMiss( event )
    if event.sub == "UP" then return end
    -- if a mouse event occurs off of the input, remove focus from the input.
    self.stage:removeKeyboardFocus( self )
end

function Input:getCursorInformation()
    local x, y = self:getTotalOffset()

    local cursorPos
    if self.cursorPosition < self.width then
        cursorPos = self.cursorPosition
    else
        cursorPos = self.width - 1
    end

    return self.selected == 0, x + cursorPos - 1, y, self.activeTextColour
end

function Input:onFocusLost() self.focused = false; self.acceptKeyboard = false; self.changed = true end
function Input:onFocusGain() self.focused = true; self.acceptKeyboard = true; self.changed = true end
