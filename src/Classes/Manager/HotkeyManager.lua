local insert, remove, sub, len = table.insert, table.remove, string.sub, string.len

class "HotkeyManager" {
    keys = nil;
    combinations = nil;

    application = nil;
}

function HotkeyManager:initialise( application )
    self.application = AssertClass( application, "Application", true, "HotkeyManager requires an Application Instance as its constructor argument, not '"..tostring( application ).."'")

    self.keys, self.combinations = {}, {}
end

local function matchCombination()

end

function HotkeyManager:assignKey()
    -- A key has been pressed
end

function HotkeyManager:relieveKey()
    -- A key has been un-pressed (key up/relieved)
end

function HotkeyManager:checkCombination()
    -- A program wants to know if a combination of keys has been met
end

function HotkeyManager:registerCombination()
    -- Register this combination with a specified callback to be executed when its met.
end

function HotkeyManager:removeCombination()
    -- Remove a combination by name.
end

function HotkeyManager:checkCombinations()
    -- Checks every combinations matching requirements against the pressed keys.
end
