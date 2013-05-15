local Layer = require 'map.Layer'
local LayerTile = class('LayerTile', Layer)

function LayerTile:_init(tiled, map)

    local data, w,  h = tiled.data, tiled.width, tiled.height
    local ts = map.tilesets[1]

    local grid = MOAIGrid.new()
    grid:initRectGrid(w, h, ts.tilewidth, ts.tileheight)

    for y = 0, h - 1 do for x = 1, w do
        grid:setTile     (x, y + 1, data[y * w + x])
        grid:setTileFlags(x, y + 1, 0x40000000)
    end end

    --const int FlippedHorizontallyFlag = http://getmoai.com/forums/moaigrid-confusion-t240/

    local tiles = MOAITileDeck2D.new()
    tiles:setTexture(ts.tex)
    tiles:setSize(ts.imagewidth / ts.tilewidth, ts.imageheight / ts.tileheight)

    local prop = MOAIProp2D.new()
    prop:setDeck(tiles)
    prop:setGrid(grid)

    self.prop = prop

end

return LayerTile