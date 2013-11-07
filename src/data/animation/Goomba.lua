return {
    atlass = data.atlass.Sprites,
    skip = 6,
    default = 'walk',
    mirror  = false,
    sequences = {
        walk  = {'goomba1', 'goomba2'}, 
        -- die   = {
        --     {img = 'goomba1', move={x=0,y=0}, force={x=0,y=0}, speed={}, imp={}, action='none'}

        -- }
    },
    extra = {
        toleranceX    = 5,
        toleranceY    = 1,
    }
}