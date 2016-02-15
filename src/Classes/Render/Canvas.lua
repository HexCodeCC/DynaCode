local insert = table.insert
local remove = table.remove
local empty = {false, false, false}

abstract class "Canvas" alias "COLOUR_REDIRECT" {
    width = 10;
    height = 6;

    buffer = nil;
}

function Canvas:initialise( ... )
    local width, height = ParseClassArguments( self, { ... }, { {"width", "number"}, {"height", "number"} }, true, true )

    self.width = width
    self.height = height

    self:clear()
end

function Canvas:clear( w, h )
    local width = w or self.width
    local height = h or self.height

    --if not width or not height then return end

    local buffer = {}
    for i = 1, width * height do
        buffer[ i ] = { false, false, false }
    end

    self.buffer = buffer
end

function Canvas:drawToCanvas( canvas, xO, yO )
    if not canvas then return error("Requires canvas to draw to") end
    local buffer = self.buffer

    local xO = xO or 0
    local yO = yO or 0

    local pos, yPos, yBPos, bPos, pixel

    for y = 0, self.height - 1 do
        yPos = self.width * y
        yBPos = canvas.width * ( y + yO )
        for x = 1, self.width do
            pos = yPos + x
            bPos = yBPos + (x + xO)

            pixel = buffer[ pos ]
            canvas.buffer[ bPos ] = { pixel[1] or " ", pixel[2] or self.textColour, pixel[3] or self.backgroundColour }
        end
    end
end

function Canvas:setWidth( width )
    if not self.buffer then self.width = width return end
    local height, buffer = self.height, self.buffer
    local selfWidth = self.width

    while selfWidth < width do
        -- Insert pixels at the end of each line to make up for the increase in width
        for i = 1, height do
            insert( buffer, ( selfWidth + 1 ) * i, empty )
        end
        selfWidth = selfWidth + 1
    end
    while selfWidth > width do
        for i = 1, width do
            remove( buffer, selfWidth * i )
        end
        selfWidth = selfWidth - 1
    end

    self.width = selfWidth
end

function Canvas:setHeight( height )
    if not self.buffer then self.height = height return end
    local width, buffer, cHeight = self.width, self.buffer, self.height
    local selfHeight = self.height

	while selfHeight < height do
		for i = 1, width do
			buffer[#buffer + 1] = empty
		end
		selfHeight = selfHeight + 1
	end

	while selfHeight > height do
		for i = 1, width do
			remove( buffer, #buffer )
		end
		selfHeight = selfHeight - 1
	end

    self.height = selfHeight
end
