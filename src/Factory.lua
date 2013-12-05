local Factory = class()

function Factory:_init(callbacks)
    self.instances = {}
    self.callbacks = callbacks or {}
end

function Factory:__index(key)
    if  self.instances[key] then return self.instances[key] end
    if  self.callbacks[key] then
        self.instances[key] = self.callbacks[key]() or 
            error('Factory index "' .. key .. '" has to return a value.')
        return self.instances[key]
    end
    return nil
end

function Factory:__newindex(key, callback)
    assert(not self.instances[key], 'Factory index "' .. key .. '" can not be overwritten.')
    assert(is_function(callback)  , 'Wrong callback for a Factory!')
    self.callbacks[key] = callback
end

function Factory:set(key, callback)
    self:__newindex (key, callback)
end

function Factory:instantiate()
    for key, func in pairs(self.callbacks) do 
        self.instances[key] = func() or error('Factory index "' .. key .. '" has to return a value.')
    end
    self.callbacks = {}
end

return Factory