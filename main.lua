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
targetRect = {x=900, y=200, width=200, height=100, draw=true}
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
	local success =
		love.window.setMode(windowWidth, windowHeight, windowMode)

	love.graphics.setBackgroundColor(27/255, 135/255, 36/255)

	-- Hand
	hand_frames = {}
	hand_dt = 0
	animate_hand = false
	hand_frame = 1
	for i=0,2 do
		table.insert(hand_frames, love.graphics.newImage("assets/hand-"..i..".png"))
	end
	for i=1,0,-1 do
		table.insert(hand_frames, love.graphics.newImage("assets/hand-"..i..".png"))
	end

	-- Bullet
	bullet = love.graphics.newImage("assets/bullet.png")

	-- Gun
	gun_sheet = love.graphics.newImage("assets/gun-sheet.png")
	gun_frames = {}
	gun_frame_width = 60
	gun_frame_height = 40
	for i=0,19 do
		table.insert(gun_frames, love.graphics.newQuad(0, i*gun_frame_height, gun_frame_width, gun_frame_height, gun_sheet:getWidth(), gun_sheet:getHeight()))
	end
end

function love.update(dt)
	tick.update(dt)

	-- Moving Rect
	movingRect.x = movingRect.speed * dt + movingRect.x
	if movingRect.x > 1000 then
		targetMiss()
	end

	-- Hand
	if animate_hand then
		hand_dt = hand_dt + dt*20
		hand_frame = math.floor(hand_dt) % 5 + 1
		if hand_frame == 5 then
			hand_dt = 0
			animate_hand = false
		end
	end

end

function love.draw()
	-- Game State
	if gameState == GameStates.ready then
		love.graphics.print("Ready...", 250, 100)
	elseif gameState == GameStates.go then
		love.graphics.print("GOOOOOOOOOOOOOOOOOOOOOO", 250, 100)
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
		-- TODO: Bullet is rendering at 0, 0; render it instead from the middle of the hitbox
		love.graphics.draw(bullet, movingRect.x, movingRect.y, math.rad(180), .5, .5, bullet:getWidth()/2, bullet:getHeight()/2)
	end

	-- Score
	love.graphics.print("Score: "..score, 100, 100)

	-- Hand
	love.graphics.draw(hand_frames[hand_frame], targetRect.x, targetRect.y-50)

	-- Gun
	love.graphics.draw(gun_sheet, gun_frames[1], 200, 250, 0, -5, 5, gun_frame_width/2, gun_frame_height/2)
end

function love.keypressed(key)
	if key == "space" then
		if checkCollided(movingRect, targetRect) then
			targetHit()
		end
		animate_hand = true
		hand_dt = 0
	elseif key == "escape" then
		love.event.quit()
	end
end
