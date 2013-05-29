local drawMixin = {}

function drawMixin:draw(x, y)
    local prop = self.prop
    prop:setLoc(x or 0, y or 0)
    flow.tempLayer:insertProp(prop)
end

return drawMixin