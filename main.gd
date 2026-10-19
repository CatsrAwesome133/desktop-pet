extends Node2D


var speed = 300
var direction = Vector2(1,0) # in (x,y); +x is right and +y is down (cough cough turtle)

var screen_size = Vector2()
var current_screen = DisplayServer.window_get_current_screen()
var window_size = Vector2(200.0,200.0)
var os_name = ""


func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size(current_screen))
	var screen_scale = DisplayServer.screen_get_scale(current_screen)
	os_name = OS.get_name()
	
	if os_name == "Windows":
		screen_scale = 1.5
	print(screen_scale)
	
	screen_size = screen_size / screen_scale
	print("Screen: ", screen_size)

func _physics_process(delta: float) -> void:
	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction*speed*delta # delta is time since last frame
	
	print(window_position)
	window_position.x = clamp(window_position.x, 0, screen_size.x - window_size.x)
	window_position.y = clamp(window_position.y, 0, screen_size.y - window_size.y)
	
	DisplayServer.window_set_position(Vector2i(window_position))
