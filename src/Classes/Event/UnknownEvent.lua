class "UnknownEvent" mixin "Event" {
    main = false;
    sub = "EVENT";
}

function UnknownEvent:initialise( raw )
    self.raw = raw

    self.main = raw[1]:upper()
end
