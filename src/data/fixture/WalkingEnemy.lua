local f = require 'data.fixture.Filters'
return {
    id = 'Mob',
    option = 'dynamic',
    fixtures = {
        ['area']={
                option = 'rect',
                args = {-6, 0, 6, 8},
                restitution = 0,
                friction = 0
        },
        body = {
                option = 'rect',
                args = {-6, -6, 6, 0},
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
    fixedRotation = true,
    fixCategory = f.C_ENEMY,
    fixMask     = f.M_ENEMY
}