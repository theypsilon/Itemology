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
        ['foot1']={
                option = 'circle',
                args = {-4, 8, 2},
                sensor = true
        },
        ['foot2']={
                option = 'circle',
                args = {4, 8, 2},
                sensor = true
        },
        ['hand1']={
                option = 'circle',
                args = {-8, 0, 3},
                sensor = true
        },
        ['hand2']={
                option = 'circle',
                args = { 8, 0, 3},
                sensor = true
        },
    },
    x = 0,
    y = 0,
    mass = 1,
    fixedRotation = true,
}