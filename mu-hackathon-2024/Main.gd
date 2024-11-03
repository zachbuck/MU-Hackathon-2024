extends Node2D

var orientation = "up"

var selected = ""

var sprite_data = {
	"Spreader": 		{"default": [0, 0]},
	"Digger": 		{"up": [1, 1], 	"right": [1, 0], 	"left": [1, 2], 	"down": [1, 3]},
	"Water": 		{"up": [2, 1], 	"right": [2, 0], 	"left": [2, 2], 	"down": [2, 3]},
	"Seed Maker": 	{"up": [3, 0], 	"right": [3, 1], 	"down": [3, 2], 	"left": [3, 3]},
	"Conveyor": 		{"up": [4, 0], 	"right": [4, 1], 	"down": [4, 2], 	"left": [4, 3]}
}

func on_select_building(type: String):
	selected = type
	update_selected()

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_R and event.pressed == true:
			update_selected()
			if orientation == "up":
				orientation = "right"
			elif orientation == "right":
				orientation = "down"
			elif orientation == "down":
				orientation = "left"
			elif orientation == "left":
				orientation = "up"
		if event.keycode == KEY_ESCAPE:
			selected = ""
			update_selected()
	elif event is InputEventMouseMotion:
		update_selected()
		$Sprite2D.position.x = floor(((event.global_position.x - 960) / 4 + $Camera.position.x) / 16) * 16
		$Sprite2D.position.y = floor(((event.global_position.y - 540) / 4 + $Camera.position.y) / 16) * 16
		if (get_placeable(selected, Vector2i(floor(((event.global_position.x - 960) / 4 + $Camera.position.x) / 16), floor(((event.global_position.y - 540) / 4 + $Camera.position.y) / 16)))):
			$Sprite2D.modulate.b = 1
			$Sprite2D.modulate.g = 1
		else:
			$Sprite2D.modulate.g = 0
			$Sprite2D.modulate.b = 0
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var base_pos = Vector2i(floor(((event.global_position.x - 960) / 4 + $Camera.position.x) / 16), floor(((event.global_position.y - 540) / 4 + $Camera.position.y) / 16))
			if $Machines.find_machine_at_position(base_pos) != null:
				if $Machines.find_machine_at_position(base_pos).type == "Spreader":
					for x in range(0, 21):
						for y in range(0, 21):
							if $Background.get_cell_atlas_coords(base_pos - Vector2i(10, 10) + Vector2i(x, y)) != Vector2i(1, 0):
								continue
							$Background.set_cell(base_pos - Vector2i(10, 10) + Vector2i(x, y), 0, Vector2i(0, 0), 0)
			
			var machine = $Machines.find_machine_at_position(Vector2i(floor(((event.global_position.x - 960) / 4 + $Camera.position.x) / 16), floor(((event.global_position.y - 540) / 4 + $Camera.position.y) / 16)))
			if machine.particles != null:
				$Machines.remove_child(machine.particles)
			$Machines.machines.erase(machine)
			$Machines.erase_cell(Vector2i(floor(((event.global_position.x - 960) / 4 + $Camera.position.x) / 16), floor(((event.global_position.y - 540) / 4 + $Camera.position.y) / 16)))
			
			
			if $Machines.find_machine_at_position(base_pos + Vector2i(1, 0)) != null:
				if $Machines.find_machine_at_position(base_pos + Vector2i(1, 0)).type == "Conveyor":
					$Machines.set_cell(base_pos + Vector2i(1, 0), 0, get_conveyor_atlas(base_pos + Vector2i(1, 0)), 0)
			if $Machines.find_machine_at_position(base_pos + Vector2i(0, 1)) != null:
				if $Machines.find_machine_at_position(base_pos + Vector2i(0, 1)).type == "Conveyor":
					$Machines.set_cell(base_pos + Vector2i(0, 1), 0, get_conveyor_atlas(base_pos + Vector2i(0, 1)), 0)
			if $Machines.find_machine_at_position(base_pos - Vector2i(1, 0)) != null:
				if $Machines.find_machine_at_position(base_pos - Vector2i(1, 0)).type == "Conveyor":
					$Machines.set_cell(base_pos - Vector2i(1, 0), 0, get_conveyor_atlas(base_pos - Vector2i(1, 0)), 0)
			if $Machines.find_machine_at_position(base_pos - Vector2i(0, 1)) != null:
				if $Machines.find_machine_at_position(base_pos - Vector2i(0, 1)).type == "Conveyor":
					$Machines.set_cell(base_pos - Vector2i(0, 1), 0, get_conveyor_atlas(base_pos - Vector2i(0, 1)), 0)
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and selected != "":
			var base_pos = Vector2i(floor(((event.global_position.x - 960) / 4 + $Camera.position.x) / 16), floor(((event.global_position.y - 540) / 4 + $Camera.position.y) / 16))
			if $Machines.find_machine_at_position(base_pos) != null or (not get_placeable(selected, base_pos)) or ($Machines.inventory["seeds"] < 1):
				return
			var temp = $Machines.Machine.new()
			temp.init(Vector2i(floor(((event.global_position.x - 960) / 4 + $Camera.position.x) / 16), floor(((event.global_position.y - 540) / 4 + $Camera.position.y) / 16)), orientation, selected, $Machines)
			$Machines.machines.append(temp)
			var direction = orientation if selected != "Spreader" else "default"
			$Machines.set_cell(Vector2i(floor(((event.global_position.x - 960) / 4 + $Camera.position.x) / 16), floor(((event.global_position.y - 540) / 4 + $Camera.position.y) / 16)), 0, Vector2i(sprite_data[selected][direction][0], sprite_data[selected][direction][1]), 0)
			$Machines.inventory["seeds"] -= 1
			if selected == "Conveyor":
				$Machines.set_cell(base_pos, 0, get_conveyor_atlas(base_pos), 0)
			elif selected == "Spreader":
				for x in range(0, 21):
					for y in range(0, 21):
						if $Background.get_cell_atlas_coords(base_pos - Vector2i(10, 10) + Vector2i(x, y)) != Vector2i(0, 0):
							continue
						$Background.set_cell(base_pos - Vector2i(10, 10) + Vector2i(x, y), 0, Vector2i(1, 0), 0)
			if $Machines.find_machine_at_position(base_pos + Vector2i(1, 0)) != null:
				if $Machines.find_machine_at_position(base_pos + Vector2i(1, 0)).type == "Conveyor":
					$Machines.set_cell(base_pos + Vector2i(1, 0), 0, get_conveyor_atlas(base_pos + Vector2i(1, 0)), 0)
			if $Machines.find_machine_at_position(base_pos + Vector2i(0, 1)) != null:
				if $Machines.find_machine_at_position(base_pos + Vector2i(0, 1)).type == "Conveyor":
					$Machines.set_cell(base_pos + Vector2i(0, 1), 0, get_conveyor_atlas(base_pos + Vector2i(0, 1)), 0)
			if $Machines.find_machine_at_position(base_pos - Vector2i(1, 0)) != null:
				if $Machines.find_machine_at_position(base_pos - Vector2i(1, 0)).type == "Conveyor":
					$Machines.set_cell(base_pos - Vector2i(1, 0), 0, get_conveyor_atlas(base_pos - Vector2i(1, 0)), 0)
			if $Machines.find_machine_at_position(base_pos - Vector2i(0, 1)) != null:
				if $Machines.find_machine_at_position(base_pos - Vector2i(0, 1)).type == "Conveyor":
					$Machines.set_cell(base_pos - Vector2i(0, 1), 0, get_conveyor_atlas(base_pos - Vector2i(0, 1)), 0)
		
		
func get_placeable(type: String, pos: Vector2i) -> bool:
	var atlas_coords = $Background.get_cell_atlas_coords(pos)
	
	if atlas_coords == Vector2i(0, 0):
		return false
	elif type == "Water":
		return atlas_coords == Vector2i(3, 0)
	else:
		return atlas_coords != Vector2i(3, 0)
		
		
func get_conveyor_atlas(pos: Vector2i) -> Vector2i:
	
	var direction = $Machines.find_machine_at_position(pos).rot
	
	var leftmachine = $Machines.find_machine_at_position(pos - Vector2i(1, 0))
	var left = false
	if leftmachine != null:
		left = leftmachine.rot == "right"
		
	var downmachine = $Machines.find_machine_at_position(pos + Vector2i(0, 1))
	var down = false
	if downmachine != null:
		down = downmachine.rot == "up"
		
	var rightmachine = $Machines.find_machine_at_position(pos + Vector2i(1, 0))
	var right = false
	if rightmachine != null:
		right = rightmachine.rot == "left"
	
	var upmachine = $Machines.find_machine_at_position(pos - Vector2i(0, 1))
	var up = false
	if upmachine != null:
		up = upmachine.rot == "down"
	
	if direction == "up":
		if left and down and right:
			return Vector2i(9, 0)
		elif left and down and (not right):
			return Vector2i(7, 0)
		elif right and down and (not left):
			return Vector2i(8, 0)
		elif left and right and (not down):
			return Vector2i(10, 0)
		elif right and (not down) and (not left):
			return Vector2i(5, 3)
		elif left and (not down) and (not right):
			return Vector2i(6, 3)
		elif down and (not left) and (not right):
			return Vector2i(4, 0)
		else:
			return Vector2i(4, 0)
			
	elif direction == "right":
		if up and left and down:
			return Vector2i(9, 1)
		elif up and left and (not down):
			return Vector2i(7, 1)
		elif up and (not left) and down:
			return Vector2i(10, 1)
		elif (not up) and left and down:
			return Vector2i(8, 3)
		elif up and (not left) and (not down):
			return Vector2i(6, 2)
		elif (not up) and left and (not down):
			return Vector2i(4, 1)
		elif (not up) and (not left) and down:
			return Vector2i(5, 0)
		else:
			return Vector2i(4, 1)
			
	elif direction == "down":
		if right and up and left:
			return Vector2i(9, 2)
		elif right and up and (not left):
			return Vector2i(7, 2)
		elif right and (not up) and left:
			return Vector2i(10, 2)
		elif (not right) and up and left:
			return Vector2i(8, 2)
		elif right and (not up) and (not left):
			return Vector2i(6, 1)
		elif (not right) and up and (not left):
			return Vector2i(4, 2)
		elif (not right) and (not up) and left:
			return Vector2i(5, 1)
		else:
			return Vector2i(4, 2)
		
	elif direction == "left":
		if right and up and down:
			return Vector2i(9, 3)
		elif right and up and (not down):
			return Vector2i(8, 1)
		elif right and (not up) and down:
			return Vector2i(7, 3)
		elif (not right) and up and down:
			return Vector2i(10, 3)
		elif right and (not up) and (not down):
			return Vector2i(4, 3)
		elif (not right) and up and (not down):
			return Vector2i(5, 2)
		elif (not right) and (not up) and down:
			return Vector2i(6, 0)
		else:
			return Vector2i(4, 3)
	
	return Vector2i()
			
func update_selected():
	if selected != "":
		$Sprite2D.visible = true
		if len(sprite_data[selected]) != 1:
			$Sprite2D.texture.region.position.x = sprite_data[selected][orientation][0] * 16
			$Sprite2D.texture.region.position.y = sprite_data[selected][orientation][1] * 16
		else:
			$Sprite2D.texture.region.position.x = sprite_data[selected]["default"][0] * 16
			$Sprite2D.texture.region.position.y = sprite_data[selected]["default"][1] * 16
	else:
		$Sprite2D.visible = false
