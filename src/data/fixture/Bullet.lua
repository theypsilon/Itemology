local f = require 'data.fixture.Filters'
return {
    id = 'Mob',
    option = 'dynamic',
    fixtures = {
        ['area']={
                option = 'rect',
                args = {-1, 1, 1, -1},
                density = 1,
                restitution = 100,
                friction = 100
        },
    },
    x = 0,
    y = 0,
    mass = 100,
    fixedRotation = true,
    bullet = true,
    gravityScale = 0,

    fixCategory = f.C_FRIEND_SHOOT,
    fixMask     = f.M_FRIEND_SHOOT
}