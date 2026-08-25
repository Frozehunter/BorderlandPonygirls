extends DefaultBtn

enum CARE {
	TRAINING,
	TEASING,
	CLIMAX
}

@export var care_type = CARE.TRAINING

func _ready() -> void:
	super()
	var actions = []
	match care_type:
		CARE.TRAINING:
			actions = GameData.training_actions
		CARE.TEASING:
			actions = GameData.teasing_actions
		CARE.CLIMAX:
			actions = GameData.climax_actions
	disabled = !Utils.requierments_met(actions)
	_add_tooltips(actions)

func _add_tooltips(actions : Array[Action]):
	tooltip = CARE.keys()[care_type].capitalize()
	tooltip += "\n"
	tooltip += "\n".join(TooltipManager.get_tooltips(actions))

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return _pony_from_drop(data) != null

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var pony := _pony_from_drop(data)
	if pony == null:
		return
	PonygirlManager.focused_ponygirl = pony
	await get_tree().physics_frame
	match care_type:
		CARE.TRAINING:
			ModalManager.open_care_result_modal(GameData.training_actions)
		CARE.TEASING:
			ModalManager.open_care_result_modal(GameData.teasing_actions)
		CARE.CLIMAX:
			ModalManager.open_care_result_modal(GameData.climax_actions)
	GlobalSignals.update_ponygirls.emit()

func _pony_from_drop(data: Variant) -> Ponygirl:
	if data is Ponygirl:
		return data
	if data is Dictionary and data.get("ponygirl") is Ponygirl:
		return data.ponygirl
	return null
