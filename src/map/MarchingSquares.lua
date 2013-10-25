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

local function check(x,y,isWall,checked)
    checked = checked or {}

    local function checkOne(x,y)
        checked[x] = checked[x] or {}
        checked[x][y] = true
    end

    local function checkRecursive(x,y)
        if isWall(x,y) and not (checked[x] and checked[x][y]) then
            checkOne(x,y)
            checkRecursive(x-1,y  )
            checkRecursive(x  ,y-1)
            checkRecursive(x+1,y  )
            checkRecursive(x  ,y+1)
        end
    end

    checkRecursive(x,y)

    return checked
end

function March.traceMap(map)
    local wall = March.getWall(map)
    local mapw, maph = table.count(wall[1]), table.count(wall)

    local function isWall(x, y)
        return x > 0 and y > 0 and x <= mapw and y <= maph and wall[y][x]
    end

    local checked = {}
    local structure = {}
    for y,row in pairs(wall) do for x,_ in pairs(row) do
        if not (checked[x] and checked[x][y]) and isWall(x,y) then
            check(x,y,isWall,checked)
            local poly = Collision.adaptPolygon(March.trace(x, y, isWall))
            structure[#structure + 1] = poly
        end
    end end

    return structure
end

function March.getWall(map)
    local collision  = map('platforms')

    return Collision.getWallMatrix(
        collision, 
        Collision.getOpaqueGraphics(
            map:getTilesetAsAtlass(1)))
end

function March.makeFixturesPol(map)

    local wall = March.getWall(map)

    local floor = physics.world:addBody(MOAIBox2DBody.STATIC) 
    floor:setTransform(0, 0)

    for j,row in pairs(wall) do for i,solid in pairs(row) do
        if solid then
            local x, y = (i-1)*16, (j-1)*16
            local fix = floor:addEdges{x, y, x + 16, y, x + 16, y + 16, x, y + 16}
        end
    end end
end

function March.makeChainFixtures(structure)
    local fixtures = {}
    for _,poly in pairs(structure) do
        local floor = physics.world:addBody(MOAIBox2DBody.STATIC) 
        floor:setTransform(0, 0)
        floor:addChain(poly, true)
        fixtures[#fixtures + 1] = floor
    end

    return fixtures
end

return March