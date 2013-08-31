local dirs = {
    {x =  1, y =  0},
    {x =  0, y =  1},
    {x = -1, y =  0},
    {x =  0, y = -1}
}

local d_right, d_left, d_up, d_down = dirs[1], dirs[3], dirs[4], dirs[2]

local d_vertical, d_horizontal = {dirs[2], dirs[4]}, {dirs[1], dirs[3]}

local adys = {
    {x =  1, y =  1},
    {x = -1, y = -1},
    {x =  1, y = -1},
    {x = -1, y =  1},
    {x =  0, y =  0},
    d_right, d_left, d_up, d_down
}

local Collision = {}

function Collision.getOpaqueGraphics(atlass)
    local tiles = {}
    for k,v in pairs(atlass.graphics) do
        v.wall = false
        for x = v.x, v.x + v.w - 1 do for y = v.y, v.y + v.h - 1 do
            local r, g, b, alpha  = atlass.tex:getRGBA(x, y)
            if alpha == 1 then
                tiles[k] = true
                break
            end
        end end
    end
    return tiles
end

function Collision.getWallMatrix(layer, opaques)
    local matrix = {}
    for tile, x, y in layer:iterator() do 
        matrix[y]    = matrix [y] or {}
        matrix[y][x] = opaques[tile] and true or false
    end
    return matrix
end

function Collision.getCollisionFixtures(wallMatrix, tw, th)
    local fixtures = {}
    for y, row in pairs(wallMatrix) do for x, v in pairs(row) do
        if v then
            fixtures[#fixtures + 1] = {
                x = (x-1) * tw, y = (y-1) * th,
                w =         tw, h =         th
            }
        end
    end end
    return fixtures
end

function Collision.getEmptySolution()
    return {walked = {}, poly = {{x=1,y=1,d=d_down}}, lastborder = {
        x = d_right,
        y = d_up
    }}
end

function Collision.makeInitialSolution(x, y, walked)
    local sol = Collision.getEmptySolution()

    if walked then sol.walked = walked end

    local v   = {x = x, y = y, d = d_right, pd = d_up}

    sol.poly[2] = v

    return sol
end

function Collision.go(map)
    local tw, th     = map.tileWidth, map.tileHeight

    local collision  = map('platforms')

    local wall       =  Collision.getWallMatrix(
                            collision, 
                            Collision.getOpaqueGraphics(
                                map:getTilesetAsAtlass(1)))

    local mapw, maph = map.mapWidth, map.mapHeight

    local sol        = Collision.getEmptySolution()

    local function grade(x, y )
        local g = 0
        for _,m in pairs(adys) do
            local nx, ny = x + m.x, y + m.y
            if nx == 0 or ny == 0 or nx > mapw or ny > maph 
            or not wall[ny][nx] then g = g + 1 end
        end
        return g
    end

    local function isWall(x, y)
        return x > 0 and y > 0 and x <= mapw and y <= maph and wall[y][x]
    end

    local function isCandidate(x, y, cx, cy)
        for _,m in pairs(adys) do
            local dx, dy =   m.x,   m.y
            local nx, ny = x + dx, y + dy
            if not isWall(nx, ny) then
                return true
            end
        end
        return false
    end 

    local function getDirs(x, y)
        if not wall[y][x] then return {} end
        local resdir = {}
        for _,d in pairs(dirs) do   
            local nx, ny = x + d.x, y + d.y
            if isCandidate(nx, ny, x, y) then 
                table.insert(resdir, d)
            end
        end
        return resdir
    end

    local function notWalkedBefore(walked, x, y)
        walked[y]        = walked[y]    or {}
        walked[y][x]     = walked[y][x] or {}
        return table.count(walked[y][x]) == 0
    end


    local function mapHasher(x, y)
        return (y - 1) * mapw + x
    end

    local function getHoles(x, y)
        local holes = {}
        for _,m in pairs(adys) do
            local nx, ny = x + m.x, y + m.y
            if not isWall(nx, ny) then
                holes[mapHasher(nx, ny)] = true
            end
        end
        return holes
    end

    local function hasSameHoles(nx, ny, x, y)
        local nholes, holes = getHoles(nx, ny), getHoles(x, y)
        for hash,_ in pairs(nholes) do if holes[hash] then return true end end
        return false
    end

    local function isOpposite(d1, d2)
        return false
        --return (d1.x * -1) == d2.x and (d1.y * -1) == d2.y
    end

    local tileSize = {x = tw, y = th}
    local function changeBorder(pv, border)
        local i = pv.d.x ~= 0 and 'x' or 'y'
        if pv.d[i] ~= border[i][i] then
            pv[i] = pv[i] + (pv.d[i] * tileSize[i])
            border[i] = pv.d
        end
    end

    local function insertVertex(sol, pv, nd, nx, ny)
        if isOpposite(pv.d, nd) then
            error 'is opposite!'
        else

            --changeBorder(pv, sol.lastborder)

            local testx = pv.x + (pv.d.x * (tw - 1)) -1
            dump(testx, pv.x, pv.d.x, math.floor(testx / tw), nx, math.floor(testx / tw) == math.floor((pv.x-1) / tw))
            if pv.d.x ~= 0 and math.floor(testx / tw) == math.floor((pv.x-1) / tw) then
                dump(pv.x)
                pv.x = pv.x + pv.d.x * tw
            end

            local testy = pv.y + (pv.d.y * (th - 1)) -1
            if pv.d.y ~= 0 and math.floor(testy / th) == math.floor((pv.y-1) / th) then                
                pv.y = pv.y + pv.d.y * th
            end 

            local vertex   = table.copy(pv)

            --vertex.x, vertex.y = vertex.x + nd.x * tw, vertex.y + nd.y * th
            -- if nd == d_left and vertex.d == d_down then
            --     vertex.y = vertex.y + th
            -- end

            sol.poly[#sol.poly + 1] = vertex
            return vertex
        end
    end

    local function resolve(sol, x, y, pv, pd)

        if table.count(sol.poly) == 10 then return end

        local args

        sol.walked[y]        = sol.walked[y]    or {}
        sol.walked[y][x]     = sol.walked[y][x] or {}
        sol.walked[y][x][pd] = true

        pv.d                 = pd
        pv.x                 = pv.x + pd.x *tw
        pv.y                 = pv.y + pd.y *th

        local sameHoles, notWalked = {}, {}
        
        for _,d in pairs(getDirs(x, y)) do
            local nx, ny     = x + d.x, y + d.y

            sol.walked[ny]        = sol.walked[ny]     or {}
            sol.walked[ny][nx]    = sol.walked[ny][nx] or {}

            if isWall(nx, ny) and not sol.walked[ny][nx][d] then
                local pack = {nx, ny, d}

                if hasSameHoles(nx, ny, x, y) 
                    then sameHoles[pack] = true end
                if notWalkedBefore(sol.walked, nx, ny) 
                    then notWalked[pack] = true end

                if not args then args = pack
                elseif sameHoles[pack] then
                    if not sameHoles[args] then args = pack 
                    elseif notWalked[pack] then
                        if not notWalked[args] then args = pack
                        elseif d == pd then args = pack end
                    end     
                elseif notWalked[pack] and not sameHoles[args] then
                    if not notWalked[args] then args = pack
                    elseif d == pd then args = pack end
                elseif d == pd and not sameHoles[args] and not notWalked[args] then
                    args = pack
                end
            end
        end

        if args then 
            local nx, ny, d = unpack(args)
            local vertex = d == pd and pv or insertVertex(sol, pv, d, nx, ny)
            return resolve(sol, nx, ny, vertex, d) 
        end

    end

    local function drawMap(poly)
        if poly then
            for _,v in pairs(poly) do 
                local x, y = math.floor(v.x / 16), math.floor(v.y / 16)+1
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

    local function adaptPolygon(input)
        local output = {}
        for i,v in ipairs(input) do
            local x, y = v.x, v.y

            -- if     v.d == d_right then
            --     x, y = v.x * tw      , (v.y - 1) * th
            -- elseif v.d == d_left  then
            --     x, y = (v.x - 1) * tw, v.y * th
            -- elseif v.d == d_up    then
            --     x, y = (v.x - 1) * tw, (v.y - 1) * th
            -- else
            --     x, y = v.x * tw      , v.y * th
            -- end

            output[i*2 - 1] = x
            output[i*2    ] = y

            -- output[i] = {x,y}
        end
        return output
    end

    local walked = {}
    for y, row in pairs(wall) do
        for x, isWall in pairs(row) do
            if isWall and notWalkedBefore(walked, x, y) then
                local sol = Collision.makeInitialSolution(x, y, walked)
                local v   = sol.poly[2]
                resolve(sol, v.x, v.y, v, v.d)
                local pol = adaptPolygon(sol.poly)
                return sol, pol, function() return drawMap(sol.poly) end
            end
        end
    end
end

return Collision