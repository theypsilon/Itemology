return {
    id = 'Mob',
    option = 'dynamic',
    fixtures = {
        ['area']={
                option = 'rect',
                args = {-6, 8, 6, -6},
                density = 0.01,
                restitution = 0,
                friction = 2
        },
        ['sensor']={
                option = 'circle',
                args = {0, 8, 2},
                sensor = true
        }
    },
    x = 100,
    y = 100,
    mass = 1,
    fixedRotation = true,
}