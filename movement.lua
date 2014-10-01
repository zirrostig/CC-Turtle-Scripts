-- http://pastebin.com/nEkRA28E
local x,y,z,d = 0,0,0,1

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
		d = math.fmod(d + 3, 4) -- add 4 so that it stays positive
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

function gt(xn,yn,zn,dn)
	if xn == nil then x = 0 end
	if yn == nil then y = 0 end
	if zn == nil then z = 0 end
	if dn == nil then dn = 1 end

	while x ~= xn or y ~= yn or z ~= zn do
		local moved = false
		if xn < x then
			face(2)
			moved = g('F', x - xn) or moved
		else
			face(0)
			moved = g('F', xn - x) or moved
		end

		if zn < z then
			face(3)
			moved = g('F', z - zn) or moved
		else
			face(1)
			moved = g('F', zn - z) or moved
		end

		if yn < y then
			moved = g('D', y - yn) or moved
		else
			moved = g('U', yn - y) or moved
		end

		if not moved then
			print("I'm stuck")
			return false
		end
	end
	face(dn)
	return true
end

function setPos(xn,yn,zn,dn)
	x = xn
	y = yn
	z = zn
	d = dn
end

function getPos()
	return x,y,z,d
end

function getX()
	return x
end

function getY()
	return y
end

function getZ()
	return z
end

function getD()
	return d
end

-- vim: noet ts=2 sw=2
