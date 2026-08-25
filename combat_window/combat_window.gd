extends CanvasLayer

@onready var enemy_name_label: Label = %EnemyNameLabel
@onready var enemy_health_label: Label = %EnemyHealthLabel
@onready var scene_title: Label = %SceneTitle
@onready var scene_description: Label = %SceneDescription
@onready var actions_container: VBoxContainer = %ActionsContainer
@onready var end_combat_btn: DefaultBtn = %EndCombatBtn
@onready var content_image: TextureRect = %ContentImage

const COMBAT_BTN = preload("uid://81o40hsg8i6j")

func _ready() -> void:
	GlobalSignals.update_combat.connect(_update)
	GameData.game_state = Enums.GAME_STATES.COMBAT
	enemy_name_label.text = CombatManager.enemy_name
	actions_container.visible = true
	end_combat_btn.visible = false
	_update()

func _update():
	enemy_health_label.text = "%s/%s" % [CombatManager.enemy_health, CombatManager.ENEMY_MAX_HEALTH]
	if AttributesManager.current_health <= 0:
		_defeat_update()
	elif CombatManager.enemy_health <= 0:
		_victory_update()
	else:
		CombatManager.select_next_scene()
		_normal_scene_update()

func _normal_scene_update():
	var scene := CombatManager.current_scene
	var combat := CombatManager.current_combat
	scene_title.text = combat.title if combat else "Combat"
	scene_description.text = ""
	if scene == null:
		scene_description.text = "The fight falls apart before it can begin."
		content_image.texture = null
		for btn in actions_container.get_children():
			btn.queue_free()
		actions_container.visible = false
		end_combat_btn.visible = true
		return
	if scene.flavor_lines.size() > 0:
		scene.flavor_lines.shuffle()
		scene_description.text += Utils.translate(scene.flavor_lines[0])
		scene_description.text += "\n\n"
	scene_description.text += Utils.translate(scene.description)
	content_image.texture = scene.img
	for btn in actions_container.get_children():
		btn.queue_free()
	for action in scene.get_actions():
		var b = COMBAT_BTN.instantiate()
		b.action = action
		actions_container.add_child(b)

func _victory_update():
	scene_title.text = "Victory!"
	scene_description.text = CombatManager.get_victory_txt()
	content_image.texture = CombatManager.current_combat.victory_img
	actions_container.visible = false
	end_combat_btn.visible = true

func _defeat_update():
	scene_title.text = "Defeat!"
	scene_description.text = CombatManager.get_defeat_txt()
	content_image.texture = CombatManager.current_combat.defeat_img
	actions_container.visible = false
	end_combat_btn.visible = true

func _on_end_combat_btn_pressed() -> void:
	if AttributesManager.current_health <= 0:
		CombatManager.defeat()
	elif CombatManager.enemy_health <= 0:
		CombatManager.victory()
	if AttributesManager.gold < 0: return
	SceneManager.change_scene(SceneManager.MAIN_WINDOW)
