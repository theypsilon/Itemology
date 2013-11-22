local Layer = require 'map.Layer'
local LayerTile = class('LayerTile', Layer)

function LayerTile:_init(tiled, map)
    self.prop = self:_load(tiled.data, tiled.width, tiled.height, map.tilesets[1])
    self.prop:setPriority(tiled.properties.z or tiled.id)
    self.map  = map
end

function LayerTile:_load(data, w, h, ts)

    local function load_deck()
        local deck = MOAITileDeck2D.new()
        if ts.spacing == 0 and ts.margin == 0 then
            deck:setTexture(ts.tex)
            deck:setSize(ts.imagewidth  / ts.tilewidth, 
                         ts.imageheight / ts.tileheight)
        else
            deck = MOAIGfxQuadDeck2D.new()
            local tw       , th         = ts.imagewidth, ts.imageheight
            local tileWidth, tileHeight = ts.tilewidth , ts.tileheight
            local margin   , spacing    = ts.margin    , ts.spacing
            local tileX = math.floor((tw - margin) / (tileWidth + spacing))
            local tileY = math.floor((th - margin) / (tileHeight + spacing))
            deck:reserve(tileX * tileY)
            deck:setTexture(ts.tex)

            local i = 1
            for y = 1, tileY do
                for x = 1, tileX do
                    local sx = (x - 1) * (tileWidth + spacing) + margin
                    local sy = (y - 1) * (tileHeight + spacing) + margin
                    local ux0 = sx / tw
                    local uy0 = sy / th
                    local ux1 = (sx + tileWidth) / tw
                    local uy1 = (sy + tileHeight) / th

                    deck:setUVRect(i, ux0, uy0, ux1, uy1)
                    i = i + 1
                end
            end
        end
        return deck
    end

    local function load_grid()
        local grid = MOAIGrid.new()
        if ts.spacing == 0 and ts.margin == 0 then
            grid:initRectGrid(w, h, ts.tilewidth, ts.tileheight)
            grid.flags = MOAIGridSpace.TILE_Y_FLIP
            for y = 0, h - 1 do  for x = 1, w do
                grid:setTile     (x, y + 1, data[y * w + x])
                grid:setTileFlags(x, y + 1, MOAIGridSpace.TILE_Y_FLIP) --const int FlippedHorizontallyFlag = http://getmoai.com/forums/moaigrid-confusion-t240/
            end end
        else
            grid:setSize(w, h, ts.tilewidth, ts.tileheight)

            for y = 0, h-1 do
                local rowData = {}
                for x = 0, w-1 do
                    table.insert(rowData, data[y * w + x+1] or 0)
                end
                grid:setRow(y + 1, unpack(rowData))
            end
        end
        return grid
    end

    local prop = MOAIProp2D.new()
    prop:setDeck(load_deck())
    prop:setGrid(load_grid())

    return prop
end

function LayerTile:__call(x, y)
    return self.prop:getGrid():getTile(x, y)
end

function LayerTile:iterator()
    local grid = self.prop:getGrid()
    local w, h = grid:getSize()
    local o    = grid.flags or 0
    return coroutine.wrap(function()
        for y = 1, h do  for x = 1, w do
            coroutine.yield(self(x, y) - o, x, y)
        end end
    end)
end

return LayerTile