abstract class "NodeContainer" extends "Node" mixin "MTemplateHolder" mixin "MNodeManager" {
    acceptMouse = true;
    acceptKeyboard = true;
    acceptMisc = true;

    forceRedraw = true;
}

function NodeContainer:resolveDCMLChildren()
    -- If this was defined using DCML then any children will be placed in a table ready to be added to the actual 'nodes' table. This is because the parent node is not properly configured right away.

    local nodes = self.nodesToAdd
    for i = 1, #nodes do
        local node = nodes[i]

        self:addNode( node )
        if node.nodesToAdd and type( node.resolveDCMLChildren ) == "function" then
            node:resolveDCMLChildren()
        end
    end
    self.nodesToAdd = {}
end
