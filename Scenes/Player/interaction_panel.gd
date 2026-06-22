extends Control
class_name FocusPanel

@export var label_offset: Vector2
@onready var label = $%Label

func _ready() -> void:
	visible = false

func setup(focused_obj: InteractionComponent):
	label.text = focused_obj.obj_name + "\n" + focused_obj.act_tip
	visible = true

func follow_obj_pos(obj_pos_2d: Vector2):
	position = obj_pos_2d + label_offset
