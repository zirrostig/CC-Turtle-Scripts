----------------------------
-- Turtle Quarry          --
--                        --
-- pastebin.com/ip0EYCYr  --
--                        --
-- Replacement for the    --
-- builtin 'excavate'     --
-- program.               --
--                        --
-- Args: default in []    --
--                        --
-- quarry <width>[9]      --
--        <length>[9]     --
--        <depth>[9]      --
--        <chestCount>[1] --
--        <offset>[0]     --
--                        --
----------------------------

tArgs = { ... }
width = tonumber(tArgs[1]) or 2
length = tonumber(tArgs[2]) or 2
depth = tonumber(tArgs[3]) or 2
chest_count = tonumber(tArgs[4]) or 1
start_offset = tonumber(tArgs[5]) or 0
x,y,z,d,l = 0,0,0,1,0
xs,ys,zs,ds = 0,0,0,1
resume = 0

-- x - left-right (width)
-- z - forward-back (length)
-- y - up-down (depth, 0 is top, increases going down)

-- d (dir relative to starting position)
-- 0 right
-- 1 forward
-- 2 left
-- 3 back

-- l (layer direction, needed for return function)
-- (O designates layer start, X layer end)
-- 0 - Right
-- 1 - Left

function tl(num)
	if num == nil then
		num = 1
	end
	for i = 1,num do
		turtle.turnLeft()
		d = math.fmod(d + 1, 4)
	end
end

function tr(num)
	if num == nil then
		num = 1
	end
	for i = 1,num do
		turtle.turnRight()
		d = math.fmod((d - 1) + 4, 4) -- add 4 so that it stays positive
	end
end

function face(dir)
	if d == dir then
		return
	elseif math.fmod(d+1, 4) == dir then
		tl(1)
	else
		while d ~= dir do
			tr(1)
		end
	end
end


function g(dir, num)
	if dir == nil then
		dir = 'F'
	end
	if num == nil then
		num = 1
	end
	if dir == 'F' then
		for i = 1,num do
			if not turtle.forward() then
				if turtle.detect() then
					print("Something is in the way")
				else
					print("out of fuel")
				end
				return false
			end
		end
		if d == 0 then
			x = x + num
		elseif d == 1 then
			z = z + num
		elseif d == 2 then
			x = x - num
		elseif d == 3 then
			z = z - num
		end
	elseif dir == 'B' then
		for i = 1,num do
			if not turtle.back() then
				print("out of fuel")
				return false
			end
		end
		if d == 0 then
			x = x - num
		elseif d == 1 then
			z = z - num
		elseif d == 2 then
			x = x + num
		elseif d == 3 then
			z = z + num
		end
	elseif dir == 'U' then
		for i = 1,num do
			if not turtle.up() then
				if turtle.detectUp() then
					print("Something is in the way")
				else
					print("out of fuel")
				end
				return false
			end
		end
		y = y - num
	elseif dir == 'D' then
		for i = 1,num do
			if not turtle.down() then
				if turtle.detectDown() then
					print("Something is in the way")
				else
					print("out of fuel")
				end
				return false
			end
		end
		y = y + num
	else
		print("Bad direction")
		return false
	end
	return true
end

function cmpDir(dir)
	if dir == 'U' then
		return turtle.compareUp()
	elseif dir == 'F' then
		return turtle.compare()
	elseif dir == 'D' then
		return turtle.compareDown()
	end
end


function detectDir(dir)
	if dir == 'U' then
		return turtle.detectUp()
	elseif dir == 'F' then
		return turtle.detect()
	elseif dir == 'D' then
		return turtle.detectDown()
	end
end

function digDir(dir)
	if dir == 'U' then
		return turtle.digUp()
	elseif dir == 'F' then
		return turtle.dig()
	elseif dir == 'D' then
		return turtle.digDown()
	end
end

function hasSpaceFor(dir)
	-- Two loops because 1 check is much faster and will be true often enough

	-- Does quick check for empty spots
	for i=1,16 do
		-- if nothing is in the slot
		if turtle.getItemCount(i) == 0 then
			return true
		end
	end

	-- This is much slower due to the turtle.select(i) call
	for i=1,16 do
		-- Check if it is the same item and would fit
		-- Items that drop different than their ore can't
		-- make this check yet, and depend on an empty slot
		turtle.select(i)
		if turtle.getItemSpace() > 0 and cmpDir(dir) then
			return true
		end
	end
	-- No Room, fail
	return false
end

function dig(dir)
	while detectDir(dir) do
		if hasSpaceFor(dir) then
			turtle.select(1)
			digDir(dir)
		else
			return false -- Only when out of space
		end
		-- Wait for gravel/sand/gravity blocks
		sleep(0.4)
	end
	return true
end

function returnToSurface()
	print("Returing to Surface")
	-- Save current position
	xs,ys,zs,ds = x,y,z,d

	-- Get clear of un-mined blocks
	if d == 1 or d == 3 then
		g('B')
	elseif z > 0 then -- Not at bottom
		face(3)
		g('F')
	else
		face(1)
		g('F')
	end
	if y > 1 then
		g('U', 2)
	elseif y > 0 then
		g('U')
	end

	-- Return to start
	if x ~= 0 then
		face(2)
		g('F', x)
	end
	if z ~= 0 then
		face(3)
		g('F', z)
	end
	g('U', y)
end

function emptyStuff()
	print("Emptying Inventory")
	face(3)
	if x ~= 0 or y ~= 0 or z ~= 0 or d ~= 3 then
		print("not facing chest(s)")
		return false
	end
	for i = 1,16 do
		turtle.select(i)
		if turtle.getItemCount() ~= 0 then
			while not turtle.drop() do
				if chest_count > y + 1 then
					g('U')
				else
					print("Make room in chest")
					return false
				end
			end
		end
	end
	-- Reset position
	while y < 0 do
		g('D')
	end
	return true
end

function returnToMining()
	print("Returning To Mining")
	-- ys should not be 0, bad stuff happened if so
	if ys <= 0 then
		print("Should never have ys == 0")
	elseif ys <= 2 then
		g('D', ys)
	else
		g('D', ys - 2)
	end

	face(0)
	g('F', xs)
	face(1)
	g('F', zs)

	-- Hopefully these 1 or 2 digs don't cause the turtle to run out of space :P
	for i = 1,2 do
		if y < depth then
			dig('D')
			g('D')
		end
	end

	face(ds)
end

function endOfLayer()
	if l == 0 then
		return x >= width - 1 and z >= (math.fmod(width,2) * (length - 1))
	elseif l == 1 or l == 2 then
		return x == 0 and z == 0
	end
	print("Can't determine layer completion")
	return true
end

function digLayer()
	-- A layer is 3 y levels since the turtle moves by mining up, down and forward
	--
	-- Dig down 2 to begin layer
	print("Digging layers")
	local start
	if resume == 0 then
		for i = 1,2 do
			if y < depth then
				if not dig('D') then
					resume = 1
					return false
				end
				g('D')
			end
		end
		start = true
	end
	resume = 0

	-- Will stop if out of space
	while not endOfLayer() do
		if not dig('U') then
			resume = 1
			return false
		end
		-- Last 1 or 2 layers, so only dig down if we're supposed to
		if y < depth then
			if not dig('D') then
				resume = 1
				return false
			end
		end
		-- Turn if necessary
		if not start and (z == 0 or z == length - 1) then
			if d == 1 or d == 3 then
				face(2 * l)
			elseif z == length - 1 then
				face(3)
			elseif z == 0 then
				face(1)
			end
		end
		start = false

		if not dig('F') then
			resume = 1
			return false
		end
		g('F')
	end
	-- When finishing a layer, the last block above/below are left
	if not dig('U') then
		resume = 1
		return false
	end
	if y < depth then
		if not dig('D') then
			resume = 1
			return false
		end
		g('D')
	end

	if l == 1 or l == 2 then
		l = 0
	elseif z == length - 1 then
		l = 1
	elseif z == 0 then
		l = 2
	end

	-- Turn to face the next correct direction
	if z == 0 then
		face(1)
	else
		face(3)
	end

	return true
end


function main()
	print("Turtle Quarry v0.1")
	print("Make sure the turtle is in the bottom left corner of the to be hole.")
	print("And make sure a chest is behind the turtle")
	print("EX: quarry 3 5 <depth> <chests> <offset>")
	print()
	print("---")
	print("---")
	print("---")
	print("---")
	print("^--  Turtle is facing up")
	print("CC   Chest behind")
	print()
	print("Waiting 3s before starting")
	sleep(3)

	-- Go to start offset
	if start_offset > 0 then
		print("Going to starting offset")
	end
	while y < start_offset do
		if not dig('D') then
			returnToSurface()
			while not emptyStuff() do
				print("Make room in chest")
				sleep(10)
			end
			returnToMining()
		end
		g('D')
	end

	print("Mining...")
	turtle.select(1)
	while y ~= depth do
		if not digLayer() then
			returnToSurface()
			while not emptyStuff() do
				sleep(10)
			end
			returnToMining()
		end
	end
	returnToSurface()
	while not emptyStuff() do
		print("Make room in chest")
		sleep(10)
	end
end

main()

-- vim: noet ts=2 sw=2
