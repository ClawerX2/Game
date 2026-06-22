extends InteractionComponent
class_name LootComponent

@export var item_data: ItemData

func interact(player: Player):
	player.inventory.pickup_item(item_data)
	get_parent().queue_free()
