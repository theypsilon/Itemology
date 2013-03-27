require 'lib.Reload'

class.Engine()

function Engine:_init()
    self.entities = {}
    self.factory  = {}
    print 'init Engine!'
end

function Engine:setup()
end

function Engine:update()
	updateInstance(self)
end