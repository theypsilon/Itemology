twirlingTowardsFreedom = function ()
	MOAIThread.blockOnAction ( prop:moveRot ( 100, 1.5 ))
	MOAIThread.blockOnAction ( prop:moveRot ( -100, 1.5 ))
	package.loaded ['second'] = nil;
	require 'second'
	twirlingTowardsFreedom()
end