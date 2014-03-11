local SystemFactory; import 'system'

return SystemFactory.create(

	'updateVelocity',

	{'body', 'pos'},

	function(self, e)
		e.vx, e.vy = e.body:getLinearVelocity()
	end
)