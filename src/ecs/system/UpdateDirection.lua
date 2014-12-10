local System; import 'ecs'
local UpdateDirection = class(System)

function UpdateDirection:requires()
	return {'action', 'direction'}
end

function UpdateDirection:update(e, _, action, dir)

	if  dir.x ~= 0 or action.left or action.right then
	    local dx  =  (action.left  and -1 or 0)
	           	  +  (action.right and  1 or 0)

	    if dx ~= 0 then dir.left = dx < 0 end

	    dir.x     = dx
    end

    if  dir.y ~= 0 or action.up or action.down then
    	dir.y  =     (action.up   and -1 or 0)
        	   +     (action.down and  1 or 0)
    end
end


return UpdateDirection