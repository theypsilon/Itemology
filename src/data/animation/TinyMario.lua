local Data; import();
return {
    atlass = Data.atlass.Sprites,
    skip = 6,
    default = 'walk',
    mirror  = false,
    constructCall = true,
    sequences = {
        walk  = {'walk', 'stand'}, 
        stand = {'stand'},
        run   = {'run2', 'run1'},
        jump  = {'jump'},
        fly   = {'fly'},
        fall  = {'fall'},
        skid  = {'skid'},
        die   = function(animation, entity)
            local  body = require('Physics'):registerBody({option = 'dynamic'}, animation.prop)
            local     e = entity.pos.y
            local _,  l = entity.level.map:getBorder()
            local _,  y = body:getPosition()
            y = y + e

            local particle = {
                physic_change = {vx = 0, vy = -130},
                body          = body,
                modeDef       = {addGravity = 50, maxVyFall = 150}
            }

            entity.level.manager:add_entity(particle)

            coroutine.yield()

            local v
            while y < l do
                _, y = body:getPosition()
                y = y + e
                coroutine.yield('dead')
            end
        end
    },
    extra = {
        toleranceX    = 5,
        toleranceY    = 1,
        walkRunUmbral = 0.9,
    }
}