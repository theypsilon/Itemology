local System; import 'ecs'
local UpdateLevelPosition = class(System)

function UpdateLevelPosition:requires()
	return {'level', 'body', 'pos'}
end

function UpdateLevelPosition:update(e, _, level, body, pos)
	if not is_table(level) then return end

    local ixo, iyo = level.map:toXYO(pos.x, pos.y)
    local x, y     = body:getPosition()
    assert(type(ixo) == 'number')
    assert(type(iyo) == 'number')

    local _, limit = level.map:getBorder()
    if y > limit + 100 then
    	e:remove()
    end

    if e.removed then
        level.entities[e] = nil
        level:removeEntity(e, ixo, iyo)
    else
        local fxo, fyo = level.map:toXYO(x, y)
        assert(type(fxo) == 'number')
        assert(type(fyo) == 'number')
    	
        if fxo ~= ixo or fyo ~= iyo then
            level:removeEntity(e, ixo, iyo)
            level:insertEntity(e, fxo, fyo)
        end
	end

    pos.x, pos.y = x, y
end


return UpdateLevelPosition