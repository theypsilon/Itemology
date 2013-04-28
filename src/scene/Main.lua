return {

    onCreate = function(e)
        flower.Resources.addResourceDirectory(project .. 'res/maps')

        layer = flower.Layer()
        layer:setScene(scene)
        layer:setSortMode(MOAILayer.SORT_PRIORITY_ASCENDING)
        layer:setTouchEnabled(true)
        
        tileMap = tiled.TileMap()
        tileMap:loadLueFile("plattform.lua")
        tileMap:setLayer(layer)

        -- tileMap:addEventListener("touchDown", tileMap_OnTouchDown)
        -- tileMap:addEventListener("touchUp", tileMap_OnTouchUp)
        -- tileMap:addEventListener("touchMove", tileMap_OnTouchMove)
        -- tileMap:addEventListener("touchCancel", tileMap_OnTouchUp)

        -- ResourceManager:addPath(project .. 'res/maps')

        -- mapLoader = TMXMapLoader()
        -- mapData = mapLoader:loadFile(project .. "res/maps/plattform.tmx")

        -- layer = flower.Layer()
        -- layer:setScene(scene)
        -- layer:setTouchEnabled(true)
        
        -- camera = flower.Camera()
        -- layer:setCamera(camera)
        
        -- tileMap = tiled.TileMap()
        -- tileMap:setLayer(layer)
        -- tileMap:loadMapData(mapData)
        
        
        -- tileMap:addEventListener("touchDown", tileMap_OnTouchDown)
        -- tileMap:addEventListener("touchUp", tileMap_OnTouchUp)
        -- tileMap:addEventListener("touchMove", tileMap_OnTouchMove)
        -- tileMap:addEventListener("touchCancel", tileMap_OnTouchUp)
    end

}