sprites = {
	gr1 = {x = 0,   y = 0,   w = 16, h = 16},
	gr2 = {x = 16,  y = 0,   w = 32, h = 32},
	gr3 = {x = 0,   y = 0,   w = 32, h = 32},
	gr4 = {x = 0,   y = 0,   w = 32, h = 32},
	gr5 = {x = 0,   y = 0,   w = 32, h = 32},
	gr6 = {x = 0,   y = 0,   w = 32, h = 32},
	gr7 = {x = 0,   y = 0,   w = 32, h = 32},
}

local grid = love.graphics.newImage('res/img/grid.png')
local grid_x, grid_y = 800, 600

local function draw(self, x,y) love.graphics.drawq(grid, self.quad, x, y) end

local function load_sprite(gr) 
	gr.quad = love.graphics.newQuad(gr.x, gr.y, gr.w, gr.h, grid_x, grid_y)
	gr.draw = draw
end

function sprites.get(name)
	local  gr = sprites[name]
	if not gr      then return nil      end
	if not gr.quad then load_sprite(gr)	end
	return gr
end