abstract class "MCanvas"
function MCanvas:setTextColour( colour )
    self.canvas.textColour = colour
    self.textColour = colour

    self.forceRedraw = true
end

function MCanvas:setBackgroundColour( colour )
    self.canvas.backgroundColour = colour
    self.backgroundColour = colour

    self.forceRedraw = true
end
