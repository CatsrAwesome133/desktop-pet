extends Node2D

# coords in (x,y); +x is right and +y is down (cough cough turtle)
var velocity = Vector2(-130, 0) #speedisavector  in pixels per second
var ghost_mass = Vector2(1, 1) # completley useless vector2 in arbitraty unit of mass
var f = Vector2(10, 10) # in arbitraty unit of force
var G = Vector2(0, 1800) # gravity in arbitrary units of force
var drag = Vector2(0.9, 0.4) # in % of original speed
var margin = 30

var net = Vector2(0, 0) # in arbitraty unit of force
var max_v = Vector2(300,300) # currently redundant; in pps
var idle_timer = 0.0 # in seconds
var acc = Vector2(0, 0) # in pixels per second
var tick = 0
var prev_direction = -1
var last_anim = ""
var drag_v = Vector2() # in pps
var last_mouse = Vector2()
var current_direction = -1
var anim = {}

var turning = false
var idle = false
var just_turned = "none"
var dragging = false
var just_stopped = false
var idle_mode = "none"

var screen_size = Vector2()
var current_screen = DisplayServer.window_get_current_screen()
var screen_origin = Vector2(DisplayServer.screen_get_usable_rect(current_screen).position) # this is so that the pet can live in all screens
var window_size = Vector2(200.0,200.0)
var all_screens = Vector2()
var drag_offset = Vector2()
var os_name = "" # currently redundant

var start_again = Vector2(-130, 0)
var neutral = Vector2(-130, G.y * ghost_mass.y)


@onready var ghost = $AnimatedSprite2D
@onready var area = $Area2D


func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size(current_screen))
	all_screens = Vector2((screen_size + screen_origin) - window_size)
	all_screens.x += margin
	area.input_event.connect(_on_area_input)
	os_name = OS.get_name()
	
	print("Origin: ", screen_origin)
	print("Screen: ", screen_size)
	print("All Screens: ", all_screens)
	
	ghost.play("walk")
	
	DisplayServer.window_set_position(Vector2i(all_screens.x/6, all_screens.y - 10))

func _physics_process(delta: float) -> void:
	var window_position = Vector2(DisplayServer.window_get_position())
	var next_pos = window_position + (velocity + acc*delta)*delta
	current_direction = sign(velocity.x)
	
	# Dragging trigger
	if dragging:
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_win_pos = mouse_pos - drag_offset
		drag_v = (mouse_pos - last_mouse) / delta
		last_mouse = mouse_pos
		idle = false
		print("Dragging at: ", drag_v)
		
		if sign(velocity.x) == 1:
			anim = {
				"left": "drag_right",
				"right": "drag_left",
			}
		if sign(velocity.x) == -1:
			anim = {
				"left": "drag_left",
				"right": "drag_right",
			}
		if sign(velocity.x) == 0:
			anim = {
				"left": "drag",
				"right": "drag",
			}
		
		if abs(drag_v.x) > 100:
			print("Woah that's fast")
			print("You're going ", sign(drag_v.x))
			if sign(drag_v.x) == 1:
				ghost.play(anim["right"])
			if sign(drag_v.x) == -1:
				ghost.play(anim["left"])
		else:
			ghost.play("drag")
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		return
	
	# Idle triggers
	if idle:
		idle_timer -= delta
		if idle_timer <= 0 and window_position.y >= all_screens.y - 15:
			idle = false
			start_again = Vector2(130*prev_direction, 0)
			velocity = start_again
			if idle_mode == "map":
				ghost.play("map_stop")
				await ghost.animation_finished
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
			idle_mode = "none"
			ghost.play("walk")
		return
	
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
	
	
	# stop bouncing eventually
	if window_position.y >= all_screens.y:
		if just_stopped:
			pass
		else:
			maybe_idle(1.0)
	
	var target_v = Vector2()
	if sign(velocity.x) == -1:
		target_v = Vector2(start_again.x, 0)
		velocity = velocity.lerp(target_v, 2 * delta)
	elif sign(velocity.x) == 1:
		target_v = Vector2(start_again.x * -1, 0)
		velocity = velocity.lerp(target_v, 2 * delta)
	if abs(velocity.x) <= (start_again.x * -1) + 5:
		velocity = target_v
	
	if not turning:
		if sign(velocity.x) == 1:
			ghost.flip_h = true
		elif sign(velocity.x) == -1:
			ghost.flip_h = false
	
	net.y = G.y
	
	# physics
	acc = net/ghost_mass
	velocity += acc*delta*drag
	window_position += velocity*delta # delta is time since last frame
	
	print("Speed: ", velocity)
	print("Acc: ", acc)
	print(window_position)
	
	maybe_shade()
	DisplayServer.window_set_position(Vector2i(window_position))


func _on_area_input(_viewport, event, _shape_idx):
	var window_position = Vector2(DisplayServer.window_get_position())
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		print("Double click!")
		if window_position.y >= all_screens.y - 20 and not idle:
			var help = str(ghost.animation)
			print("We're on the ground too!")
			ghost.play("pet")
			idle_timer = 1
			idle = true
			await ghost.animation_finished
			ghost.play(help)
			idle_timer = 0
			idle = false
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print("HEY WE MOVE")
			dragging = true
			last_anim = ghost.animation
			print(last_anim)
			drag_offset = Vector2(90, 55)
			
			ghost.play("drag_start")
			await ghost.animation_finished
			ghost.play("drag")


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			dragging = false
			velocity = drag_v
			ghost.play("drag_stop")
			await ghost.animation_finished
			ghost.play(last_anim)


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
		just_stopped = true
		idle_timer = randf_range(1.0, 3.0) # a-b seconds
		var r = randi() % 3
		match r:
			0:
				ghost.play("idle")
				velocity.x = 0
				idle_mode = "stand"
			1: # placeholder
				ghost.play("map_start")
				velocity.x = 0
				idle_mode = "map"
			2: # placeholder
				ghost.play("idle")
				velocity.x = 0


func fix_turning():
	var last_tick = sign(velocity.x)
	var prev_tick = current_direction
	if not turning and not idle:
		match [last_tick, prev_tick]:
			[1, 1]: # both right
				ghost.flip_h = true
			[-1, -1]: # both left
				ghost.flip_h = false
			[1, -1]: # turn to right
				ghost.play("turn_right")
				await ghost.animation_finished
				ghost.flip_h = true
			[-1, 1]: # turn to left
				ghost.play("turn_left")
				await ghost.animation_finished
				ghost.flip_h = false


func maybe_shade():
	if randf() < 0.0001:
		var last_anim = ghost.animation
		ghost.play("shade")
		await ghost.animation_finished
		ghost.play(last_anim)
