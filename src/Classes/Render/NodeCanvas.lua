local len, sub = string.len, string.sub

class "NodeCanvas" extends "Canvas" {
    node = nil;
}

function NodeCanvas:initialise( ... )
    local node, width, height = ParseClassArguments( self, { ... }, { {"node", "table"}, {"width", "number"}, {"height", "number"} }, true, true )

    if not classLib.isInstance( node ) then
        return error("Node argument (first unordered) is not a class instance! Should be a node class instance. '" .. tostring( node ) .. "'")
    elseif not node.__node then
        return error("Node argument (first unordered) is an invalid class instance. '"..tostring( node ).."'")
    end
    self.node = node

    self.super( width, height )
end

function NodeCanvas:drawToCanvas( canvas, xO, yO )
    local buffer = self.buffer
    --local frame = self.frame
    local stage = self.node.stage
    local hasNodeParent = self.node.parent and true or false

    local borderOffset = stage.borderless and not hasNodeParent and 2 or 1

    local xO = type( xO ) == "number" and xO - 1 or 0
    local yO = type( yO ) == "number" and yO - (not hasNodeParent and borderOffset or 2) or 0

    local width = self.width
    local height = self.height

    local sOffset = (stage.shadow and not hasNodeParent and 1) or 0

    local cHeight = canvas.height - sOffset
    local cWidth = canvas.width - sOffset

    local yPos, yBPos, pos, bPos, pixel

    local yOO = yO + (hasNodeParent and 2 or borderOffset)
    local yOS = yO + sOffset

    local tc, bg = self.node.textColour, self.node.backgroundColour


    for y = 0, height do
        yPos = width * y
        yBPos = canvas.width * ( y + yO + 1 )
        if y + yOO > 0 and y + yOS < cHeight then
            for x = 1, width do
                if x + xO > 0 and x + xO - 1 < cWidth then
                    pos = yPos + x
                    bPos = yBPos + (x + xO)

                    pixel = buffer[ pos ]
                    if pixel then
                        -- draw the node pixel
                        canvas.buffer[ bPos ] = { pixel[1] or " ", pixel[2] or tc, pixel[3] or bg }
                    else
                        canvas.buffer[ bPos ] = { " ", tc, bg }
                    end
                end
            end
        end
    end
end

-- Methods for drawing geometry shapes into canvas.

-- BASIC SHAPES
function NodeCanvas:drawArea( x1, y1, width, height, tc, bg )
    for y = y1, (y1 + height - 1) do
        local yPos = self.width * ( y - 1 )
        for x = x1, (x1 + width - 1) do
            self.buffer[ yPos + x ] = { " ", tc, bg }
        end
    end
end


-- TEXT
function NodeCanvas:drawTextLine( text, x, y, tc, bg, width, overflow )
    -- draws a text line at the co-ordinates.
    if width and overflow then text = OverflowText( text, width ) end

    local yPos = self.width * (y - 1)
    for i = 1, width or len( text ) do
        if x + i + 1 < 0 or x + i - 1 > self.width then return end
        local char = sub( text, i, i )
        self.buffer[ yPos + i + x - 1 ] = { char ~= "" and char or " ", tc, bg }
    end
end

function NodeCanvas:drawXCenteredTextLine( text, y, tc, bg, overflow )
    -- calculate the best X ordinate based on the length of the text and width of the node.
end

function NodeCanvas:drawYCenteredTextLine( text, x, tc, bg, overflow )

end

function NodeCanvas:drawCenteredTextLine( text, tc, bg, overflow )

end


--TODO improve this code (little messy) *job release-0*
function NodeCanvas:wrapText( text, width )
    -- returns a table of text lines, the table can be drawn by nodes using alignment settings
    if type( text ) ~= "string" or type( width ) ~= "number" then
        return error("Expected string, number")
    end
    local lines = {}
    local lineIndex = 1
    local position = 1
    local run = true
    local function newline()
        -- strip all whitespace from the end of the line.
        lines[ lineIndex ] = TextHelper.whitespaceTrim( lines[ lineIndex ] )
        -- move to the next line
        lineIndex = lineIndex + 1
        position = 1
    end
    while len( text ) > 0 do
        local whitespace = string.match( text, "^[ \t]+" )
        if whitespace then
            -- print the whitespace, even over other lines.
            for i = 1, len( whitespace ) do
                lines[ lineIndex ] = not lines[ lineIndex ] and sub( whitespace, i, i ) or lines[ lineIndex ] .. sub( whitespace, i, i )
                position = position + 1
                if position > width then newline() end
            end
            text = sub( text, len(whitespace) + 1 )
        end
        local word = string.match( text, "^[^ \t\n]+" )
        if word then
            if len( word ) > width then
                local line
                for i = 1, len( word ) do
                    lines[ lineIndex ] = not lines[ lineIndex ] and "" or lines[ lineIndex ]
                    line = lines[ lineIndex ]
                    -- attach the character
                    lines[ lineIndex ] = line .. sub( word, i, i )
                    position = position + 1
                    if position > width then newline() end
                end
            elseif len( word ) <= width then
                if len( word ) + position - 1 > width then newline() end
                local line = lines[ lineIndex ]
                lines[ lineIndex ] = line and line .. word or word
                position = position + #word
                if position > width then newline() end
            end
            text = sub( text, len( word ) + 1 )
        else return lines end
    end
    return lines
end
function NodeCanvas:drawWrappedText( x1, y1, width, height, text, vAlign, hAlign, bgc, tc )
    -- The text is a table of lines returned by wrapText, draw into the canvas the text (raw)
    if type( text ) ~= "table" then
        return error("drawWrappedText: text argument (5th) must be a table of lines")
    end
    local drawX, drawY
    if vAlign then
        -- use the total lines to calculate the position of this line.
        if vAlign == "top" then
            drawY = 0
        elseif vAlign == "center" then
            drawY = (height / 2) - ( #text / 2 ) + 1
        elseif vAlign == "bottom" then
            drawY = math.floor( height - #text )
        else return error("Unknown vAlign mode") end
    else return error("Unknown vAlign mode") end

    self:drawArea( x1, y1, width, height, tc, bgc )
    if height < #text then
        self:drawTextLine( "...", 1, 1, tc, bgc )
        return
    end

    for lineIndex = 1, #text do
        local line = text[ lineIndex ]
        if hAlign then
            if hAlign == "left" then
                drawX = 1
            elseif hAlign == "center" then
                drawX = math.ceil((width / 2) - (len( line ) / 2) + .5 )
            elseif hAlign == "right" then
                drawX = math.floor( width - len( line ) )
            else return error("Unknown hAlign mode") end
        else return error("Unknown hAlign mode") end
        local y = math.ceil(drawY + lineIndex - .5)
        if y1 + y - 2 >= y1 then
            self:drawTextLine( line, drawX + x1 - 1, y + y1 - 2, tc, bgc )
        end
    end
end
