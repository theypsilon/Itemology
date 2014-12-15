function table.pack(...)
  return { n = select("#", ...), ... }
end

local function time(f)
	local t = os.clock()
	f()
	return os.clock() - t
end

local function funeach()
	require 'lib/fun'()

	local c = 10000000
	local t

	--1
	t         = os.clock()
	local rs1 = 0
	for i = 1, c - 1 do rs1 = rs1 + i end
	local r1  = os.clock() - t

	--2
	t         = os.clock()
	local rs2 = 0
	range(1, c):each(function(v) rs2 = rs2 + v end)
	local r2  = os.clock() - t

	local m   = range(1, c):totable()
	--3
	t         = os.clock()
	local rs3 = 0
	for _, v in pairs(m) do rs3 = rs3 + v end
	local r3  = os.clock() - t

	--4
	t         = os.clock()
	local rs4 = 0
	each(function(v) rs4 = rs4 + v end, m)
	local r4  = os.clock() - t

	--5
	t         = os.clock()
	local rs5 = range(1, c):reduce(function(a, b) return a + b end, 0)
	local r5  = os.clock() - t

	print(rs1, rs2, rs3, rs4, rs5)
	
	return r1, r2, r3, r4, r5
end

local function test(f, c)
	local results

	for i = 0, c do
		local r = table.pack(f())
	    if not results then results = r else
	    	for k, v in pairs(r) do
	    		results[k] = results[k] + v
	    	end
	    end 
	end

	for k, v in pairs(results) do
		print(k .. ': ' .. v)
	end
end

test(funeach, 5)