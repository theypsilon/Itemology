local System; import 'ecs'
local RemoveEntities = class(System)

function RemoveEntities:requires()
    return {'removed'}
end

function RemoveEntities:update(e)
    if e.prop then e.prop:clear(); e.prop = nil end
    if e.body then e.body:clear(); e.body = nil end
    if e.level then e.level:remove(e) else self.manager:remove_entity(e) end
end


return RemoveEntities