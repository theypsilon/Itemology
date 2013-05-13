class.Atlass()

local function validate(path)

end

local function make_prop(self)
	local prop = MOAIProp2D.new()
	prop:setDeck (self.atlass.deck)
	prop:setIndex(self.i)
	prop:setPiv(self.w / 2, self.h / 2)
	prop:setPriority(1000)
	return prop
end

local function remove_prop(self) 
	self.layer:removeProp(self) 
end

local function new_prop(self)
	local layer = self.atlass.layer
	local prop  = make_prop(self)
	
	prop.layer  = layer
	prop.remove = remove_prop

	layer:insertProp(prop)
	return prop
end

local function draw_prop(self, x, y)
	local prop = make_prop(self)
	if x and y then prop:setLoc(x, y) end
	flow.tempLayer:insertProp(prop)
	return prop
end

function Atlass:_init(path, frames, layer)
	validate(path)

	local total = 0
	for name,region in pairs(frames) do
		total    = total + 1
		region.i = total
	end

	local tex = MOAITexture.new ()
    tex:load('res/img/' .. path)

    local width, height = tex:getSize()

    local deck = MOAIGfxQuadDeck2D.new ()
    deck:setTexture(tex)
    deck:reserve(total)

    for _,region in pairs(frames) do
    	local uv = {}
    	uv.u0 = region.x / width
    	uv.v0 = region.y / height
    	uv.u1 = (region.x + region.w) / width
    	uv.v1 = (region.y + region.h) / height
    	deck:setUVRect(region.i, uv.u0, uv.v0,    uv.u1,    uv.v1)
    	deck:setRect  (region.i,     0,     0, region.w, region.h)

    	region.atlass  = self
    	region.newProp =  new_prop
    	region.draw    = draw_prop
    end

    self.layer    = layer
    self.deck     = deck
	self.graphics = frames
	self.total    = total
end

function Atlass:get(name)
	return self.graphics[name]
end