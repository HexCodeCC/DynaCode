DCML.registerTag("Button", {
    contentCanBe = "text";
    argumentType = {
        X = "number";
        Y = "number";
        width = "number";
        height = "number";
    };
    callbacks = {
        onTrigger = "onTrigger" -- called after moused down and up again on the button.
    };
    callbackGenerator = "#generateNodeCallback"; -- "#" signifies relative function (on the instance.) @ Node.generateNodeCallback
})

class "Button" extends "Node" {
    text = nil;

    yCenter = false;
    xCenter = false;

    active = false;
    focused = false;

    -- colours
    textColour = 1;
    backgroundColour = colours.cyan;

    activeTextColour = 1;
    activeBackgroundColour = colours.lightBlue;

    acceptMouse = true;
}

function Button:initialise( ... )
    local text, X, Y, width, height = ParseClassArguments( self, { ... }, { {"text", "string"}, {"X", "number"}, {"Y", "number"}, {"width", "number"}, {"height", "number"} }, true, true )

    self.super:initialise( X, Y, width, height )
    self.text = text
end

function Button:updateLines()
    if not self.text then return end -- stops line updates during instantiation (the super:init sets width, however text is set afterwards (see Button:initialise))
    self.lines = self.canvas:wrapText( self.text, self.width )
end

function Button:setText( text )
    -- set the raw text, also generate a wrapped version.
    self.text = text
    self:updateLines()
end

function Button:setWidth( width )
    self.width = width
    self:updateLines()
end

function Button:preDraw()
    self.canvas:drawWrappedText( 1, 1, self.width, self.height, self.lines, "center", "center", self.active and self.activeBackgroundColour or self.backgroundColour, self.active and self.activeTextColour or self.textColour )
end

function Button:onMouseDown( event ) -- initial click, set focus to this button and highlight it.
    self.focused = true
    self.active = true
end

function Button:onMouseDrag( event )
    if self.focused then
        self.active = true -- mouse dragged onto node after dragging off, re-highlight it
    end
end

function Button:onMouseMiss( event )
    if self.focused and event.sub == "DRAG" then -- dragged off of node, set colour back to normal
        self.active = false
    elseif event.sub == "UP" and ( self.focused or self.active ) then -- mouse up off of the node, set its colour back to normal and remove focus
        self.active = false
        self.focused = false
    end
end

function Button:onMouseUp( event ) -- mouse up on node, trigger callback and reset colours and focus
    if self.active then
        -- clicked
        if self.onTrigger then self:onTrigger( event ) end

        self.active = false
        self.focused = false
    end
end
