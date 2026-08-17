extends Resource
class_name AttributesManager

const MAX_HEALTH := 10
const BASE_ABILITY_VALUE := 60

@export var _boss_title: String = ""
@export var _boss_name: String = ""
@export var _gold: int = 250
@export var _repute: int = 50
@export var _current_health: int = MAX_HEALTH

# ================================================== set/get
static var boss_title : String:
	set(new_value):
		GameData.attributes_manager._boss_title = new_value
		GlobalSignals.update_attribute.emit()
	get:
		return GameData.attributes_manager._boss_title
static var boss_name : String:
	set(new_value):
		GameData.attributes_manager._boss_name = new_value
		GlobalSignals.update_attribute.emit()
	get:
		return GameData.attributes_manager._boss_name
static var gold : int:
	set(new_value):
		GameData.attributes_manager._gold = new_value
		GlobalSignals.update_attribute.emit()
		if GameData.attributes_manager._gold < 0:
			ModalManager.open_game_over_modal()
	get:
		return GameData.attributes_manager._gold
static var repute : int:
	set(value):
		GameData.attributes_manager._repute = clampi(value, 0, 100)
		GlobalSignals.update_attribute.emit()
	get:
		return GameData.attributes_manager._repute
static var current_health :int:
	set(value):
		GameData.attributes_manager._current_health = clampi(value, 0, MAX_HEALTH)
		GlobalSignals.update_attribute.emit()
	get:
		return GameData.attributes_manager._current_health

static var sway : int:
	get:
		return get_attribute_value(Enums.ATTRIBUTES.SWAY)
static var command : int:
	get:
		return get_attribute_value(Enums.ATTRIBUTES.COMMAND)
static var trickery : int:
	get:
		return get_attribute_value(Enums.ATTRIBUTES.TRICKERY)
static var muscle : int:
	get:
		return get_attribute_value(Enums.ATTRIBUTES.MUSCLE)
static var wits : int:
	get:
		return get_attribute_value(Enums.ATTRIBUTES.WITS)

# ================================================== helper
static func get_modified_repute() -> int:
	return clampi(repute + get_modifier(Enums.ATTRIBUTES.REPUTE), 0, 100)

static func get_attribute_description(att: Enums.ATTRIBUTES) -> String:
	match att:
		Enums.ATTRIBUTES.MUSCLE:
			return "Physical power, fighting, toughness, and intimidation."
		Enums.ATTRIBUTES.WITS:
			return "Knowledge, observation, reasoning, and practical expertise."
		Enums.ATTRIBUTES.TRICKERY:
			return "Stealth, deception, opportunism, and underhanded planning."
		Enums.ATTRIBUTES.SWAY:
			return "Charm, persuasion, negotiation, and social influence."
		Enums.ATTRIBUTES.COMMAND:
			return "Leadership, discipline, morale, and group coordination."
		_:
			return ""

static func get_attribute_value(attribute: Enums.ATTRIBUTES) -> int:
	return clampi(BASE_ABILITY_VALUE + get_modifier(attribute), 0, 100)

static func get_ability_value(ability: Enums.ABILITIES) -> int:
	var att = Enums.ability_to_attribute(ability)
	return clampi(BASE_ABILITY_VALUE + get_modifier(att), 0, 100)

static func get_modifier(att : Enums.ATTRIBUTES) -> int:
	if GameData.ponygirl_manager == null:
		return 0
	var modifier = 0
	for pony in PonygirlManager.ponygirls:
		if not pony.active: continue
		modifier += pony.get_modifier(att)
	return modifier

static func get_attribute_icon(id : Enums.ATTRIBUTES) -> Texture2D:
	match id:
		Enums.ATTRIBUTES.SWAY:
			return preload("res://assets/icons/speach_bubbel.png")
		Enums.ATTRIBUTES.MUSCLE:
			return preload("res://assets/icons/fist.png")
		Enums.ATTRIBUTES.COMMAND:
			return preload("res://assets/icons/banner.png")
		Enums.ATTRIBUTES.TRICKERY:
			return preload("res://assets/icons/dagger.png")
		Enums.ATTRIBUTES.WITS:
			return preload("res://assets/icons/eye.png")
		Enums.ATTRIBUTES.GOLD:
			return preload("res://assets/icons/coin.png")
		Enums.ATTRIBUTES.HEALTH:
			return preload("res://assets/icons/heart.png")
		Enums.ATTRIBUTES.REPUTE:
			return preload("res://assets/icons/star.png")
		_:
			return preload("res://assets/icons/questionmark.png")

static func get_ability_icon(id : Enums.ABILITIES) -> Texture2D:
	var att_id = Enums.ability_to_attribute(id)
	return get_attribute_icon(att_id)
