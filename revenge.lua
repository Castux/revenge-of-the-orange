-- revenge.lua -- Revenge of the Orange
-- Copyright (C) 2008 Noé Falzon

-- This program is  free software:  you can redistribute it and/or modify it
-- under  the terms  of the  GNU General Public License  as published by the
-- Free Software Foundation, version 3 of the License.
--
-- This program  is  distributed  in the hope  that it will  be useful,  but
-- WITHOUT  ANY WARRANTY;  without  even the implied  warranty of MERCHANTA-
-- BILITY  or  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
-- License for more details.
--
-- You should have received a copy of the  GNU General Public License  along
-- with this program. If not, see <http://www.gnu.org/licenses/>.


require "evol"

-- All the super globals



ticks = 0

N = 7		-- grid size
basetsize = 80	-- tile size
ngoals = 2	-- number of goals
level = 1
lives = 10
gameover = false
playtime = false

goverfade = 0
fadespeed = 50

circletiles = false

blowing = {}
blowrate = 100
blowzoom = 3

forblow = {}
chaintime = 200

forspawn = {}
spawntime = 800
stopspawn = false

spawning = {}
spawnrate = 300

	-- Camera (in pixels)

camx,camy = 0,0
camspeed = 10

	-- Player position (in tiles not pixels!)
px, py = math.floor(N/2), math.floor(N/2)
pcolor = {255,255,255,200}

	-- Walker

walker = {x = 1, y = 1, side = 1, ticks = 0}
walkdelay = 600

sliding = {}
slidespeed = 230


goalglow = 1.5

resettimer = false

-- Preparing everything

-- get command line options
width = arg[1] or 640
height = arg[2] or 500
fullscreen = arg[3] ~= nil or false

evol.init(width,height,fullscreen)
evol.showCursor(false)

-- adjust tilesize to resolution
tsize = basetsize * evol.height/500

math.randomseed(os.time())

-- Load sound

notes = {}

for i = 1,9 do
	notes[i] = evol.loadSound(i .. ".wav")
end

music = evol.loadMusic("music.ogg")

evol.musicVolume(80)
music:play(-1)	-- loop forever

-- Colors

black = {0,0,0}
white = {255,255,255}

hsv2rgb = function(h,s,v)

	local hi = math.floor(h/60) % 6
	local f = h/60 - math.floor(h/60)
	
	local p = v*(1-s)
	local q = v*(1-f*s)
	local t = v*(1-(1-f)*s)

	local r,g,b

	if hi == 0 then r,g,b = v,t,p
	elseif hi == 1 then r,g,b = q,v,p
	elseif hi == 2 then r,g,b = p,v,t
	elseif hi == 3 then r,g,b = p,q,v
	elseif hi == 4 then r,g,b = t,p,v
	elseif hi == 5 then r,g,b = v,p,q
	end
	
	return {r*255,g*255,b*255}
	
end

sv = {{1,1}, {1,0.333}, {0.666,1}, {1,0.666}}

resetcol = function()
	cols = {}
	
	local h = math.random(0,359)
	
	for i = 1,4 do
		
		local s,v = sv[i][1], sv[i][2]	
		
		cols[i] = hsv2rgb(h,s,v)
	end
	
	-- making complementary (for goals)	
	local h2 = (h + 180) % 360
	cols[5] = hsv2rgb(h2,1,1)
	cols[5][4] = 100
end

-- Grid

randcolor = function()
	return cols[math.random(1,4)]
end


resetgrid = function()
	grid = {}
	statusgrid = {} -- holds whether a tile has been destroyed
	
	for i = 1,N do
		grid[i] = {}
		statusgrid[i] = {}
		
		for j = 1,N do
			spawn(i,j)
		end
	end
	
	goals = {}
	for i = 1,ngoals do
		goals[i] = {math.random(2,N-1), math.random(2,N-1)}
	end
	
	
end

reset = function()
	
	makelevel()
	winstate = false
	dead = false
	
	walker = {x = 1, y = 1, side = 1, ticks = 0}
	px, py = math.floor(N/2)+1, math.floor(N/2)+1
	stopspawn = false
	blowing = {}
	florblow = {}
	spawning = {}
	forspawn = {}
	sliding = {}
	resetcol()
	resetgrid()

end

resetdelay = function(t)
	if resettimer then return end
	resettimer = true
	resetticks = ticks + t
end

makelevel = function()
	
	local l = math.floor(level/3) + 1

	N = math.floor((l - 1)/2) + 5
	ngoals = math.floor(l/2) + 1
	
end

drawtile = function(i,j, tile)
	local x1, y1, x2, y2
	
	if not tile then return end
	
	local color = {tile.color[1],tile.color[2],tile.color[3],255 - tile.blow/100*255}
	local zoom = 1 + tile.blow/100*blowzoom
	
	
	x1 = (i-1)*tsize - (camx - evol.width/2) - tsize*(zoom-1)/2
	y1 = (j-1)*tsize - (camy - evol.height/2) - tsize*(zoom-1)/2
	x2 = x1 + tsize*zoom - 1
	y2 = y1 + tsize*zoom - 1


	if circletiles then
		evol.circle((x1+x2)/2, (y1+y2)/2, zoom*tsize/2, nil, true, color)
	else
		evol.box(x1, y1, x2, y2, nil, color)
	end
end

drawplayer = function()
	local x1, y1
		
	x1 = (px-0.5)*tsize - (camx - evol.width/2)
	y1 = (py-0.5)*tsize - (camy - evol.height/2)

	local zoom = 0.75

	if circletiles then
		evol.circle(x1, y1, tsize/2*zoom, nil, true, pcolor)
	else
		evol.box(x1-tsize/2*zoom, y1-tsize/2*zoom, x1+tsize/2*zoom-1, y1+tsize/2*zoom-1, nil, pcolor)
	end
end

drawstatus = function(i,j)
	local x1, y1, x2, y2
	
	x1 = (i-1)*tsize - (camx - evol.width/2)
	y1 = (j-1)*tsize - (camy - evol.height/2)
	x2 = x1 + tsize - 1
	y2 = y1 + tsize - 1


	if statusgrid[i][j] then
		evol.circle((x1+x2)/2, (y1+y2)/2, tsize/2, nil, true, {255,0,0,200})
	end

end

drawgrid = function()
	for i = 1,N do for j = 1,N do
		drawtile(i,j,grid[i][j])
	end end
end

blowtile = function(x,y)
	local tmp = grid[x][y]
	if not tmp then return end
	
	tmp.x = x
	tmp.y = y
	table.insert(blowing,tmp)
	grid[x][y] = nil
	statusgrid[x][y] = true
	
	if px == x and py == y then die() end
	
	notes[math.random(1,9)]:play()
end

isblowing = function(x,y)
	for i,v in ipairs(blowing) do
		if v.x == x and v.y == y then return true end
	end
	
	return false
end

chainblow = function(x,y,color)

	if x < 1 or x > N or y < 1 or y > N then return end
	
	local tmp = grid[x][y]
	if not tmp then return end

	if color ~= tmp.color then return end

	blowtile(x,y)
	
	markforblow(x-1,y,color)
	markforblow(x+1,y,color)
	markforblow(x,y-1,color)
	markforblow(x,y+1,color)
end

startchain = function(x,y)
	if grid[x][y] then chainblow(x,y,grid[x][y].color) end
end

markforblow = function(x,y,color)
	table.insert(forblow,{x,y,color,ticks})
end

-- spawning tiles

markforspawn = function(x,y)
	if stopspawn then return end

	table.insert(forspawn,{x,y,ticks})
end

ismarkedforspawn = function(x,y)
	for i,v in ipairs(forspawn) do
		if v[1] == x and v[2] == y then return true end
	end
	
	return false
end

spawn = function(x,y)
	if stopspawn then return end

	table.insert(spawning,{x,y,randcolor(), spawn = 0})
	statusgrid[x][y] = false
end

drawspawning = function(v)
	local x1, y1, x2, y2
		
	local zoom = v.spawn/100*tsize
	local color = {v[3][1],v[3][2],v[3][3], v.spawn/100*255}
	
	x1 = (v[1] - 0.5)*tsize - (camx - evol.width/2) - 0.5*zoom
	y1 = (v[2] - 0.5)*tsize - (camy - evol.height/2) - 0.5*zoom
	x2 = x1 + zoom
	y2 = y1 + zoom
	
	if circletiles then
		evol.circle((x1+x2)/2, (y1+y2)/2, zoom/2, nil, true, color)
	else
		evol.box(x1, y1, x2, y2, nil, color)
	end
end



walkerincr = function()
	if walker.side == 1 then
		walker.x = walker.x + 1
		if walker.x == N then walker.side = 2 end
	elseif walker.side == 2 then
		walker.y = walker.y + 1
		if walker.y == N then walker.side = 3 end
	elseif walker.side == 3 then
		walker.x = walker.x - 1
		if walker.x == 1 then walker.side = 4 end
	elseif walker.side == 4 then
		walker.y = walker.y - 1
		if walker.y == 1 then walker.side = 1 end
	end
end

-- Shifting functions

cycle = function(x,y,dir)
	
	if x <= 1 or x >= N or y <= 1 or y >= N then
		return
	end
	
	if not ( grid[x-1][y-1] and
		grid[x-1][y] and
		grid[x-1][y+1] and
		grid[x][y-1] and
		grid[x][y+1] and
		grid[x+1][y-1] and
		grid[x+1][y] and
		grid[x+1][y+1]
		)
	then
		return
	end
	
	if dir == 1 then
	
		slide(x-1, y-1, 1, 0)
		slide(x-1, y, 0, -1)
		slide(x-1, y+1, 0, -1)
		slide(x, y-1, 1, 0)
		slide(x, y+1, -1, 0)
		slide(x+1, y-1, 0, 1)
		slide(x+1, y, 0, 1)
		slide(x+1, y+1, -1, 0)
	else
		slide(x-1, y-1, 0, 1)
		slide(x-1, y, 0, 1)
		slide(x-1, y+1, 1, 0)
		slide(x, y-1, -1, 0)
		slide(x, y+1, 1, 0)
		slide(x+1, y-1, -1, 0)
		slide(x+1, y, 0, -1)
		slide(x+1, y+1, 0, -1)
	end
end

rowshift = function(r,dir)
	local possible = true
	
	-- possible only if all tiles are present
	for i = 1,N do
		possible = possible and grid[i][r]
	end
	
	if not possible then
		return
	end

	if dir == 1 then
		blowtile(N,r)
		for i = 1,N-1 do
			slide(i, r, 1, 0)
		end
		markforspawn(1,r)
	else
		blowtile(1,r)
		for i = 2,N do
			slide(i, r, -1, 0)
		end
		markforspawn(N,r)
	end
end

colshift = function(c,dir)
	local possible = true
	
	-- possible only if all tiles are present
	for i = 1,N do
		possible = possible and grid[c][i]
	end
	
	if not possible then
		return
	end
	if dir == 1 then
		blowtile(c,N)
		for i = 1,N-1 do
			slide(c, i, 0, 1)
		end
		markforspawn(c, 1)
	else
		blowtile(c, 1)
		for i = 2,N do
			slide(c, i, 0, -1)
		end
		markforspawn(c, N)
	end
end


slide = function(x,y,dx,dy)
	
	table.insert(sliding,{x,y,dx,dy,grid[x][y].color, slide = 0})
	grid[x][y] = nil
end

drawsliding = function(tile)
	local x1, y1, x2, y2
		
	x1 = (tile[1]-1)*tsize - (camx - evol.width/2) + tile[3]*tile.slide/100*tsize
	y1 = (tile[2]-1)*tsize - (camy - evol.height/2) + tile[4]*tile.slide/100*tsize
	x2 = x1 + tsize - 1
	y2 = y1 + tsize - 1

	if circletiles then
		evol.circle((x1+x2)/2, (y1+y2)/2, tsize/2, nil, true, tile[5])
	else
		evol.box(x1, y1, x2, y2, nil, tile[5])
	end
end

-- goals stuff

drawgoal = function(tile)
	local x1, y1
		
	x1 = (tile[1]-0.5)*tsize - (camx - evol.width/2)
	y1 = (tile[2]-0.5)*tsize - (camy - evol.height/2)

	local zoom = 1 + 0.25*math.sqrt(1 + math.sin(2*math.pi*goalglow*ticks/1000))

	if circletiles then
		evol.circle(x1, y1, tsize/4*zoom, nil, true, cols[5])
	else
		evol.box(x1-tsize/4*zoom, y1-tsize/4*zoom, x1+tsize/4*zoom-1, y1+tsize/4*zoom-1, nil, cols[5])
	end
end

-- happens only when step on void, or explode underyou
die = function()
	
	if winstate then return end  -- to avoid dying in the explosion spree

	dead = true
	stopspawn = true
	for i = 1,N do for j = 1,N do
		blowtile(i,j)
	end end
	
	lives = lives - 1
	if lives <= 0 then gameover = true end
	resetdelay(2000)
end

-- Main loop

reset()
resetdelay(0)
quit = false

while not quit do	
	
	dt,fps,ticks = evolcore.timer()
	
	evol.input {
		function(key)
			if key == evol.key_escape then quit = true end

			if not gameover then if ticks > resetticks + 100/spawnrate + spawntime then
			
				if key == evol.key_x then cycle(px,py,-1)				
				elseif key == evol.key_v then cycle(px,py,1)
			--	elseif key == evol.key_r then reset()	-- CHEAT
				elseif key == evol.key_o then circletiles = not circletiles
			--	elseif key == evol.key_q then blowtile(px,py) 	-- CHEAT
			--	elseif key == evol.key_plus then level=level+1 	--CHEAT
			--	elseif key == evol.key_minus then lives=lives-1 	--CHEAT
				end
			
				if evol.isKeyDown(evol.key_c) then
					if key == evol.key_right then rowshift(py,1)
					elseif key == evol.key_left then rowshift(py,-1)
					elseif key == evol.key_up then colshift(px,-1)
					elseif key == evol.key_down then colshift(px,1)
					end
				else
					if key == evol.key_right then px = px + 1
					elseif key == evol.key_left then px = px - 1
					elseif key == evol.key_up then py = py - 1
					elseif key == evol.key_down then py = py + 1
					end
				
					if not grid[px] or not grid[px][py] then die() end
				end end
			end
		end
	}
	
	-- Update camera
	camx = camx + ((px - 0.5)*tsize - camx)*camspeed*dt
	camy = camy + ((py - 0.5)*tsize - camy)*camspeed*dt

	-- Update walker
	if ticks >= walker.ticks + walkdelay then
		startchain(walker.x,walker.y)
		walkerincr()
		walker.ticks = ticks
	end
	
	-- Update blowing tiles
	for i,v in ipairs(blowing) do
		v.blow = v.blow + blowrate*dt
		if v.blow >= 100 then
			table.remove(blowing,i)
			markforspawn(v.x,v.y)
		end
	end
	
	-- Update marked for blow tiles
	for i,v in ipairs(forblow) do
		if ticks >= v[4] + chaintime then
			chainblow(v[1],v[2],v[3])
			table.remove(forblow,i)
		end
	end
	
	-- Update marked for spawn
	for i,v in ipairs(forspawn) do
		if ticks >= v[3] + spawntime then
			spawn(v[1],v[2])
			table.remove(forspawn,i)
		end
	end
	
	-- Update spawning tiles
	for i,v in ipairs(spawning) do
		v.spawn = v.spawn + spawnrate*dt
		if v.spawn >= 100 then
			grid[v[1]][v[2]] = {color = v[3], blow = 0}
			table.remove(spawning,i)
		end
	end
	
	-- Update sliding tiles
	for i,v in ipairs(sliding) do
		v.slide = v.slide + slidespeed*dt
		if v.slide >= 100 then
			grid[v[1]+v[3]][v[2]+v[4]] = {color = v[5], blow = 0}
			table.remove(sliding,i)
		end
	end
	
	-- Check winning condition
	local win = true
	for i,v in ipairs(goals) do
		win = win and statusgrid[v[1]][v[2]]
	end
	if win and not winstate and not dead and not gameover then
		winstate = true
		stopspawn = true
		for i = 1,N do for j = 1,N do
			blowtile(i,j)
		end end
		
		level = level + 1
		resetdelay(2000)
	end
	
	-- Reseting timer
	if resettimer and ticks > resetticks then
		resettimer = false
		reset()
	end
	
	--[[DRAW STUFF]]
	
	evol.fill(black)
	
	if not winstate then
		
		if not dead then
			-- draw tiles
			drawgrid()
		
			-- draw spawning tiles
			for i,v in ipairs(spawning) do
				drawspawning(v)
			end
	
			-- draw sliding tiles
			for i,v in ipairs(sliding) do
				drawsliding(v)
			end
		end
		
		-- draw player
		drawplayer()
	

		-- draw goals
		for i,v in ipairs(goals) do
			drawgoal(v)
		end
	end
	
	-- only blowing tiles are allowed during winning state
	-- draw blowing tiles
	for i,v in ipairs(blowing) do
		drawtile(v.x,v.y,v)
	end
	
	
	-- GAME OVER
	
	if gameover then
		goverfade = goverfade + fadespeed*dt
		if goverfade > 200 then goverfade = 200 end
		evol.box(0,0,evol.width-1,evol.height-1,nil,{255,255,255,goverfade})
	
	end
	
	-- print level thing
	lbox = 15 * tsize/basetsize
	for i = 1,level do
		evol.box(lbox+2,i*lbox+2,2*lbox-2,(i+1)*lbox-2 , nil, {cols[5][1],cols[5][2],cols[5][3]})
	end
	
	-- print lives thing
	for i = 1,lives do
		evol.box(evol.width-2*lbox+2,i*lbox+2,evol.width-lbox-2,(i+1)*lbox-2 , nil, {cols[5][1],cols[5][2],cols[5][3]})
	end

	
	evol.flip()		
end

-- Cleaning the mess

for i,v in ipairs(notes) do
	v:free()
end

music:free()

evol.quit()
