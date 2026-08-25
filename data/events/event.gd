extends Resource
class_name Event

@export var titel : String
var id: StringName:
	get:
		return Utils.string_to_id(titel)
@export_multiline var description : String:
	get:
		return Utils.translate(description)
@export var img : Texture2D
@export var show_as_quest := true
@export var content : Array[_EventContent]
@export var open_actions : Array[Action]
@export var close_actions : Array[Action]

func requirements_are_met() -> bool:
	for action in open_actions:
		if not action.requirement_met():
			return false
	return true

func open() -> void:
	for action in open_actions:
		action.use()

func close() -> void:
	for action in close_actions:
		action.use()
	for c in content:
		if c is EventCheck:
			c.reset()
		if c is EventBtn:
			c.reset()
