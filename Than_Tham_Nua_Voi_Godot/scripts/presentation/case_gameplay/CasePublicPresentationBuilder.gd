class_name CasePublicPresentationBuilder
extends RefCounted

const VIETNAMESE_LETTERS: String = (
	"ÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬĐÈÉẺẼẸÊỀẾỂỄỆÌÍỈĨỊ"
	+ "ÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢÙÚỦŨỤƯỪỨỬỮỰỲÝỶỸỴ"
	+ "àáảãạăằắẳẵặâầấẩẫậđèéẻẽẹêềếểễệìíỉĩị"
	+ "òóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵ"
)

const DEAD_PUBLIC_INFORMATION: String = "*Chết...*"


func build_suspect_views(case_definition: CaseDefinition, runtime_state: CaseRuntimeState = null, roles: Array[RoleDefinition] = []) -> Array[SuspectPublicViewData]:
	var views: Array[SuspectPublicViewData] = []
	if case_definition == null:
		return views
	var information_service: RoleInformationEvaluationService = RoleInformationEvaluationService.new()
	var obscure_relations: Array[InvestigationObscureRelation] = _obscure_relations(case_definition)
	var definitions_by_id: Dictionary = {}
	for suspect in case_definition.suspects:
		if suspect != null:
			definitions_by_id[suspect.suspect_id] = suspect
	var sorted_ids: Array[int] = []
	for suspect_id in definitions_by_id:
		sorted_ids.append(suspect_id)
	sorted_ids.sort()
	for suspect_id in sorted_ids:
		var view_data := SuspectPublicViewData.new(suspect_id)
		var definition: SuspectDefinition = definitions_by_id[suspect_id] as SuspectDefinition
		if definition != null:
			view_data.board_slot = definition.board_slot
		var suspect_runtime: SuspectRuntimeState = runtime_state.find_suspect(suspect_id) if runtime_state != null else null
		var source_public_text: String = ""
		var latest_function_statement: String = _latest_public_function_statement(runtime_state, suspect_id)
		var displayed_information: InvestigationInformationResult = null
		if suspect_runtime != null and suspect_runtime.is_dead:
			view_data.public_status_text = "Đã chết"
		if suspect_runtime != null and suspect_runtime.is_investigated:
			view_data.is_investigated = true
			if not suspect_runtime.is_dead:
				view_data.public_status_text = "Đã điều tra"
			view_data.public_role_name = _role_display_name(roles, definition.displayed_role_id)
			view_data.public_role_group = _role_group_for_role_id(roles, definition.displayed_role_id)
			var source_information: InvestigationInformationResult = information_service.evaluate(case_definition, suspect_id, roles, {}, runtime_state)
			source_public_text = source_information.public_text() if source_information != null else ""
			var information: InvestigationInformationResult = source_information
			information = _apply_obscure_relations(information_service, information, case_definition, obscure_relations, runtime_state)
			displayed_information = information
			if information != null and information.is_obscured:
				if not information.role_identity_visible:
					view_data.public_role_obscured = true
					view_data.public_role_name = _mask_role_name(view_data.public_role_name)
				if not information.text_information_visible:
					view_data.public_information_obscured = true
					view_data.public_investigation_statement = _mask_public_information(source_public_text)
				else:
					view_data.public_investigation_statement = information.public_text()
			elif information != null and information.has_public_information():
				if not information.role_identity_visible:
					view_data.public_role_obscured = true
					view_data.public_role_name = _mask_role_name(view_data.public_role_name)
				view_data.public_investigation_statement = information.public_text()
			else:
				view_data.public_investigation_statement = definition.public_investigation_statement
			if view_data.public_role_obscured:
				view_data.public_role_group = -1
			_apply_public_function_state(view_data, suspect_runtime)
		_apply_full_truth(view_data, runtime_state)
		if view_data.full_truth_visible and definition != null:
			view_data.public_role_obscured = false
			view_data.public_information_obscured = false
			view_data.public_role_name = view_data.truth_current_role_name if not view_data.truth_current_role_name.is_empty() else _role_display_name(roles, definition.true_role_id)
			view_data.truth_role_group = _role_group_for_role_id(roles, runtime_state.current_role_id_for_suspect(case_definition, suspect_id))
			view_data.reveal_previous_statement = _previous_public_statement(latest_function_statement, source_public_text, view_data.public_investigation_statement)
			view_data.reveal_has_previous_statement = not view_data.reveal_previous_statement.is_empty()
			view_data.reveal_default_statement = _reveal_default_statement(view_data)
			view_data.public_investigation_statement = view_data.reveal_default_statement
			view_data.has_public_function = false
			view_data.is_function_available = false
			view_data.public_function_text = ""
			view_data.public_function_marker_state = ""
		if suspect_runtime != null and suspect_runtime.is_dead:
			view_data.public_information_obscured = false
			if view_data.full_truth_visible:
				if view_data.reveal_previous_statement.is_empty():
					view_data.reveal_previous_statement = _previous_public_statement(latest_function_statement, source_public_text, view_data.public_investigation_statement)
					view_data.reveal_has_previous_statement = not view_data.reveal_previous_statement.is_empty()
				view_data.reveal_default_statement = DEAD_PUBLIC_INFORMATION
				view_data.public_investigation_statement = DEAD_PUBLIC_INFORMATION
			elif view_data.is_investigated:
				view_data.public_investigation_statement = DEAD_PUBLIC_INFORMATION
		_apply_public_relation_metadata(view_data, displayed_information, case_definition, definition, runtime_state)
		views.append(view_data)
	return views


func _apply_public_relation_metadata(
	view_data: SuspectPublicViewData,
	information: InvestigationInformationResult,
	case_definition: CaseDefinition,
	source_definition: SuspectDefinition,
	runtime_state: CaseRuntimeState
) -> void:
	if view_data == null:
		return
	view_data.public_relation_suspect_ids = PackedInt32Array()
	view_data.public_relation_board_slots = PackedInt32Array()
	view_data.public_relation_hover_enabled = false
	if (
		information != null
		and view_data.public_investigation_statement != DEAD_PUBLIC_INFORMATION
	):
		_add_public_information_relation_ids(view_data, information, case_definition, source_definition)
	if runtime_state != null:
		for record: PublicFunctionRecord in runtime_state.public_function_records:
			if record != null and record.is_locked and record.source_suspect_id == view_data.suspect_id:
				_add_relation_ids(view_data, record.target_suspect_ids)
		if view_data.full_truth_visible:
			if view_data.truth_obscure_target_suspect_id > 0:
				_add_relation_id(view_data, view_data.truth_obscure_target_suspect_id)
			for event: CaseTimedEventRuntimeState in runtime_state.timed_events:
				if (
					event != null
					and event.source_suspect_id == view_data.suspect_id
					and event.fired
					and event.kill_attempted
					and event.kill_outcome == CaseKillResult.Outcome.KILLED
					and event.target_suspect_id > 0
				):
					_add_relation_id(view_data, event.target_suspect_id)


func _add_public_information_relation_ids(
	view_data: SuspectPublicViewData,
	information: InvestigationInformationResult,
	case_definition: CaseDefinition,
	source_definition: SuspectDefinition
) -> void:
	if information == null or not information.text_information_visible or source_definition == null:
		return
	if information.payload_kind == InvestigationInformationResult.PayloadKind.WEATHER_REPORT:
		_add_relation_ids(view_data, information.weather_suspect_ids)
	elif information.payload_kind == InvestigationInformationResult.PayloadKind.NO_MEDDLER_FOUND:
		_add_relation_ids(view_data, information.weather_suspect_ids)
	elif _is_therapist_public_count(information):
		view_data.public_relation_hover_enabled = true
		if information.numeric_value > 0:
			_add_relation_ids(view_data, _orthogonal_suspect_ids(case_definition, source_definition.suspect_id))
	elif _is_reporter_public_distance(information):
		_add_relation_ids(view_data, _suspect_ids_at_manhattan_distance(case_definition, source_definition, information.numeric_value))
	elif information.payload_kind == InvestigationInformationResult.PayloadKind.BLOOD_HOUND_CLUE:
		_add_relation_ids(view_data, _blood_hound_candidate_ray_ids(case_definition, source_definition.suspect_id, information.direction_key))


func _is_therapist_public_count(information: InvestigationInformationResult) -> bool:
	return (
		information != null
		and information.payload_kind == InvestigationInformationResult.PayloadKind.NUMBER
		and information.behavior_role_id == &"therapist"
		and information.numeric_information_visible
		and information.numeric_value >= 0
	)


func _is_reporter_public_distance(information: InvestigationInformationResult) -> bool:
	return (
		information != null
		and information.payload_kind == InvestigationInformationResult.PayloadKind.NUMBER
		and information.behavior_role_id == &"reporter"
		and information.numeric_information_visible
		and information.numeric_value >= 0
	)


func _orthogonal_suspect_ids(case_definition: CaseDefinition, source_suspect_id: int) -> PackedInt32Array:
	var ids: PackedInt32Array = PackedInt32Array()
	for suspect: SuspectDefinition in CaseSpatialService.new().suspects_orthogonally_adjacent_to(case_definition, source_suspect_id):
		if suspect != null:
			ids.append(suspect.suspect_id)
	return ids


func _suspect_ids_at_manhattan_distance(case_definition: CaseDefinition, source: SuspectDefinition, distance: int) -> PackedInt32Array:
	var ids: PackedInt32Array = PackedInt32Array()
	if case_definition == null or source == null or distance < 0:
		return ids
	var spatial: CaseSpatialService = CaseSpatialService.new()
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect == null or suspect.suspect_id == source.suspect_id:
			continue
		if spatial.orthogonal_step_distance(source.board_slot, suspect.board_slot) == distance:
			ids.append(suspect.suspect_id)
	return ids


func _blood_hound_candidate_ray_ids(case_definition: CaseDefinition, source_suspect_id: int, direction: StringName) -> PackedInt32Array:
	var ids: PackedInt32Array = PackedInt32Array()
	if direction == CaseSpatialService.BLOOD_HOUND_BARK or direction == CaseSpatialService.BLOOD_HOUND_SNIFF or direction == &"":
		return ids
	for suspect: SuspectDefinition in CaseSpatialService.new().suspects_in_cardinal_direction(case_definition, source_suspect_id, direction):
		if suspect != null:
			ids.append(suspect.suspect_id)
	return ids


func _add_relation_ids(view_data: SuspectPublicViewData, suspect_ids: PackedInt32Array) -> void:
	for suspect_id: int in suspect_ids:
		_add_relation_id(view_data, suspect_id)


func _add_relation_id(view_data: SuspectPublicViewData, suspect_id: int) -> void:
	if view_data == null or suspect_id <= 0 or suspect_id == view_data.suspect_id:
		return
	if suspect_id in view_data.public_relation_suspect_ids:
		return
	view_data.public_relation_suspect_ids.append(suspect_id)


func _previous_public_statement(latest_function_statement: String, source_public_text: String, public_investigation_statement: String) -> String:
	var candidates: PackedStringArray = PackedStringArray([
		latest_function_statement,
		source_public_text,
		public_investigation_statement,
	])
	for candidate: String in candidates:
		if not candidate.strip_edges().is_empty():
			return candidate
	return ""


func _latest_public_function_statement(runtime_state: CaseRuntimeState, suspect_id: int) -> String:
	if runtime_state == null:
		return ""
	var latest_record: PublicFunctionRecord = null
	for record in runtime_state.public_function_records:
		if record == null or not record.is_locked or record.source_suspect_id != suspect_id:
			continue
		if latest_record == null or record.record_id > latest_record.record_id:
			latest_record = record
	if latest_record == null:
		return ""
	return _public_function_card_statement(latest_record)


func _public_function_card_statement(record: PublicFunctionRecord) -> String:
	if record == null:
		return ""
	if record.target_suspect_ids.size() == 2:
		return "%d và %d %s." % [
			record.target_suspect_ids[0],
			record.target_suspect_ids[1],
			record.public_result_text.to_lower(),
		]
	if record.target_suspect_ids.size() == 1:
		return record.summary_text()
	return record.public_result_text


func _obscure_relations(case_definition: CaseDefinition) -> Array[InvestigationObscureRelation]:
	var relations: Array[InvestigationObscureRelation] = []
	if case_definition == null:
		return relations
	for suspect in case_definition.suspects:
		if suspect == null or suspect.obscure_target_suspect_id <= 0:
			continue
		var relation: InvestigationObscureRelation = InvestigationObscureRelation.new()
		if relation.configure(suspect.suspect_id, suspect.obscure_target_suspect_id):
			relations.append(relation)
	return relations


func _apply_obscure_relations(
	information_service: RoleInformationEvaluationService,
	information: InvestigationInformationResult,
	case_definition: CaseDefinition,
	relations: Array[InvestigationObscureRelation],
	runtime_state: CaseRuntimeState = null
) -> InvestigationInformationResult:
	var result: InvestigationInformationResult = information
	for relation in relations:
		result = information_service.apply_obscure_relation(result, case_definition, relation, runtime_state)
	return result


func _apply_public_function_state(view_data: SuspectPublicViewData, suspect_runtime: SuspectRuntimeState) -> void:
	var runtime_function: InteractiveFunctionRuntimeState = suspect_runtime.interactive_function
	if runtime_function == null or runtime_function.state == InteractiveFunctionRuntimeState.State.HIDDEN:
		return
	view_data.has_public_function = true
	if runtime_function.state == InteractiveFunctionRuntimeState.State.AVAILABLE:
		view_data.is_function_available = true
		view_data.public_function_marker_state = "available"
	elif runtime_function.state == InteractiveFunctionRuntimeState.State.EXHAUSTED:
		view_data.public_function_marker_state = "consumed"


func _role_display_name(roles: Array[RoleDefinition], role_id: StringName) -> String:
	for role in roles:
		if role != null and role.role_id == role_id:
			return role.display_name
	return "Vai chưa xác định"


func _role_group_for_role_id(roles: Array[RoleDefinition], role_id: StringName) -> int:
	for role in roles:
		if role != null and role.role_id == role_id:
			return role.role_group
	return -1


func _reveal_default_statement(view_data: SuspectPublicViewData) -> String:
	if view_data == null:
		return ""
	if view_data.truth_obscure_target_suspect_id > 0:
		var obscure_line: String = "Che giấu Nghi phạm %d." % view_data.truth_obscure_target_suspect_id
		if not view_data.truth_impersonated_role_name.is_empty():
			return "Ta giả danh %s.\n%s" % [view_data.truth_impersonated_role_name, obscure_line]
		return obscure_line
	if not view_data.truth_impersonated_role_name.is_empty():
		return "Ta giả danh %s." % view_data.truth_impersonated_role_name
	if view_data.truth_relation_notes.size() > 0:
		return "\n".join(view_data.truth_relation_notes)
	return ""


func _mask_role_name(value: String) -> String:
	return "?????" if not value.is_empty() else ""


func _mask_public_information(value: String) -> String:
	var masked: String = ""
	for index: int in range(value.length()):
		var character: String = value.substr(index, 1)
		masked += "■" if _is_unicode_letter(character) else character
	return masked


func _is_unicode_letter(character: String) -> bool:
	if character.length() != 1:
		return false
	var codepoint: int = character.unicode_at(0)
	return (
		(codepoint >= 65 and codepoint <= 90)
		or (codepoint >= 97 and codepoint <= 122)
		or VIETNAMESE_LETTERS.contains(character)
	)


func _apply_full_truth(view_data: SuspectPublicViewData, runtime_state: CaseRuntimeState) -> void:
	if view_data == null or runtime_state == null or runtime_state.truth_reveal == null:
		return
	for truth in runtime_state.truth_reveal.suspect_truths:
		if truth != null and truth.suspect_id == view_data.suspect_id:
			view_data.full_truth_visible = true
			view_data.truth_original_true_role_name = truth.original_true_role_name
			view_data.truth_current_role_name = truth.current_role_name
			view_data.truth_true_role_name = truth.true_role_name
			view_data.truth_alignment_label = truth.alignment_label
			view_data.truth_impersonated_role_name = truth.impersonated_role_name
			view_data.truth_is_corrupted = truth.is_corrupted
			view_data.truth_obscure_target_suspect_id = truth.obscure_target_suspect_id
			view_data.truth_note = truth.truth_note
			view_data.truth_relation_notes = truth.relation_notes.duplicate()
			return
