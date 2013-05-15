local Layer = require 'map.Layer'
local LayerTile = class('LayerTile', Layer)

function LayerTile:_init(layer, map)

    dump(layer)
    os.exit()

    local grid = MOAIGrid.new()
    grid:initRectGrid(15,10,32,32)

    grid:setRow(10,0x0b,0x0c,0x0d,0x0b,0x0c,0x0b,0xc7,0xc7,0xc7,0xc7,0x0d,0x0b,0x0c,0x0d,0xc7)
    grid:setRow(9,0x2e,0x2f,0x30,0x31,0x32,0x0b,0x0c,0x0d,0xc7,0x0c,0x0d,0x0b,0x0c,0x0d,0x0b)
    grid:setRow(8,0x41,0x42,0x43,0x44,0x45,0x0b,0x0c,0x0d,0x0b,0x0c,0x0d,0x0b,0x0c,0x0d,0x0b)
    grid:setRow(7,0x55,0x56,0x57,0x58,0x59,0x0b,0x0c,0x0d,0x0b,0x0c,0x0d,0x0b,0x0c,0x0d,0x0b)
    grid:setRow(6,0x69,0x6a,0x6b,0x6c,0x6d,0x0b,0x0c,0x0d,0x0b,0x0c,0x0d,0x0b,0x0c,0x0d,0x0b)
    grid:setRow(5,0x7d,0x7e,0x7f,0x80,0x81,0x0b,0x0c,0x0d,0x0b,0x0c,0x0d,0x0b,0x0c,0x0d,0x0b)
    grid:setRow(4,0x91,0x92,0x93,0x94,0x95,0x0b,0x0c,0x0d,0xc7,0x0c,0x0d,0x0b,0x0c,0x0d,0x0b)
    grid:setRow(3,0xa5,0xa6,0xa7,0xa8,0xa9,0x0b,0x0c,0xc7,0xc7,0x0c,0x0d,0x0b,0x0c,0x0d,0x0b)
    grid:setRow(2,0xb9,0xba,0xbb,0xbc,0xbd,0xc7,0xc7,0xc7,0xc7,0xc7,0x0d,0x0b,0x0c,0x0d,0x0b)
    grid:setRow(1,0xc2,0xc2,0xc2,0xc2,0xc2,0xc2,0xc2,0xc2,0xc2,0xc2,0xc2,0xc2,0xc2,0xc2,0xc2)

end

return LayerTile