extends ColorRect
class_name DropRect

signal item_dropped(slot_id: int)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_INT # Проверка: точно ли получили id слота а не null

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	item_dropped.emit(data)
