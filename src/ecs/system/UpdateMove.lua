local System; import 'ecs'
local UpdateMove = class(System)

function UpdateMove:requires()
	return {'controller', 'ability', 'move'}
end

function UpdateMove:update(e, _, controller, ability, move)
    ability = {
        {'jump', 'setJump'},
        {},
    }


    local next_move = {}
    if controller.left or controller.right then
        table.insert(next_move, 'dx')
        e.dx =  (controller.left  and -1 or 0) + 
                (controller.right and +1 or 0)
    end
 
    for i, 0, #ability do
        local iter     = ability[i]
        local key, val = iter[1], iter[2]
        if controller[key] then
            table.insert(next_move, val)
        end
    end

    move:next(next_move)
end


return UpdateMove