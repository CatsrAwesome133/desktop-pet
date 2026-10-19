extends Node2D

# coords in (x,y); +x is right and +y is down (cough cough turtle)
var velocity = Vector2(-130, 0) #speedisavector  in pixels per second
var ghost_mass = Vector2(1, 1) # completley useless vector2
var f = Vector2(10, 10) # in pixels mass per second
var G = Vector2(0, 980)
var drag = Vector2(0.9, 0.4) # in % of original speed0
var margin = 30

var net = Vector2(0, 0)
var max_v = Vector2(300,300)
var idle_timer = 0.0
var acc = Vector2(0, 0) # in pixels per second
var tick = 0
var prev_direction = -1

var turning = false
var idle = false
var just_turned = "none"

var screen_size = Vector2()
var current_screen = DisplayServer.window_get_current_screen()
var screen_origin = Vector2(DisplayServer.screen_get_usable_rect(current_screen).position) # this is so that the pet can live in all screens
var window_size = Vector2(200.0,200.0)
var all_screens = Vector2()
var os_name = "" # currently redundant

var start_again = Vector2(-130, 0)


@onready var ghost = $AnimatedSprite2D


func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size(current_screen))
	all_screens = Vector2((screen_size + screen_origin) - window_size)
	all_screens.x += margin
	os_name = OS.get_name()
	
	print("Origin: ", screen_origin)
	print("Screen: ", screen_size)
	print("All Screens: ", all_screens)
	
	ghost.play("walk")
	
	DisplayServer.window_set_position(Vector2i(all_screens.x/6, all_screens.y - 10))

func _physics_process(delta: float) -> void:
	if idle:
		idle_timer -= delta
		if idle_timer <= 0:
			idle = false
			start_again = Vector2(130*prev_direction, 0)
			velocity = start_again
			if just_turned != "none":
				if just_turned == "right":
					ghost.play("turn_right")
				elif just_turned == "left":
					ghost.play("turn_left")
				await ghost.animation_finished
				just_turned = "none"
			if prev_direction == 1:
				ghost.flip_h = true
			else:
				ghost.flip_h = false
			ghost.play("walk")
		return
	
	var window_position = Vector2(DisplayServer.window_get_position())
	var next_pos = window_position + (velocity + acc*delta)*delta
	just_turned = "none"
	
	# Bottom Boundary Bounce
	if window_position.y > all_screens.y:
		window_position.y =  all_screens.y   # Snap to floor
		if velocity.y > 0:          # If moving downward, bounce!
			velocity.y = -velocity.y * 0.8 * drag.y # Reverse and lose 20% energy
		maybe_idle(0.05)

	# Top Boundary Bounce (Ceiling)
	elif window_position.y < 0:
		window_position.y = 0   # Snap to ceiling
		if velocity.y < 0:
			velocity.y = -velocity.y * 0.8

	# Left Boundary Bounce
	if window_position.x < margin * -1:
		window_position.x = margin * -1
		if velocity.x < 0:
			velocity.x = -velocity.x
		maybe_idle(0.2)
		if not idle:
			turn("right")
		just_turned = "right"

	# Right Boundary Bounce
	elif window_position.x >  all_screens.x:
		window_position.x =  all_screens.x
		if velocity.x > 0:
			velocity.x = -velocity.x
		maybe_idle(0.2)
		if not idle:
			turn("left")
		just_turned = "left"
	
	net.y = G.y
	
	# physics
	acc = net/ghost_mass
	velocity += acc*delta*drag
	window_position += velocity*delta # delta is time since last frame
	
	print("Speed: ", velocity)
	print("Acc: ", acc)
	print(window_position)
	
	
	DisplayServer.window_set_position(Vector2i(window_position))


func turn(direction):
	turning = true
	if direction == "left":
		ghost.play("turn_left")
	if direction == "right":
		ghost.play("turn_right")
	await ghost.animation_finished
	ghost.play("walk")
	ghost.flip_h = !ghost.flip_h
	turning = false


func maybe_idle(freq):
	if randf() < freq: # this is the chance it rests
		prev_direction = sign(velocity.x)
		idle = true
		idle_timer = randf_range(1.0, 3.0) # a-b seconds
		var r = randi() % 3
		if r != 4:
			ghost.play("idle")
			velocity.x = 0


func accelerate_until(speed):
	var diff = Vector2(10, 10)
	if speed.x - velocity.x != 0:
		diff.x = 10
	if speed.y - velocity.y != 0:
		diff.y = 10
	velocity += (speed - velocity)/5 + diff
	tick += 1
	if abs(speed-velocity) <= diff:
		acc = Vector2(0, 0)
		velocity = speed
		tick = 0
	
	return speed
