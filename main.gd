extends Node2D

# coords in (x,y); +x is right and +y is down (cough cough turtle)
var velocity = Vector2(300, 0) #speedisavector  in pixels per second
var acc = Vector2(0, 0) # in pixels per second
var ghost_mass = Vector2(1, 1) # completley useless vector2
var f = Vector2(10, 10) # in pixels mass per second
var G = Vector2(0, 980)
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
	
	if next_pos.x <= 0 or next_pos.x >= all_screens.x:
		velocity.x *= -1
	if next_pos.y <= 0 or next_pos.y >= all_screens.y:
		velocity.y *= -1
	
	net.y = G.y
	
	# physics
	acc = net/ghost_mass
	velocity += acc*delta
	window_position += velocity*delta # delta is time since last frame
	
	print("Speed: ", velocity)
	print("Acc: ", acc)
	print(window_position)
	window_position.x = clamp(window_position.x, 0, all_screens.x)
	window_position.y = clamp(window_position.y, 0, all_screens.y)
	
	DisplayServer.window_set_position(Vector2i(window_position))
