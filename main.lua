--[[
Title: Hitbox Game
Description: React to an incoming block, and time your button press to when 2 hitboxes match up.

Check 1. 2 Entities, Target Box (on right), and Moving Box (from left)
Check 2. Score counter
Check 3. Delete box after a) has been caught by target b) goes out of bounds
Check 4. Continuously spawn new Moving Box
Check - Randomize speed of moving box
Check - Have random wait time before moving box is spawned
Check - Ready, Go, Lose text
- Wider window
- Different graphics
	- Moving box: bullet
		- Gun
		- Bullet
		- Blast
		- Punched bullet
	- Target box: fist
		- Punch
		- retract
	- Funky background
- Sound effects
- Better Start and end scripting
--]]


-------------------------------
---------vV GLOBALS Vv---------
-------------------------------
function enum(enums, initial_id)
	initial_id = initial_id or 0

	enum_table = {}

	for i, v in ipairs(enums) do
		enum_table[v] = i + initial_id
	end

	return enum_table
end
GameStates = enum{"ready", "go", "lose"}

movingRect = {x=100, y=200, width=100, height=100, speed=200, draw=true}
targetRect = {x=500, y=200, width=200, height=100, draw=true}
score = 0
tick = require "tick"
gameState = GameStates.go

--------------------------------------
---------vV USER FUNCTIONS Vv---------
--------------------------------------


function rangeMap(in_begin, in_end, out_begin, out_end, input)
	local factor =  (out_end-out_begin)/(in_end - in_begin)
	return  (factor * (input - in_begin)) + out_begin
end

function checkCollided(a, b)
	if a.x < b.x + b.width and
		a.x + a.width > b.x and
		a.y < b.y + b.height and
		a.y + a.height > b.y then
			print("Bam!")
			return true
		else
			print("No bam...")
			return false
	end
end

---------------------------------------
---------vV STAGE FUNCTIONS Vv---------
---------------------------------------

function _despawnMovingRect()
	movingRect.x = 0
	movingRect.speed = 0
	movingRect.draw = false
end

function _resetMovingRect()
	movingRect.x=100
	movingRect.speed = math.random(200, 400)
	movingRect.draw = true
	gameState = GameStates.go
end

function targetHit()
	_despawnMovingRect()
	score = score + 1
	gameState = GameStates.ready

	tick.delay(_resetMovingRect, rangeMap(0, 1, 0, 2, math.random()))
end

function targetMiss()
	_resetMovingRect()
	gameState = GameStates.lose
end


------------------------------------
---------vV LOVE MACHINE Vv---------
------------------------------------

function love.load()
	local windowMode = {
		fullscreen = false,
		centered = true,
		resizable = false,
		borderless = true
	}
	local windowWidth = 1200
	local windowHeight = 480
	local success = love.window.setMode(windowWidth, windowHeight, windowMode)
end

function love.update(dt)
	tick.update(dt)

	-- Moving Rect
	movingRect.x = movingRect.speed * dt + movingRect.x
	if movingRect.x > 1000 then
		targetMiss()
	end
end

function love.draw()
	-- Game State
	if gameState == GameStates.ready then
		love.graphics.print("Ready...", 250, 100)
	elseif gameState == GameStates.go then
		love.graphics.print("GOOO", 250, 100)
	elseif gameState == GameStates.lose then
		love.graphics.print("You fucking loser...", 250, 100)
	end


	-- Target
	if targetRect.draw then
		love.graphics.rectangle("line", targetRect.x, targetRect.y, targetRect.width, targetRect.height)
	end

	-- Moving
	if movingRect.draw then
		love.graphics.rectangle("line", movingRect.x, movingRect.y, movingRect.width, movingRect.height)
	end

	-- Score
	love.graphics.print("Score: "..score, 100, 100)
end

function love.keypressed(key)
	if key == "space" then
		if checkCollided(movingRect, targetRect) then
			targetHit()
		end
	elseif key == "escape" then
		love.event.quit()
	end
end
