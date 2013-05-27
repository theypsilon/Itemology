physics = {}

function physics.init()

    global{ world = MOAIBox2DWorld.new() }

    world:setGravity( 0, 1 )
    world:setUnitsToMeters( .10 )
    world:start()
    layer.main:setBox2DWorld( world )

end