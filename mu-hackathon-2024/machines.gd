extends TileMapLayer

#	 TODO 
# - maybe some particles around the plants

#	TODO far away goals
# - save / load?
# - more machines
# - world gen

@onready
var background = self.get_parent().get_node("Background")

var background_tiles = {
	"bad": Vector2i(0, 0),
	"good": Vector2i(1, 0),
	"dirt": Vector2i(2, 0),
	"water": Vector2i(3, 0)
}

var sprite_data = {
	"Spreader": 		{"default": [0, 0]},
	"Digger": 		{"up": [1, 1], 	"right": [1, 0], 	"left": [1, 2], 	"down": [1, 3]},
	"Water": 		{"up": [2, 1], 	"right": [2, 0], 	"left": [2, 2], 	"down": [2, 3]},
	"Seed Maker": 	{"up": [3, 0], 	"right": [3, 1], 	"down": [3, 2], 	"left": [3, 3]},
	"Conveyor": 		{"up": [4, 0], 	"right": [4, 1], 	"down": [4, 2], 	"left": [4, 3]}
}

class Machine:
	var pos: Vector2i
	var rot: String
	var type: String
	
	var last_updated: int = 0
	var inventory: Array = []
	var particles: Node = null
	
	func init(pos, rot, type, node):
		self.pos = pos
		self.rot = rot
		self.type = type
		
		if self.type == "Digger":
			particles = GPUParticles2D.new()
			particles.process_material = load("res://flower_particles.tres")
			particles.modulate = Color(0.941, 0.541, 0.271)
			particles.position = Vector2(pos) * 16 + Vector2(8, 2)
			node.add_child(particles)
		elif self.type == "Water":
			particles = GPUParticles2D.new()
			particles.process_material = load("res://flower_particles.tres")
			particles.modulate = Color(0.392, 0.957, 0.941)
			particles.position = Vector2(pos) * 16 + Vector2(8, 6)
			node.add_child(particles)
		elif self.type == "Spreader":
			particles = GPUParticles2D.new()
			particles.process_material = load("res://flower_particles.tres")
			particles.modulate = Color(0.984, 0.949, 0.212)
			particles.position = Vector2(pos) * 16 + Vector2(8, 2)
			node.add_child(particles)
			
			
		
var machines: Array = []

var inventory: Dictionary = {
	"dirt": 0,
	"water": 0,
	"seeds": 10
}

class Item:
	var type: String

var last_update = 0

func _ready():
	for machine_name in sprite_data.keys():
		for direction in sprite_data[machine_name]:
			var atlas_position = Vector2i(sprite_data[machine_name][direction][0], sprite_data[machine_name][direction][1])
			var positions = get_used_cells_by_id(-1, atlas_position, -1)
			for pos in positions:
				var temp = Machine.new()
				temp.init(pos, direction, machine_name, self)
				machines.append(temp)
			
			

func _process(delta):
	last_update += delta
	if last_update > 1:
		process_machines()
		last_update -= 1
		updateInventory()

func process_machines():
	var conveyor_list = {}
	for machine in machines:
		if machine.type == "Conveyor":
			conveyor_list[machine] = false
	
	for machine in conveyor_list.keys():
		update_conveyor(machine, machine.pos, conveyor_list)
	
	for machine in machines:
		if machine.type == "Spreader":
			update_spreader(machine, machine.pos)
		elif machine.type == "Digger":
			update_digger(machine, machine.pos)
		elif machine.type == "Water":
			update_water(machine, machine.pos)
		elif machine.type == "Seed Maker":
			update_seed_maker(machine, machine.pos)


func updateInventory():
	var container = get_parent().get_node("Camera/Control/Container/VBoxContainer")
	container.get_node("Earth/Label2").text = str(inventory["dirt"])
	container.get_node("Water/Label2").text = str(inventory["water"])
	container.get_node("Seeds/Label2").text = str(inventory["seeds"])


func find_machine_at_position(pos: Vector2i) -> Machine:
	for machine in machines:
		if machine.pos == pos:
			return machine
	return null


func update_spreader(spreader: Machine, pos: Vector2i):
	spreader.last_updated += 1
	if spreader.last_updated == 10:
		inventory["seeds"] -= 1
		spreader.last_updated -= 10


func update_seed_maker(seed_maker: Machine, pos: Vector2i):
	if seed_maker.inventory.has("dirt") and seed_maker.inventory.has("water"):
		seed_maker.inventory.append("seeds")
		seed_maker.inventory.erase("dirt")
		seed_maker.inventory.erase("water")
	if seed_maker.rot == "up":
		var output = find_machine_at_position(pos - Vector2i(0, 1))
		if output != null:
			if (not output.inventory.has("seeds")) and seed_maker.inventory.has("seeds"):
				output.inventory.append("seeds")
				seed_maker.inventory.erase("seeds")
	elif seed_maker.rot == "down":
		var output = find_machine_at_position(pos + Vector2i(0, 1))
		if output != null:
			if (not output.inventory.has("seeds")) and seed_maker.inventory.has("seeds"):
				output.inventory.append("seeds")
				seed_maker.inventory.erase("seeds")
	elif seed_maker.rot == "left":
		var output = find_machine_at_position(pos - Vector2i(1, 0))
		if output != null:
			if (not output.inventory.has("seeds")) and seed_maker.inventory.has("seeds"):
				output.inventory.append("seeds")
				seed_maker.inventory.erase("seeds")
	elif seed_maker.rot == "right":
		var output = find_machine_at_position(pos + Vector2i(1, 0))
		if output != null:
			if (not output.inventory.has("seeds")) and seed_maker.inventory.has("seeds"):
				output.inventory.append("seeds")
				seed_maker.inventory.erase("seeds")


func update_conveyor(conveyor: Machine, pos: Vector2i, conveyor_list: Dictionary):
	
	if conveyor_list[conveyor] == true:
		return
		
	conveyor_list[conveyor] = true
	
	var output: Machine
	if conveyor.rot == "up":
		output = find_machine_at_position(pos - Vector2i(0, 1))
	elif conveyor.rot == "down":
		output = find_machine_at_position(pos + Vector2i(0, 1))
	elif conveyor.rot == "left":
		output = find_machine_at_position(pos - Vector2i(1, 0))
	elif conveyor.rot == "right":
		output = find_machine_at_position(pos + Vector2i(1, 0))
	if output != null:
		if output.type == "Seed Maker":
			if (not output.inventory.has("dirt")) and conveyor.inventory.has("dirt"):
				output.inventory.append("dirt")
				conveyor.inventory.erase("dirt")
			if (not output.inventory.has("water")) and conveyor.inventory.has("water"):
				output.inventory.append("water")
				conveyor.inventory.erase("water")
		elif output.type == "Conveyor":
			update_conveyor(output, output.pos, conveyor_list)
			for type in conveyor.inventory:
				if (not output.inventory.has(type)):
					output.inventory.append(type)
					conveyor.inventory.erase(type)
		elif output.type == "Spreader":
			for type in conveyor.inventory:
				if type in inventory.keys():
					inventory[type] += 1
					conveyor.inventory.erase(type)
	


func update_water(water: Machine, pos: Vector2i):
	
	if water.last_updated < 4:
		water.last_updated += 1
		return
	water.last_updated -= 4
	
	if background.get_cell_atlas_coords(pos) == background_tiles["water"]:
		if water.inventory.size() < 1:
			var temp = Item.new()
			temp.type = "water"
			water.inventory.append(temp)
	if water.inventory.size() != 0:
		if water.rot == "up":
			var output = find_machine_at_position(pos - Vector2i(0, 1))
			if output != null:
				if not output.inventory.has("water"):
					output.inventory.append("water")
					water.inventory.erase("water")
		elif water.rot == "down":
			var output = find_machine_at_position(pos + Vector2i(0, 1))
			if output != null:
				if not output.inventory.has("water"):
					output.inventory.append("water")
					water.inventory.erase("water")
		elif water.rot == "left":
			var output = find_machine_at_position(pos - Vector2i(1, 0))
			if output != null:
				if not output.inventory.has("water"):
					output.inventory.append("water")
					water.inventory.erase("water")
		elif water.rot == "right":
			var output = find_machine_at_position(pos + Vector2i(1, 0))
			if output != null:
				if not output.inventory.has("water"):
					output.inventory.append("water")
					water.inventory.erase("water")


func update_digger(digger: Machine, pos: Vector2i):
	
	if digger.last_updated < 4:
		digger.last_updated += 1
		return
	digger.last_updated -= 4
	
	if background.get_cell_atlas_coords(pos) == background_tiles["dirt"]:
		if digger.inventory.size() < 1:
			var temp = Item.new()
			temp.type = "dirt"
			digger.inventory.append(temp)
	if digger.inventory.size() != 0:
		if digger.rot == "up":
			var output = find_machine_at_position(pos - Vector2i(0, 1))
			if output != null:
				if not output.inventory.has("dirt"):
					output.inventory.append("dirt")
					digger.inventory.erase("dirt")
		elif digger.rot == "down":
			var output = find_machine_at_position(pos + Vector2i(0, 1))
			if output != null:
				if not output.inventory.has("dirt"):
					output.inventory.append("dirt")
					digger.inventory.erase("dirt")
		elif digger.rot == "left":
			var output = find_machine_at_position(pos - Vector2i(1, 0))
			if output != null:
				if not output.inventory.has("dirt"):
					output.inventory.append("dirt")
					digger.inventory.erase("dirt")
		elif digger.rot == "right":
			var output = find_machine_at_position(pos + Vector2i(1, 0))
			if output != null:
				if not output.inventory.has("dirt"):
					output.inventory.append("dirt")
					digger.inventory.erase("dirt")
