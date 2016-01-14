-- Templates can be used by stages and container nodes normally via the use of ':openTemplate'. Templates can also be created using ':exportTemplate'

-- Because contained nodes will require a 'stage' and/or 'parent' property Templates will have to be registered to an owner.
-- The stage/parent will then be extracted from the owner and the template's owner will be locked.

class "Template" {
    nodes = {};

    owner = nil;
    ID = nil;
}

function Template:addNode()

end
