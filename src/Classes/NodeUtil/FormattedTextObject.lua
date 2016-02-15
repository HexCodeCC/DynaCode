-- The FormattedTextObject has dynamic a height which will change to fit the size of the text
local len, match, sub = string.len, string.match, string.sub

local function splitWord( word )
    local wordLength = len( word )

    local i = 0
    return (function()
        i = i + 1
        if i <= wordLength then return sub( word, i, i ) end
    end)
end

class "FormattedTextObject" extends "Node" {
    segments = {};
    cache = {
        height = nil;
        text = nil;
    };

    receivesEvents = false
}

function FormattedTextObject:initialise( owner, width )
    self.owner = classLib.isInstance( owner ) and owner or error("Cannot set owner of FormattedTextObject to '"..tostring( owner ).."'", 2)
    self.width = type( width ) == "number" and width or error("Cannot set width of FormattedTextObject to '"..tostring( width ).."'", 2)
end

function FormattedTextObject:cacheSegmentInformation()
    if not text then self.owner:parseIdentifiers() text = self.text end
    if not self.text then return error("Failed to parse text identifiers. No new text received.") end

    local segments = self.segments
    local width, text, lines, currentY, currentX = self.owner.cache.displayWidth, self.text, {}, 1, 1
    local textColour, backgroundColour, lineAlignment = false, false, self.owner.defaultAlignment or "left"

    local function newline( manual )
        currentX = 1

        lines[ currentY ].align = AssertEnum( lineAlignment, {"left", "center", "centre", "right"}, "Failed FormattedTextObject caching: '"..tostring( lineAlignment ).."' is an invalid alignment setting.") -- set the property on this line for later processing
        lines[ currentY ][ manual and "isNewline" or "isWrapped"] = true

        currentY = currentY + 1

        lines[ currentY ] = {
            align = lineAlignment
        }
        return lines[ currentY ]
    end
    lines[ currentY ] = {
        align = lineAlignment
    }

    local textIndex = 0
    local function applySegments()
        local segment = segments[ textIndex ]

        if segment then
            textColour = segment[1] or textColour
            backgroundColour = segment[2] or backgroundColour
            lineAlignment = segment[3] or lineAlignment
        end
        textIndex = textIndex + 1
    end

    local function appendChar( char )
        local currentLine = lines[ currentY ]
        lines[ currentY ][ #currentLine + 1 ] = {
            char,
            textColour,
            backgroundColour
        }
        currentX = currentX + 1
    end

    -- pre-process the text line by fetching each word and analysing it.
    while len( text ) > 0 do
        local new = match( text, "^[\n]+")
        if new then
            for i = 1, len( new ) do
                newline( true )
                applySegments()
            end
            text = sub( text, len( new ) + 1 )
        end

        local whitespace = match( text, "^[ \t]+" )
        if whitespace then
            local currentLine = lines[ currentY ]
            for char in splitWord( whitespace ) do
                applySegments()
                currentLine[ #currentLine + 1 ] = {
                    char,
                    textColour,
                    backgroundColour
                }

                currentX = currentX + 1
                if currentX > width then currentLine = newline() end
            end
            text = sub( text, len(whitespace) + 1 )
        end

        local word, lengthOfWord = match( text, "%S+" )
        if word then
            lengthOfWord = len( word )
            text = sub( text, lengthOfWord + 1 )

            if currentX + lengthOfWord <= width then
                -- if this word can fit on the current line then add it
                for char in splitWord( word ) do
                    -- append this character after searching for and applying segment information.
                    applySegments()
                    appendChar( char ) -- we know the word can fit so we needn't check the width here.
                end
            elseif lengthOfWord <= width then
                -- if this word cannot fit on the current line but can fit on a new line add it to a new one
                newline()
                for char in splitWord( word ) do
                    applySegments()
                    appendChar( char )
                end
            else
                -- if the word cannot fit on a new line then wrap it over multiple lines
                if currentX > width then newline() end
                for char in splitWord( word ) do
                    applySegments()
                    appendChar( char )

                    if currentX > width then newline() end
                end
            end
        else break end
    end

    -- wrap the final line (this is done when newlines are generated so all but the last line will be ready)
    lines[currentY].align = lineAlignment

    self:cacheAlignments( lines )
end

function FormattedTextObject:cacheAlignments( _lines )
    local lines = _lines or self.lines
    local width = self.owner.cache.displayWidth

    local line, alignment
    for i = 1, #lines do
        line = lines[ i ]
        alignment = line.align

        if alignment == "left" then
            line.X = 1
        elseif alignment == "center" then
            line.X = math.ceil( ( width / 2 ) - ( #line / 2 ) ) + 1
        elseif alignment == "right" then
            line.X = width - #line + 1
        else return error("Invalid alignment property '"..tostring( alignment ).."'") end
    end

    self.lines = lines
    return self.lines
end

function FormattedTextObject:draw( xO, yO )
    local owner = self.owner
    if not classLib.isInstance( owner ) then
        return ParameterException("Cannot draw '"..tostring( self:type() ).."'. The instance has no owner.")
    end

    local canvas = owner.canvas
    local buffer = canvas.buffer

    if not self.lines then
        self:cacheSegmentInformation()
    end
    local lines = self.lines
    local width = self.owner.width

    -- Draw the text to the canvas ( the cached version )
    local startingPos, pos, pixel
    for i = 1, #lines do
        local line = lines[i]
        local lineX = line.X
        startingPos = canvas.width * ( i - 0 )

        for x = 1, #line do
            local pixel = line[x]
            if pixel then
                buffer[ (canvas.width * (i - 1 + yO)) + (x + lineX - 1) ] = { pixel[1], pixel[2], pixel[3] }
            end
        end
    end
end

function FormattedTextObject:getCache()
    if not self.cache then
        self:cacheText()
    end

    return self.cache
end


function FormattedTextObject:getHeight()
    if not self.lines then
        self:cacheSegmentInformation()
        self.owner.recacheAllNextDraw = true
    end

    return #self.lines
end

function FormattedTextObject:getCanvas() -- Because FormattedTextObject are stored in the node table the NodeScrollContainer will expect a canvas. So we redirect the request to the owner.
    return self.owner.canvas
end
