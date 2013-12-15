return {
    image     = 'grid.png',
    defaultcp = {x = 7,    y = 7},
    frames    = table.complete({
        stand = {x = 0,    y = 0},
        walk  = {x = 16,   y = 0},
        skid  = {x = 32,   y = 0},
        jump  = {x = 48,   y = 0},
        run1  = {x = 64,   y = 0},
        run2  = {x = 80,   y = 0},
        fly   = {x = 96,   y = 0},
        fall  = {x = 112,  y = 0},
        dead  = {x = 128,  y = 0},

        goomba1    = {x = 0,  y = 16},
        goomba2    = {x = 16, y = 16},
        deadgoomba = {x = 32, y = 16},

        djump      = {x = 0,  y = 32},
        power2     = {x = 16, y = 32},
        power3     = {x = 32, y = 32},

        diamond1   = {x = 0,  y = 48},
        diamond2   = {x = 16, y = 48},
        diamond3   = {x = 32, y = 48},
        diamond4   = {x = 48, y = 48},

        coin1   = {x = 0,   y = 64},
        coin2   = {x = 16,  y = 64},
        coin3   = {x = 32,  y = 64},
        coin4   = {x = 48,  y = 64},
        coin5   = {x = 64,  y = 64},
        coin6   = {x = 80,  y = 64},
        coin7   = {x = 96,  y = 64},
        coin8   = {x = 112, y = 64},

        bullet = {x = 0,  y = 80},
        cursor = {x = 16, y = 80}
    }, {w = 16, h = 16, cp = {0,0}})
}