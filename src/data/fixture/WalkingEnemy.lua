return {
    id = 'Mob',
    option = 'dynamic',
    fixtures = {
        ['area']={
                option = 'rect',
                args = {-6, 8, 6, -4},
                density = 0.01,
                restitution = 0,
                friction = 0
        },
        ['sensorL']={
                option = 'circle',
                args = {-10, 8, 2},
                sensor = true
        },
        ['sensorR']={
                option = 'circle',
                args = { 10, 8, 2},
                sensor = true
        },
        ['head']={
                option = 'rect',
                args = { -6, -4, 6, -4},
                sensor = true
        }
    },
    x = 100,
    y = 100,
    mass = 1,
    fixedRotation = true,
}