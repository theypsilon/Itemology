local System; import 'system'
local RemoveEntities = class(System)

function RemoveEntities:requires()
    return {'removed'}
end

function RemoveEntities:update(e, dt)
    if e.prop then e.prop:clear(); e.prop = nil end
    if e.body then e.body:clear(); e.body = nil end
    if e.level then e.level:remove(e) else manager:remove_entity(e) end
end


return RemoveEntities