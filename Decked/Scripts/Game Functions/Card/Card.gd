extends Resource
class_name Card

enum Rarity { COMMON, RARE, LEGENDARY }
enum BuffType { HEALTH, DAMAGE, SPEED }

@export var card_name: String = "Card Name"
@export_multiline var description: String = "Card Description"
@export var icon: Texture2D
@export var rarity: Rarity = Rarity.COMMON
@export var buff_type: BuffType = BuffType.DAMAGE
@export var value: float = 1.0

func _init(p_name = "", p_desc = "", p_rarity = Rarity.COMMON, p_type = BuffType.DAMAGE, p_val = 1.0, p_icon: Texture2D = null):
	card_name = p_name
	description = p_desc
	rarity = p_rarity
	buff_type = p_type
	value = p_val
	icon = p_icon
