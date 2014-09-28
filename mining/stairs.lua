tArgs = { ... }
x,y,z,d = 0,0,0,1

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
		y = y + num
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
		y = y - num
	else
		print("Bad direction")
		return false
	end
	return true
end

function goTo(xn,yn,zn,dn)
	if dn == nil then
		dn = d
	end

	if xn < x then
		face(2)
		g('F', x - xn)
	else
		face(0)
		g('F', xn - x)
	end

	if zn < x then
		face(2)
		g('F', z - xn)
	else
		face(0)
		g('F', zn - x)
	end

	if yn < y then
		g('D', y - yn)
	else
		g('U', yn - y)
	end
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

function stairs(w, h, ss1, ss2, sp1, sp2)
	-- Place turtle where first left most stair should go, starting from bottom
	-- facing 'up' the stairs
	local dir = true
	for i=1,h do
		tr()

		for j=1,w do
			if not selectSlots(sp1, sp2) then
				return false
			end
			turtle.placeDown()
			if j < w then
				g('F')
			end
		end

		tl()
		g('U')

		for j=1,w do
			if not selectSlots(ss1, ss2) then
				return false
			end
			turtle.placeDown()
			if j < w then
				tl()
				g('F')
				tr()
			end
		end
		if i < h then
			g('F')
		end
	end
end

function platform(w, l, s1, s2)
	-- Place turtle 1 above where the left, bottom most platform block should go
	local dir = 0
	for i=1,w do
		if dir == 0 then
			tr()
		else
			tl()
		end

		for j=1,l do
			if not selectSlots(s1, s2) then
				return false
			end
			turtle.placeDown()
			if j < l then
				g('F')
			end
		end

		if dir == 0 then
			tl()
			dir = 1
		else
			tr()
			dir = 0
		end
		if i < w then
			g('F')
		end
	end
end

function wall(w, h, s1, s2, compact)
	-- w  - base width of the wall
	-- h  - height of the wall
	-- s1 - wall materials slot first
	-- s2 - wall materials slot last
	-- compact - bool, if true, will not place last block,
	-- 					 and will be found in that spot, if false
	-- 					 will be found 1 layer above that, with the
	-- 					 wall complete
	--
	-- Place turtle at the bottom facing the direction the wall should be built
	--
	if compact == nil then
		compact = false
	end

	tr()
	tr()
	y = 0
	while y < h do
		local btp
		if y < h - 3 then
			btp = 3
			g('U')
		elseif y < h - 2 then
			btp = 2
			g('U')
		elseif y < h - 1 then
			btp = 2
		end

		for i=1,w do
			if btp > 2 and i < w then -- Don't place above if last column
				if not selectSlots(s1,s2) then
					return false
				end
				turtle.placeUp()
			end

			if btp > 1 then
				if not selectSlots(s1,s2) then
					return false
				end
				turtle.placeDown()
			end

			if i < w then
				g('B')
				if not selectSlots(s1,s2) then
					return false
				end
				turtle.place()
			end
		end

		while btp > 1 do
			if compact and y == h then
				break
			end

			g('U')
			if not selectSlots(s1,s2) then
				return false
			end
			turtle.placeDown()
			btp = btp - 1
		end
		tr()
		tr()
	end

	return true
end

function spiralStairs(w, l, h, ps, sw, ss1, ss2, sp1, sp2, ccw)
	-- w    - width  (left/right)
	-- l    - length (forward/back)
	-- h    - height (up/down)
	-- ps   - platform size (always square)
	-- sw   - stair width
	-- ss1  - stair materials slot first
	-- ss2  - stair materials slot last
	-- sp1  - platform materials slot first
	-- sp2  - platform materials slot last
	-- ccw  - bool, set true to go counter clockwise
	--
	-- Stair height is calculated to be (w or l) - 2 * ps
	--
	-- Place the turtle at the bottom, in the bottom left corner where the
	--  first(base) platform should be.
	--
	--
	if ccw == nil then
		ccw = false
	end

	local platform_or_stair = true
	local width_or_length = true -- true width, fale length

	if ccw then
		width_or_length = 0
	else
		width_or_length = 1
	end

	g('U')
	while y < h do
		d = 1
		if platform_or_stair then
			-- Platform
			platform(ps, ps, sp1, sp2)
			if math.fmod(ps, 2) == 0 then
				if ccw then
					face(3)
					g('F', ps - 1)
					face(2)
				else
					face(0)
					g('F', ps - 1)
				end
			else
				if ccw then
					face(3)
					g('F', ps - 1)
					face(2)
					g('F', ps - 1)
				else
					face(0)
				end
			end
		else
			-- Stair
			local sh
			if width_or_length then
				sh = w - 2 * ps
			else
				sh = l - 2 * ps
			end
			width_or_length = not width_or_length
			stairs(sw, sh, ss1, ss2, sp1, sp2)
		end

		platform_or_stair = not platform_or_stair
		g('F')
	end

end

-- vim: noet ts=2 sw=2
