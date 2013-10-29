return {
    id = 'Mob',
    option = 'dynamic',
    fixtures = {
        ['area']={
                option = 'rect',
                args = {-6, 8, 6, -6},
                density = 0.01,
                restitution = 0,
                friction = 0
        },
        ['sensor1']={
                option = 'circle',
                args = {-4, 8, 2},
                sensor = true
        },
        ['sensor2']={
                option = 'circle',
                args = {4, 8, 2},
                sensor = true
        }
    },
    x = 100,
    y = 100,
    mass = 1,
    fixedRotation = true,
}