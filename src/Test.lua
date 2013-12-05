local GC = class()

GC.i = 0

function GC:_init()
    GC.i = GC.i + 1
end

function GC:__gc()
    GC.i = GC.i - 1
end

return GC