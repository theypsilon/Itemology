require 'lib.Reload'

class.Engine()

function Engine:initialize()
    self.entities = {}
    self.factory  = {}
    print 'init Engine!'
end

function Engine:setup()
end

function Engine:__call()
	reload.instance(self)
end