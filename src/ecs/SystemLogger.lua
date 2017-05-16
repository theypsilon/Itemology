local SystemLogger = class()

function SystemLogger:_init(logger_factory, folderpath, is_deep_diff)
    self.folderpath     = folderpath
    self.is_deep_diff   = is_deep_diff
    self.system_set     = {}
    self.logger_factory = logger_factory
    self.entity_id      = 0
    self.entities       = {}
end

local function compare(c1, c2)
    if not is_table(c1) then
        return c1 == c2
    end

    local bool = true
    for k, v in pairs(c1) do
        bool = bool and c2[k] == v
    end
    return bool
end

local function to_string(key, value)
    local format = "%s:%s"
    if is_boolean(value) then
        value = value and "true" or "false"
    elseif is_number(value) then
        format = "%s:%.2g"
    elseif is_table(value) then
        local temp = ""
        for k, v in pairs(value) do
            if not is_fundamental(v) then
                temp = false
                break
            end
            temp = temp .. (temp == "" and "" or ",") .. to_string(k, v)
        end
        value  = temp
        format = value and "%s:{%s}" or "%s"
    elseif is_userdata(value) then
        -- @FIXME: something more concrete, please
        value = "<userdata>"
    end
    return string.format(format, key, value)
end

function SystemLogger:proxy_updating_methods(system)
    local id = self:get_id(system)

    local class_instance = getmetatable(system)
    
    local update = class_instance.update
    assert(update)
    local update_proxy = function(system, e, dt, ...)
        local backup = SystemLogger.copy_for_diff(e)
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
        local file  = count .. "_" .. system._name .. ".log"
        if count < 100 then file = "0" .. file end
        if count <  10 then file = "0" .. file end
        system_descriptor = {
            file     = file,
            logger   = self.logger_factory(file)
        }
        self.system_set[system] = system_descriptor
    end
    return system_descriptor
end

function SystemLogger.copy_for_diff(entity)
    local result = {}
    for component_key, component_value in pairs(entity) do
        if is_table(component_value) then
            result[component_key] = table.shallow_copy(component_value)
        else
            result[component_key] = component_value
        end
    end
    return result
end

function SystemLogger:add_diff(system_descriptor, before, entity)
    local added, modified, missing = {}, {}, {}

    for after_k, after_v in pairs(entity) do
        local before_v = before[after_k]
        if is_nil(before_v) then
            table.insert(added, to_string(after_k, after_v))
        elseif not compare(before_v, after_v) then
            table.insert(modified, to_string(after_k, after_v))
        end
        before[after_k] = nil
    end

    for before_k, before_v in pairs(before) do
        if not is_nil(before_v) then 
            table.insert(missing, to_string(before_k, before_v)) 
        end
    end

    self:insert_entry(system_descriptor, entity, added, modified, missing)
end

function SystemLogger:insert_entry(system_descriptor, entity, added, modified, missing)
    if not system_descriptor[entity] then
        local id = self.entities[entity]
        if not id then 
            id = tostring(entity) .. " " .. self.entity_id
            self.entity_id = self.entity_id + 1
            self.entities[entity] = id
        end
        system_descriptor[entity] = {
            id         = id,
            last_entry = SystemLogger.create_entry(id)
        }
    end

    local descriptor_entity = system_descriptor[entity]

    local entry = SystemLogger.create_entry(descriptor_entity.id, added, missing, modified)

    if descriptor_entity.last_entry ~= entry then
        descriptor_entity.last_entry = entry
        system_descriptor.logger:info(entry)
    end
end

function SystemLogger.create_entry(id, added, missing, modified)
    return string.format("(%s) +{%s} -{%s} ~{%s}", 
        id, 
        added and table.concat(added, ",") or '',
        missing and table.concat(missing, ",") or '', 
        modified and table.concat(modified, ",") or '')
end

function SystemLogger:add_remove(system_descriptor, entity)
end

return SystemLogger