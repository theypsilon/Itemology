local Animation = class.Animation()
local Atlass = require 'Atlass'

local function table_next(self)
    local animation = self.animation
    self.prop:setIndex(animation[self.step])
    if self.step >= #animation then self.step = 1
                               else self.step = self.step + 1 end
    return true
end

local function coroutine_next(self, ...)
    if coroutine.status(self.animation) == 'dead' then return false, false end
    local  status, img, extra = coroutine.resume(self.animation, self, ...)
    if     status and img then self.prop:setIndex(self.atlass:get(img).i) end
    if not status and img then error(img) end
    return status, extra
end

function Animation:_init(definition, prop, skip, default)
    
    local atlass   = Atlass(definition.atlass)

    self.skip      = definition.skip or 1
    self.frame     = definition.skip or 1
    self.mirror    = definition.mirror == true
    self.extra     = definition.extra
    self.prop      = prop or atlass:prop()

    default        = default or definition.default

    local newSequences = {}
    for name,seq in pairs(definition.sequences) do
        if type(seq) == 'table' then
            local newSeq = {}
            for k,v in pairs(seq) do newSeq[k] = atlass:get(v).i end
            newSequences[name] = newSeq
        else
            self.atlass = atlass
            newSequences[name] = coroutine.create(seq)
        end
    end
    self.sequences = newSequences
    self._nextStep = table_next

    if default then self:setAnimation(default) end

    atlass:get(definition.sequences[definition.default][1]):newProp(self.prop)
end

function Animation:setAnimation(animation)
    local  seq = self.sequences[animation]
    assert(seq, 'no animation sequence named "' .. animation .. '"')
    if seq ~= self.animation then 
        if type(seq) == 'table' then 
            self.step = 1
            self._nextStep = table_next
        else
            self._nextStep = coroutine_next
        end
        self.animation = seq
    end
    return self
end

function Animation:next(...)
    if self.frame < self.skip then 
        self.frame = self.frame + 1
        return false, true
    else
        self.frame = 1
    end

    return true, self:_nextStep(...)
end

function Animation:setMirror(boolean)
    if boolean ~= self.mirror then self.prop:setScl(-1, 1) else self.prop:setScl(1, 1) end
    return self
end

return Animation