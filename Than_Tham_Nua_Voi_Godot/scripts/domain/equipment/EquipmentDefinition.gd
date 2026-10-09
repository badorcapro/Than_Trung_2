class_name EquipmentDefinition
extends Resource

@export var equipment_definition_id: StringName
@export var display_name := ""
@export var equipment_type: EquipmentEnums.EquipmentType = EquipmentEnums.EquipmentType.RELIC
@export var stigmata_slot: EquipmentEnums.StigmataSlot = EquipmentEnums.StigmataSlot.NONE
@export var tier: EquipmentEnums.Tier = EquipmentEnums.Tier.A
@export var set_id: StringName
@export var gold_stat_rows: Array[Dictionary] = []
@export var gold_upgrade_costs: Array[int] = []
@export var purple_stat_bonuses: Dictionary = {}
@export var skill_marker: StringName
@export var skill_name: String = ""
@export var skill_cooldown: int = 0
@export var skill_descriptions: Array[String] = []
@export var test_only_not_canon_locked := true

func stat_row(gold_level: int) -> Dictionary:
	if gold_level < 1 or gold_level > gold_stat_rows.size(): return {}
	return gold_stat_rows[gold_level - 1].duplicate(true)

func gold_cost(from_level: int) -> int:
	if from_level < 1 or from_level > gold_upgrade_costs.size(): return -1
	return gold_upgrade_costs[from_level - 1]

func get_purple_bonus(milestone: int) -> Dictionary:
	if purple_stat_bonuses.has(milestone):
		return (purple_stat_bonuses[milestone] as Dictionary).duplicate(true)
	elif purple_stat_bonuses.has(String(milestone)):
		return (purple_stat_bonuses[String(milestone)] as Dictionary).duplicate(true)
	match milestone:
		1:
			return {"speed": 2 + int(tier)}
		3:
			return {"stamina": 40 + int(tier) * 20}
		5:
			return {"strength": 30 + int(tier) * 15}
		_:
			return {}

func get_skill_level(purple_level: int) -> int:
	if purple_level >= 6:
		return 4
	elif purple_level >= 4:
		return 3
	elif purple_level >= 2:
		return 2
	return 1

func get_skill_description(purple_level: int) -> String:
	var lvl: int = get_skill_level(purple_level)
	if lvl - 1 < skill_descriptions.size() and not skill_descriptions[lvl - 1].is_empty():
		return skill_descriptions[lvl - 1]
	if equipment_type == EquipmentEnums.EquipmentType.RELIC:
		match lvl:
			1: return "Cấp 1: Kích hoạt sao chép 1 item từ người chơi được chọn hoặc nhận 1 hành động phụ."
			2: return "Cấp 2: Kích hoạt sao chép 2 item từ người chơi được chọn."
			3: return "Cấp 3: Kích hoạt sao chép 3 item và giảm 1 tiêu hao khi kích hoạt."
			4: return "Cấp 4: Kích hoạt sao chép 4 item, có thể chọn từ nhiều người chơi khác nhau."
			_: return "Kỹ năng kích hoạt Kỷ Vật."
	else:
		match lvl:
			1: return "Cấp 1: Nội tại gia tăng 10% Thể Lực và ổn định lộ trình di chuyển."
			2: return "Cấp 2: Nội tại gia tăng 18% Thể Lực và 5% Tốc Độ."
			3: return "Cấp 3: Nội tại gia tăng 25% Thể Lực và 10% Tốc Độ."
			4: return "Cấp 4: Nội tại gia tăng 35% Thể Lực, 15% Tốc Độ và giảm thiểu rủi ro cạm bẫy."
			_: return "Kỹ năng nội tại Vết Thánh."

func get_total_stats(gold_level: int, purple_level: int) -> Dictionary:
	var base: Dictionary = stat_row(gold_level)
	var st_stamina: int = int(base.get("stamina", base.get("hp", 0)))
	var st_speed: int = int(base.get("speed", base.get("spd", 0)))
	var st_strength: int = int(base.get("strength", base.get("power", base.get("str", 0))))

	if st_stamina == 0:
		st_stamina = 120 + gold_level * 50 + int(tier) * 150
	if st_speed == 0:
		st_speed = 60 + gold_level * 25 + int(tier) * 80
	if st_strength == 0:
		st_strength = 50 + gold_level * 20 + int(tier) * 70

	for m: int in [1, 3, 5]:
		if purple_level >= m:
			var bonus: Dictionary = get_purple_bonus(m)
			st_stamina += int(bonus.get("stamina", bonus.get("hp", 0)))
			st_speed += int(bonus.get("speed", bonus.get("spd", 0)))
			st_strength += int(bonus.get("strength", bonus.get("power", bonus.get("str", 0))))

	return {
		"stamina": st_stamina,
		"speed": st_speed,
		"strength": st_strength,
	}
