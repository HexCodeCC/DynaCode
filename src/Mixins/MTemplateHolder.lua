abstract class "MTemplateHolder" {
    templates = {};
    activeTemplate = nil;
}

function MTemplateHolder:registerTemplate( template )
    if classLib.typeOf( template, "Template", true ) then
        if not template.owner then
            -- Do any templates with the same name exist?
            if not self:getTemplateByName( template.name ) then
                template.owner = self

                table.insert( self.templates, template )
                return true
            else
                ParameterException("Failed to register template '"..tostring( template ).."'. A template with the name '"..template.name.."' is already registered on this object ("..tostring( self )..").")
            end
        else
            ParameterException("Failed to register template '"..tostring( template ).."'. The template belongs to '"..tostring( template.owner ).."'")
        end
    else
        ParameterException("Failed to register object '"..tostring( template ).."' as template. The object is an invalid type.")
    end
    return false
end

function MTemplateHolder:unregisterTemplate( nameOrTemplate )
    local isName = type( nameOrTemplate ) == "string"
    local templates = self.templates

    local template
    for i = 1, #templates do
        template = templates[ i ]

        if (isName and template.name == nameOrTemplate) or (not isName and template == nameOrTemplate) then
            -- This is our guy!
            template.owner = nil
            table.remove( templates, i )

            return true -- boom, job done
        end
    end

    return false -- we didn't find a template to un-register.
end

function MTemplateHolder:getTemplateByName( name )
    local templates = self.templates

    local template
    for i = 1, #templates do
        template = templates[ i ]

        if template.name == name then
            return template
        end
    end

    return false
end

function MTemplateHolder:setActiveTemplate( nameOrTemplate )
    if type( nameOrTemplate ) == "string" then
        local target = self:getTemplateByName( nameOrTemplate )

        if target then
            self.activeTemplate = target
            self.changed = true
            self.forceRedraw = true
        else
            ParameterException("Failed to set active template of '"..tostring( self ).."' to template with name '"..nameOrTemplate.."'. The template could not be found.")
        end
    elseif classLib.typeOf( nameOrTemplate, "Template", true ) then
        self.activeTemplate = nameOrTemplate
        self.changed = true
        self.forceRedraw = true
    else
        ParameterException("Failed to set active template of '"..tostring( self ).."'. The target object is invalid: "..tostring( nameOrTemplate ) )
    end
end

function MTemplateHolder:getNodes()
    if self.activeTemplate then
        return self.activeTemplate.nodes
    end

    return self.nodes
end
