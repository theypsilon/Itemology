return {
    ogHorForce          = 10,  -- on ground horizontal force
    oaHorForce          = 3,   -- on air horizontal force
    maxVxWalk           = 150, -- maximum speed by walking
    maxVxRun            = 250, -- maximum speed by running
    alwaysRun           = true,

    slowWalk            = 1.5, -- slowdown rate when stop walking (friction-like)
    slowRun             = 0.4, -- slowdown rate when stop running (friction-like)
    maxVyFall           = 250, -- maximum speed when falling down
    addGravity          = 10,  -- additional gravity for the character
    timeFactor          = 40,  -- factor rate: multiplies time differential

    jumpImp             = {250, 0, 0, 0, 50, 50, 50}, -- progressive jump impulse
    djumpUp             = 350,
    djumpMaxVx          = 100,
    wjumpVxBase         = 150,
    wjumpVxPlus         = 100,

    wjumpUp             = 300,
    wallSlidingSpeed    = 75,

}