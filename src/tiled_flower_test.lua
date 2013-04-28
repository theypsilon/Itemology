addPackagePath(libpath)

require 'flower'

addPackagePath(libpath .. 'hanappe/projects/flower-extensions/samples/')
flower.Resources.addResourceDirectory(libpath .. 'hanappe/projects/flower-extensions/samples/assets/')
flower.Resources.addResourceDirectory(libpath .. 'hanappe/projects/flower-extensions/assets/')
flower.Resources.addResourceDirectory(libpath .. 'hanappe/projects/flower-library/assets/')

import({
    libpath .. 'hanappe/projects/flower-extensions/assets/',
    libpath .. 'hanappe/projects/flower-extensions/src/',
    flower   = 'hanappe/projects/flower-library/src/',
    main     = 'hanappe/projects/flower-extensions/samples/main',
})