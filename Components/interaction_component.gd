extends Node
class_name InteractionComponent

@export var mesh: MeshInstance3D
@export var obj_name: String 
@export var act_tip: String #Подсказка к действию ("Подобрать", "Использовать" ...)

const OUTLINE_SHADER_MATERIAL = preload("uid://dd3e56e08wej5")

func interact(player: Player):
	pass

func set_outline():
	mesh.material_overlay = OUTLINE_SHADER_MATERIAL
	
func reset_outline():
	mesh.material_overlay = null

func _ready() -> void:
	reset_outline()
