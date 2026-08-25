extends Resource
class_name PonygirlManager

const FIRST_NAMES := [
	"Sugar",
	"Puffy",
	"Horny",
	"Milky",
	"Needy",
	"Bouncy",
	"Juicy",
	"Slutty",
	"Dirty",
	"Naughty",
	"Kinky",
	"Wet",
	"Tasty",
	"Sassy",
	"Cheeky",
    "Lusty"
]
const LAST_NAMES := [
	"Tits",
	"Cunt",
	"Pussy",
	"Eyes",
	"Lips",
	"Ass",
	"Booty",
	"Cheeks",
	"Hips",
	"Thighs",
    "Legs"
]
const EYE_COLORS := [
	"Brown",
	"Hazel",
	"Amber",
	"Green",
	"Emerald",
	"Blue",
	"Gray",
	"Violet",
	"Red",
	"Crimson",
	"Gold",
	"Silver",
	"Black"
]
const HAIR_COLORS := [
	"Black",
	"Brown",
	"Chestnut",
	"Auburn",
	"Red",
	"Ginger",
	"Blonde",
	"White",
	"Gray",
	"Silver"
]
const SKIN_TONES := [
	"Pale",
	"Fair",
	"Light",
	"Tan",
	"Olive",
	"Bronze",
	"Brown",
	"Ebony",
	"Ashen",
	"Golden",
    "Porcelain"
]
const PORTRAITS := {
	Enums.PONYGIRL_RACES.HUMAN: [
		preload("res://assets/img/ponygirls/human_01.png"),
		preload("res://assets/img/ponygirls/human_02.png"),
		preload("res://assets/img/ponygirls/human_03.png"),
		preload("res://assets/img/ponygirls/human_04.png"),
		preload("res://assets/img/ponygirls/human_05.png"),
		preload("res://assets/img/ponygirls/human_08.png"),
		preload("res://assets/img/ponygirls/human_09.png")
	],
	Enums.PONYGIRL_RACES.ELF: [
		preload("res://assets/img/ponygirls/elf_01.png"),
		preload("res://assets/img/ponygirls/elf_02.png"),
		preload("res://assets/img/ponygirls/elf_03.png"),
		preload("res://assets/img/ponygirls/elf_04.png")
	],
	Enums.PONYGIRL_RACES.DEMONBLOOD: [
		preload("res://assets/img/ponygirls/demonblood_01.png"),
		preload("res://assets/img/ponygirls/demonblood_02.png")
	],
}
const MAX_ACTIVE := 4
const MAX_RESTING := 4
const MAX_TOTAL := MAX_ACTIVE + MAX_RESTING

@export var _ponygirls: Array[Ponygirl] = []
@export var _focused_ponygirl: Ponygirl = null

# ================================================== set/get
static var ponygirls: Array[Ponygirl]:
	set(value):
		GameData.ponygirl_manager._ponygirls = value
	get:
		return GameData.ponygirl_manager._ponygirls

static var focused_ponygirl: Ponygirl:
	set(value):
		GameData.ponygirl_manager._focused_ponygirl = value
	get:
		return GameData.ponygirl_manager._focused_ponygirl

# ================================================== helper
static func init() -> void:
	if ponygirls.size() < MAX_TOTAL:
		ponygirls.resize(MAX_TOTAL)

static func get_active_ponygirls() -> Array[Ponygirl]:
	var list: Array[Ponygirl] = []
	for pony in get_all_ponygirls():
		if pony.active: list.push_back(pony)
	return list

static func get_resting_ponygirls() -> Array[Ponygirl]:
	var list: Array[Ponygirl] = []
	for pony in get_all_ponygirls():
		if not pony.active: list.push_back(pony)
	return list

static func get_all_ponygirls() -> Array[Ponygirl]:
	var all_ponygirls: Array[Ponygirl] = []
	for pony in ponygirls:
		if pony == null: continue
		all_ponygirls.append(pony)
	return all_ponygirls

static func get_random_active_ponygirl() -> Ponygirl:
	var active_ponygirls := get_active_ponygirls()
	if active_ponygirls.is_empty():
		return null
	return active_ponygirls.pick_random()

static func get_random_resting_ponygirl() -> Ponygirl:
	var resting_ponygirls := get_resting_ponygirls()
	if resting_ponygirls.is_empty():
		return null
	return resting_ponygirls.pick_random()

static func get_perk_by_name(perk_name: StringName) -> Perk:
	for perk in GameData.list_of_perks:
		if perk.name == perk_name:
			return perk
	return null

static func slots_free() -> bool:
	for pony in ponygirls:
		if pony == null:
			return true
	return false

static func add_ponygirl_to_slot(pony: Ponygirl, slot: int) -> bool:
	if pony == null:
		push_error("PonygirlManager.add_ponygirl_to_slot: pony is null")
		return false
	if slot < 0 or slot >= MAX_TOTAL:
		push_error("PonygirlManager.add_ponygirl_to_slot: invalid slot")
		return false
	if ponygirls[slot] != null:
		return false
	var new_pony := pony.duplicate(true) as Ponygirl
	new_pony.init()
	new_pony.active = slot < MAX_ACTIVE
	ponygirls[slot] = new_pony
	focused_ponygirl = new_pony
	return true

static func add_ponygirl(pony: Ponygirl) -> void:
	if pony == null:
		push_error("PonygirlManager.add_ponygirl: pony is null")
		return
	for slot in range(MAX_TOTAL):
		if ponygirls[slot] != null:
			continue
		var new_pony := pony.duplicate(true) as Ponygirl
		new_pony.init()
		new_pony.active = slot < MAX_ACTIVE
		ponygirls[slot] = new_pony
		focused_ponygirl = new_pony
		return
	push_warning("PonygirlManager.add_ponygirl: no free slots")

static func swap_slots(first_slot: int, second_slot: int) -> void:
	if first_slot == second_slot:
		return
	if first_slot < 0 or first_slot >= MAX_TOTAL:
		return
	if second_slot < 0 or second_slot >= MAX_TOTAL:
		return
	var first_pony := ponygirls[first_slot]
	var second_pony := ponygirls[second_slot]
	ponygirls[first_slot] = second_pony
	ponygirls[second_slot] = first_pony
	if ponygirls[first_slot] != null:
		ponygirls[first_slot].active = first_slot < MAX_ACTIVE
	if ponygirls[second_slot] != null:
		ponygirls[second_slot].active = second_slot < MAX_ACTIVE
