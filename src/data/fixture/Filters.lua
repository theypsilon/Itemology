local C_BOUNDARY     = 0x0001
local C_FRIEND       = 0x0002
local C_ENEMY        = 0x0004
local C_ENEMY_SHOOT  = 0x0008
local C_FRIEND_SHOOT = 0x0010
local C_ITEM         = 0x0020

return {
    C_BOUNDARY     = C_BOUNDARY,
    C_FRIEND       = C_FRIEND,
    C_ENEMY        = C_ENEMY,
    C_ENEMY_SHOOT  = C_ENEMY_SHOOT,
    C_FRIEND_SHOOT = C_FRIEND_SHOOT,
    C_ITEM         = C_ITEM,

    M_FRIEND       = C_BOUNDARY + C_ENEMY  + C_ENEMY_SHOOT + C_ITEM,
    M_ENEMY        = C_BOUNDARY + C_FRIEND + C_FRIEND_SHOOT,
    M_FRIEND_SHOOT = C_BOUNDARY + C_ENEMY,
    M_ITEM         = C_FRIEND
}