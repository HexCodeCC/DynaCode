-- Templates can be used by stages and container nodes normally via the use of ':openTemplate'. Templates can also be created using ':exportTemplate'

-- Because contained nodes will require a 'stage' and/or 'parent' property Templates will have to be registered to an owner.
-- The stage/parent will then be extracted from the owner and the template's owner will be locked.

class "Template" mixin "MNodeManager" {
    nodes = {};

    owner = nil;
    name = nil;
}

function Template:initialise( name, owner, DCML )
    self.name = type( name ) == "string" and name or ParameterException("Failed to initialise template. Name '"..tostring( name ).."' is invalid.")
    self.owner = classLib.isInstance( owner ) and owner or ParameterException("Failed to initialise template. Owner '"..tostring( owner ).."' is invalid.")

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
end
