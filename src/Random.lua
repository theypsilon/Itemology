math.randomseed( os.time() )

local rand, pow, floor = math.random, math.pow, math.floor

local Random = {}

function Random.next(prob, min, max)
    if not prob then prob = 2 end
    if not min or not max then min, max = 0, 1 end

    return (min + (max - min) * pow(rand(), prob))
end

return Random