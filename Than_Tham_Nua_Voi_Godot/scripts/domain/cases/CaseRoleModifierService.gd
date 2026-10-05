class_name CaseRoleModifierService
extends RefCounted

const CRITIC_ROLE_ID: StringName = &"critic"
const POOR_EFFECTIVE_REPUTATION: int = 2
const CRITIC_REPUTATION_LOSS_MULTIPLIER: int = 2


static func is_critic_role_id(role_id: StringName) -> bool:
	return role_id == CRITIC_ROLE_ID


static func adjusted_reputation_delta(player: PlayerCaseState, reputation_delta: int) -> int:
	if reputation_delta >= 0 or player == null or not is_critic_role_id(player.case_role_id):
		return reputation_delta
	return reputation_delta * CRITIC_REPUTATION_LOSS_MULTIPLIER


static func effective_turn_reputation(player: PlayerCaseState) -> int:
	if player == null:
		return 0
	if is_critic_role_id(player.case_role_id):
		return mini(player.reputation, POOR_EFFECTIVE_REPUTATION)
	return player.reputation


static func true_role_ids_in_play(case_definition: CaseDefinition) -> Dictionary:
	var ids: Dictionary = {}
	if case_definition == null:
		return ids
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect != null and not String(suspect.true_role_id).is_empty():
			ids[suspect.true_role_id] = true
	return ids


static func requires_pretend_role_not_true_in_play(suspect: SuspectDefinition) -> bool:
	return suspect != null and is_critic_role_id(suspect.true_role_id) and suspect.is_impersonating


static func critic_pretend_role_is_present(suspect: SuspectDefinition) -> bool:
	if suspect == null or not is_critic_role_id(suspect.true_role_id):
		return true
	return suspect.is_impersonating and suspect.true_role_id != suspect.displayed_role_id and not String(critic_pretend_role_id(suspect)).is_empty()


static func critic_pretend_role_id(suspect: SuspectDefinition) -> StringName:
	if suspect == null:
		return &""
	if not String(suspect.impersonated_role_id).is_empty():
		return suspect.impersonated_role_id
	return suspect.displayed_role_id


static func critic_pretend_role_is_not_true_in_play(case_definition: CaseDefinition, suspect: SuspectDefinition) -> bool:
	if not requires_pretend_role_not_true_in_play(suspect):
		return true
	var pretend_role_id: StringName = critic_pretend_role_id(suspect)
	if String(pretend_role_id).is_empty():
		return false
	return not true_role_ids_in_play(case_definition).has(pretend_role_id)
