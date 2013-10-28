class.Animation()

local function table_next(self)
    assert(self.sequences[self.animation], 'no animation sequence named "' .. self.animation .. '"')
    local animation = self.sequences[self.animation]
    self.prop:setIndex(animation[self.step])
    if self.step >= #animation then self.step = 1
                               else self.step = self.step + 1 end
end

local function coroutine_next(self, ...)
    return coroutine.resume(self.sequences, ...)
end

function Animation:_init(definition, prop, skip, ...)
    
    local atlass   = Atlass(definition.atlass)

    self.prop      = atlass.graphics[definition.default]:newProp()
    self.skip      = definition.skip or 1
    self.frame     = 1
    self.mirror    = definition.mirror == true

    if definition.default then self:setAnimation(definition.default) end

    if utils.is_callable(definition.sequences) then
        local co = coroutine.create(definition.sequences)
        self.sequences = co
        if definition.constructCall then coroutine.resume(co, self, ...) end
        Animation._nextStep = coroutine_next
    else
        local newSequences = {}
        for name,seq in pairs(definition.sequences) do
            local newSeq = {}
            for k,v in pairs(seq) do newSeq[k] = atlass:get(v).i end
            newSequences[name] = newSeq
        end
        self.sequences      = newSequences
        Animation._nextStep = table_next
    end
end

function Animation:setAnimation(animation)
    if animation ~= self.animation then self.step = 1 end
    self.animation = animation
end

function Animation:next(...)
    if self.frame < self.skip then 
        self.frame = self.frame + 1
        return
    else
        self.frame = 1
    end

    return self:_nextStep(...)
end

function Animation:setMirror(boolean)
    if boolean ~= self.mirror then self.prop:setScl(-1, 1) else self.prop:setScl(1, 1) end
end