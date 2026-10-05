class_name ConsumableItemDefinition
extends Resource

enum EffectType { MOVE_DISTANCE_BONUS, SPEED_BONUS, EXTRA_MOVEMENT_ACTION, MOVEMENT_ACTION_PENALTY }
enum TargetScope { SELF, ALL_OTHER_PLAYERS }

@export var item_id: StringName
@export var display_name: String
@export_multiline var description: String
@export var effect_type: EffectType = EffectType.MOVE_DISTANCE_BONUS
@export var magnitude := 1
@export var duration: TemporaryEffectState.Duration = TemporaryEffectState.Duration.THIS_MOVE
@export var target_scope: TargetScope = TargetScope.SELF
@export var tags: Array[StringName] = []
@export var test_only_not_canon_locked := true
