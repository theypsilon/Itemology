local jump_states = {}

local Jumper = class()
function Jumper:_init(t)
    assert(t == 'jump'      or t == 'double_jump' 
        or t == 'wall_jump' or t == 'bounce', t)
    self.type = t
end

function Jumper:next(e)
    --error 'overload me'
    return false
end

local NormalJumper = class(Jumper)
function NormalJumper:_init()
    Jumper._init('jump')
    self.step  = 0
    self.limit = 1
end

function NormalJumper:next(e)
    if not e.action.jump then return false end
    self.jump(self.step)
    self.step = self.step + 1
    return self.step >= self.limit
end

local function jump_factory(t)
    return Jumper(t)
end

local function c_next_jump(c, state, t)
    state.jumped  = true
    state.jumping = jump_factory(t)
    c:next('jump')
end

local function jump_factory2(t)
    return t == 'jump'        and NormalJumper()
        or t == 'double_jump' and NormalJumper()
        or t == 'wall_jump'   and NormalJumper()
        or t == 'bounce'      and NormalJumper()
        or error ('unknown jumping type: '..t)
end

function jump_states.stand(c, state, e)
    if state.jumped and not e.action.jump then
        state.jumped = nil
    elseif not state.jumped and e.action.jump then
        c_next_jump(c, state, 'jump')
    elseif not e.physics.onGround then
        c:next('fall')
    end
    state.djumped = nil
    state.wjumped = nil
end

function jump_states.jump(c, state, e)
    if not state.jumping:next(e) then
        state.jumping = nil
        c:next('fall')
    end
end

function jump_states.fall(c, state, e)
    local physics = e.physics
    local powerup = true

    if state.jumped and not e.action.jump then
        state.jumped = nil
    end

    if not state.djumped and powerup  
    and not state.jumped and e.action.jump then
        --consume(powerup)
        state.djumped = true
        c_next_jump(c, state, 'double_jump')
    elseif physics.onEnemy then
        state.djumped = nil
        state.jumping = jump_factory('bounce')
        c:next('jump')
    elseif e.dx ~= 0 and e.dx == physics.touchWall 
    and state.wjumped ~= physics.touchWall then
        state.sliding  = physics.touchWall
        c:next('slide')
    elseif physics.onGround then
        c:next('stand')
    end
end

function jump_states.slide(c, state, e)
    local physics = e.physics
    if state.jumped and not e.action.jump then
        state.jumped = nil
    end

    if physics.touchWall ~= state.sliding then
        c:next('fall')
    elseif not state.jumped and e.action.jump then
        state.wjumped = state.sliding
        c_next_jump(c, state, 'wall_jump')
    elseif physics.onGround then
        c:next('stand')
    end
end

local  Job = require 'Job'
return Job.chain(jump_states, 'stand')