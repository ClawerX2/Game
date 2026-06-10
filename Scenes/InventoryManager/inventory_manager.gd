extends Node
class_name InventoryManager

@onready var grid: GridContainer = %GridContainer
@onready var canvas: CanvasLayer = %CanvasLayer

var slot_prefab: PackedScene = load("res://Scenes/InventoryManager/inventory_slot.tscn")
var slots_count: int = 24
var slots: Array[InventorySlot] = []
var is_opened: bool = false

func add_new_slot():
	var new_slot = slot_prefab.instantiate() as InventorySlot
	grid.add_child(new_slot)
	slots.append(new_slot)

func inv_toggle():
	if is_opened: #если открыт, то закрываем
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		canvas.visible = false
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		canvas.visible = true
		
	is_opened = !is_opened

func _ready() -> void:
	is_opened = false
	canvas.visible = false
	for i in slots_count:
		add_new_slot()
