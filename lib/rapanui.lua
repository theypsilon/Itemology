local oldrequire = require
require = hackedRequire('../lib/rapanui/','rapanui-sdk')
require 'rapanui-sdk/rapanui'
require = oldrequire