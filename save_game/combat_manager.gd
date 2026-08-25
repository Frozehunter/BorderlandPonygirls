extends Resource
class_name CombatManager

const ENEMY_MAX_HEALTH := 3

@export var _current_combat: Combat
@export var _enemy_name := ""
@export var _enemy_health := 0
@export var _current_scene: CombatScene
@export var _last_scene: CombatScene

# ================================================== set/get
static var current_combat: Combat:
	set(value):
		GameData.combat_manager._current_combat = value
	get:
		return GameData.combat_manager._current_combat
static var enemy_name: String:
	set(value):
		GameData.combat_manager._enemy_name = value
	get:
		return GameData.combat_manager._enemy_name
static var enemy_health: int:
	set(value):
		GameData.combat_manager._enemy_health = maxi(value, 0)
	get:
		return GameData.combat_manager._enemy_health
static var current_scene: CombatScene:
	set(value):
		GameData.combat_manager._current_scene = value
	get:
		return GameData.combat_manager._current_scene
static var last_scene: CombatScene:
	set(value):
		GameData.combat_manager._last_scene = value
	get:
		return GameData.combat_manager._last_scene

# ================================================== helper
static func start_combat() -> void:
	enemy_name = current_combat.get_enemy_name()
	enemy_health = ENEMY_MAX_HEALTH
	var focused := PonygirlManager.focused_ponygirl
	var keep_focus := (
		current_combat.keep_focused_ponygirl
		and focused != null
		and focused.active
	)
	if not keep_focus:
		PonygirlManager.focused_ponygirl = PonygirlManager.get_random_active_ponygirl()
	current_scene = null
	last_scene = null

static func select_next_scene() -> void:
	if current_combat == null:
		current_scene = null
		return
	if not current_combat.keep_focused_ponygirl:
		PonygirlManager.focused_ponygirl = PonygirlManager.get_random_active_ponygirl()
	last_scene = current_scene
	current_scene = current_combat.get_next_scene(last_scene)

static func action_success() -> void:
	enemy_health -= 1

static func action_failure() -> void:
	AttributesManager.current_health -= 1

# ================================================== victory/defeat
static func victory() -> void:
	if current_combat.victory_actions.is_empty():
		_use_actions(GameData.combat_victory_actions)
	else:
		_use_actions(current_combat.victory_actions)

static func defeat() -> void:
	if current_combat.defeat_actions.is_empty():
		_use_actions(GameData.combat_defeat_actions)
	else:
		_use_actions(current_combat.defeat_actions)

static func _use_actions(actions : Array[Action]):
	for action in actions:
		action.use()

static func _get_actions_txt(actions : Array[Action]):
	var txt = ""
	for action in actions:
		txt += "\n" + action.get_result()
	return txt

static func get_victory_txt() -> String:
	var txt := current_combat.victory_txt
	txt += "\n"
	if current_combat.victory_actions.is_empty():
		txt += _get_actions_txt(GameData.combat_victory_actions)
	else:
		txt += _get_actions_txt(current_combat.victory_actions)
	return Utils.translate(txt)

static func get_defeat_txt() -> String:
	var txt := current_combat.defeat_txt
	txt += "\n"
	if current_combat.defeat_actions.is_empty():
		txt += _get_actions_txt(GameData.combat_defeat_actions)
	else:
		txt += _get_actions_txt(current_combat.defeat_actions)
	return Utils.translate(txt)
