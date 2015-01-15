require 'test.Bootstrap'

describe('ecs.system.UpdateWalker', function()

    local UpdateWalker = require 'ecs.system.UpdateWalker'

    describe('Update', function()
        local def = require 'src.data.motion.Mario'
        local body_vel, e, dt, dir, v
        local body = {
            setLinearVelocity = function(_, x, y)
                body_vel.x, body_vel.y = x, y
            end
        }
        local factor = 0.1/6.0
        local post_dt = 1 / (1.5 * def.timeFactor)

        before_each(function()
            body_vel = {}
            e        = {ground = {on = true}, vy = 0}
            dt       = 1.5
            dir      = {x = 0, y = 0}
            v        = {x = 0, y = 0}
        end)

        it('starts moving to the right', function()
            dir.x = 1
            UpdateWalker.update({}, e, dt, nil, dir, v, def, body)
            assert.are.same(body_vel, {
                x = def.maxVxWalk*factor*def.ogHorForce*post_dt, y = 0
            })
        end)

        it('moves to the right, with velocity >= max, changes nothing', function()
            dir.x = 1
            v.x = def.maxVxWalk
            UpdateWalker.update({}, e, dt, nil, dir, v, def, body)
            assert.are.same(body_vel, {})
        end)

        local right = def.maxVxWalk * .9

        it('moves right and stops', function()
            v.x = right
            UpdateWalker.update({}, e, dt, nil, dir, v, def, body)
            assert.are.same(body_vel, {
                x = right * def.slowWalk, y = 0
            })
        end)

        it('moves right and changes direction', function()
            v = body_vel
            v.x = right
            dir.x = 1
            UpdateWalker.update({}, e, dt, nil, dir, v, def, body)
            --UpdateWalker.update({}, e, dt, nil, dir, v, def, body)
            --UpdateWalker.update({}, e, dt, nil, dir, v, def, body)
            assert.are.same(body_vel, {
                x = right * def.slowWalk, y = 0
            })
        end)
    end)
end)