local function propagateStage()
    -- Changes to this scene have occurred, let the stage know.
end

local function getFromDCML( path )
    return DCML.parse( DCML.loadFile( path ) )
end

class "Scene" {
    stage = nil;
    nodes = {};
}

function Scene:initialise( id, stage, path )
    self.stage = AssertClass( stage, "Stage", true, "Scene expected 'Stage' instance during initialisation. Got: '"..tostring( stage ).."'")

    if path then
        -- handle DCML loading
    end

    self:__overrideMetaMethod("__add", function( a, b )
        if classLib.typeOf(a, "Scene", true) then
            if classLib.isInstance( b ) and b.__node then
                return self:addNode( b )
            else
                error("Invalid right hand assignment. Should be instance of DynaCode node. "..tostring( b ))
            end
        else
            error("Invalid left hand assignment. Should be instance of Scene. "..tostring( a ))
        end
    end)
    self.ID = id
end

function Scene:addNode( node )
    local nodes = self.nodes

    node.scene = self
    node.stage = self.stage

    nodes[ #nodes + 1 ] = node
    return node
end

function Scene:removeNode( _node )
    local nodes = self.nodes

    local node
    for i = 1, #nodes do
        node = nodes[i]

        if node == _node then
            table.remove( nodes, i )
            break
        end
    end
end

function Scene:getNodeByID( id )
    local nodes = self.nodes

    local node
    for i = 1, #nodes do
        node = nodes[i]

        if node.ID == id then
            return node
        end
    end
end

function Scene:getNodesByType( _type )
    local nodes = self.nodes
    local results = {}

    local node
    for i = 1, #nodes do
        node = nodes[i]

        if node.__type == _type then results[ #results + 1 ] = node end
    end

    return results
end

function Scene:appendFromDCML( path )
    local stage = self.stage
    local data = getFromDCML( path )
    local nodes = self.nodes

    for i = 1, #data do
        local node = data[i]

        if not node.__node then
            return error("Scenes can only load nodes via DCML, not '"..tostring( node ).."'!")
        end
        node.scene = self
        node.stage = stage

        nodes[ #nodes + 1 ] = node
    end
end

function Scene:replaceWithDCML( path )
    -- All nodes will be detached and replaces with the content of the DCML path.
    self:clearNodes()
    self:appendFromDCML( path )
end

function Scene:clearNodes()
    local nodes = self.nodes

    for i = 1, #nodes do
        local node = nodes[i]

        node.stage = nil
        node.scene = nil

        if node.destroy then node:destroy() end

        table.remove( nodes, i )
    end
end
