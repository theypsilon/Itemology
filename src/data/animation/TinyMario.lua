return {
    atlass = data.atlass.Sprites,
    skip = 6,
    default = 'walk',
    mirror  = false,
    constructCall = true,
    sequences = {
        walk  = {'walk', 'stand'}, 
        stand = {'stand'},
        run   = {'run2', 'run1'},
        jump  = {'jump'},
        fly   = {'fly'},
        fall  = {'fall'},
        skid  = {'skid'},
    }
}

    -- sequences = function(self)
    --     coroutine.yield()

    --     local seq = {
    --         walk  = {8, 5}, 
    --         stand = {5}
    --     }

    --     while true do
    --         local animation = seq[self.animation]
    --         self.prop:setIndex(animation[self.step])
    --         if self.step >= #animation then self.step = 1
    --                                    else self.step = self.step + 1 end
    --         coroutine.yield()
    --     end

    -- end