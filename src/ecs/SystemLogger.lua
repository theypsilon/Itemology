local SystemLogger = class()

function SystemLogger:_init(logger, folderpath, is_deep_diff)
    self.folderpath   = folderpath
    self.is_deep_diff = is_deep_diff
    self.system_set   = {}
    self.logger       = logger
end

local function copy(entity)
    local result = {}
    if not is_table(entity) then die(entity) end
    for component_key, component_value in pairs(entity) do
        result[component_key] = is_table(component_value) and table.shallow_copy(component_value) or component_value
    end
    return result
end

local function compare(c1, c2)
    local bool = true
    if is_table(c1) then
        for k, v in pairs(c1) do
            bool = bool and c2[k] == v
        end
    else
        bool = bool and c1 == c2
    end
    return bool
end

function SystemLogger:proxy_updating_methods(system)
    local id = self:get_id(system)

    local class_instance = getmetatable(system)
    
    local update = class_instance.update
    assert(update)
    local update_proxy = function(system, e, dt, ...)
        local backup = self:copy_for_diff(e)
        update(system, e, dt, ...)
        self:add_diff(id, backup, e)
    end

    local remove_entity = class_instance.remove_entity
    assert(remove_entity)
    local remove_entity_proxy = function(system, entity, ...)
        remove_entity(system, entity, ...)
        self:add_remove(id, entity)
    end

    return update_proxy, remove_entity_proxy
end

function SystemLogger:get_id(system)
    local system_descriptor = self.system_set[system]
    if not system_descriptor then
        local count = table.count(self.system_set) + 1
        system_descriptor = {
            file = count .. "_" .. system._name .. ".log", 
            entities = {}
        }
        self.system_set[system] = system_descriptor
    end
    return system_descriptor
end

function SystemLogger:copy_for_diff(entity)
    return copy(entity)
end

function SystemLogger:add_diff(system_descriptor, before, after)
    local added, modified, missing = {}, {}, {}
    for after_k, after_v in pairs(after) do
        local before_v = before[after_k]
        if not before_v then
            table.insert(added, after_k)
        elseif not compare(before_v, after_v) then
            table.insert(modified, after_k)
        end
        before[after_k] = nil
    end
    for before_k, _ in pairs(before) do
        table.insert(missing, before_k)
    end
    local entry = "added:{" .. table.concat(added, ",") .. "}"
           .. ", missing:{" .. table.concat(missing, ",") .. "}"
           ..", modified:{" .. table.concat(modified, ",") .. "}"
    if not system_descriptor[after] or system_descriptor[after] ~= entry then
        system_descriptor[after] = entry
        print(system_descriptor.file .. " > " .. entry)
    end
end

function SystemLogger:add_remove(system_descriptor, entity)
end

return SystemLogger