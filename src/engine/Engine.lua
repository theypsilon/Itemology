require 'lib.Reload'

class.Engine()

function Engine:_init()
    self.entities = {}
    self.factory  = {}
    print 'init Engine!'
end

function Engine:setup()
end

function Engine:__call()
	reload.instance(self)
end