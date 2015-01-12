local Import = require 'lib.Import.init'
local Class  = require 'lib.Class.init'
_G.import = Import.import
_G.class  = Class.class

local UpdateWalker = require 'src.ecs.system.UpdateWalker'

describe('UpdateWalker System', function()
    describe('Update', function()
        local def = require 'src.data.motion.Mario'
        local body_vel, e, dt, dir, v
        local body = {
            setLinearVelocity = function(_, x, y)
                body_vel.x, body_vel.y = x, y
            end
        }
        local factor = 0.1/6.0

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
            dt = 1 / (dt * def.timeFactor)
            assert.are.same(body_vel, {
                x = def.maxVxWalk*factor*def.ogHorForce*dt, y = 0
            })
        end)

        local right = def.maxVxWalk * .9

        it('moves right and stops', function()
            v.x = right
            UpdateWalker.update({}, e, dt, nil, dir, v, def, body)
            assert.are.same(body_vel, {
                x = v.x * def.slowWalk, y = 0
            })
        end)

        it('moves right and changes direction', function()
            v = body_vel
            v.x = right
            dir.x = -1
            UpdateWalker.update({}, e, dt, nil, dir, v, def, body)
            UpdateWalker.update({}, e, dt, nil, dir, v, def, body)
            UpdateWalker.update({}, e, dt, nil, dir, v, def, body)
            assert.are.same(body_vel, {
                x = v.x * def.slowWalk, y = 0
            })
        end)
    end)
end)