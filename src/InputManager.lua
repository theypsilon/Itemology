require 'lib.Operations'

function initInput()
	input = {}
	input.keyboardBinding   = {}
	input.keyboardCallbacks = {[true] = {}, [false] = {}}
	--local actionDevice      = {}

	bindActionToKeyCode('ESC'  , 27 )
	bindAction('ESC', function() os.exit() end)
end

local inputStash = {}
function inputStatusPush()
	table.insert(inputStash,input)
end

function inputStatusPop()
	input = table.remove(inputStash)
end

function bindAction( action, callback1, callback2 )
	local keyCode = input.keyboardBinding[action]

	assert(keyCode   ~= nil, 'keyCode   ~= nil')
	assert(callback2 == nil or utils.is_callable(callback2),
		  'callback2 == nil or utils.is_callable(callback2)')

	if type(callback1) == 'boolean' then
		input.keyboardCallbacks[callback1][keyCode] = callback2
	else
		assert(utils.is_callable(callback1), 'is_callable(callback1)')
		input.keyboardCallbacks[true ][keyCode] = callback1
		input.keyboardCallbacks[false][keyCode] = callback2
	end
end

function bindActionToKeyCode( action, keyCode )
	local oldKeyCode = input.keyboardBinding[action]
	if oldKeyCode ~= nil then
		input.keyboardCallbacks[true ][keyCode] = input.keyboardCallbacks[true ][oldKeyCode]
		input.keyboardCallbacks[false][keyCode] = input.keyboardCallbacks[false][oldKeyCode]
		input.keyboardCallbacks[true ][oldKeyCode] = nil
		input.keyboardCallbacks[false][oldKeyCode] = nil
	end
	input.keyboardBinding[action] = keyCode
end

-- function input.check( action )
-- 	local currentDevice = actionDevice[action]
-- 	if currentDevice ~= nil then
-- 		error('check for device \'' .. currentDevice .. '\' not implemented')
-- 	end
-- end

local function onKeyboardEvent ( keyCode, down )
	local callback  = input.keyboardCallbacks[down][keyCode]
	if    callback ~= nil then 
		  callback()
	elseif down then print(keyCode) end
end

initInput()

MOAIInputMgr.device.keyboard   :setCallback ( onKeyboardEvent)
MOAIInputMgr.device.pointer    :setCallback ( function() end )
MOAIInputMgr.device.mouseLeft  :setCallback ( function() end )
MOAIInputMgr.device.mouseMiddle:setCallback ( function() end )
MOAIInputMgr.device.mouseRight :setCallback ( function() end )

bindActionToKeyCode('left' , 97 )
bindActionToKeyCode('right', 100)
bindActionToKeyCode('up'   , 119)
bindActionToKeyCode('down' , 115)

bindActionToKeyCode('b1'   , 13 )
bindActionToKeyCode('b2'   , 32 )