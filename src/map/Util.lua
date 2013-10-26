local MarchingSquares = require 'algorithm.MarchingSquares'

local Util     = {}

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

function Util.getSolidStructure(map)
    local wall = Util.getWall(map)
    local mapw, maph = table.count(wall[1]), table.count(wall)

    local function isWall(x, y)
        return x > 0 and y > 0 and x <= mapw and y <= maph and wall[y][x]
    end

    local checked = {}
    local structure = {}
    for y,row in pairs(wall) do for x,_ in pairs(row) do
        if not (checked[x] and checked[x][y]) and isWall(x,y) then
            check(x,y,isWall,checked)
            local poly = MarchingSquares(x, y, isWall)
            structure[#structure + 1] = poly
        end
    end end

    return structure
end

local function getWallMatrix(layer, opaques)
    local matrix = {}
    for tile, x, y in layer:iterator() do 
        matrix[y]    = matrix [y] or {}
        matrix[y][x] = opaques[tile] and true or false
    end
    return matrix
end

function Util.getWall(map)
    local collision  = map('platforms')

    return getWallMatrix(
        collision, 
        map:getTilesetAsAtlass(1):getOpaqueGraphics()
    )
end

local function adaptPolygon(input, factorx, factory)
    if not factorx then factorx = 1 end
    if not factory then factory = 1 end
    local output = {}
    for i,v in ipairs(input) do
        local x, y = v.x - 1, v.y - 1

        output[i*2 - 1] = x * factorx
        output[i*2    ] = y * factory

    end
    return output
end

function Util.makeChainFixtures(structure)
    local fixtures = {}
    for _,poly in pairs(structure) do
        local floor = physics.world:addBody(MOAIBox2DBody.STATIC) 
        floor:setTransform(0, 0)
        floor:addChain(adaptPolygon(poly, 16, 16), true)
        fixtures[#fixtures + 1] = floor
    end

    return fixtures
end

function Util.makeSquareFixtures(wall, width, height)
    if not width or not height then width, height = 16, 16 end

    local floor = physics.world:addBody(MOAIBox2DBody.STATIC) 
    floor:setTransform(0, 0)

    for j,row in pairs(wall) do for i,solid in pairs(row) do
        if solid then
            local x, y = (i-1)*width, (j-1)*height
            local fix = floor:addEdges{x, y, x + width, y, x + width, y + height, x, y + height}
        end
    end end
end

function Util.drawMap(poly, wall)
    if poly then
        for _,v in pairs(poly) do 
            local x, y = v.x, v.y
            if wall[y] then
                if wall[y][x] then wall[y][x] = '_' end
            end
        end
    end

    local s = "\n"
    for y,v in pairs(wall) do
        s = s .. y .. "\t"
        for x,w in pairs(v) do
            if x % 5 == 1 then s = s .. '.' end
            w = type(w) ~= 'boolean' and w or w and 'x' or ' '
            s = s .. w
        end
        s = s .. "\n"
    end
    return s
end

return Util