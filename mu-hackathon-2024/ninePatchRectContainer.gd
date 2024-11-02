extends Container

@onready
var patchRect = $NinePatchRect

@export
var otherNode: Control

# Called when the node enters the scene tree for the first time.
func _ready():
	patchRect.size = otherNode.size + Vector2(16, 16)
	patchRect.position = Vector2(-8, -8)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
