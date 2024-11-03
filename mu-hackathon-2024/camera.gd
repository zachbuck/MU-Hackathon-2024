extends Camera2D

func _ready():
	$Control.position = Vector2(-0.5 * 1920 / zoom.x, -0.5 * 1080 / zoom.x)
	$Control.size = Vector2(1920 / zoom.x, 1080 / zoom.x)
	
func _input(event):
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			self.position -= event.relative * (1 / self.zoom.x)
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			#zoom.x += 0.5
			#zoom.y += 0.5
			#if zoom.x > 4:
				#zoom.x = 4
				#zoom.y = 4
		#elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#zoom.x -= 0.5
			#zoom.y -= 0.5
			#if zoom.x < 1:
				#zoom.x = 1
				#zoom.y = 1
		#$Control.position = Vector2(-0.5 * 1920 / zoom.x, -0.5 * 1080 / zoom.x)
		#$Control.size = Vector2(1920 / zoom.x, 1080 / zoom.x)
		#$Control/Container.scale = Vector2(2 / zoom.x, 2 / zoom.x)
		#$Control/Container2.scale = Vector2(4 / zoom.x, 4 / zoom.x)
