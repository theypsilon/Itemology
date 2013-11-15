local Rectangle = class.Rectangle()

function Rectangle:_init(x, y, w, h)
    self.x, self.y, self.w, self.h = x, y, w, h
end

function Rectangle.contains(r, p)
    return  p.x >= r.x and 
            p.y >= r.y and 
            p.x <= r.w and 
            p.y <= r.h
end

return Rectangle