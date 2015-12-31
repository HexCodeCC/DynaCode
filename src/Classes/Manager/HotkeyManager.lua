local insert, remove, sub, len = table.insert, table.remove, string.sub, string.len

local cache = {}
local heldSupport = true
local redirects = {
    leftShift = "shift";
    rightShift = "shift";

    leftCtrl = "ctrl";
}

class "HotkeyManager" {
    keys = {};
    combinations = {};

    application = nil;
}

function HotkeyManager:initialise( application )
    self.application = AssertClass( application, "Application", true, "HotkeyManager requires an Application Instance as its constructor argument, not '"..tostring( application ).."'")
end

local function matchCombination( self, combination, pressOnly )
    local parts = {}
    if cache[ combination ] then
        parts = cache[ combination ]
    else
        -- seperate into parts
        for word in string.gmatch(combination, '([^-]+)') do
            parts[#parts+1] = word
        end
        cache[ combination ] = parts
    end

    -- Check if each key is pressed
    local ok = true
    for i = 1, #parts do
        if not self.keys[ parts[i] ] or ( pressOnly and self.keys[ parts[i]].held ) then
            -- if the key is not being pressed or the key is being held and the combination needs an un-pressed key.
            ok = false
            break
        end
    end

    return ok
end

function HotkeyManager:assignKey( event, noRedirect )
    -- A key has been pressed
    if event.main == "KEY" then
        -- set key
        if event.held == nil then
            -- doesn't support
            heldSupport = false
        end
        local name = keys.getName( event.key )
        local keyData = { held = event.held, keyID = event.key }

        if not name then return end

        self.keys[ name ] = keyData
        if not noRedirect then
            -- if the key has a redirect, create that redirect too
            local re = redirects[ name ]
            if re then
                self.keys[ re ] = keyData
            end
        end
    end
end

function HotkeyManager:relieveKey( event, noRedirect )
    -- A key has been un-pressed (key up/relieved)
    if event.main == "KEY" then
        local name = keys.getName( event.key )
        if not name then return end

        self.keys[ name ] = nil

        if not noRedirect then
            local re = redirects[ name ]
            if re then
                self.keys[ re ] = nil
            end
        end
    end
end

function HotkeyManager:handleKey( event )
    if event.sub == "UP" then
        self:relieveKey( event )
    else
        self:assignKey( event )
    end
end

function HotkeyManager:matches( combination )
    -- A program wants to know if a combination of keys has been met
    return matchCombination( self, combination )
end

function HotkeyManager:registerCombination( name, combination, callback, mode )
    -- Register this combination with a specified callback to be executed when its met.
    if not name or not combination or not type( callback ) == "function" then return error("Expected string name, string combination, function callback") end

    self.combinations[ #self.combinations + 1 ] = { name, combination, mode or "normal", callback }
end

function HotkeyManager:removeCombination( name )
    -- Remove a combination by name.
    if not name then return error("Requires name to search") end

    for i = 1, #self.combinations do
        local c = self.combinations[i]
        if c[1] == name then
            table.remove( self.combinations, i )
            break
        end
    end
end

function HotkeyManager:checkCombinations()
    -- Checks every combinations matching requirements against the pressed keys.
    for i = 1, #self.combinations do
        local c = self.combinations[i]
        if matchCombination( self, c[2], c[3] == "strict" ) then
            c[4]( self.application )
        end
    end
end

function HotkeyManager:reset()
    -- if the app is restarted clear the currently held keys
    self.keys = {}
end
