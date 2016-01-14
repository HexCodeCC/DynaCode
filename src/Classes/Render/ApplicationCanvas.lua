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
local blit = type( term.blit ) == "function" and term.blit or nil
local write = term.write
local setCursorPos = term.setCursorPos
local concat = table.concat


local setTextColour, setBackgroundColour = term.setTextColour, term.setBackgroundColour

class "ApplicationCanvas" extends "Canvas" {
    textColour = colors.red;
    backgroundColour = colours.cyan;

    old = {};
}

function ApplicationCanvas:initialise( ... )
    ParseClassArguments( self, { ... }, { {"owner", "Application"}, {"width", "number"}, {"height", "number"} }, true )
    AssertClass( self.owner, "Application", true, "Instance '"..self:type().."' requires an Application Instance as the owner" )

    print( tostring( self.width )..", "..tostring( self.height ))

    self.super( self.width, self.height )
end


function ApplicationCanvas:drawToScreen( force )
    -- MUCH faster drawing! Tearing almost completely eliminated

    local pos = 1
    local buffer = self.buffer
    local width, height = self.width, self.height
    local old = self.old

    -- local definitions (faster than repeatedly defining the local inside the loop )
    local tT, tC, tB, tChanged
    local pixel, oPixel

    local tc, bg = self.textColour or 1, self.backgroundColour or 1
    if blit then
        for y = 1, height do
            tT, tC, tB, tChanged = {}, {}, {}, false -- text, textColour, textBackground

            for x = 1, width do
                -- get the pixel content, add it to the text buffers
                pixel = buffer[ pos ]
                oPixel = old[ pos ]

                tT[ #tT + 1 ] = pixel[1] or " "
                tC[ #tC + 1 ] = paint[ pixel[2] or tc ]
                tB[ #tB + 1 ] = paint[ pixel[3] or bg ]

                -- Set tChanged to true if this pixel is different to the last.
                if not oPixel or pixel[1] ~= oPixel[1] or pixel[2] ~= oPixel[2] or pixel[3] ~= oPixel[3] then
                    tChanged = true
                    old[ pos ] = { pixel[1], pixel[2], pixel[3] }
                end

                pos = pos + 1
            end
            if tChanged then
                setCursorPos( 1, y )
                blit( concat( tT, "" ), concat( tC, "" ), concat( tB, "" ) ) -- table.concat comes with a major speed advantage compared to tT = tT .. pixel[1] or " ". Same goes for term.blit
            end
        end
    else
        local oldPixel
        local old = self.old

        local oldTc, oldBg = 1, 32768
        setTextColour( oldTc )
        setBackgroundColour( oldBg )

        for y = 1, height do
            for x = 1, width do
                pixel = buffer[ pos ]
                oldPixel = old[ pos ]

                if force or not oldPixel or not ( oldPixel[1] == pixel[1] and oldPixel[2] == pixel[2] and oldPixel[3] == pixel[3] ) then

                    setCursorPos( x, y )

                    local t = pixel[2] or tc
                    if t ~= oldTc then setTextColour( t ) oldTc = t end

                    local b = pixel[3] or bg
                    if b ~= oldBg then setBackgroundColour( b ) oldBg = b end

                    write( pixel[1] or " " )

                    old[ pos ] = { pixel[1], pixel[2], pixel[3] }
                end
                pos = pos + 1
            end
        end
    end
end
