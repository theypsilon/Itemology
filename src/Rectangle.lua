local Rectangle = class()

function Rectangle:_init(x, y, w, h)
    self.x, self.y, self.w, self.h = x, y, w, h
end

function Rectangle.contains(r, p)
	if p.pos and p.pos.x and p.pos.y then p = p.pos end
    return  p.x >= r.x and 
            p.y >= r.y and 
            p.x <= r.w and 
            p.y <= r.h
end

return Rectangle