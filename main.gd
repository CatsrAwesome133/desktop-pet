extends Node2D

# coords in (x,y); +x is right and +y is down (cough cough turtle)
var velocity = Vector2(300, 0) #speedisavector  in pixels per second
var acc = Vector2(0, 0) # in pixels per second
var ghost_mass = Vector2(1, 1) # completley useless vector2
var f = Vector2(10, 10) # in pixels mass per second
var G = Vector2(0, 980)
var drag = Vector2(0.9, 0.4) # in % of original speed
var net = Vector2(0, 0)

var max_v = Vector2(300,300)

var screen_size = Vector2()
var current_screen = DisplayServer.window_get_current_screen()
var screen_origin = Vector2(DisplayServer.screen_get_usable_rect(current_screen).position) # this is so that the pet can live in all screens
var window_size = Vector2(200.0,200.0)
var all_screens = Vector2()
var os_name = "" # currently redundant


func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size(current_screen))
	all_screens = Vector2((screen_size + screen_origin) - window_size)
	os_name = OS.get_name()
	
	print("Origin: ", screen_origin)
	print("Screen: ", screen_size)
	print("All Screens: ", all_screens)
	
	DisplayServer.window_set_position(Vector2i(all_screens.x/2, all_screens.y - 10))

func _physics_process(delta: float) -> void:
	var window_position = Vector2(DisplayServer.window_get_position())
	var next_pos = window_position + (velocity + acc*delta)*delta
	
	# Bottom Boundary Bounce
	if window_position.y > all_screens.y:
		window_position.y =  all_screens.y   # Snap to floor
		if velocity.y > 0:          # If moving downward, bounce!
			velocity.y = -velocity.y * 0.8 # Reverse and lose 20% energy

	# Top Boundary Bounce (Ceiling)
	elif window_position.y < 0:
		window_position.y = 0   # Snap to ceiling
		if velocity.y < 0:
			velocity.y = -velocity.y * 0.8

	# Left Boundary Bounce
	if window_position.x < 0:
		window_position.x = 0
		if velocity.x < 0:
			velocity.x = -velocity.x * 0.8

	# Right Boundary Bounce
	elif window_position.x >  all_screens.x:
		window_position.x =  all_screens.x
		if velocity.x > 0:
			velocity.x = -velocity.x * 0.8
	
	net.y = G.y
	
	# physics
	acc = net/ghost_mass
	velocity += acc*delta*drag
	window_position += velocity*delta # delta is time since last frame
	
	print("Speed: ", velocity)
	print("Acc: ", acc)
	print(window_position)
	
	
	DisplayServer.window_set_position(Vector2i(window_position))
