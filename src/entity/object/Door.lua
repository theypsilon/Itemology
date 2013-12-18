local Physics, Data; import()

return function(d,p)
    local x, y, w, h = p.x, p.y, p.width, p.height
    local body   = Physics:makeItemBody(x, y, 'rect', {0, 0, w, h})
    local object = table.copy(p.properties)
    object.body  = body

    object.x, object.y = p.x, p.y
    return object
end