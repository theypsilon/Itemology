local SystemFactory; import 'system'

return SystemFactory.create(

	'UpdateLevelPosition',
	
	{'level', 'body', 'pos'},

	function(self, e)
		local level, body, pos = e.level, e.body, e.pos
        local ixo, iyo = level.map:toXYO(pos.x, pos.y)
        local x, y     = body:getPosition()
        assert(type(ixo) == 'number')
        assert(type(iyo) == 'number')

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
)