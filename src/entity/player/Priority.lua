return setmetatable({
        WOUNDED =     'wounded',
        JUMPING =     'jumping',
       DJUMPING =    'djumping',
    WALLJUMPING = 'walljumping'

}, {__index = function(t,k) return k end})