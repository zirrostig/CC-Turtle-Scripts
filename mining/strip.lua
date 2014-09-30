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

function quarry(w, l, d, chests, chestD)
	local sx,sy,sz,sd = m.getPos()

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


	-- Begin quarrying
	local yf = sy + d
	local colDir = sd -- Start going away
	local rowDir = math.fmod(sd + 3, 4) -- Start going right

	while m.getY() > yf do
		local y = m.getY()
		local mineUp,mineDown = false,false

		while not u.digG('D', 1, ignoreSpace) do -- Go down at least 1
			local xt,yt,zt,dt = m.getPos()
			m.gt(sx,sy,sz,sd)
			u.emptyStuff(chests, chestD)
			m.g('D')
			m.digGT(xt,yt,zt,dt)
		end

		if y > yf - 2 then -- Mine Above
			while not u.digG('D', 1, ignoreSpace) do
				local xt,yt,zt,dt = m.getPos()
				m.g('U')
				m.gt(sx,sy,sz,sd)
				u.emptyStuff(chests, chestD)
				m.g('D')
				m.digGT(xt,yt,zt,dt)
			end
			mineUp = true
		end

		if y > yf - 1 then -- Mine Below
			while not u.dig('D', ignoreSpace) do
				local xt,yt,zt,dt = m.getPos()
				if m.getY() + 2 < ys then m.g('U', 2) end
				m.gt(sx,sy,sz,sd)
				u.emptyStuff(chests, chestD)
				m.g('D')
				m.digGT(xt,yt,zt,dt)
			end
			mineDown = true
		end

		-- Mine out a layer (1-3 y levels)
		for x=1,w do
			-- Dig Column
			for z=1,l do

				if mineUp then
					while not u.dig('U', ignoreSpace) do
						local xt,yt,zt,dt = m.getPos()
						if z ~= 1 then m.g('B') end
						if m.getY() + 2 < ys then
							m.g('U', 2)
						elseif m.getY() + 1 < ys then
							m.g('U')
						end
						m.gt(sx,sy,sz,sd)
						u.emptyStuff(chests, chestD)
						m.g('D')
						m.digGT(xt,yt,zt,dt)
					end
				end

				if mineDown then
					while not u.dig('D', ignoreSpace) do
						local xt,yt,zt,dt = m.getPos()
						if z ~= 1 then m.g('B') end
						if m.getY() + 2 < ys then
							m.g('U', 2)
						elseif m.getY() + 1 < ys then
							m.g('U')
						end
						m.gt(sx,sy,sz,sd)
						u.emptyStuff(chests, chestD)
						m.g('D')
						m.digGT(xt,yt,zt,dt)
					end
				end

				if z < l then
					while not u.digG('F', 1, ignoreSpace) do
						local xt,yt,zt,dt = m.getPos()
						if z ~= 1 then m.g('B') end
						if m.getY() + 2 < ys then
							m.g('U', 2)
						elseif m.getY() + 1 < ys then
							m.g('U')
						end
						m.gt(sx,sy,sz,sd)
						u.emptyStuff(chests, chestD)
						m.g('D')
						m.digGT(xt,yt,zt,dt)
					end
				end
			end

			-- Rotate to face next column
			m.face(rowDir)

			if x < w then
				-- End of column, turn and move to next
				while not u.digG('F', 1, ignoreSpace) do
					local xt,yt,zt,dt = m.getPos()
					if m.getY() + 2 < ys then
						m.g('U', 2)
					elseif m.getY() + 1 < ys then
						m.g('U')
					end
					m.gt(sx,sy,sz,sd)
					u.emptyStuff(chests, chestD)
					m.g('D')
					m.digGT(xt,yt,zt,dt)
				end
			end

			-- Update column movement direction
			colDir = math.fmod(colDir + 2, 4)
			m.face(colDir)
		end

		-- End of layer, prepare for next
		rowDir = math.fmod(rowDir + 2, 4)

	end

	-- Return home
	u.digGT(sx,sy,sz,sd,ignoreSpace)

	if not ignoreSpace then
		u.emptyStuff(chests, chestD)
	end

end

-- vim: noet ts=2 sw=2
