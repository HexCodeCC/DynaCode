class "UnknownEvent" extends "Event" {
    main = false;
    sub = "EVENT";
}

function UnknownEvent:initialise( raw )
    self.super:initialise( raw )

    self.main = raw[1]:upper()
end
