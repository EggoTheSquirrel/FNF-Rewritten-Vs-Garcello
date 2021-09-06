--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Rewritten

Copyright (C) 2021  HTV04 -- And EggoTheSquirrel!!!

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]

local stageBack, stageFront, frontSmoke, backSmoke, garSleeping, scene
local garCough
local fading = 1
local tightBars = false

return {
	enter = function(self)
		weeks:enter()
		
		stageBack = Image(love.graphics.newImage(graphics.imagePath("garcello/alley-back")))
		stageFront = Image(love.graphics.newImage(graphics.imagePath("garcello/alley")))
		
		enemy = love.filesystem.load("sprites/garcello/garcello.lua")()

		garSleeping = Image(love.graphics.newImage(graphics.imagePath("garcello/garcello-sleeping")))
		garSleeping.x = -800
		garSleeping.y = 125

		tightBars = false
		
		girlfriend.x, girlfriend.y = 30, -90
		enemy.x, enemy.y = -380, -70
		boyfriend.x, boyfriend.y = 260, 100
		
		enemyIcon:animate("garcello", false)
		
		self:load()
	end,
	
	load = function(self)
		weeks:load()

		fading = 1

		if songNum == 5 then
			scene = love.filesystem.load("sprites/garcello/scene.lua")()
			scene.x, scene.y = 320, 180

			scene:animate("scene", false)

			garCough = love.audio.newSource("sounds/garcello/garcello-dies.ogg", "stream")
		elseif songNum == 4 then
			enemy = love.filesystem.load("sprites/garcello/garcello-ghosty.lua")()
			enemy.x, enemy.y = -390, -80
			
			stageBack = Image(love.graphics.newImage(graphics.imagePath("garcello/alley-back-rise")))
			stageFront = Image(love.graphics.newImage(graphics.imagePath("garcello/alley-rise")))

			inst = love.audio.newSource("music/garcello/fading-inst.ogg", "stream")
			voices = love.audio.newSource("music/garcello/fading-voices.ogg", "stream")
		elseif songNum == 3 then
			enemy = love.filesystem.load("sprites/garcello/garcello-dead.lua")()
			enemy.x, enemy.y = -390, -80
			
			stageBack = Image(love.graphics.newImage(graphics.imagePath("garcello/alley-back-alt")))
			stageFront = Image(love.graphics.newImage(graphics.imagePath("garcello/alley-alt")))

			frontSmoke = love.filesystem.load("sprites/garcello/smoke.lua")()
			backSmoke = love.filesystem.load("sprites/garcello/smoke.lua")()

			frontSmoke.x, frontSmoke.y = -50, -175
			backSmoke.x, backSmoke.y = -100, -300

			backSmoke:animate("smokey", true)
			frontSmoke:animate("smokey", true)

			garSleeping = Image(love.graphics.newImage(graphics.imagePath("garcello/garcello-sleeping")))
			garSleeping.x = -800
			garSleeping.y = 125

			enemyIcon:animate("garcello dead")

			inst = love.audio.newSource("music/garcello/release-inst.ogg", "stream")
			voices = love.audio.newSource("music/garcello/release-voices.ogg", "stream")
		elseif songNum == 2 then
			enemy = love.filesystem.load("sprites/garcello/garcello-tired.lua")()
			enemy.x, enemy.y = -390, -80

			garSleeping = nil
			
			enemyIcon:animate("garcello tired")

			inst = love.audio.newSource("music/garcello/nerves-inst.ogg", "stream")
			voices = love.audio.newSource("music/garcello/nerves-voices.ogg", "stream")
		else
			enemy.x, enemy.y = -380, -70
			
			garSleeping = nil

			inst = love.audio.newSource("music/garcello/headache-inst.ogg", "stream")
			voices = love.audio.newSource("music/garcello/headache-voices.ogg", "stream")
		end
		
		stageFront.y, stageBack.y = -50, 50

		enemy:animate("idle")
		
		self:initUI()
		
		if songNum ~= 5 then
			inst:play()
			weeks:voicesPlay()
		else
			garCough:play()
		end
	end,
	
	initUI = function(self)
		weeks:initUI()
		
		if songNum == 4 then
			weeks:generateNotes(love.filesystem.load("charts/garcello/fading" .. songAppend .. ".lua")())
		elseif songNum == 3 then
			weeks:generateNotes(love.filesystem.load("charts/garcello/release" .. songAppend .. ".lua")())
		elseif songNum == 2 then
			weeks:generateNotes(love.filesystem.load("charts/garcello/nerves" .. songAppend .. ".lua")())
		elseif songNum == 1 then
			weeks:generateNotes(love.filesystem.load("charts/garcello/headache" .. songAppend .. ".lua")())
		end
	end,
	
	update = function(self, dt)
		if gameOver then
			if not graphics.isFading then
				if input:pressed("confirm") then
					inst:stop()
					inst = love.audio.newSource("music/game-over-end.ogg", "stream")
					inst:play()
					
					Timer.clear()
					
					cam.x, cam.y = -boyfriend.x, -boyfriend.y
					
					boyfriend:animate("dead confirm", false)
					
					graphics.fadeOut(3, function() self:load() end)
				elseif input:pressed("gameBack") then
					graphics.fadeOut(0.5, function() Gamestate.switch(menu) end)
				end
			end
			
			boyfriend:update(dt)
			
			return
		end
		
		if songNum ~= 5 then weeks:update(dt) end

		if songNum == 3 then
			backSmoke:update(dt)
			frontSmoke:update(dt)

			if musicTime >= 104400 and tightBars ~= true then
				enemy:animate("cool guy", false)
				tightBars = true
			end
		elseif songNum == 5 then
			scene:update(dt)
		end


		if health >= 80 then
			if enemyIcon.anim.name == "garcello" then
				enemyIcon:animate("garcello losing", false)
			elseif enemyIcon.anim.name == "garcello tired" then
				enemyIcon:animate("garcello tired losing", false)
			elseif enemyIcon.anim.name == "garcello dead" then
				enemyIcon:animate("garcello dead losing", false)
			end
		else
			if enemyIcon.anim.name == "garcello losing" then
				enemyIcon:animate("garcello", false)
			elseif enemyIcon.anim.name == "garcello tired losing" then
				enemyIcon:animate("garcello tired", false)
			elseif enemyIcon.anim.name == "garcello dead losing" then
				enemyIcon:animate("garcello dead", false)
			end
		end
		
		if songNum == 5 then
			if scene.animated ~= true then
				if fading > 0 then fading = fading - 0.0025 end
				if fading <= 0 then 
					songNum = 3
					self:load() 
				end
			end
		elseif not graphics.isFading and not inst:isPlaying() and not voices:isPlaying() then
			if storyMode then
				if songNum == 2 then 
					songNum = 5
					self:load()
				end
				if songNum < 4 then
					songNum = songNum + 1
					self:load()

				elseif songNum ~= 5 then
				graphics.fadeOut(0.5, function() Gamestate.switch(menu) end)
				end
			end
		end
		
		if songNum ~= 5 then weeks:updateUI(dt) end
	end,
	
	draw = function(self)
		if songNum == 5 then
			love.graphics.push()
				graphics.setColor(fading, fading, fading, 1)
				love.graphics.scale(2, 2)
				scene:draw()
				graphics.setColor(1, 1, 1, 1)
			love.graphics.pop()
			return
		else

			weeks:draw()

			if gameOver then return end
			
			love.graphics.push()
				love.graphics.translate(lovesize.getWidth() / 2, lovesize.getHeight() / 2)
				love.graphics.scale(cam.sizeX, cam.sizeY)
				
				love.graphics.push()
					love.graphics.translate(cam.x * 0.9, cam.y * 0.9)
					
					stageBack:draw()

					if songNum == 3 then
						graphics.setColor(1, 1, 1, 0.5)

						love.graphics.push()

							love.graphics.scale(1.3, 1.3)
							backSmoke:draw()

						love.graphics.pop()

						graphics.setColor(1, 1, 1, 1 )
					end

					stageFront:draw()
					
					if songNum == 3 or songNum == 4 then
						garSleeping:draw()
					end

					girlfriend:draw()
				love.graphics.pop()
				love.graphics.push()
					love.graphics.translate(cam.x, cam.y)
					
					if songNum == 4 and musicTime >= 36000 then
						graphics.setColor(1, 1, 1, fading)
						if fading > 0 then fading = fading - 0.0045 end
					end

					if fading > 0 then enemy:draw() end
					graphics.setColor(1, 1, 1, 1)
					
					boyfriend:draw()
				love.graphics.pop()
				if songNum == 3 then
					love.graphics.push()
						love.graphics.translate(cam.x, cam.y)
						love.graphics.scale(1.7, 1.6)
						graphics.setColor(1, 1, 1, 0.7)
						frontSmoke:draw()
					love.graphics.pop()
				end
				weeks:drawRating(0.9)
			love.graphics.pop()
			
			weeks:drawUI()
		end
	end,
	
	leave = function(self)
		stageBack = nil
		stageFront = nil
		frontSmoke = nil
		backSmoke = nil
		garSleeping = nil
		scene = nil

		garCough = nil
		
		weeks:leave()
	end
}
