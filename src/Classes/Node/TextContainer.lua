class "TextContainer" extends "MultiLineTextDisplay"

function TextContainer:setText( text )
    self.text = text

    if self.__init_complete then
        self:parseIdentifiers()
        self.container:cacheSegmentInformation()

        -- Because the user may have been scrolling when the text changed, make sure that the Y offset isn't too big for this text.
        self.verticalScroll = math.max( math.min( self.verticalScroll, self.container.height - 1 ), 0 )

        self.changed = true
    end
end
