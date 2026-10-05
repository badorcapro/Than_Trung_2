class_name CaseTruthRevealBuilder
extends RefCounted

func build(case_definition: CaseDefinition, runtime: CaseRuntimeState, roles: Array[RoleDefinition]) -> CaseTruthReveal:
	if case_definition == null or runtime == null or not runtime.is_settled or runtime.settlement_result == null:
		return null
	var reveal := CaseTruthReveal.new()
	reveal.case_id = case_definition.case_id
	reveal.evil_suspect_ids = case_definition.evil_suspect_ids.duplicate()
	reveal.player_resolutions.assign(runtime.settlement_result.player_resolutions)
	reveal.public_function_records.assign(runtime.public_function_records)
	var relation_notes_by_source: Dictionary = _relation_notes_by_source(case_definition, runtime, roles)
	for suspect in case_definition.suspects:
		var truth := SuspectTruthReveal.new()
		var current_role_id: StringName = runtime.current_role_id_for_suspect(case_definition, suspect.suspect_id)
		var current_group: CaseEnums.RoleGroup = suspect.role_group
		for role: RoleDefinition in roles:
			if role != null and role.role_id == current_role_id:
				current_group = role.role_group
				break
		truth.suspect_id = suspect.suspect_id
		truth.displayed_role_name = _role_name(roles, suspect.displayed_role_id)
		truth.original_true_role_name = _role_name(roles, suspect.true_role_id)
		truth.current_role_id = current_role_id
		truth.current_role_name = _role_name(roles, current_role_id)
		truth.true_role_name = truth.current_role_name
		truth.impersonated_role_name = _role_name(roles, suspect.impersonated_role_id) if not String(suspect.impersonated_role_id).is_empty() else ""
		truth.alignment_label = "Phe Thiện" if CaseRolePoolService.alignment_for_role_group(current_group) == CaseEnums.Alignment.GOOD else "Phe Ác"
		truth.role_group_label = _group_label(current_group)
		truth.is_impersonating = suspect.is_impersonating
		truth.is_corrupted = PoisonerTaintService.new().is_effectively_corrupted(case_definition, runtime, suspect.suspect_id)
		truth.obscure_target_suspect_id = suspect.obscure_target_suspect_id
		truth.truth_note = suspect.truth_reveal_note
		var relation_notes_value: Variant = relation_notes_by_source.get(suspect.suspect_id, PackedStringArray())
		if relation_notes_value is PackedStringArray:
			truth.relation_notes = PackedStringArray(relation_notes_value)
		reveal.suspect_truths.append(truth)
	runtime.truth_reveal = reveal
	return reveal


func _relation_notes_by_source(case_definition: CaseDefinition, runtime: CaseRuntimeState, roles: Array[RoleDefinition]) -> Dictionary:
	var notes: Dictionary = {}
	if case_definition == null or runtime == null:
		return notes
	for record: PoisonerTaintRecord in runtime.poisoner_taint_records:
		if record == null or not record.applied or record.target_suspect_id <= 0:
			continue
		_add_relation_note(notes, record.source_suspect_id, "%s đã Tha Hóa Số Hiệu %d." % [
			_role_name(roles, runtime.current_role_id_for_suspect(case_definition, record.source_suspect_id)),
			record.target_suspect_id,
		])
	for record: BarkeepTransformationRecord in runtime.barkeep_transformation_records:
		if record == null or not record.applied or record.target_suspect_id <= 0:
			continue
		_add_relation_note(notes, record.source_suspect_id, "%s đã biến Số Hiệu %d thành %s." % [
			_role_name(roles, runtime.current_role_id_for_suspect(case_definition, record.source_suspect_id)),
			record.target_suspect_id,
			_role_name(roles, record.resulting_role_id),
		])
	for event: CaseTimedEventRuntimeState in runtime.timed_events:
		if not _timed_event_is_successful_kill(event):
			continue
		_add_relation_note(notes, event.source_suspect_id, "Ở mốc %dh, ta đã giết Số Hiệu %d." % [
			event.threshold_hour,
			event.target_suspect_id,
		])
	return notes


func _timed_event_is_successful_kill(event: CaseTimedEventRuntimeState) -> bool:
	return (
		event != null
		and event.fired
		and event.kill_attempted
		and event.kill_outcome == CaseKillResult.Outcome.KILLED
		and event.source_suspect_id > 0
		and event.target_suspect_id > 0
	)


func _add_relation_note(notes: Dictionary, source_suspect_id: int, note: String) -> void:
	var source_notes: PackedStringArray = PackedStringArray()
	var source_notes_value: Variant = notes.get(source_suspect_id, PackedStringArray())
	if source_notes_value is PackedStringArray:
		source_notes = PackedStringArray(source_notes_value)
	source_notes.append(note)
	notes[source_suspect_id] = source_notes

func _role_name(roles: Array[RoleDefinition], role_id: StringName) -> String:
	for role in roles:
		if role != null and role.role_id == role_id:
			return role.display_name
	return String(role_id)

func _group_label(group: CaseEnums.RoleGroup) -> String:
	return ["Người Vô Tội", "Kẻ Bao Đồng", "Thuộc Hạ", "Nghịch Thần"][group]
