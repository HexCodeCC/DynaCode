local GREYSCALE_FILTER = {
    [1] = 256;
    [2] = 256;
    [4] = 256;
    [8] = 1;
    [16] = 256;
    [32] = 128;
    [64] = 256;
    [128] = 128;
    [256] = 128;
    [512] = 256;
    [1024] = 128;
    [2048] = 128;
    [4096] = 128;
    [8192] = 256;
    [16384] = 128;
    [32768] = 128;
}

class "StageCanvas" extends "Canvas" {
    frame = nil;

    filter = nil;

    cache = nil;
    greyOutWhenNotFocused = true;
}

function StageCanvas:initialise( ... )
    --self.super:initialise( ... )
    local width, height = ParseClassArguments( self, { ... }, { {"width", "number"}, {"height", "number"} }, true, true )
    AssertClass( self.stage, "Stage", true, "StageCanvas requires stage to be a Stage instance, not: "..tostring( self.stage ) )

    self.super:initialise( width, height )

    self.cache = {}

    self:redrawFrame()
    self:updateFilter()
end

function StageCanvas:updateFilter()
    if self.stage.focused or not self.greyOutWhenNotFocused then
        self.filter = "NONE"
    else
        self.filter = "GREYSCALE"
    end
end

function StageCanvas:setFilter( fil )
    -- clear the cache
    self.filter = fil
    self:redrawFrame()
end

function StageCanvas:getColour( col )
    if self.filter == "NONE" then return col end

    if self.filter == "GREYSCALE" then
        return GREYSCALE_FILTER[ col ]
    end
end

function StageCanvas:redrawFrame()
    -- This function creates a table of pixels representing the background and shadow of the stage.
    -- Function should only be executed during full clears, not every draw.
    local stage = self.stage
    local gc = self.getColour

    local hasTitleBar = not stage.borderless
    local title = OverflowText(stage.title or "", stage.width - ( stage.closeButton and 1 or 0 ) ) or ""
    local hasShadow = stage.shadow and stage.focused

    local shadowColour = stage.shadowColour
    local titleColour = stage.titleTextColour
    local titleBackgroundColour = stage.titleBackgroundColour

    local width = self.width --+ ( stage.shadow and 0 or 0 )
    local height = self.height --+ ( stage.shadow and 1 or 0 )

    local frame = {}
    for y = 0, height - 1 do
        local yPos = width * y
        for x = 1, width do
            -- Find out what goes here (title, shadow, background)
            local pos = yPos + x
            if hasTitleBar and y == 0 and ( hasShadow and x < width or not hasShadow ) then
                -- Draw the correct part of the title bar here.
                if x == stage.width and stage.closeButton then
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
    self.frame = frame
end

function StageCanvas:drawToCanvas( canvas, xO, yO, ignoreMap )
    local buffer = self.buffer
    local frame = self.frame
    local stage = self.stage
    local gc = self.getColour

    local mappingID = self.stage.mappingID

    local xO = type( xO ) == "number" and xO - 1 or 0
    local yO = type( yO ) == "number" and yO - 1 or 0

    local width = self.width --+ ( stage.shadow and 0 or 0 )
    local height = self.height -- ( stage.shadow and 1 or 1 )

    local map = self.stage.application.layerMap

    for y = 0, height - 1 do
        local yPos = width * y
        local yBPos = canvas.width * ( y + yO )
        if y + yO + 1 > 0 and y + yO - 1 < canvas.height then

            for x = 1, width do
                if x + xO > 0 and x + xO - 1 < canvas.width then

                    local bPos = yBPos + (x + xO)

                    if map[ bPos ] == mappingID then

                        local pos = yPos + x
                        local pixel = buffer[ pos ]
                        if pixel then
                            if not pixel[1] then
                                -- draw the frame
                                local framePixel = frame[ pos ]
                                if framePixel then
                                    local fP = framePixel[1]
                                    if x == self.width and y == 0 and not stage.borderless and stage.closeButton and self.greyOutWhenNotFocused then -- keep the closeButton coloured.
                                        canvas.buffer[ bPos ] = { fP, framePixel[2] or self.textColour, framePixel[3] or self.backgroundColour}
                                    else
                                        canvas.buffer[ bPos ] = { fP, gc( self, framePixel[2] or self.textColour ), gc( self, framePixel[3] or self.backgroundColour ) }
                                    end
                                end
                            else
                                -- draw the node pixel
                                canvas.buffer[ bPos ] = { pixel[1] or " ", gc( self, pixel[2] or self.textColour ), gc( self, pixel[3] or self.backgroundColour ) }
                            end
                        else
                            canvas.buffer[ bPos ] = { false, false, false }
                        end
                    end
                end
            end
        end
    end
end

function StageCanvas:clear()
    --self.stage.forceRedraw = true

    local width = self.width
    local height = self.height
    local buffer = {}
    for i = 1, width * height do
        buffer[ i ] = { false, false, false }
    end

    self.buffer = buffer
end
