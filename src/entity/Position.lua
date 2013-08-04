local tn = tonumber

local    Position = class('BodyPosition', class.properties)
function Position:_init(body) rawset(self, 'body', body)                   end

function Position:get_x ( )  local x, y = self.body:getPosition() return x end
function Position:get_y ( )  local x, y = self.body:getPosition() return y end

function Position:set_x (x)  self.body:setTransform(tn(x), self.y)         end
function Position:set_y (y)  self.body:setTransform(self.x, tn(y))         end

function Position:get(    )  return self.body:getPosition (            )   end
function Position:set(x, y)         self.body:setTransform(tn(x), tn(y))   end

return Position