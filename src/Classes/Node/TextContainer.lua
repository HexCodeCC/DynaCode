class "TextContainer" extends "MultiLineTextDisplay"

function TextContainer:initialise( ... )
    local text, X, Y, width, height = ParseClassArguments( self, { ... }, { {"text", "string"}, {"X", "number"}, {"Y", "number"}, {"width", "number"}, {"height", "number"} }, true, true )
    self.super( X, Y, width, height )

    self.text = text
    self.container = FormattedTextObject( self, self.width )

    self.nodes[ 1 ] = self.container
end

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

function TextContainer:setWidth( width )
    self.super:setWidth( width )
    if self.container then self.container:cacheSegmentInformation() end
end
