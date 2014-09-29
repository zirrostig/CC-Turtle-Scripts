-- http://pastebin.com/QHsmLBM9

os.loadAPI("movement")
local m = movement

function stairs(w, h, ss1, ss2, sp1, sp2)
	-- Place turtle where first left most stair should go, starting from bottom
	-- facing 'up' the stairs
	local dir = true
	for i=1,h do
		m.tr()

		for j=1,w do
			if not selectSlots(sp1, sp2) then
				return false
			end
			turtle.placeDown()
			if j < w then
				m.g('F')
			end
		end

		m.tl()
		m.g('U')

		for j=1,w do
			if not selectSlots(ss1, ss2) then
				return false
			end
			turtle.placeDown()
			if j < w then
				m.tl()
				m.g('F')
				m.tr()
			end
		end
		if i < h then
			m.g('F')
		end
	end
end

function platform(w, l, s1, s2, compact)
	-- Place turtle where the left, bottom most platform block should go
	if compact == nil then
		compact = false
	end
	local right = true
	-- Face backwards
	m.tr()
	m.tr()
	for i=1,w do
		-- Face backwards
		if right then
			m.tr()
		else
			m.tl()
		end

		-- Place Row
		for j=1,l do
			-- Except for last block
			if j < l then
				m.g('B')
				if not selectSlots(s1, s2) then
					return false
				end
				turtle.place()
			end
		end

		-- Setup for change of direction
		if right then
			m.tl()
			right = false
		else
			m.tr()
			right = true
		end

		-- Move to next row (finishing the current one) if not last row or we know we can place last block (not compact)
		if i < w or not compact then
			m.g('B')
			if not selectSlots(s1, s2) then
				return false
			end
			turtle.place()
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

	m.tr()
	m.tr()

	local yf = m.getY() + h
	while m.getY() < yf do
		local y = m.getY()
		local btp
		if y < yf - 3 then
			btp = 3
			m.g('U')
		elseif y < yf - 2 then
			btp = 2
			m.g('U')
		elseif y < yf - 1 then
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
				m.g('B')
				if not selectSlots(s1,s2) then
					return false
				end
				turtle.place()
			end
		end

		while btp > 1 do
			local y = m.getY()
			if compact and y == yf then
				break
			end

			m.g('U')
			if not selectSlots(s1,s2) then
				return false
			end
			turtle.placeDown()
			btp = btp - 1
		end
		m.tr()
		m.tr()
	end

	m.tr()
	m.tr()

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

	m.g('U')
	while y < h do
		if platform_or_stair then
			-- Platform
			m.g('D')
			if not platform(ps, ps, sp1, sp2, true) then
				return false
			end
			m.g('U')
			if not selectSlots(sp1, sp2) then
				return false
			end
			turtle.placeDown()

			if math.fmod(ps, 2) == 0 then
				if ccw then
					m.g('B', ps - 1)
					m.tl()
				else
					m.tr()
					m.g('F', ps - 1)
				end
			else
				if ccw then
					m.g('B', ps - 1)
					m.tl()
					m.g('F', ps - 1)
				else
					m.tr()
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
		m.g('F')
	end

end

-- vim: noet ts=2 sw=2
