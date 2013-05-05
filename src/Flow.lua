flow = love

local callbacks = {
	'load', 'update', 'draw', 'mousepressed', 'mousereleased',
	'keypressed', 'keyreleased', 'focus', 'quit'
}

local cbmap = table.flip(callbacks)

function flow.get()
	local callStatus = {}
	for _,v in ipairs(callbacks) do
		callStatus[v] = flow[v]
	end
	return callStatus
end

function flow.set(callStatus)
	for k,v in pairs(callStatus) do
		if cbmap[k] ~= nil then
			flow[k] = v
		end
	end
end

local stack = {}

function flow.push()
	table.insert(stack, flow.get())
end

function flow.pop()
	flow.set(table.remove(stack, #stack))
end

function flow.reset()
	for _,v in ipairs(callbacks) do
		flow[k] = nil
	end
end

function flow.exit()
	love.event.push("quit")
end

return flow