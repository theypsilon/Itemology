require 'Includes'

 -- Path to the tmx files. The file structure must be similar to how they are saved in Tiled
loader.path = "res/maps/"

 -- Loads the map file and returns it
map = loader.load("plattform.tmx")

function flow.draw()
    love.graphics.print("Hello World", 400, 300)
    map:draw()
end

function flow.update() end

-- -- Limits the drawing range of the map. Important for performance
-- map:setDrawRange(0,0,love.graphics.getWidth(), love.graphics.getHeight())

-- -- Automatically sets the drawing range to the size of the screen.
-- map:autoDrawRange(tx, ty, scale, padding)

-- -- Accessing individual layers
-- map.layers["layer name"]

-- -- A shortcut for accessing specific layers
-- map("layer name")

-- -- Finding a specific tile
-- map.layers["layer name"]:get(5,5)

-- -- A shortcut for finding a specific tile
-- map("layer name")(5,5)

-- -- Iterating over all tiles in a layer
-- for x, y, tile in map("layer name"):iterate() do
--    print( string.format("Tile at (%d,%d) has an id of %d", x, y, tile.id) )
-- end

-- -- Iterating over all objects in a layer
-- for i, obj in pairs( map("object layer").objects ) do
--     print( "Hi, my name is " .. obj.name )
-- end

-- -- Find all objects of a specific type in all layers
-- for _, layer in pairs(map.layers) do
--    if layer.class == "ObjectLayer" then
--         for _, obj in pairs(player.objects) do
--             if obj.type == "enemy" then print(obj.name) end
--         end
--    end
-- end

-- -- draw the tile with the id 4 at (100,100)
-- map.tiles[4]:draw(100,100)

-- -- Access the tile's properties set by Tiled
-- map.tiles[4].properties

-- -- Turns off drawing of non-tiled objects.
-- map.drawObjects = false
