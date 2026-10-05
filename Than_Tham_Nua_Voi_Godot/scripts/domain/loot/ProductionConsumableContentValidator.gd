class_name ProductionConsumableContentValidator
extends RefCounted

const EXPECTED_ITEM_COUNT := 3
const EXPECTED_ITEMS := {
	"consumable_hanh_lo_phu": {
		"display_name": "Hành Lộ Phù",
		"description": "Tăng 1 ô di chuyển cho lần di chuyển kế tiếp.",
		"effect_type": ConsumableItemDefinition.EffectType.MOVE_DISTANCE_BONUS,
		"duration": TemporaryEffectState.Duration.THIS_MOVE,
	},
	"consumable_lenh_bai_thong_hanh": {
		"display_name": "Lệnh Bài Thông Hành",
		"description": "Nhận thêm 1 lượt di chuyển trong vòng này.",
		"effect_type": ConsumableItemDefinition.EffectType.EXTRA_MOVEMENT_ACTION,
		"duration": TemporaryEffectState.Duration.THIS_ROUND,
	},
	"consumable_ngu_ma_lenh": {
		"display_name": "Ngự Mã Lệnh",
		"description": "Tăng 1 Tốc độ cho lần di chuyển kế tiếp.",
		"effect_type": ConsumableItemDefinition.EffectType.SPEED_BONUS,
		"duration": TemporaryEffectState.Duration.THIS_MOVE,
	},
}


func validate(items: Array[ConsumableItemDefinition]) -> Array[String]:
	var errors: Array[String] = []
	var seen_ids: Dictionary = {}
	if items.size() != EXPECTED_ITEM_COUNT:
		errors.append("Production consumable count must be 3")
	for item: ConsumableItemDefinition in items:
		if item == null:
			errors.append("Production consumable is null")
			continue
		var item_key := String(item.item_id)
		if item.item_id == &"" or seen_ids.has(item_key):
			errors.append("Production consumable IDs must be non-empty and unique")
		seen_ids[item_key] = true
		var expected: Dictionary = EXPECTED_ITEMS.get(item_key, {})
		if expected.is_empty():
			errors.append("Production consumable ID is not approved: %s" % item.item_id)
			continue
		if item.display_name != String(expected.get("display_name", "")):
			errors.append("Production consumable display name is not canonical: %s" % item.item_id)
		if item.description != String(expected.get("description", "")):
			errors.append("Production consumable description is not canonical: %s" % item.item_id)
		if item.effect_type != int(expected.get("effect_type", -1)):
			errors.append("Production consumable effect is not canonical: %s" % item.item_id)
		if item.duration != int(expected.get("duration", -1)):
			errors.append("Production consumable duration is not canonical: %s" % item.item_id)
		if item.magnitude != 1:
			errors.append("Production consumable magnitude must be 1: %s" % item.item_id)
		if item.target_scope != ConsumableItemDefinition.TargetScope.SELF:
			errors.append("Production consumable target must be SELF: %s" % item.item_id)
		if item.test_only_not_canon_locked:
			errors.append("Production consumable cannot be TEST_ONLY: %s" % item.item_id)
	for expected_id: String in EXPECTED_ITEMS:
		if not seen_ids.has(expected_id):
			errors.append("Missing production consumable: %s" % expected_id)
	return errors
