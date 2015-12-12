local paint = { -- converts decimal to paint colors during draw time.
    [1] = "0";
    [2] = "1";
    [4] = "2";
    [8] = "3";
    [16] = "4";
    [32] = "5";
    [64] = "6";
    [128] = "7";
    [256] = "8";
    [512] = "9";
    [1024] = "a";
    [2048] = "b";
    [4096] = "c";
    [8192] = "d";
    [16384] = "e";
    [32768] = "f";
}

class "ApplicationCanvas" extends "Canvas" {
    textColour = colors.red;
    backgroundColour = 1;

    old = nil;
}

function ApplicationCanvas:initialise( ... )
    ParseClassArguments( self, { ... }, { {"owner", "Application"}, {"width", "number"}, {"height", "number"} }, true )
    AssertClass( self.owner, "Application", true, "Instance '"..self:type().."' requires an Application Instance as the owner" )

    self.super:initialise( self.width, self.height )
    self.old = {}
end

function ApplicationCanvas:drawToScreen( force )
    local xOffset = tonumber( xOffset ) and xOffset or 0
    local yOffset = tonumber( yOffset ) and yOffset or 0

    local width, height = self.width, self.height
    local buffer = self.buffer
    local old = self.old

    local oldT, oldB = 1, 32768
    term.setBackgroundColor( 32768 )
    term.setTextColor( 1 )

    local printPixel
    if term.blit then
        printPixel = function( pixel )
            term.blit( pixel[1] or " ", paint[ pixel[2] or self.textColour ], paint[ pixel[3] or self.backgroundColour ] )
        end
    else
        printPixel = function( pixel )
            local tc, bg = pixel[2] or self.textColour, pixel[3] or self.backgroundColour
            if oldT ~= tc then term.setTextColor( tc ) oldT = tc end
            if oldB ~= bg then term.setBackgroundColor( bg ) oldB = bg end
            term.write( pixel[1] or " " )
        end
    end

    for y = 1, height do
        for x = 1, width do
            if x + xOffset > 0 and x - xOffset <= width then
                local pos = ( width * (y - 1 + yOffset) ) + x

                term.setCursorPos( x, y )
                local lP = old[ pos ]
                local cP = buffer[ pos ]
                if force or not lP or ( lP[1] ~= cP[1] or lP[2] ~= cP[2] or lP[3] ~= cP[3] ) then
                    if not buffer[pos] then
                        printPixel { " ", self.textColour, self.backgroundColour }
                        old[ pos ] = { " ", self.textColour, self.backgroundColour }
                    else
                        printPixel( cP )
                        old[ pos ] = { cP[1], cP[2], cP[3] }
                    end
                end
            end
        end
    end
end
