-- The TextInput class does pretty much all the same stuff as the TextContainer except text identifiers.
local sub = string.sub
class "TextInput" extends "TextContainer" alias {
    cursorColor = "cursorColour"
} {
    cursorPosition = 1;
    cursorColour = colours.lime;

    allowsIdentifiers = false;
    mask = false;
}

function TextInput:initialise( ... )
    local X, Y, width, height = ParseClassArguments( self, { ... }, { {"X", "number"}, {"Y", "number"}, {"width", "number"}, {"height", "number"} }, true, true )
    self.super( "", X, Y, width, height )
end

function TextInput:getCursorOffsetFromPosition( X, Y )
    local lines = self.container.lines
    if not lines then return end
    local lineOffset = 0
    Y = Y + self.yOffset

    -- Add the lines from the start to before the clicked line.
    for i = 1, Y - 1 do
        local line = lines[ i ]
        if not line then break end

        lineOffset = lineOffset + #lines[ i ] + 1
    end
    local line = lines[ Y ]
    if not line then return end

    lineOffset = lineOffset + (X - line.X + 1)

    self.cursorPosition = lineOffset
end

function TextInput:setCursorPosition( pos )
    self.cursorPosition = ( math.max( math.min( pos, #self.text + 1 ), 1 ) )
end

function TextInput:onAnyEvent( event )
    if event.handled then return end

    if self.focused then
        if event:isType("KEY", "KEY") then
            local key = keys.getName( event.key )
            if key == "left" then
                self.cursorPosition = self.cursorPosition - 1
            elseif key == "right" then
                self.cursorPosition = self.cursorPosition + 1
            elseif key == "backspace" then
                if self.cursorPosition == 1 or #self.text == 0 then return end
                self.text = sub( self.text, 1, self.cursorPosition - 2 )..sub( self.text, self.cursorPosition )
                self.cursorPosition = self.cursorPosition - 1
            elseif key == "enter" then
                self.text = sub( self.text, 1, self.cursorPosition - 1 ) .. "\n" .. sub( self.text, self.cursorPosition )
                self.cursorPosition = self.cursorPosition + 1
            end
            event.handled = true
        elseif event:isType("CHAR", "CHAR") then
            self.text = sub( self.text, 1, self.cursorPosition - 1 ) .. event.key .. sub( self.text, self.cursorPosition )
            self.cursorPosition = self.cursorPosition + 1

            event.handled = true
        end
    end
    if event:isType("MOUSE", "CLICK") then
        self:getCursorOffsetFromPosition( event:getRelative( self ) )
    end
    if not event.handled then
        self.super:onAnyEvent( event )
    end
end

function TextInput:getCursorInformation()
    if not self.focused then return false end
    local cursorX, cursorY, active = false, 1, true
    local lines = self.container.lines

    local remainingOffset = self.cursorPosition
    local newlineOffset = 0;

    local function newlineFound( lineLen )
        if lineLen then remainingOffset = math.max( remainingOffset - lineLen - 1, 0 ) end

        cursorY = cursorY + 1
    end

    local line
    for y = 1, #lines do
        line = lines[ y ]
        if remainingOffset - 1 > #line - (line.isWrapped and 1 or 0) then
            newlineFound( #line - (line.isWrapped and 1 or 0) )
        elseif remainingOffset - 1 > #line and line.isNewline then
            newlineOffset = newlineOffset + 1
            newlineFound( #line )
        else
            cursorX = line.X + remainingOffset - 1 - newlineOffset
            break
        end
    end
    cursorY = cursorY - ( self.yOffset )

    if not cursorX or not cursorY or cursorY > self.height or cursorY < 1 or cursorX > self.width or cursorX < 1 then
        active = false
    end

    return active, cursorX, cursorY, self.cursorColour
end
