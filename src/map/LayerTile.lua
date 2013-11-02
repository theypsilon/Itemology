local Layer = require 'map.Layer'
local LayerTile = class('LayerTile', Layer)

function LayerTile:_init(tiled, map)
    self.prop = self:_load(tiled.data, tiled.width, tiled.height, map.tilesets[1])
    self.prop:setPriority(tiled.id)
    self.map  = map
end

function LayerTile:_load(data, w, h, ts)

    local function load_deck()
        local deck = MOAITileDeck2D.new()
        deck:setTexture(ts.tex)
        deck:setSize(ts.imagewidth  / ts.tilewidth, 
                     ts.imageheight / ts.tileheight)
        return deck
    end

    local function load_grid()
        local grid = MOAIGrid.new()
        grid:initRectGrid(w, h, ts.tilewidth, ts.tileheight)

        for y = 0, h - 1 do  for x = 1, w do
            grid:setTile     (x, y + 1, data[y * w + x])
            grid:setTileFlags(x, y + 1, MOAIGridSpace.TILE_Y_FLIP) --const int FlippedHorizontallyFlag = http://getmoai.com/forums/moaigrid-confusion-t240/
        end end
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
    local w, h = self.prop:getGrid():getSize()
    return coroutine.wrap(function()
        for y = 1, h do  for x = 1, w do
            coroutine.yield(self(x, y) - MOAIGridSpace.TILE_Y_FLIP, x, y)
        end end
    end)
end

return LayerTile