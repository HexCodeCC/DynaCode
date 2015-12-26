abstract class "NodeContainer" extends "Node" {
    acceptMouse = true;
    acceptKeyboard = true;
    acceptMisc = true;

    nodes = {};
    forceRedraw = true;
}

function NodeContainer:getNodeByType( _type )
    local results, nodes = {}, self.nodes

    for i = 1, #nodes do
        local node = nodes[i]
        if class.typeOf( node, _type, true ) then results[ #results + 1 ] = node end
    end
    return results
end

function NodeContainer:getNodeByName( name )
    local results, nodes = {}, self.nodes

    for i = 1, #nodes do
        local node = nodes[i]
        if node.name == name then results[ #results + 1 ] = node end
    end
    return results
end

function NodeContainer:addNode( node )
    node.parent = self
    node.stage = self.stage

    self.nodes[ #self.nodes + 1 ] = node
end

function NodeContainer:removeNode( nodeOrName )
    local nodes = self.nodes

    local isName = not ( class.isInstance( nodeOrName ) and class.__node )

    for i = 1, #nodes do
        local node = nodes[i]
        if (isName and node.name == nodeOrName) or ( not isName and node == nodeOrName ) then
            node.parent = nil
            return table.remove( self.nodes, i )
        end
    end
end
