extends Resource
class_name ItemData # Данные о предмете как об объекте в инвентаре

@export var item_name: String
@export var item_type: ItemType
@export var icon: Texture2D
@export var viewmodel: PackedScene

# префаб объекта для его создания при выбрасывании из инвентаря
@export_file("*.tscn") var full_prefab_path: String 
