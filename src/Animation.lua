local Atlass; import()

local Animation = class()

local function hex2rgb(hex)
    if #hex % 2 == 1 then hex = hex:sub(2) end
    local alpha = tonumber('0x' .. hex:sub(7, 8))
    return  {
                tonumber('0x' .. hex:sub(1, 2)) / 255, 
                tonumber('0x' .. hex:sub(3, 4)) / 255, 
                tonumber('0x' .. hex:sub(5, 6)) / 255,
                                alpha and alpha / 255
            }
end

local function set_attr(self, attr)
    if not attr then return end

    if attr.color  then self.prop: setColor(unpack(attr. color)) end
    if attr.scolor then self.prop:seekColor(unpack(attr.scolor)) end
    if attr.skip   then self.skip = attr.skip end
    if attr.once   then for k,_ in pairs(attr) do attr[k] = nil end end

    return attr.sprite or attr[1]
end

local function set_img(self, img)
    if is_table(img) then img = set_attr(self, img) end
    self.prop:setIndex(self.atlass:get(img).i)
end

local function table_next(self)
    local step, animation, attr = self.step, self.animation, self.cur_attr
    self.prop:setIndex(animation[step])
    if step >= #animation then self.step = 1
                          else self.step = step + 1 end

    if attr then set_attr(self, attr[step]) end

    return true
end

local function coroutine_next(self, ...)
    if coroutine.status(self.animation) == 'dead' then return false, false end
    local  status, img, extra = coroutine.resume(self.animation, self, ...)
    if     status and img then set_img(self, img) end
    if not status and img then error(img) end
    return status, extra
end

local function process_attributes(attr)
    attr = table.deep_copy(attr)

    local  sprite = attr.sprite or attr[1]
    attr.sprite = nil
    attr[1]     = nil

    local color = attr.color
    if color and not is_table(color) then
        attr.color = hex2rgb(is_string(color) and         color 
                                              or tostring(color))
    end

    color = attr.scolor
    if color then
        if #color < 5 then
            local rgb = hex2rgb(color[1])
            if not rgb[4] then rgb[4] = 0 end
            rgb[5], rgb[6] = color[2], color[3]
            color = rgb
        end
        attr.scolor = color
    end

    for _,k in pairs{'color', 'scolor'} do
        local color = attr[k]
    end

    return sprite, attr
end

function Animation:_init(definition, prop, skip, default)
    
    local atlass   = Atlass(definition.atlass)

    self.skip      = definition.skip or 1
    self.frame     = definition.skip or 1
    self.mirror    = definition.mirror == true
    self.extra     = definition.extra
    self.prop      = prop or atlass:prop()

    default        = default or definition.default

    local newSequences, attributes = {}, {}
    for name,seq in pairs(definition.sequences) do
        if is_table(seq) then
            local newSeq, attr = {}, {}
            for k,v in pairs(seq) do 
                if is_table(v) then v, attr[k] = process_attributes(v) end
                if v then newSeq[k] = atlass:get(v).i end
            end
            newSequences[name] = newSeq
            if not table.empty(attr) then attributes[name] = attr end
        elseif is_function(seq) then
            self.atlass = atlass
            newSequences[name] = coroutine.create(seq)
        else error 'bad definition of animation' end
    end
    self.sequences = newSequences
    self._nextStep = table_next
    if not table.empty(attributes) then self.attributes = attributes end

    if default then self:setAnimation(default) end

    local img = table.first(
                    table.first(
                        table.filter(definition.sequences, is_table)))
    assert(img)
    atlass:get(is_table(img) and (img.sprite or img[1]) or img):newProp(self.prop)
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
    if self.attributes then self.cur_attr = self.attributes[animation] end
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