local oldrequire = require
require = hackedRequire('../lib/hanappe/projects/flower-library/src/','flower')

require '../lib/hanappe/projects/flower-library/src/flower'
require '../lib/hanappe/projects/flower-extensions/src/tiled'
require '../lib/hanappe/projects/flower-extensions/src/physics'
require '../lib/hanappe/projects/flower-extensions/src/widget'

require = oldrequire