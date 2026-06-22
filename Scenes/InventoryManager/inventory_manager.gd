extends Node
class_name InventoryManager

@onready var grid: GridContainer = %GridContainer
@onready var drop_rect: DropRect = %DropRect
@onready var toolbar: HBoxContainer = %HBoxContainer
@onready var inv: Panel = $Inv

var slot_prefab: PackedScene = load("res://Scenes/InventoryManager/inventory_slot.tscn")
var slots_count: int = 24
var tb_slots_count: int = 5
var slots: Array[InventorySlot] = []
var is_opened: bool = false

var selected_slot: InventorySlot = null

func add_new_slot(container: Control):
	var new_slot = slot_prefab.instantiate() as InventorySlot
	new_slot.id = slots.size()
	new_slot.item_swapped.connect(_on_items_swapped)
	container.add_child(new_slot)
	slots.append(new_slot)
	
func pickup_item(item_data: ItemData) -> bool:
	for slot in slots:
		if slot.is_empty():
			slot.add_item(item_data)
			return true
	return false

func inv_toggle():
	if is_opened: #если открыт, то закрываем
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		self.mouse_filter = Control.MOUSE_FILTER_IGNORE
		inv.visible = false
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		self.mouse_filter = Control.MOUSE_FILTER_STOP
		inv.visible = true
		
	is_opened = !is_opened

func select_from_toolbar(tb_slot_num):
	var slot = toolbar.get_child(tb_slot_num) as InventorySlot
	if selected_slot != null:
		selected_slot.selection.visible = false
	slot.selection.visible = true
	selected_slot = slot

func _on_items_swapped(from_id: int, to_id: int):
	var in_data = slots[from_id].item
	var out_data = slots[to_id].item
	
	slots[from_id].add_item(out_data)
	slots[to_id].add_item(in_data)

func _on_item_dropped(slot_id: int):
	var prefab = load(slots[slot_id].item.full_prefab_path)
	var inst = prefab.instantiate() as Node3D
	
	get_tree().current_scene.add_child(inst)
	inst.position = (get_parent() as Node3D).position
	
	slots[slot_id].add_item(null)

func toolbar_scroll_next():
	pass

func _ready() -> void:
	is_opened = true
	inv_toggle()
	
	drop_rect.item_dropped.connect(_on_item_dropped)
	
	for i in slots_count:
		add_new_slot(grid)
	for i in tb_slots_count:
		add_new_slot(toolbar)
		var tb_slot = toolbar.get_child(i) as InventorySlot
		tb_slot.label.text = str(i + 1)
