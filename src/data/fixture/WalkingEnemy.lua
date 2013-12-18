local f = require 'data.fixture.Filters'
return {
    option = 'dynamic',
    fixtures = {
        ['area']={
                option = 'rect',
                args = {-6, 0, 6, 8},
                restitution = 0,
                friction = 0,
                kills = true
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
                args = { -6, -6, 6, 2},
                sensor = true
        }
    },
    x = 100,
    y = 100,
    fixedRotation = true,
    fixCategory = f.C_ENEMY,
    fixMask     = f.M_ENEMY
}