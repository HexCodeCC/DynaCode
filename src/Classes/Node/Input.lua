class "Input" extends "Node" {
    acceptMouse = true;
    acceptKeyboard = false;

    content = nil;
    selectedRange = nil;
    cursorPosition = 0;

    selectedTextColour = 1;
    selectedBackgroundColour = colors.blue;

    textColour = 32768;
    backgroundColour = 1;

    placeholder = "Input";
}

function Input:initialise( ... )
    self.super:initialise( ... )

    self.content = ""
    self.selectedRange = { 0, 0 } -- start, end (of text index, not onscreen pixel. 1 based)
end

function Input:preDraw()
    self.canvas:drawArea( self.X, self.Y, self.width, self.height, self.backgroundColour, self.textColour )
end

function Input:onMouseDown()
    self.stage:redirectKeyboardFocusHere( self )
end

function Input:onKeyDown( event )
    -- check what key was pressed and act accordingly
end

function Input:onChar( event )
    -- add this key into the content at the correct location
end

function Input:onMouseMiss( event )
    -- if a mouse event occurs off of the input, remove focus from the input.
    self.stage:removeKeyboardFocus( self )
end
