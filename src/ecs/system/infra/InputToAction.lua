local System; import 'ecs'
local InputToAction = class(System)

function InputToAction:_init()
    System._init(self)

    self.keys  = require('Input').state.keyboardStatus
    self.codes = require 'data.key.SDLKeycodes'
end

function InputToAction:requires()
	return {'input', 'action'}
end

function InputToAction:update(e, _, input, action)
    for action_name, key_name in pairs(input) do
        local code   = self.codes[key_name] or key_name
        local pushed = self.keys[code]
        
        if not pushed then
        	pushed   = self.keys[string.byte(code)]
        end
        action[action_name] = pushed
    end
end


return InputToAction