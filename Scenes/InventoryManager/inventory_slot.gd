extends Control
class_name InventorySlot

@onready var icon: TextureRect = $TextureRect
@onready var label: Label = $Label
@onready var selection: ReferenceRect = $Selection

var id: int = -1
var item: ItemData = null

signal item_swapped(from_slot_id: int, to_slot_id: int)

func _ready() -> void:
	selection.visible = false

func add_item(new_item: ItemData):
	item = new_item
	icon.modulate.a = 1.0
	if item != null:
		icon.texture = item.icon
	else:
		icon.texture = null

func is_empty() -> bool:
	if item == null: return true
	return false

func _get_drag_data(at_position: Vector2) -> Variant:
	if is_empty(): return null
	var preview: TextureRect = TextureRect.new()
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.size = icon.size
	preview.texture = icon.texture
	preview.position = Vector2.ONE * 100
	#Input.set_custom_mouse_cursor(icon.texture, Input.CURSOR_ARROW, Vector2.ZERO)
	#icon.modulate.a = 0.5
	set_drag_preview(preview)
	return id
	
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_INT # Проверка: точно ли получили id слота а не null

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	item_swapped.emit(data, id) # из слота с id=data в слот с данным id=id (в данный слот)
