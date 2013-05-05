local scene = {}

local map, player = nil, nil

function scene.load()
	require 'entity.Player'

	map    = tiled.load("plattform.tmx")
	player = Player()
end

function scene.draw()
    map   :draw()
    player:draw()
end

function scene.update(dt) 
	if pause then return end
	player:tick(dt)
	reload.all (  )
end

function scene.focus(inside)
	pause = not inside
end

return scene

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
