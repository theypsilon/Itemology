local input = {}

local state
function input.initialState()
	state = {
		keyboardBinding   = {},
		keyboardCallbacks = {[true] = {}, [false] = {}},
		toBind = {}
	}
end
input.initialState()

function input.bindAction( action, callback1, callback2 )
	if is_table(action) then 
		for _,suba in pairs(action) do 
			input.bindAction(suba, callback1, callback2 )
		end
		return
	end

	assert(is_string(action) or is_number(action))
	local keyCode   = state.keyboardBinding[action]
	local callbacks = state.keyboardCallbacks

	if keyCode == nil then 
		state.toBind[action] = {callback1, callback2}
		return
	end

	assert(keyCode   ~= nil, 'keyCode   ~= nil')
	assert(is_nil(callback2) or is_callable(callback2),
		  'is_nil(callback2) or is_callable(callback2)')

	if is_boolean(callback1) then
		callbacks[callback1][keyCode] = callback2
	else
		assert(is_callable(callback1), 'is_callable(callback1)')
		callbacks[true ][keyCode] = callback1
		callbacks[false][keyCode] = callback2
	end
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
	local callback  = state.keyboardCallbacks[down][keyCode]
	if    callback ~= nil then 
		  callback()
	elseif down then print(keyCode) end
end

MOAIInputMgr.device.keyboard   :setCallback ( onKeyboardEvent)
MOAIInputMgr.device.pointer    :setCallback ( function() end )
MOAIInputMgr.device.mouseLeft  :setCallback ( function() end )
MOAIInputMgr.device.mouseMiddle:setCallback ( function() end )
MOAIInputMgr.device.mouseRight :setCallback ( function() end )

return input