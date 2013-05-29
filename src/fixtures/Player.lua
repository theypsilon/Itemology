return {
    id = 'Mob',
    option = 'dynamic',
    fixtures = {
        {  
            option = 'rect',
            args = {-8, 8, 8, -8},
            density = 0.01,
            restitution = 0,
            friction = 2
        },{
            option = 'rect',
            args = {-8, 8, 8, -8},
            sensor = true
        }
    },
    x = 100,
    y = 100,
    mass = 1,
    fixedRotation = true,
}