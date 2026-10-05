class_name CaseProceduralPretendCapability
extends RefCounted

const COPYCAT_ROLE_ID: StringName = &"copycat"
const COPYCAT_ACTIVE_ROLE_IDS: Array[StringName] = [&"tailor", &"vigilante"]
const CONMAN_ROLE_ID: StringName = &"conman"
const POISONER_ROLE_ID: StringName = &"poisoner"
const BARKEEP_ROLE_ID: StringName = &"barkeep"
const SPECTRE_ROLE_ID: StringName = &"spectre"
const SERIAL_KILLER_ROLE_ID: StringName = &"serial_killer"
const CRITIC_ROLE_ID: StringName = &"critic"
const CLOCK_MAKER_ROLE_ID: StringName = &"clock_maker"
const MOBSTER_ROLE_IDS: Array[StringName] = [&"tutorial_mobster", &"mobster"]
const STATIC_BEHAVIOR_ROLE_IDS: Array[StringName] = [
	&"tutorial_priest", &"priest", &"reporter", &"therapist",
	&"weatherman", &"blood_hound", &"mathematician", &"mailman",
]
const MOBSTER_PROCEDURAL_ROLE_IDS: Array[StringName] = [
	&"tutorial_priest", &"priest", &"reporter", &"therapist", &"mathematician",
	&"weatherman", &"blood_hound", &"mailman", &"clock_maker", &"tailor", &"vigilante",
]
const MOBSTER_AUTHORED_COMPAT_ROLE_IDS: Array[StringName] = [
	&"tutorial_priest", &"priest", &"reporter", &"therapist", &"mathematician",
	&"weatherman", &"blood_hound", &"mailman", &"tailor", &"vigilante", &"clock_maker",
]
const SERIAL_KILLER_LYING_BEHAVIOR_ROLE_IDS: Array[StringName] = [
	&"tutorial_priest", &"priest", &"reporter", &"therapist",
	&"weatherman", &"blood_hound", &"mathematician", &"mailman", &"clock_maker",
	&"tailor", &"vigilante",
]
const CRITIC_LYING_BEHAVIOR_ROLE_IDS: Array[StringName] = [
	&"tutorial_priest", &"priest", &"reporter", &"therapist", &"mathematician",
	&"weatherman", &"blood_hound", &"mailman", &"clock_maker",
]


static func is_pretender(role_id: StringName) -> bool:
	return role_id == COPYCAT_ROLE_ID or role_id == CONMAN_ROLE_ID or role_id == POISONER_ROLE_ID or role_id == BARKEEP_ROLE_ID or role_id == SPECTRE_ROLE_ID or role_id == SERIAL_KILLER_ROLE_ID or role_id == CRITIC_ROLE_ID or MOBSTER_ROLE_IDS.has(role_id)


static func is_supported_behavior(role_id: StringName) -> bool:
	return STATIC_BEHAVIOR_ROLE_IDS.has(role_id)


static func is_supported_lying_behavior(role_id: StringName) -> bool:
	return MOBSTER_PROCEDURAL_ROLE_IDS.has(role_id)


static func behavior_requires_current_native_witness(role_id: StringName) -> bool:
	return COPYCAT_ACTIVE_ROLE_IDS.has(role_id)


static func procedural_current_native_witness_is_satisfied(
	source_suspect_id: int,
	behavior_role_id: StringName,
	candidate_suspect_ids: PackedInt32Array,
	current_role_ids_by_suspect: Dictionary
) -> bool:
	if not behavior_requires_current_native_witness(behavior_role_id):
		return true
	for suspect_id: int in candidate_suspect_ids:
		if suspect_id == source_suspect_id:
			continue
		if StringName(current_role_ids_by_suspect.get(suspect_id, &"")) == behavior_role_id:
			return true
	return false


static func serial_killer_can_pretend(role_id: StringName) -> bool:
	return SERIAL_KILLER_LYING_BEHAVIOR_ROLE_IDS.has(role_id)


static func critic_can_pretend(role_id: StringName) -> bool:
	return CRITIC_LYING_BEHAVIOR_ROLE_IDS.has(role_id)


static func mobster_can_pretend_procedurally(role_id: StringName) -> bool:
	return MOBSTER_PROCEDURAL_ROLE_IDS.has(role_id)


static func mobster_can_pretend_authored_compatible(role_id: StringName) -> bool:
	return MOBSTER_AUTHORED_COMPAT_ROLE_IDS.has(role_id)


static func can_pretend_procedural(
	pretender_role_id: StringName,
	target_role: RoleDefinition
) -> bool:
	if not is_pretender(pretender_role_id) or target_role == null:
		return false
	if pretender_role_id == SERIAL_KILLER_ROLE_ID:
		return serial_killer_can_pretend(target_role.role_id)
	if pretender_role_id == CRITIC_ROLE_ID:
		return critic_can_pretend(target_role.role_id)
	if target_role.role_id == CLOCK_MAKER_ROLE_ID:
		if MOBSTER_ROLE_IDS.has(pretender_role_id):
			return mobster_can_pretend_procedurally(target_role.role_id)
		if pretender_role_id == COPYCAT_ROLE_ID:
			return CaseRolePoolService.role_alignment(target_role) == CaseEnums.Alignment.GOOD
		return false
	if COPYCAT_ACTIVE_ROLE_IDS.has(target_role.role_id):
		if pretender_role_id == COPYCAT_ROLE_ID:
			return CaseRolePoolService.role_alignment(target_role) == CaseEnums.Alignment.GOOD
		if MOBSTER_ROLE_IDS.has(pretender_role_id):
			return mobster_can_pretend_procedurally(target_role.role_id)
		return false
	if not is_supported_behavior(target_role.role_id):
		return false
	if MOBSTER_ROLE_IDS.has(pretender_role_id):
		return mobster_can_pretend_procedurally(target_role.role_id)
	if pretender_role_id == COPYCAT_ROLE_ID:
		return CaseRolePoolService.role_alignment(target_role) == CaseEnums.Alignment.GOOD
	return true


static func can_pretend_authored_compatible(
	pretender_role_id: StringName,
	target_role: RoleDefinition
) -> bool:
	if not is_pretender(pretender_role_id) or target_role == null:
		return false
	if MOBSTER_ROLE_IDS.has(pretender_role_id):
		return mobster_can_pretend_authored_compatible(target_role.role_id)
	return can_pretend_procedural(pretender_role_id, target_role)


# Backward-compatible procedural alias for established generator/solver callers.
static func can_pretend(
	pretender_role_id: StringName,
	target_role: RoleDefinition
) -> bool:
	return can_pretend_procedural(pretender_role_id, target_role)
