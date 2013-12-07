local Physics;          import()
local MarchingSquares;  import 'algorithm'

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

function Util.getSolidStructure(layer)
    local wall = Util.getWall(layer)
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

function Util.getWall(layer)
    return getWallMatrix(
        layer, 
        layer.map:getTilesetAsAtlass(1):getOpaqueGraphics()
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
    local chains = {}
    for _,poly in pairs(structure) do
        local floor = Physics:registerBody{
            option = 'static',
            x = 0, y = 0,
            fixtures = {{
                option = 'chain', 
                args   = {adaptPolygon(poly, 16, 16)}, 
                closed = true
            }}
        }
        floor.structure = true
        chains[#chains + 1] = floor
    end

    return chains
end

function Util.makeSquareFixtures(wall, width, height)
    if not width or not height then width, height = 16, 16 end

    local edges = {}
    for j,row in pairs(wall) do for i,solid in pairs(row) do
        if solid then
            local x, y = (i-1)*width, (j-1)*height
            local fix = {x, y, x + width, y, x + width, y + height, x, y + height}
            edges[#edges + 1] = fix
        end
    end end

    return Physics:registerBody{
        option = 'static',
        x = 0, y = 0,
        fixtures = edges
    }
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