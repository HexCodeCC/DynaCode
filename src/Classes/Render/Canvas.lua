abstract class "Canvas" alias "COLOUR_REDIRECT" {
    width = 10;
    height = 6;

    buffer = nil;
}

function Canvas:initialise( ... )
    local width, height = ParseClassArguments( self, { ... }, { {"width", "number"}, {"height", "number"} }, true, true )
    self.width = width
    self.height = height

    if self:type() == "StageCanvas" then
        width = width + 1
        height = height + 1
    end

    local buffer = {}
    for i = 1, width * height do
        buffer[ i ] = { false, false, false }
    end

    self.buffer = buffer
end

function Canvas:drawToCanvas( canvas, xO, yO )
    if not canvas then return error("Requires canvas to draw to") end
    local buffer = self.buffer

    local xO = type( xO ) == "number" and xO or 0
    local yO = type( yO ) == "number" and yO or 0


    for y = 0, self.height - 1 do
        local yPos = self.width * y
        local yBPos = canvas.width * ( y + yO )
        for x = 1, self.width do
            local pos = yPos + x
            local bPos = yBPos + (x + xO)

            local pixel = buffer[ pos ]
            canvas.buffer[ bPos ] = { pixel[1] or " ", pixel[2] or self.textColour or false, pixel[3] or self.backgroundColour or false }
        end
    end
end
