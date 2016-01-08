class "TextContainer" extends "MultiLineTextDisplay"

function TextContainer:setText( text )
    self.text = text

    if self.__init_complete then
        self.container.text = text
    end
end
