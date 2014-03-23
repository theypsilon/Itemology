local System; import 'ecs'
local UpdateJumpState = class(System)

local Text = require 'Text'
local jump_factory = require 'Jumps'

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
    local  next_state, jump = self[state.state](self, state, e)
    if not next_state then return end
    if jump then
        assert(selector[jump], 'selector doesnt know about this jump: '..jump)
        jump = selector[jump]
        assert(resource[jump], 'resource doesnt know about this jump: '..jump)
        local res = resource[jump]
        if res > 1 then
            resource[jump] = res - 1
            state.jumping  = jump_factory(jump, e)
            change_state(state.jumping.type, state)
            next_state     = 'jump'
        end
        print (jump)
    else
        print (next_state)
    end
    state.state = next_state
end

function UpdateJumpState:stand(state, e)
    state.djumped = nil
    state.wjumped = nil
    if not state.jumped and e.action.jump then
        return 'jump', 'jump'
    elseif not e.physics.onGround then
        return 'fall'
    end
end

function UpdateJumpState:jump(state, e)
    if not state.jumping:next(e) then
        state.jumping = nil
        return 'fall'
    end
end

function UpdateJumpState:fall(state, e)
    local physics = e.physics

    if not state.djumped and not state.jumped and e.action.jump then
        return 'jump', 'double_jump'
    elseif physics.onEnemy then
        return 'jump', 'bounce'
    elseif e.dx ~= 0 and e.dx == physics.touchWall 
    and state.wjumped ~= physics.touchWall then
        state.sliding  = physics.touchWall
        return 'slide'
    elseif physics.onGround then
        return 'stand'
    end
end

function UpdateJumpState:slide(state, e)
    local physics = e.physics

    if physics.touchWall ~= state.sliding then
        return 'fall'
    elseif not state.jumped and e.action.jump then
        return 'jump', 'wall_jump'
    elseif physics.onGround then
        return 'stand'
    end
end

return UpdateJumpState