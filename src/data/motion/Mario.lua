return {
    update              = true,

    hitpoints           = 5,

    -- MOTION

    ogHorForce          = 10,  -- on ground horizontal force
    oaHorForce          = 2.4, -- on air horizontal force
    maxVxWalk           = 150, -- maximum speed by walking
    maxVxRun            = 250, -- maximum speed by running
    alwaysRun           = false,

    slowWalk            = .6258, -- slowdown rate when stop walking (friction-like)
    slowRun             = .9,  -- slowdown rate when stop running (friction-like)
    maxVyFall           = 350, -- maximum speed when falling down
    addGravity          = 20,  -- additional gravity for the character
    timeFactor          = 40,  -- factor rate: multiplies time differential

    -- JUMPS

    jumpImp             = {150, 150, 130, 130, 110, 110, 110, 110}, -- progressive jump impulse

    wjumpVxBase         = 150, -- wall jump lateral base velocity
    wjumpVxPlus         = 25, -- wall jump additional velocity if move keys are pressed

    wjumpUp             = 350, -- wall jump up velocity
    wallSlidingSpeed    = 75,  -- falling velocity when sliding against a wall

    djumpUp             = 350, -- double jump up velocity
    djumpMaxVx          = 100, -- double jump horizontal velocity max limit

    sjumpGravity        = 0.7,
    sjumpMaxFallSpeed   = 100,

    fjumpGravity        = 0,
    fjumpInitVLimit     = 100,
    fjumpInitVFactor    = 3,
    fjumpCancelValue    = 3,
    fjumpChargeTime     = 60,
    fjumpFlyTime        = 60,
    fjumpMinChargeValue = 10,
    fjumpChargeFactor   = 1.3,

    kjumpCadenceTime    = 15,
    kjumpFullTime       = 200,
    kjumpFallSpeedLimit = 30,

    tjumpDiagonalFactor = 65,
    tjumpStraightFactor = 110,
    tjumpFreezing       = 0,

    pjumpGravity        = 0,
    pjumpFlyTime        = 60,
    pjumpRepeat         = math.huge,

    xjumpJumpSpeed      =  305,
    xjumpJumpTime       =    3,
    xjumpJumpVertLimit  =   30,
    xjumpRejumpVyLimit  = math.huge,
    xjumpRejumpFalling  = false,
    xjumpGravity        =  0.3,
    xjumpFallSpeedLimit =   30,
}