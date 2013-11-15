return {
    atlass = data.atlass.Sprites,
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
            local    ey = entity.y
            local _, ly = entity.level.map:getBorder()
            local _,  y = body:getPosition()
            y = y + ey

            coroutine.yield()
            body:applyLinearImpulse(0, -250)
            while y < ly do
                _, y = body:getPosition()
                y = y + ey
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