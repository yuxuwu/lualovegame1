current_frame = 1
current_frame_dt = 0

button_x = 500
button_y = 200
button_width = 100
button_height = 100
button_text = "Animate"

rendering = false


function buttonPressed()
	print("Button pressed")
	rendering = true
	current_frame_dt = 0
end


function love.load()
	frames_hand = {}

	for i=0,2 do
		table.insert(frames_hand, love.graphics.newImage("assets/hand-"..i..".png"))
	end
	for i=1,0,-1 do
		table.insert(frames_hand, love.graphics.newImage("assets/hand-"..i..".png"))
	end

	print(love.graphics.getColor())
end

function love.update(dt)
	if(rendering) then
		current_frame_dt = current_frame_dt + dt*20
		current_frame = math.floor(current_frame_dt) % 5 + 1
		if current_frame == 5 then
			current_frame_dt = 0
			rendering = false
		end
	end
end

function love.draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(frames_hand[current_frame], 100, 100)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("fill", button_x, button_y, button_width, button_height)

	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.print(button_text, button_x, button_y)
end

function love.mousepressed(x, y, button, istouch, presses)
	if button == 1 and
		button_x < x and x < button_x+button_width and
		button_y < y and y < button_y+button_height then
			buttonPressed()
	end
end
