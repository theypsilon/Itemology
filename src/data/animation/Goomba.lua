local Data; import();
return {
    atlass          = Data.atlass.Sprites,
    skip            = 6,
    default         = 'walk',
    mirror          = false,
    constructCall   = true,
    sequences = {
        walk  = {'goomba1', 'goomba2'}, 
        die   = function(a, entity, a, c)
            local  init  =  entity.ticks
            coroutine.yield()
            while  init + 100 > entity.ticks do coroutine.yield('deadgoomba') end
        end
    },
    extra = {
        toleranceX    = 5,
        toleranceY    = 1,
    }
}