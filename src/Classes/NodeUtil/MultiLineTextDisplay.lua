-- The MultiLineTextDisplay stores the parsed text in a FormattedTextObject class which is then used by the NodeScrollContainer to detect the need for and draw scrollbars to traverse the text.

-- When any nodes extending this class are drawn the draw request will be forwarded to the FormattedTextObject where it will then decide (based on the size of the parent node) how to
-- layout the formatted text (this included colouring and alignments of course).
local len, find, sub, match, gmatch, gsub = string.len, string.find, string.sub, string.match, string.gmatch, string.gsub
local function parseColour( cl )
    return colours[ cl ] or colors[ cl ] or error("Invalid colour '"..cl.."'")
end


abstract class "MultiLineTextDisplay" extends "NodeScrollContainer" {
    lastHorizontalStatus = false;
    lastVerticalStatus = false;
    displayWidth = 0;
}

function MultiLineTextDisplay:parseIdentifiers()
    local segments = {}
    local str = self.text
    local oldStop = 0

    local newString = gsub( str, "[ ]?%@%w-%-%w+[[%+%w-%-%w+]+]?[ ]?", "" )

    -- Loop until the string has been completely searched
    local textColour, backgroundColour, alignment = false, false, false
    while len( str ) > 0 do
        -- Search the string for the next identifier.
        local start, stop = find( str, "%@%w-%-%w+[[%+%w-%-%w+]+]?" )
        local leading, trailing, identifier

        if not start or not stop then break end

        leading = sub( str, start - 1, start - 1 ) == " "
        trailing = sub( str, stop + 1, stop + 1 ) == " "
        identifier = sub( str, start, stop )

        -- Remove the identifier from the string along with everything prior. Reduce the X index with that too.
        local X = stop + oldStop - len( identifier )
        oldStop = oldStop + start - 2 - ( leading and 1 or 0 ) - ( trailing and 1 or 0 )

        -- We have the X index which is where the settings will be applied during draw, trim the string
        str = sub( str, stop )

        -- Parse this identifier
        for part in gmatch( identifier, "([^%+]+)" ) do
            if sub( part, 1, 1 ) == "@" then
                -- discard the starting symbol
                part = sub( part, 2 )
            end

            local pre, post = match( part, "(%w-)%-" ), match( part, "%-(%w+)" )
            if not pre or not post then error("identifier '"..tostring( identifier ).."' contains invalid syntax") end

            if pre == "tc" then
                textColour = parseColour( post )
            elseif pre == "bg" then
                backgroundColour = parseColour( post )
            elseif pre == "align" then
                alignment = post
            else
                error("Unknown identifier target '"..tostring(pre).."' in identifier '"..tostring( identifier ).."' at part '"..part.."'")
            end
        end

        segments[ X ] = { textColour, backgroundColour, alignment }
    end

    local container = self.container
    container.segments, container.text = segments, newString
end

function MultiLineTextDisplay:getActiveScrollbars( ... )
    log("i", "Getting activeScrollBars")
    local h, v = self.super:getActiveScrollbars( ... )
    -- The scrollbar status is updated, has our display width been changed?

    if self.lastVerticalStatus ~= v then
        -- A scroll bar has been created/removed. Re-cache the text content to accomodate the new width.
        self.displayWidth = self.width - ( v and 1 or 0 )
        self.lastVerticalStatus = v
    end

    self.container:cacheSegmentInformation()

    return h, v
end
