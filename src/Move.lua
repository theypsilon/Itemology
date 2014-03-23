local Move = class()

function Move:_init(history)
	if history then self.history = {} end
end

function Move:next(next_move)
	assert(is_array(next_move))
	self.cur = next_move
	if self.history then 
		table.insert(self.history, next_move) 
	end
end

function Move:get()
	return pairs(self.cur)
end