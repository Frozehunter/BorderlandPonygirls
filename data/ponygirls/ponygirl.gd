extends Resource
class_name Ponygirl

const XP_THRESHOLDS = [0, 10, 20, 40, 80]
const SUBMISSION_THRESHOLDS = [30, 70]
const AROUSAL_THRESHOLDS = [25, 75];
const LEVEL_BONUS_THRESHOLDS = [4, 5];

@export var name := ""
@export var id := ""
@export var _race: Enums.PONYGIRL_RACES = Enums.PONYGIRL_RACES.UNKNOWN
@export var race := "":
	get:
		return Enums.PONYGIRL_RACES.keys()[_race].capitalize()
@export var hair_color := ""
@export var eye_color := ""
@export var skin_tone := ""
@export var _portrait : Texture2D
var portrait: Texture2D:
	set(value):
		_portrait = value
	get:
		return get_display_texture()
@export var xp := 0:
	set(value):
		xp = value
		_update_normal_perks()
@export var perks :Array[Perk] = []
@export var submission := 50:
	set(value):
		submission = clamp(value, 0, 100)
		_update_background_perks()
@export var arousal := 0:
	set(value):
		arousal = clamp(value, 0, 100)
		_update_background_perks()
@export var active = false
var level :int:
	get:
		for i in range(XP_THRESHOLDS.size() - 1, -1, -1):
			if xp >= XP_THRESHOLDS[i]:
				return i + 1
		return 1

func init() -> void:
	if id.is_empty():
		id = str(ResourceUID.create_id())
	if name.is_empty():
		name = get_random_name()
	if _race == Enums.PONYGIRL_RACES.UNKNOWN:
		_race = _get_random_race()
	if hair_color.is_empty():
		hair_color = PonygirlManager.HAIR_COLORS.pick_random()
	if eye_color.is_empty():
		eye_color = PonygirlManager.EYE_COLORS.pick_random()
	if skin_tone.is_empty():
		skin_tone = PonygirlManager.SKIN_TONES.pick_random()
	if portrait == null and PonygirlManager.PORTRAITS.has(_race):
		portrait = PonygirlManager.PORTRAITS[_race].pick_random()
	_update_perks()

static func get_random_name() -> String:
	var first_name = PonygirlManager.FIRST_NAMES.pick_random()
	var last_name = PonygirlManager.LAST_NAMES.pick_random()
	return "%s-%s" % [first_name, last_name]

func _get_random_race() -> Enums.PONYGIRL_RACES:
	var roll := randi_range(0, 6)
	if roll < 4:
		return Enums.PONYGIRL_RACES.HUMAN
	elif roll < 6:
		return Enums.PONYGIRL_RACES.ELF
	else:
		return Enums.PONYGIRL_RACES.TIEFLING

# ======================================================= abilities
func get_mod_bonus() -> int:
	var bonus = 5
	var horny = PonygirlManager.get_perk_by_name('Horny')
	var desperately_horny = PonygirlManager.get_perk_by_name('Desperately Horny')
	if level == 4: bonus += 1
	if level == 5: bonus += 2
	if perks.has(horny): bonus += 2
	if perks.has(desperately_horny): bonus -= 2
	return bonus

func get_modifier(att : Enums.ATTRIBUTES) -> int:
	var modifier := 0
	var bonus = get_mod_bonus()
	for perk in perks:
		if perk.bonus == att: modifier += bonus
		if perk.malus == att: modifier -= 5
	return modifier

# ======================================================= perks
func _update_perks():
	_update_normal_perks()
	_update_background_perks()

func _update_normal_perks() -> void:
	_drop_duplicate_groups()
	var list_of_perks: Array = GameData.list_of_perks.duplicate()
	list_of_perks.shuffle()
	var target := mini(level, 3)
	while get_amount_of_normal_perks() < target and not list_of_perks.is_empty():
		var perk: Perk = list_of_perks.pop_front()
		if perk == null or perk.background:
			continue
		if perks.has(perk):
			continue
		if not _can_add_perk(perk):
			continue
		perks.push_back(perk)

func _can_add_perk(perk: Perk) -> bool:
	if perk.group == Perk.GROUPS.NONE:
		return true
	return not _has_perk_group(perk.group)

func _has_perk_group(group: Perk.GROUPS) -> bool:
	for existing in perks:
		if existing == null or existing.background:
			continue
		if existing.group == group:
			return true
	return false

func _drop_duplicate_groups() -> void:
	var seen: Dictionary = {}
	var kept: Array[Perk] = []
	for perk in perks:
		if perk == null:
			continue
		if perk.background or perk.group == Perk.GROUPS.NONE:
			kept.append(perk)
			continue
		if seen.has(perk.group):
			continue
		seen[perk.group] = true
		kept.append(perk)
	perks = kept

func get_amount_of_normal_perks() -> int:
	var amount := 0
	for perk in perks:
		if perk.background:
			continue
		amount += 1
	return amount

func _update_background_perks() -> void:
	_toggle_perk("Unhappy", submission <= SUBMISSION_THRESHOLDS[0])
	_toggle_perk("Happy", submission >= SUBMISSION_THRESHOLDS[1])
	_toggle_perk("Horny", arousal >= AROUSAL_THRESHOLDS[0] && arousal < AROUSAL_THRESHOLDS[1])
	_toggle_perk("Desperately Horny", arousal >= AROUSAL_THRESHOLDS[1])

func _toggle_perk(perk_id: String, enable: bool):
	var perk = PonygirlManager.get_perk_by_name(perk_id)
	perks.erase(perk)
	if enable && perk: perks.append(perk)

# ======================================================= portraits (race_NN state lineart)
func get_submission_state_key() -> String:
	if submission <= SUBMISSION_THRESHOLDS[0]:
		return "unhappy"
	if submission >= SUBMISSION_THRESHOLDS[1]:
		return "happy"
	return "neutral"

func get_arousal_state_key() -> String:
	if arousal >= AROUSAL_THRESHOLDS[1]:
		return "desperately_horny"
	if arousal >= AROUSAL_THRESHOLDS[0]:
		return "horny"
	return "calm"

func get_portrait_state_key() -> String:
	return "%s_%s" % [get_submission_state_key(), get_arousal_state_key()]

## Prefer portrait asset basename (elf_01, human_02) so state linearts match race pool.
func get_portrait_slug() -> String:
	if _portrait != null:
		var path := _portrait.resource_path
		if not path.is_empty():
			return path.get_file().get_basename().to_lower()
	return name.strip_edges().to_lower().replace("-", "_").replace(" ", "_")

## State lineart by race id, then race base under assets/img/, then portrait export.
func get_display_texture() -> Texture2D:
	var base := get_portrait_slug()
	if base.is_empty():
		return _portrait
	var state_key := get_portrait_state_key()
	var candidates: Array[String] = [
		"res://assets/img/ponygirls/states/lineart/%s_%s.png" % [base, state_key],
		"res://assets/img/ponygirls/%s.png" % base,
		"res://assets/img/%s.png" % base,
	]
	for path in candidates:
		var tex := _load_portrait_texture(path)
		if tex != null:
			return tex
	return _portrait

func _load_portrait_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if ResourceLoader.exists(path):
		var res := load(path)
		if res is Texture2D:
			return res as Texture2D
	if not FileAccess.file_exists(path):
		return null
	var loaded := Image.new()
	if loaded.load(path) != OK:
		return null
	if loaded.get_format() != Image.FORMAT_RGBA8:
		loaded.convert(Image.FORMAT_RGBA8)
	return ImageTexture.create_from_image(loaded)
