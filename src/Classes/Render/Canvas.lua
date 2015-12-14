local insert = table.insert
local remove = table.remove

abstract class "Canvas" alias "COLOUR_REDIRECT" {
    width = 10;
    height = 6;

    buffer = nil;
}

function Canvas:initialise( ... )
    log("i", "initialise canvas")
    local width, height = ParseClassArguments( self, { ... }, { {"width", "number"}, {"height", "number"} }, true, true )

    local buffer = {}
    for i = 1, width * height do
        buffer[ i ] = { false, false, false }
    end

    self.buffer = buffer

    log("i", "setting canvas width, height")
    self.width = width
    self.height = height

    self:clear()
end

function Canvas:clear( w, h )
    log("w", "Canvas cleared")
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

function Canvas:setWidth( width )
    if not self.buffer then log("w", "Attempted to manipulate buffer size before initialisation!") self.width = width return end

    local height, buffer = self.height, self.buffer
    if not self.width then error("found on "..tostring( self )..". Current width: "..tostring( self.width )..", new width: "..tostring( width )) end
    while self.width < width do
        -- Insert pixels at the end of each line to make up for the increase in width
        for i = 1, height do
            insert( buffer, ( self.width + 1 ) * i, {"", self.textColor, self.textColour} )
        end
        self.width = self.width + 1
    end
    while self.width > width do
        for i = 1, width do
            remove( buffer, self.width * i )
        end
        self.width = self.width - 1
    end
    --self:clear()
end

function Canvas:setHeight( height )
    if not self.buffer then log("w", "Attempted to manipulate buffer size before initialisation!") self.height = height return end
    local width, buffer, cHeight = self.width, self.buffer, self.height

	while self.height < height do
		for i = 1, width do
			buffer[#buffer + 1] = px
		end
		self.height = self.height + 1
	end

	while self.height > height do
		for i = 1, width do
			remove( buffer, #buffer )
		end
		self.height = self.height - 1
	end
    --self:clear()
end
