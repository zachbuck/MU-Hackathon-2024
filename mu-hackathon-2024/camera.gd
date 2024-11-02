extends Camera2D

func _input(event):
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			self.offset -= event.relative * (1 / self.zoom.x)
