local SystemFactory; import 'system'

return SystemFactory.create(

	'UpdateLevelScript',
	
	{'script', 'map'},

	function(self, e) 
		e.script() 
	end
)