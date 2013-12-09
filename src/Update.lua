local function update_instance(instance)
    assert(is_object(instance))
    assert(class.is_a == instance.is_a, 'not an instance')
    assert(instance._name and rawget(instance, '_name') == nil)

    for k,v in pairs(reload_related_files(instance)) do
        if is_table(v) and rawget(v, '_name') == instance._name then
            setmetatable(instance, v)
            return true
        end
    end
    return false
end

return {instance = update_instance}