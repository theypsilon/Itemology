class.Atlass()

local function validate(path, max_x, max_y)

end

function Atlass:_init(path, max_x, max_y)
	validate(path, max_x, max_y)

	self.atlass = love.graphics.newImage('res/img/' .. path)
	self.max_x, self.max_y = max_x, max_y
	function self.graphic_draw(that, x,y) 
		love.graphics.drawq(self.atlass, that.quad, x, y) 
	end
end

local function load_sprite(self, gr) 
	gr.quad = love.graphics.newQuad(gr.x, gr.y, gr.w, gr.h, self.max_x, self.max_y)
	gr.draw = self.graphic_draw
end

function Atlass:get(name)
	local  gr = self.graphics[name]
	if not gr      then return nil            end
	if not gr.quad then load_sprite(self, gr) end
	return gr
end