local TextHelper = {}
function TextHelper.leadingTrim( text )
    return (text:gsub("^%s*", ""))
end
function TextHelper.trailingTrim( text )
    local n = #text
    while n > 0 and text:find("^%s", n) do
        n = n - 1
    end
    return text:sub(1, n)
end

function TextHelper.whitespaceTrim( text ) -- both trailing and leading.
    return (text:gsub("^%s*(.-)%s*$", "%1"))
end
_G.TextHelper = TextHelper
