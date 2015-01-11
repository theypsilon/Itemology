local Logger; import()

local TickLogger = class(Logger)

function TickLogger.timer()
    assert(defined('tickClock'))
    return tickClock.ticks
end

return TickLogger