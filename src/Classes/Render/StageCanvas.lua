class "StageCanvas" extends "Canvas" {
    frame = nil;
}

function StageCanvas:initialise( ... )
    self.super:initialise( ... )
    self:redrawFrame()
end

function StageCanvas:redrawFrame()
    -- This function creates a table of pixels representing the background and shadow of the stage.
    -- Function should only be executed during full clears, not every draw.
    local stage = self.stage

    local hasTitleBar = not stage.borderless
    local title = OverflowText(stage.title or "", self.width - ( stage.closeButton and 1 or 0 ) ) or ""
    local hasShadow = stage.shadow

    local shadowColour = stage.shadowColour
    local titleColour = stage.titleTextColour
    local titleBackgroundColour = stage.titleBackgroundColour
    local backgroundColour = self.backgroundColour
    local textColour = self.textColour

    local width = self.width --+ ( stage.shadow and 1 or 0 )
    local height = self.height + ( stage.shadow and 1 or 0 )

    local frame = {}
    local max = 0
    for y = 0, height do
        local yPos = width * y
        for x = 1, width do
            max = x > max and x or max
            -- Find out what goes here (title, shadow, background)
            local pos = yPos + x
            if hasTitleBar and y == 0 and ( hasShadow and x < width or not hasShadow ) then
                -- Draw the correct part of the title bar here.
                if x == width - 1 and stage.closeButton then
                    frame[pos] = {"X", stage.closeButtonTextColour, stage.closeButtonBackgroundColour}
                else
                    local char = string.sub( title, x, x )
                    frame[pos] = {char ~= "" and char or " ", titleColour, titleBackgroundColour}
                end
            elseif hasShadow and ( ( x == width and y ~= 0 ) or ( x ~= 1 and y == height - 1 ) ) then
                -- Draw the shadow
                frame[pos] = {" ", shadowColour, shadowColour}
            else
                local ok = true
                if hasShadow and ( ( x == width and y == 0 ) or ( x == 1 and y == height - 1 ) ) then
                    ok = false
                end
                if ok then
                    frame[pos] = { false, false, false } -- background
                end
            end
        end
    end
    --error("Max X reached: "..max)
    self.frame = frame
end

function StageCanvas:drawToCanvas( canvas, xO, yO )
    local buffer = self.buffer
    local frame = self.frame
    local stage = self.stage

    local xO = type( xO ) == "number" and xO or 0
    local yO = type( yO ) == "number" and yO or 0

    local width = self.width --+ ( stage.shadow and 1 or 0 )
    local height = self.height - ( stage.shadow and 0 or 1 )

    for y = 0, height do
        local yPos = width * y
        local yBPos = canvas.width * ( y + yO )
        for x = 1, width do
            local pos = yPos + x
            local bPos = yBPos + (x + xO)

            local pixel = buffer[ pos ]
            if pixel then
                if not pixel[1] then
                    -- draw the frame
                    local framePixel = frame[ pos ]
                    if framePixel then
                        canvas.buffer[ bPos ] = { framePixel[1], framePixel[2] or self.textColour, framePixel[3] or self.backgroundColour }
                    end
                    --canvas.buffer[ bPos ] = framePixel
                else
                    -- draw the node pixel
                    canvas.buffer[ bPos ] = { pixel[1] or " ", pixel[2] or self.textColour or false, pixel[3] or self.backgroundColour or false }
                end
            else
                canvas.buffer[ bPos ] = { false, false, false }
            end
        end
    end
end
