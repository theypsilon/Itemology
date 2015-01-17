require 'test.Bootstrap'

describe('ecs.system.UpdateWalker', function()

    local UpdateWalker = require 'ecs.system.UpdateWalker'

    describe('Update', function()
        local def = require 'src.data.motion.Mario'
        local e, dt, dir, v
        local body = {setLinearVelocity = function(_, x, y) v.x, v.y = x, y end}
        local factor = 0.1/6.0
        local post_dt = 1 / (1.5 * def.timeFactor)

        local function reset_values()
            e        = {ground = {on = true}, vy = 0, _name = "Player"}
            dt       = 1.5
            dir      = {x = 0, y = 0}
            v        = {x = 0, y = 0}
            spy.on(body, "setLinearVelocity")
        end

        before_each(reset_values)

        it('starts moving to the right', function()
            dir.x = 1

            UpdateWalker.update({}, e, dt, nil, dir, v, def, body)

            assert.are.same({
                x = def.maxVxWalk*factor*def.ogHorForce*post_dt, y = 0
            }, v)
            assert.spy(body.setLinearVelocity).was.called(1)
        end)

        it('moves to the right, with velocity >= max, changes nothing', function()
            dir.x = 1
            v.x = def.maxVxWalk

            UpdateWalker.update({}, e, dt, nil, dir, v, def, body)

            assert.spy(body.setLinearVelocity).was.called(0)
        end)

        it('does not move, changes nothing', function()
            UpdateWalker.update({}, e, dt, nil, dir, v, def, body)

            assert.spy(body.setLinearVelocity).was.called(0)
        end)

        local right = def.maxVxWalk * .9

        it('moves right and stops', function()
            v.x = right

            UpdateWalker.update({}, e, dt, nil, dir, v, def, body)

            assert.are.same({
                x = right * def.slowWalk, y = 0
            }, v)
            assert.spy(body.setLinearVelocity).was.called(1)
        end)

        it('moves right and changes direction', function()
            v.x = right
            dir.x = -1
            e.ground.on = false

            UpdateWalker.update({}, e, dt, nil, dir, v, def, body)
            UpdateWalker.update({}, e, dt, nil, dir, v, def, body)
            UpdateWalker.update({}, e, dt, nil, dir, v, def, body)

            assert.are.same({
                x = right * def.slowWalk, y = 0
            }, v)
            assert.spy(body.setLinearVelocity).was.called(3)
        end)
    end)
end)