-- http://pastebin.com/safsqGeE
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

function selectSlots(start_slot, end_slot)
	if end_slot == nil then
		end_slot = start_slot
	end

	for i=start_slot,end_slot do
		if turtle.getItemCount(i) ~= 0 then
			turtle.select(i)
			return true
		end
	end
	print("Slots ",start_slot," to ",end_slot," are empty")
	return false
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

function dig(dir, ignoreSpace)
	if ignoreSpace == nil then
		ignoreSpace = false
	end

	while detectDir(dir) do
		if not ignoreSpace then
			if hasSpaceFor(dir) then
				turtle.select(1)
			else
				return false -- Only when out of space
			end
		end
		digDir(dir)
		-- Wait for gravel/sand/gravity blocks
		sleep(0.4)
	end
	return true
end

function digG(m, dir, num, ignoreSpace)
	if num == nil then num = 1 end
	if ignoreSpace == nil then ignoreSpace = false end

	for i=1,num do
		if not dig(dir, ignoreSpace) then
			return false
		end
		m.g(dir)
	end
	return true
end


function digGT(m,xn,yn,zn,dn,ignoreSpace,yFirst)
	if xn == nil then x = 0 end
	if yn == nil then y = 0 end
	if zn == nil then z = 0 end
	if dn == nil then dn = 1 end
	if ignoreSpace == nil then ignoreSpace = false end
	if yFirst == nil then yFirst = true end

	local x,y,z,d = m.getPos()
	while x ~= xn or y ~= yn or z ~= zn do
		local moved = false
		if yFirst then
			if yn < y then
				moved = digG(m, 'D', y - yn, ignoreSpace) or moved
			else
				moved = digG(m, 'U', yn - y, ignoreSpace) or moved
			end
		end

		if xn < x then
			m.face(2)
			moved = digG(m, 'F', x - xn, ignoreSpace) or moved
		else
			m.face(0)
			moved = digG(m, 'F', xn - x, ignoreSpace) or moved
		end

		if zn < z then
			m.face(3)
			moved = digG(m, 'F', z - xn, ignoreSpace) or moved
		else
			m.face(1)
			moved = digG(m, 'F', zn - z, ignoreSpace) or moved
		end

		if not yFirst then
			if yn < y then
				moved = digG(m, 'D', y - yn, ignoreSpace) or moved
			else
				moved = digG(m, 'U', yn - y, ignoreSpace) or moved
			end
		end

		if not moved then
			print("I'm stuck")
			return false
		end
		x,y,z,d = m.getPos()
	end
	m.face(dn)
end


function emptyStuff(m, chest_count, dir)
	if chest_count == nil then
		chest_count = 1
	end

	if dir == nil then
		dir = 3
	end

	print("Emptying Inventory")
	m.face(dir)
	local cc = 1
	for i = 1,16 do
		turtle.select(i)
		if turtle.getItemCount() ~= 0 then
			while not turtle.drop() do
				if chest_count > cc then
					m.g('U')
					cc = cc + 1
				else
					print("Make room in chest")
					return false
				end
			end
		end
	end
	-- Reset position
	while cc > 1 do
		m.g('D')
		cc = cc - 1
	end
	return true
end

-- vim: noet ts=2 sw=2
