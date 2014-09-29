-- http://pastebin.com/ct6xn7X1

os.loadAPI("movement")
os.loadAPI("util")
os.loadAPI("structures")
local m = movement
local u = util
local s = structures

function tunnel(w, h, d, chests, chestD)
	-- w - width (left/right)
	-- h - height (1 - 3)
	-- d - depth (forward)
	-- chests - number of chests available to place mined stuff
	--					0 will cause the turtle to not return to empty,
	--					default 1
	-- chestD - 'L', 'R', 'B', default 'B'

	-- Validate Height
	if h < 1 or h > 3 then
		print("Height must be between 1 and 3 (inclusive). For taller tunnels use the quarry program")
		return false
	end


	local sx,sy,sz,sd = m.getPos()
	local goRight = true

	-- Take care of chest direction
	if chests == nil then chests = 1 end
	local ignoreSpace = chests < 1

	if not ignoreSpace then
		if chestD == nil then chestD = 'B' end

		if     chestD == 'L' then chestD = sd + 1
		elseif chestD == 'R' then chestD = sd + 3
		elseif chestD == 'B' then chestD = sd + 2
		else
			print('Bad chest direction')
			return false
		end

		chestD = math.fmod(chestD, 4)
	end
	
	if h > 1 then
		m.g('U')
	end

	for i=1,d do
		if not u.dig('F', ignoreSpace) then
			local x,y,z,d = m.getPos()
			m.gt(sx,sy,sz,sd)
			u.emptyStuff(chests, chestD)
			m.gt(x,y,z,d)
		end
		m.g('F')

		if goRight then
			m.tr()
		else
			m.tl()
		end

		for j=1,w do
			if h > 1 then
				if not u.dig('D', ignoreSpace) then
					local x,y,z,d = m.getPos()
					m.gt(sx,sy,sz,sd)
					u.emptyStuff(chests, chestD)
					m.gt(x,y,z,d)
				end
			end

			if h > 2 then
				if not u.dig('U', ignoreSpace) then
					local x,y,z,d = m.getPos()
					m.gt(sx,sy,sz,sd)
					u.emptyStuff(chests, chestD)
					m.gt(x,y,z,d)
				end
			end

			if j < w then
				if not u.dig('F', ignoreSpace) then
					local x,y,z,d = m.getPos()
					m.gt(sx,sy,sz,sd)
					u.emptyStuff(chests, chestD)
					m.gt(x,y,z,d)
				end
				m.g('F')
			end
		end

		if goRight then
			m.tl()
		else
			m.tr()
		end
		goRight = not goRight
	end

	m.gt(sx,sy,sz,sd)

	if not ignoreSpace then
		u.emptyStuff(chests, chestD)
	end
end



-- vim: noet ts=2 sw=2
