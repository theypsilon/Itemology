local frames  = {
    stand = {x = 0,    y = 0,   w = 15, h = 15},
    walk  = {x = 16,   y = 0,   w = 15, h = 15},
    skid  = {x = 32,   y = 0,   w = 15, h = 15},
    jump  = {x = 48,   y = 0,   w = 15, h = 15},
    run1  = {x = 64,   y = 0,   w = 15, h = 15},
    run2  = {x = 80,   y = 0,   w = 15, h = 15},
    fly   = {x = 96,   y = 0,   w = 15, h = 15},
    fall  = {x = 112,  y = 0,   w = 15, h = 15},
}

return Atlass('grid.png', frames, layer.main)