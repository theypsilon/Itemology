local scene = {}

function scene.load()
	require 'entity.Player'

    local level     = Level ("plattform.tmx")
    local spawn     = level.map('objects')('spawn')
    local collision = level.map('platforms') 
    local player    = Player(level, spawn.x, spawn.y)
    local cameras   = {}
    local w, h      = graphics.getWidth(), graphics.getHeight()
    
    local tileset = level.map:getTilesetAsAtlass(1)

    for _,t in pairs(tileset.graphics) do
        t:newProp():setLoc(100 + t.x * 2, 100 + t.y * 2)
    end
    
    for k,v in pairs(tileset.graphics) do
        v.wall = false
        for x = v.x, v.x + v.w - 1 do for y = v.y, v.y + v.h - 1 do
            local r, g, b, alpha  = tileset.tex:getRGBA(x, y)
            if alpha == 1 then
                v.wall = true
                break
            end
        end end
    end

    local world = physics.world
    local collisionMap, collisionFixtures = {}, {}
    for tile, x, y in collision:iterator() do
        local t = tileset:get(tile)
        collisionMap[y]    = collisionMap[y] or {}
        collisionMap[y][x] = t.wall

        if t.wall then
            collisionFixtures[#collisionFixtures + 1] = {
                x = (x-1) * t.w, y = (y-1) * t.h, 
                w =         t.w, h =         t.h
            }
        end
    end

    local tw, th = level.map.tileWidth, level.map.tileHeight

    local mapw, maph = 
        table.count(collisionMap[1]), table.count(collisionMap)


    local dirs = {{x=1,y=0},{x=0,y=1},{x=-1,y=0},{x=0,y=-1}}
    local d_right, d_left, d_up, d_down = dirs[1], dirs[3], dirs[4], dirs[2]

    local sol, wall = {walked = {}, poly = {[{x=0,y=0,i=1,d=d_down}]=true}}, collisionMap

    for x = 1, 100 do for y = 1, 100 do
        sol.walked[y] = sol.walked[y] or {}
        sol.walked[y][x] = sol.walked[y][x] or {}
    end end

    local adys = 
    {{1, 1},{-1, -1},{1, -1},{-1, 1},{0, 0},{0, 1},{1, 0},{0, -1},{-1, 0}}

    local function grade(x, y )
        local g = 0
        for _,m in pairs(adys) do
            local nx, ny = x + m[1], y + m[2]
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
            local dx, dy =   m[1],   m[2]
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

    local function notWalkedBefore(sol, x, y)
        return table.count(sol.walked[y][x]) == 0
    end


    local function mapHasher(x, y)
        return (y - 1) * mapw + x
    end

    local function getHoles(x, y)
        local holes = {}
        for _,m in pairs(adys) do
            local nx, ny = x + m[1], y + m[2]
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

    local function resolve(sol, x, y, pv, pd)

        local args

        sol.poly  [pv]       = true
        sol.walked[y][x][pd] = true

        pv.d                 = pd
        pv.x                 = pv.x + pd.x
        pv.y                 = pv.y + pd.y
        pv.i                 = pv.i or table.count(sol.poly)

        local sameHoles, notWalked = {}, {}
        
        for _,d in pairs(getDirs(x, y)) do
            local nx, ny     = x + d.x, y + d.y

            if wall[ny] and wall[ny][nx] and not sol.walked[ny][nx][d] then
                local pack = {nx, ny, d}

                if hasSameHoles(nx, ny, x, y)   then sameHoles[pack] = true end
                if notWalkedBefore(sol, nx, ny) then notWalked[pack] = true end

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
            local vertex
            if d == pd then vertex = pv else
                vertex = table.copy(pv)
                vertex.i = nil
            end 
            return resolve(sol, nx, ny, vertex, d) 
        end

    end

    local function drawMap()
        for v,_ in pairs(sol.poly) do 
            if wall[v.y] then
                wall[v.y][v.x-1] = '_' 
            end
        end

        local s = "\n"
        for y,v in pairs(wall) do
            s = s .. y .. "\t"
            for x,w in pairs(v) do
                if x % 5 == 1 then s = s .. '.' end
                w = type(w) ~= 'boolean' and w or w and grade(x, y) or ' '
                s = s .. w
            end
            s = s .. "\n"
        end
        return s
    end

    local v = {x = 1, y = 1, d = d_right}
    resolve(sol, v.x, v.y, v, v.d)

    local shit = {}

    local function addaptPolygon(input)
        local output = {}
        for v,_ in pairs(input) do
            local i, x, y = v.i

            if     v.d == d_right then
                x, y = v.x * tw      , (v.y - 1) * th
            elseif v.d == d_left  then
                x, y = (v.x - 1) * tw, v.y * th
            elseif v.d == d_up    then
                x, y = (v.x - 1) * tw, (v.y - 1) * th
            else
                x, y = v.x * tw      , v.y * th
            end

            output[i*2 - 1] = x
            output[i*2    ] = y
            shit[i] = {x, y}
        end
        return output
    end

    local pol = addaptPolygon(sol.poly)

    --dump(shit)
    --os.exit()

    -- local tiny = {pol[1], pol[2], pol[3], pol[4]}

--     local floor = physics.world:addBody(MOAIBox2DBody.STATIC)
--     floor:setTransform(0, 0)
--      local hexPoly = {0, 0 ,
-- 616, 0 ,
-- 616, 496 ,
-- 504, 496 ,
-- 504, 464 ,
-- 536, 464 ,
-- 0, 448}
--    floor:addPolygon(pol)

    dump(sol.poly)

    dump(drawMap())
    dump(pol)
    dump(table.count(pol))

    cameras[Camera(player)] = true
    
    -- cameras[Camera(player, {x=0,   y=0  , w=w/2, h=h/2}, {x=40, y=40})] = true
    -- cameras[Camera(player, {x=w/2, y=0  , w=w/2, h=h/2}              )] = true
    -- cameras[Camera(player, {x=0  , y=h/2, w=w/2, h=h/2}, {x=80, y=65})] = true
    -- cameras[Camera(player, {x=w/2, y=h/2, w=w/2, h=h/2}, {x=10, y=10})] = true
    
    scene.cameras, scene.level, scene.player = cameras, level, player

end 

function scene.draw()
    for camera,_ in pairs(scene.cameras) do
        camera:draw()
    end

    -- love.graphics.print(
    --     "tick " .. scene.player._ticks .. 
    --     " fps " .. tostring(love.timer.getFPS()) ..
    --     "\nx: " .. scene.player.x ..
    --     "\ny: " .. scene.player.y , 
    --     20, 20 )
end
function scene.update(dt)
    if scene.pause then return end
    for camera,_ in pairs(scene.cameras) do
        camera._level:tick(dt)
    end
    physics:update()
end

function scene.focus(inside)
    scene.pause = not inside
end

return scene