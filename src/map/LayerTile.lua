local Layer = require 'map.Layer'
local LayerTile = class('LayerTile', Layer)

local function load_deck(ts)
    local deck = MOAITileDeck2D.new()
    deck:setTexture(ts.tex)
    deck:setSize(ts.imagewidth / ts.tilewidth, ts.imageheight / ts.tileheight)
    return deck
end

local function load_grid(data, w, h, ts)
    local grid = MOAIGrid.new()
    grid:initRectGrid(w, h, ts.tilewidth, ts.tileheight)

    for y = 0, h - 1 do  for x = 1, w do
        grid:setTile     (x, y + 1, data[y * w + x])
        grid:setTileFlags(x, y + 1, 0x40000000) --const int FlippedHorizontallyFlag = http://getmoai.com/forums/moaigrid-confusion-t240/
    end end
    return grid
end

local function load(data, w, h, ts)
    local prop = MOAIProp2D.new()
    prop:setDeck(load_deck(ts))
    prop:setGrid(load_grid(data, w, h, ts))
    return prop
end

function LayerTile:_init(tiled, map)
    self.prop = load(tiled.data, tiled.width, tiled.height, map.tilesets[1])
    self.prop:setPriority(tiled.id)
end

return LayerTile