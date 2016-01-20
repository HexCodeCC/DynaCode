-- Templates can be used by stages and container nodes normally via the use of ':openTemplate'. Templates can also be created using ':exportTemplate'

-- Because contained nodes will require a 'stage' and/or 'parent' property Templates will have to be registered to an owner.
-- The stage/parent will then be extracted from the owner and the template's owner will be locked.

class "Template" extends "MNodeManager" {
    nodes = {};

    owner = nil;
    name = nil;
}

function Template:initialise( name, owner, DCML )
    self.name = type( name ) == "string" and name or ParameterException("Failed to initialise template. Name '"..tostring( name ).."' is invalid.")
    self.owner = classLib.isInstance( owner ) and owner or ParameterException("Failed to initialise template. Owner '"..tostring( owner ).."' is invalid.")

    self.isStageTemplate = self.owner.__type == "Stage"

    if DCML then
        if type( DCML ) == "table" then
            for i = 1, #DCML do
                self:appendFromDCML( DCML[i] )
            end
        elseif type( DCML ) == "string" then
            self:appendFromDCML( DCML )
        else
            ParameterException("Failed to initialise template. DCML content '"..tostring( DCML ).."' is invalid type '"..type( DCML ).."'")
        end
    end

    self:__overrideMetaMethod("__add", function( a, b )
        if a == self then
            if classLib.isInstance( b ) and b.__node then
                return self:addNode( b )
            else
                return error("Invalid right hand assignment. Should be instance of DynaCode node. "..tostring( b ))
            end
        end
    end)
end

function Template:addNode( node )
    if self.isStageTemplate then
        node.stage = self.owner
    else
        node.stage = self.owner.stage or ParameterException("Failed to add node to template. Couldn't find 'stage' parameter on owner '"..tostring( self.owner ).."'")
        node.parent = self.owner
    end

    table.insert( self.nodes, node )

    return node
end
