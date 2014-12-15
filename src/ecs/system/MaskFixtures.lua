local System; import 'ecs'
local MaskFixture = class(System)

function MaskFixture:requires()
    return {'mask_fixture'}
end

function MaskFixture:update(e, _, mask_fixture)
    self:maskFixtures(e, mask_fixture)
    e.mask_fixture = nil
end

function MaskFixture:setFixtureMask(fix, mask)
    if not is_userdata(fix) then
        for _,f in pairs(fix) do
            self:setFixtureMask(f, mask)
        end
        return
    end
    local categoryBits, maskBits, groupIndex = fix:getFilter()
    fix:setFilter(categoryBits, mask, groupIndex)
end

function MaskFixture:maskFixtures (e, value, name)
    if is_table(value) then
        for k, v in pairs(value) do self:maskFixtures(e, v, k) end
        return
    end

    assert(is_positive(value), tostring(value) .. ': is not positive')

    if is_string(name) then self:setFixtureMask(e.body.fixtures[name], value)
    else 
        for _,f in pairs(e.body.fixtures) do
            self:setFixtureMask(f, value)
        end
    end
end

function MaskFixture:removeMasksFixtures(e)
    local _, maskBits, _ = table.first(e.body.fixtures):getFilter()
    self:maskFixtures(e, 0)
    e.removed_mask_fixtures = maskBits
end

function MaskFixture:restoreMaskFixtures(e)
    if is_nil(e.removed_mask_fixtures) then return end
    self:maskFixtures(e, e.removed_mask_fixtures)
    e.removed_mask_fixtures = nil
end

return MaskFixture