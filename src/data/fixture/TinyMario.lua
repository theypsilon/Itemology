local f = require 'data.fixture.Filters'
return {
    id = 'Mob',
    option = 'dynamic',
    fixtures = {
        ['area']={
                option = 'rect',
                args = {-6, 8, 6, -6},
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
        foot3 = {
                option = 'rect',
                args = {-8, 6, 8, 10},
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
    fixedRotation = true,
    bullet      = true,
    fixCategory = f.C_FRIEND,
    fixMask     = f.M_FRIEND,
}