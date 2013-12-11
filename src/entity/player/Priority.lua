return setmetatable({
    WOUNDED = 'wounded',
    JUMPING = 'jumping',

}, {__index = function(t,k) return k end})