-- evol.lua -- evöL
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

require "evolcore"

module(..., package.seeall)

require("evol_keys")

--- **General**

--- Initializes evöL
-- evol.init(w,h,[full])
-- w,h: width and height in pixels of the desired window
-- full: if true, gets fullscreen mode
init = function(w,h,full)
	width = w
	height = h
	evolcore.init(w,h,full)
end

--- Timer utility function
-- dt,fps,t = evol.timer([fpsmax])
-- Must be called each frame.
-- dt: time since last frame
-- fps: average number of frame per seconds (updated every second)
-- t: ticks (miliseconds since the program started)
-- fpsmax: if provided, limits the fps to this number
timer = evolcore.timer

--- Change cursor visibility
-- evol.showCursor(show)
-- show: if true, makes cursor visible, if false, makes it invisible
showCursor = evolcore.showCursor

--- Frees the memory associated to a previously loaded/created image, font, sound or music
-- evol.free(stuff) or stuff:free()
-- stuff: an image, font, sound or music to be freed
free = function(stuff)
	
	if stuff.type == "Image" then
		evolcore.freeSurf(stuff.surf)
	elseif stuff.type == "Font" then
		evolcore.freeFont(stuff.font)
	elseif stuff.type == "Sound" then
		evolcore.freeSound(stuff.sound)
	elseif stuff.type == "Music" then
		evolcore.freeMusic(stuff.music)
	end
	
	stuff = nil
end

--- Shuts down evöL
-- evol.quit()
quit = evolcore.quit

--- **Video**

--- Updates screen
-- evol.flip()
flip = evolcore.flip

--- **Images** 

--- A container for a drawable surface
-- Image object
-- Fields:
-- 	cx,cy: center of the image, relatively to top-left corner. Used by draw() to place the image.
-- Shortcut methods:
-- 	image:draw([x,y,[dest]])
-- 	image:fill(color,[rect])
-- 	image:putpix(x,y,color)
-- 	image:free()


-- INTERNAL! -- Prepares an Image table
local Image = function()
	tmp = {}
	tmp.blit = blit
	tmp.free = free
	tmp.fill = function(image,color,rect)
		fill(color,rect,image)
	end
	tmp.putpixel = function(image,x,y,color)
		putpix(x,y,color,image)
	end
	
	tmp.type = "Image"
	
	return tmp
end


--- Creates an image from a file (any format supported by SDL_image)
-- image = evol.loadImage(path)
-- path: string containing the path to the image to load (relative to current folder, or absolute)
-- image: the created image
loadImage = function(path)
	tmp = Image()
	tmp.surf, tmp.w, tmp.h = evolcore.loadImage(path)
	
	tmp.cx = tmp.w / 2
	tmp.cy = tmp.h / 2
	
	return tmp
end

--- Creates an empty image
-- image = evol.makeImage(w,h)
-- w,h: width and height of the image to create
-- image: the created image
makeImage = function(w,h)
	tmp = Image()
	tmp.surf, tmp.w, tmp.h = evolcore.makeSurf(w,h)
	
	tmp.cx = tmp.w / 2
	tmp.cy = tmp.h / 2
	
	return tmp
end

--- Fills a rectangle of an image with given color
-- evol.fill(color,[rect,[img]]) or image:fill(color,[rect])
-- color = {r,g,b,a} or {r,g,b}: color to fill with
-- rect = {x,y,w,h}: the rectangle to fill. Defaults to full surface.
-- img: image to fill. Defaults to screen.
fill = function(color, rect, img)
	
	img = img or {}
	rect = rect or {0,0,0,0}
	
	if not color[4] then color[4] = 255 end		-- RGB are opaque by default
	
	evolcore.fill(rect[1],rect[2],rect[3],rect[4],color[1],color[2],color[3],color[4], img.surf)
end

--- Blits an image onto another
-- evol.blit(image,[x,y,[dest]]) or image:blit([x,y,[dest]])
-- x,y: position in pixels where to put the center of the image to. Defaults to image center, so that it is put in the top left corner.
-- dest: destination image. Defaults to screen.
blit = function(image, x, y, dest)

	if not dest then dest = {} end
	if not x then x = image.cx end
	if not y then y = image.cy end
		
	evolcore.blit(image.surf, x-image.cx, y-image.cy, dest.surf)
end

--- Changes the color of a pixel on an image
-- evol.putpix(x,y,color,[image]) or image:putpix(x,y,color)
-- x,y: coordinates of the pixel to change
-- color = {r,g,b,[a]}: color to set the pixel to
-- image: the image to modify. Defaults to screen.
putpix = function(x, y, color, img)
	
	img = img or {}
	if not color[4] then color[4] = 255 end
	
	evolcore.putpix(x, y, color[1],color[2],color[3],color[4], img.surf)
end

--- **Input**


--- Polls events and call the associated callback functions
-- evol.input(callbacks)
-- callbacks = {kdown, kup, mdown, mup}: table of callback functions. Each of those can be nil if not needed.
-- Event details are passed to the functions as follows:
-- kdown(key): key down event (key: the key pressed)
-- kup(key): key up event (key: the key released)
-- mdown(x,y,b): mouse button down event (x,y: mouse coordinates, b: mouse button number)
-- mup(x,y,b): mouse button up event (x,y: mouse coordinates, b: mouse button number)
input = function(table)
	
	local ret,a,b,c = evolcore.input()

	-- return value of 0 means no event
	if ret == 0 then return end
	
	-- otherwise, call the callback if it is not nil
	-- print("ret", ret)
	
	if table[ret] then table[ret](a,b,c) end
end

--- Queries for mouse position and optionally the status of a button
-- x,y,[down] = evol.mouse([button])
-- button: the button to check status of
-- x,y: position of mouse
-- down: boolean stating if given button is down
mouse = evolcore.mouse

--- States if given mouse button is down
-- down = evol.isButtonDown(button)
-- button: the button to check status of
-- down: boolean stating if given button is down
isButtonDown = function(button)
	local _,_,down = mouse(button)
	return down == 1
end

--- States if given key is down
-- down = evol.isKeyDown(key)
-- key: the key to check status of
-- down: boolean stating if given key is down
isKeyDown = evolcore.isKeyDown

--- **Fonts**

--- A container for fonts
-- Font object
-- Fields:
-- 	font.width: glyph width if the font is monospace, or else 0
-- Shortcut methods:
-- 	font:write(text,x,y,[color,[image]])
-- 	font:free()

-- INTERNAL! -- Prepares a Font table
local Font = function()
	tmp = {}
	
	tmp.write = write
	tmp.free = free
	
	tmp.type = "Font"
	
	return tmp
end

--- Loads a font
-- font = evol.loadFont(path,size)
-- path: string containing the path to the font to load (relative to current folder, or absolute)
-- size: number of pixels high the fo--- Loads a font
-- font = evol.loadFont(path,size)
-- path: string containing the path to the font to load (relative to current folder, or absolute)nt should render in later
loadFont = function(path, size)
	tmp = Font()
	tmp.font,tmp.width = evolcore.loadFont(path, size)

	return tmp
end

--- Renders text to an image
-- evol.write(font,text,x,y,[color,[image]]) or font:write(text,x,y,[color,[image]])
-- font: the font to use for render
-- text: UTF-8 string to render
-- x,y: position in pixels where the top-left corner of render text should appear
-- color = {r,g,b}: color to render the text in. Defaults to black.
-- image: destination image. Defaults to screen. 
write = function(font, text, x, y, color, surf)
	
	surf = surf or {}
	color = color or {0,0,0}
	
	evolcore.printFont(font.font, text, color[1], color[2], color[3], x, y, surf.surf)
end

--- *Graphic primitives*

--- Draws a line
-- evol.line(x,y,u,v,[color,[aa,[image]]])
-- (x,y),(u,v): coordinates in pixel of the start and end of the line
-- color = {r,g,b,[a]}: color of the line. Defaults to black.
-- aa: set to true to draw an anti-aliased line
-- image: the image to draw to. Defaults to screen.
line = function(x, y, u, v, color, aa, surf)
	
	surf = surf or {}
	color = color or {0,0,0}
	
	if aa then aa = 1 else aa = 0 end
	
	if not color[4] then color[4] = 255 end		-- RGB are opaque by default
	
	evolcore.draw(x,y,u,v, color[1], color[2], color[3], color[4], 0, aa, surf.surf)
end

--- Draws a rectangle
-- evol.box(x,y,u,v,color,[fill,[image]])
-- (x,y),(u,v): coordinates in pixel of one corner and the opposite corner of the rectangle
-- color = {r,g,b,[a]}: color of the line. If nil, no line.
-- fill: = {r,g,b,[a]}: color of the filling. If nil, no filling.
-- image: the image to draw to. Defaults to screen.
box = function(x, y, u, v, color, fill, surf)
	
	surf = surf or {}
	
	if color and not color[4] then color[4] = 255 end	-- RGB are opaque by default
	if fill and not fill[4] then fill[4] = 255 end		-- RGB are opaque by default
	
	if fill then
		evolcore.draw(x,y,u,v, fill[1], fill[2], fill[3], fill[4], 1, 2, surf.surf)
	end
	
	if color then
		evolcore.draw(x,y,u,v, color[1], color[2], color[3], color[4], 1, 0, surf.surf)
	end
end

--- Draws a circle
-- evol.circle(x,y,r,color,[aa,[fill,[image]]])
-- (x,y),r: coordinates in pixel of center of circle, and radius
-- color = {r,g,b,[a]}: color of the line. If nil, no line.
-- aa: if true, circle is antialiased
-- fill: = {r,g,b,[a]}: color of the filling. If nil, no filling.
-- image: the image to draw to. Defaults to screen.
circle = function(x, y, r, color, aa, fill, surf)

	surf = surf or {}

	if color and not color[4] then color[4] = 255 end	-- RGB are opaque by default
	if fill and not fill[4] then fill[4] = 255 end		-- RGB are opaque by default

	if fill then	
		evolcore.draw(x,y,r,nil, fill[1], fill[2], fill[3], fill[4], 2, 2, surf.surf)
		if aa and not color then color = fill end
	end

	if color then
		if aa then aa = 1 else aa = 0 end
		evolcore.draw(x,y,r,nil, color[1], color[2], color[3], color[4], 2, aa, surf.surf)
	end	
end

--- Draws a triangle
-- evol.tri(x,y,u,v,m,n,color,[aa,[fill,[image]]])
-- (x,y),(u,v),(m,n): coordinates in pixel of the three vertices of the triangle
-- color = {r,g,b,[a]}: color of the line. If nil, no line.
-- aa: if true, triangle is antialiased
-- fill: = {r,g,b,[a]}: color of the filling. If nil, no filling.
-- image: the image to draw to. Defaults to screen.
tri = function(x, y, u, v, m, n, color, aa, fill, surf)

	surf = surf or {}

	if color and not color[4] then color[4] = 255 end	-- RGB are opaque by default
	if fill and not fill[4] then fill[4] = 255 end		-- RGB are opaque by default

	if fill then
		evolcore.drawTri(x,y,u,v,m,n, fill[1], fill[2], fill[3], fill[4], 2, surf.surf)
		if aa and not color then color = fill end
	end

	if color then
		if aa then aa = 1 else aa = 0 end
		evolcore.drawTri(x,y,u,v,m,n, color[1], color[2], color[3], color[4], aa, surf.surf)
	end	
end

--- *Sound*

-- INTERNAL! -- Prepares a Sound table
local Sound = function()
	tmp = {}
	
	tmp.play = play
	tmp.free = free
	
	tmp.type = "Sound"
	
	return tmp
end

-- INTERNAL! -- Prepares a Music table
local Music = function()
	tmp = {}
	
	tmp.play = play
	tmp.free = free
	
	tmp.type = "Music"
	
	return tmp
end

--- Loads a sound
-- sound = evol.loadSound(path)
-- path: string containing the path to the sound to load (relative to current folder, or absolute)
loadSound = function(path)
	tmp = Sound()
	tmp.sound = evolcore.loadSound(path)
	
	return tmp
end

--- Loads a music
-- music = evol.loadMusic(path)
-- path: string containing the path to the music to load (relative to current folder, or absolute)
loadMusic = function(path)
	tmp = Music()
	tmp.music = evolcore.loadMusic(path)
	
	return tmp
end

--- Plays a sound or a music
-- evol.play(stuff,n)
-- stuff: a sound or music
-- n: the number of times to play. Defaults to 1 for sounds, and infinite (-1) for music
play = function(sound, loop)

	if sound.type == "Sound" then
		if not loop then loop = 1 end
		evolcore.playSound(sound.sound, loop-1)
	elseif sound.type == "Music" then
		if not loop then loop = -1 end
		evolcore.playMusic(sound.music, loop)
	end
end

--- Sets the music volume
-- old = evol.musicVolume(new)
-- new: if from 0 to 128, sets the volume this value. Else, does nothing.
-- old: volume before changing, or current volume if new isn't between 0 and 128.
musicVolume = evolcore.musicVolume
