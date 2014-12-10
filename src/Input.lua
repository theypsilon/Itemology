local input = {}

local state
function input.initialState()
	state = {
		keyboardBinding   = {},
		keyboardCallbacks = {[true] = {}, [false] = {}},
		keyboardTables    = {},
		keyboardStatus    = {},
		toBind = {}
	}
end
input.initialState()
input.state = state

local function bindActionCallback( keyCode, callback1, callback2 )
	local callbacks = state.keyboardCallbacks

	assert(is_nil(callback2) or is_callable(callback2),
		  'is_nil(callback2) or is_callable(callback2)')

	assert(is_callable(callback1), 'is_callable(callback1)')
	callbacks[true ][keyCode] = callback1
	callbacks[false][keyCode] = callback2
end

local function bindActionBoolean( keyCode, a, b )
	state.keyboardCallbacks[a][keyCode] = b
end

local function bindActionTable( keyCode, table, key )
	assert(is_nil(table) or is_table(table),
		  'is_nil(table) or is_table(table)')

	state.keyboardTables[keyCode] = {table, key}
end

local function toKeyCode( action )
	return string.byte(action)
end

function input.bindAction( action, arg, ... )
	if is_table(action) then 
		for _,suba in pairs(action) do 
			input.bindAction(suba, arg, ... )
		end
		return
	end

	assert(is_string(action) or is_number(action))
	local  keyCode  = state.keyboardBinding[action] or toKeyCode(action)
	assert(keyCode ~= nil, 'oldKeyCode   ~= nil')

	if keyCode == nil then 
		state.toBind[action] = {arg, ...}
		return
	end

	if is_boolean(arg) then
		bindActionBoolean (keyCode, arg, ...)
	elseif is_callable(arg) then
		bindActionCallback(keyCode, arg, ...)
	else
		bindActionTable   (keyCode, arg, ...)
	end
end

function input.checkAction( action )
	if is_table(action) then
		local  ret = {}
		for _, v in pairs(action) do ret[v] = input.checkAction(v) end
		return ret
	end

	local  keyCode =   state.keyboardBinding[action]
	return keyCode and state.keyboardStatus[keyCode] or false
end

function input.bindActionToKeyCode( action, keyCode )
	assert(is_string(action) or is_number(action))
	local oldKeyCode = state.keyboardBinding[action]

	if is_table(keyCode) then 
		for _,subk in pairs(keyCode) do 
			input.bindActionToKeyCode( action, subk )
		end
		return
	end

	assert(is_number(keyCode))
	if oldKeyCode ~= nil then
		local callbacks = state.keyboardCallbacks
		callbacks[true ][keyCode] = callbacks[true ][oldKeyCode]
		callbacks[false][keyCode] = callbacks[false][oldKeyCode]
		callbacks[true ][oldKeyCode] = nil
		callbacks[false][oldKeyCode] = nil
	end
	state.keyboardBinding[action] = keyCode
	local toBind =    state.toBind[action]
	if    toBind then input.bindAction(action, unpack(toBind)) end
end

local function onKeyboardEvent ( keyCode, down )
	if state.keyboardStatus[keyCode] == down then return end
	
	local table  = state.keyboardTables[keyCode]
	if    table ~= nil then
		table[1][table[2]] = down
	end

	local callback  = state.keyboardCallbacks[down][keyCode]
	if    callback ~= nil then 
		  callback()
	end

	if callback == nil and table == nil and down then print('\t'..keyCode) end
	state.keyboardStatus[keyCode] = down and true or nil
end

MOAIInputMgr.device.keyboard   :setCallback ( onKeyboardEvent)
MOAIInputMgr.device.pointer    :setCallback ( function() end )
MOAIInputMgr.device.mouseLeft  :setCallback ( function() end )
MOAIInputMgr.device.mouseMiddle:setCallback ( function() end )
MOAIInputMgr.device.mouseRight :setCallback ( function() end )

return input