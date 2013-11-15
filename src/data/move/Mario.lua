return {
    ogHorForce          = 10,  -- on ground horizontal force
    oaHorForce          = 2.4, -- on air horizontal force
    maxVxWalk           = 150, -- maximum speed by walking
    maxVxRun            = 250, -- maximum speed by running
    alwaysRun           = false,

    slowWalk            = 1.5, -- slowdown rate when stop walking (friction-like)
    slowRun             = 0.4, -- slowdown rate when stop running (friction-like)
    maxVyFall           = 250, -- maximum speed when falling down
    addGravity          = 10,  -- additional gravity for the character
    timeFactor          = 40,  -- factor rate: multiplies time differential

    jumpImp             = {250, 0, 0, 0, 50, 50, 50}, -- progressive jump impulse
    djumpUp             = 350, -- double jump up velocity
    djumpMaxVx          = 100, -- double jump horizontal velocity max limit
    wjumpVxBase         = 150, -- wall jump lateral base velocity
    wjumpVxPlus         = 100, -- wall jump additional velocity if move keys are pressed

    wjumpUp             = 300, -- wall jump up velocity
    wallSlidingSpeed    = 75,  -- falling velocity when sliding against a wall

}