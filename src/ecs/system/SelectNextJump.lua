local System; import 'ecs'
local SelectNextJump = class(System)

function SelectNextJump:requires()
    return {'action', 'power', 'jumpSelector', 'power_type'}
end

function SelectNextJump:update(e, dt, action, power, selector, power_type)
    if not action.select then
        action._select = nil
        return
    end

    if action._select then return end
    action._select = true

    local powers = iter(power)
        :filter(function(k, v) return v > 0 end)
        :totable()

    local select_next = false
    local candidate   = nil

    for k, v in pairs(power) do
        if v > 0 then
            if select_next then
                candidate = k
                break
            elseif not candidate then
                candidate = k
            end
        end
        if k == e.last_selected then
            select_next = true
        end
    end

    if candidate then
        e.last_selected = candidate

        local ptype = power_type[candidate]

        local jump_cat, func_name = ptype[2], ptype[3]

        assert(selector[jump_cat], 'what?? '..jump_cat)
        selector[jump_cat] = func_name
    end
end

return SelectNextJump