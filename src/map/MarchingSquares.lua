local left, right, up, down, none = 'left', 'right', 'up', 'down', 'none'

local Collision = require 'map.Collision'
local March     = {}


local function calcState(x, y, isWall)
    local upLeft    = not isWall(x-1, y-1)
    local upRight   = not isWall(x  , y-1)
    local downLeft  = not isWall(x-1, y  )
    local downRight = not isWall(x  , y  )

    local state     = 0

    if upLeft    then state = state + 1 end
    if upRight   then state = state + 2 end
    if downLeft  then state = state + 4 end
    if downRight then state = state + 8 end

    return state
end

function March.trace(startX, startY, isWall)

    local function step(x, y, prevStep)
        local state, nextStep = calcState(x,y, isWall), none

        if     state == 1  then nextStep = up
        elseif state == 2  then nextStep = right
        elseif state == 3  then nextStep = right
        elseif state == 4  then nextStep = left
        elseif state == 5  then nextStep = up
        elseif state == 6  then nextStep = prevStep == up and left or right
        elseif state == 7  then nextStep = right
        elseif state == 8  then nextStep = down
        elseif state == 9  then nextStep = prevStep == right and up or down
        elseif state == 10 then nextStep = down
        elseif state == 11 then nextStep = down
        elseif state == 12 then nextStep = left
        elseif state == 13 then nextStep = up
        elseif state == 14 then nextStep = left end

        dump(state)

        return nextStep
    end

    local sol  = {}
    local x, y = startX, startY
    local prevStep = none

    repeat
        local nextStep = step(x, y, prevStep)
        --if x > 0 and x <= mapw and y > 0 and y <= maph then
        if nextStep ~= prevStep then
            sol[#sol + 1] = {i=x, j=y}
        end

        prevStep = nextStep

        if     nextStep == up    then y = y - 1
        elseif nextStep == left  then x = x - 1
        elseif nextStep == down  then y = y + 1
        elseif nextStep == right then x = x + 1 end

    until nextStep == none or (startX == x and startY == y)

    sol[#sol + 1] = sol[1]

    return sol
end

function March.go(map)
    local wall = March.getWall(map)
    local mapw, maph = table.count(wall[1]), table.count(wall)

    local function isWall(x, y)
        return x > 0 and y > 0 and x <= mapw and y <= maph and wall[y][x]
    end

    for x,row in pairs(wall) do for y,_ in pairs(row) do
        if isWall(x, y) then
            return Collision.adaptPolygon(March.trace(x, y, isWall))
        end
    end end

    return nil
end

function March.getWall(map)
    local collision  = map('platforms')

    return Collision.getWallMatrix(
        collision, 
        Collision.getOpaqueGraphics(
            map:getTilesetAsAtlass(1)))
end

function March.makeFixtures(map)

    local wall = March.getWall(map)

    local fixtures = {}

    for x,row in pairs(wall) do for y,solid in pairs(row) do
        local fix = {}
        fixtures[#fixtures + 1] = fix
    end end

    return fixtures
end

return March