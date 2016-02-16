local insert = table.insert
local alias = {
    leftShift = "shift";
    rightShift = "shift";

    leftCtrl = "ctrl";
}

abstract class "MHotkeyManager" {
    hotkeys = {};
    keys = {};
}

function MHotkeyManager:scanHotkeys()
    local hotkeys, keys, hotkey, ok, parts = self.hotkeys, self.keys
    for i = 1, #hotkeys do
        hotkey = hotkeys[ i ]
        local ignoreConsumed = hotkey[ 4 ]

        parts, ok = hotkey[ 2 ], true

        local part
        for i = 1, #parts do
            part = parts[ i ]

            if not keys[ parts[i] ] or ( not ignoreConsumed and keys[ parts[i] ][1] ) then
                -- not pressed or consumed
                ok = false
                break
            end
        end

        if ok then
            -- consume the keys and execute the callback
            if not ignoreConsumed then for i = 1, #parts do
                keys[ parts[ i ] ][1] = true
            end end

            hotkey[ 3 ]( self )
        end
    end
end

function MHotkeyManager:handleKeyEvent( event )
    local keyname, keys = keys.getName( event[ 2 ] ), self.keys
    keyname = alias[ keyname ] or keyname

    if event[1] == "key" then
        if keys[ keyname ] then return end
        keys[ keyname ] = { false }
    elseif event[1] == "key_up" then
        keys[ keyname ] = nil
    end
end

function MHotkeyManager:createHotkey( name, combination, callback, ignoreConsumed )
    if not ( type( name ) == "string" and type( combination ) == "string" and type( callback ) == "function" ) then
        return ParameterException("Expected string, string, function [, boolean]")
    end

    local requiredKeys = {}
    for word in string.gmatch(combination, "([^-]+)") do
        insert( requiredKeys, alias[ word ] or word )
    end

    insert( self.hotkeys, {
        name,
        requiredKeys,
        callback,
        ignoreConsumed
    })
end

function MHotkeyManager:removeHotkey( name )
    if type( name ) ~= "string" then
        return ParameterException("Failed to remove hotkey, expected string 'name' of hotkey to remove")
    end
    local hotkeys = self.hotkeys

    for i = 1, #hotkeys do
        if hotkeys[ i ][ 1 ] == name then
            table.remove( hotkeys, i )
            return true
        end
    end
end
