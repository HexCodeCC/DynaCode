local eventMatrix = {
    ["mouse_up"] = MouseEvent;
    ["mouse_click"] = MouseEvent;
    ["mouse_scroll"] = MouseEvent;
    ["mouse_drag"] = MouseEvent;

    ["key"] = KeyEvent;
    ["key_up"] = KeyEvent;
    ["char"] = KeyEvent;
}
function spawnEvent( raw )
    local name = raw[1]

    local m = eventMatrix[ name ]
    if not m then
        return UnknownEvent( raw )
    else
        return m( raw )
    end
end
