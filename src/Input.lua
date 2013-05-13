input = {}

function input.init()
	input.status = {}
	input.status.keyboardBinding   = {}
	input.status.keyboardCallbacks = {[true] = {}, [false] = {}}

	input.bindActionToKeyCode('ESC'  , 27)
	input.bindAction('ESC', function() flow.exit() end)
end

function input.bindAction( action, callback1, callback2 )
	local keyCode   = input.status.keyboardBinding[action]
	local callbacks = input.status.keyboardCallbacks

	assert(keyCode   ~= nil, 'keyCode   ~= nil')
	assert(callback2 == nil or utils.is_callable(callback2),
		  'callback2 == nil or utils.is_callable(callback2)')

	if type(callback1) == 'boolean' then
		callbacks[callback1][keyCode] = callback2
	else
		assert(utils.is_callable(callback1), 'is_callable(callback1)')
		callbacks[true ][keyCode] = callback1
		callbacks[false][keyCode] = callback2
	end
end

function input.bindActionToKeyCode( action, keyCode )
	local oldKeyCode = input.status.keyboardBinding[action]
	if oldKeyCode ~= nil then
		local callbacks = input.status.keyboardCallbacks
		callbacks[true ][keyCode] = callbacks[true ][oldKeyCode]
		callbacks[false][keyCode] = callbacks[false][oldKeyCode]
		callbacks[true ][oldKeyCode] = nil
		callbacks[false][oldKeyCode] = nil
	end
	input.status.keyboardBinding[action] = keyCode
end

local function onKeyboardEvent ( keyCode, down )
	local callback  = input.status.keyboardCallbacks[down][keyCode]
	if    callback ~= nil then 
		  callback()
	elseif down then print(keyCode) end
end

function flow.keypressed(key, unicode)
	onKeyboardEvent(key, true)
end

function flow.keyreleased(key, unicode)
	onKeyboardEvent(key, false)
end

MOAIInputMgr.device.keyboard   :setCallback ( onKeyboardEvent)
MOAIInputMgr.device.pointer    :setCallback ( function() end )
MOAIInputMgr.device.mouseLeft  :setCallback ( function() end )
MOAIInputMgr.device.mouseMiddle:setCallback ( function() end )
MOAIInputMgr.device.mouseRight :setCallback ( function() end )

input.init()

input.bindActionToKeyCode('left' , 97 )
input.bindActionToKeyCode('right', 100)
input.bindActionToKeyCode('up'   , 119)
input.bindActionToKeyCode('down' , 115)

input.bindActionToKeyCode('b1'   , 13 )
input.bindActionToKeyCode('b2'   , 32 )