extends Action
class_name ChangeSubmission

enum TARGET {
	FOCUSED,
	RANDOM,
	ACTIVE,
	ALL
}

@export var amount: int
@export var target := TARGET.RANDOM
var affected_ponygirls: Array[Ponygirl] = []

func use() -> void:
	affected_ponygirls = get_target_ponygirls()
	for ponygirl in affected_ponygirls:
		ponygirl.submission += amount

func requirement_met() -> bool:
	return not get_target_ponygirls().is_empty()

func get_target_ponygirls() -> Array[Ponygirl]:
	var target_ponygirls: Array[Ponygirl] = []
	match target:
		TARGET.FOCUSED:
			if PonygirlManager.focused_ponygirl:
				target_ponygirls.append(PonygirlManager.focused_ponygirl)
		TARGET.RANDOM:
			var ponygirl : Ponygirl = PonygirlManager.get_random_active_ponygirl()
			if ponygirl:
				target_ponygirls.append(ponygirl)
		TARGET.ACTIVE:
			target_ponygirls = PonygirlManager.get_active_ponygirls()
		TARGET.ALL:
			target_ponygirls = PonygirlManager.get_all_ponygirls()
	return target_ponygirls

func _get_txt() -> String:
	match target:
		TARGET.FOCUSED:
			return "Selected Ponygirl %s %s Submission" % [_get_singular_verb(), abs(amount)]
		TARGET.RANDOM:
			return "A random active ponygirl %s %s Submission" % [_get_singular_verb(), abs(amount)]
		TARGET.ACTIVE:
			return "All active ponygirls %s %s Submission" % [_get_plural_verb(), abs(amount)]
		TARGET.ALL:
			return "All ponygirls %s %s Submission" % [_get_plural_verb(), abs(amount)]
	return ""

func get_tooltip() -> String:
	if hide_tooltip: return ""
	return Utils.translate(_get_txt())

func get_result() -> String:
	if hide_description: return ""
	var text := _get_txt()
	if target == TARGET.FOCUSED:
		text = "{PONYNAME} %s %s Submission" % [_get_singular_verb(), abs(amount)]
	if target == TARGET.RANDOM and not affected_ponygirls.is_empty():
		text = "%s %s %s Submission" % [affected_ponygirls[0].name, _get_singular_verb(), abs(amount)]
	if text.is_empty(): return ""
	return Utils.translate("- " + text)

func _get_singular_verb() -> String:
	return "gains" if amount > 0 else "loses"

func _get_plural_verb() -> String:
	return "gain" if amount > 0 else "lose"
