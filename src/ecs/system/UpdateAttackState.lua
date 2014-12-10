local System; import 'ecs'
local Attacks; import()

local UpdateAttackState = class(System)
function UpdateAttackState:requires()
	return {'attackState', 'jumpState', 'attackSelector', 'attackResource'}
end

local function try_create_attack(type, selector, state, e)
    print(type)
    local attack = Attacks[selector[type]](e)
    if attack then
        state.doing = attack
        state.state = type
    end
end

function UpdateAttackState:update(e, dt, state, jump, selector, resource)
    local action = e.action

    if state.state == 'rest' then
        if action.special and state.can_special ~= false  then
            try_create_attack('special', selector, state, e)
        elseif action.run and state.can_attack  ~= false  then
            try_create_attack('attack' , selector, state, e)
        end
    end

    if state.state ~= 'rest' then
        local  continue = state.doing(action[state.state], jump)
        if not continue then
            state.state = 'rest'
            state.doing = nil
        end
    end

    if e.tasks then e.tasks() end
end

-------------------------------------
--   state :  prev  : jump_state   --
-------------------------------------
-- slash   : [rest] : [stand|fall] --
-- bash    : [rest] : [stand]      --
-- shoot   : [rest] : [stand|fall] --
-- special : [rest] : [stand|fall] --
-------------------------------------

return UpdateAttackState