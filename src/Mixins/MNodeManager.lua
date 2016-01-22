abstract class "MNodeManager" {
    nodes = {};
}

function MNodeManager:addNode( node )
    node.parent = self
    node.stage = self.stage

    table.insert( self.nodes, node )

    return node
end

function MNodeManager:removeNode( nodeOrName )
    local isName = type( nodeOrName ) == "string"
    local nodes = self.nodes

    local node
    for i = 1, #nodes do
        node = nodes[ i ]

        if (isName and node.name == nodeOrName) or (not isName and node == nodeOrName) then
            table.remove( nodes, i )
            return true
        end
    end

    return false
end

function MNodeManager:getNode( name )
    local nodes = self.nodes

    local node
    for i = 1, #nodes do
        node = nodes[ i ]

        if node.name == name then
            return node
        end
    end

    return false
end

function MNodeManager:clearNodes()
    for i = #self.nodes, 1, -1 do
        self:removeNode( self.nodes[ i ] )
    end
end

function MNodeManager:appendFromDCML( path )
    local data = DCML.parse( DCML.readFile( path ) )

    if data then for i = 1, #data do
        self:addNode( data[i] )
    end end
end

function MNodeManager:replaceWithDCML( path )
    self:clearNodes()
    self:appendFromDCML( path )
end
