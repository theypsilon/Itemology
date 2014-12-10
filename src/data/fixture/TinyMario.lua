local f = require 'data.fixture.Filters'
return {
    option = 'dynamic',
    fixtures = {
        area = {
                option = 'rect',
                args = {-6, 8, 6, -6},
                restitution = 0,
                friction = 0
        },
        foot = {{
                option = 'circle',
                args = {-4, 8, 2},
                sensor = true
            },{
                option = 'circle',
                args = {4, 8, 2},
                sensor = true
            }
        },
        kill = {
                option = 'rect',
                args = {-8, 6, 8, 12},
                sensor = true
        },
        hand_left = { 
                option = 'circle',
                args = {-8, 0, 3},
                sensor = true
        },
        hand_right = {
                option = 'circle',
                args = { 8, 0, 3},
                sensor = true
        }
    },
    x = 0,
    y = 0,
    fixedRotation = true,
    bullet      = true,
    fixCategory = f.C_FRIEND,
    fixMask     = f.M_FRIEND,
}