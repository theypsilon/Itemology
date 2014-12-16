local System; import 'ecs'
local Jumps; import()

local UpdateJumpState = class(System)
function UpdateJumpState:requires()
	return {'jumpState', 'jumpSelector', 'jumpResource'}
end

local function change_state(jump_type, state)
    if jump_type == 'jump' then
        state. jumped = true
    elseif jump_type == 'double_jump' then
        state.djumped = true
        state. jumped = true
        state.wjumped = nil
    elseif jump_type == 'wall_jump' then
        state.wjumped = state.sliding
        state. jumped = true
        state.djumped = nil
    elseif jump_type == 'bounce' then
        state.djumped = nil
    else error('wrong jump_type: '..jump_type) end
end

function UpdateJumpState:update(e, dt, state, selector, resource)

    if state.jumped and not e.action.jump then
        state.jumped = nil
    end

    assert(self[state.state], 'state was manipulated badly')
    local   next_state, jump_type = self[state.state](self, state, e)
    if not  next_state then return end
    if state['can_'..next_state] == false then return end
    if jump_type then
        if state['can_'..jump_type]   == false then return end
        assert(selector [jump_type], 'selector doesnt know about jump_type: '..jump_type)
        local jump_name = selector [jump_type]
        assert(resource [jump_name], 'resource doesnt know about jump_name: '..jump_name)
        local res = resource[jump_name]
        if res >= 1 then
            resource[jump_name]   = res - 1
            local jump_class = Jumps[jump_name]
            state.jumping    = jump_class(e)
            state.state      = 'jump'
            change_state(jump_type, state)
        end
    else
        state.state = next_state
    end
end

function UpdateJumpState:stand(state, e)
    state.djumped = nil
    state.wjumped = nil
    if not state.jumped and e.action.jump then
        return 'jump', 'jump'
    elseif not e.ground.on then
        return 'fall'
    end
end

function UpdateJumpState:jump(state, e)
    if not state.jumping(e) then
        state.jumping = nil
        return 'fall'
    end
end

function UpdateJumpState:fall(state, e)
    if not state.djumped and not state.jumped and e.action.jump then
        return 'jump', 'double_jump'
    elseif e.onEnemy then
        return 'jump', 'bounce'
    elseif e.dx ~= 0 and e.dx == e.touch.on 
    and state.wjumped ~= e.touch.on then
        state.sliding  = e.touch.on
        return 'slide'
    elseif e.ground.on then
        return 'stand'
    end
end

function UpdateJumpState:slide(state, e)
    if e.touch.on ~= state.sliding then
        return 'fall'
    elseif not state.jumped and e.action.jump then
        return 'jump', 'wall_jump'
    elseif e.ground.on then
        return 'stand'
    end
end

return UpdateJumpState