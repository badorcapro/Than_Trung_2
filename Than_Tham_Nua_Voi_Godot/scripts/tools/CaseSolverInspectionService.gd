extends RefCounted

const PUBLIC_VIEW := preload("res://scripts/domain/cases/GeneratedPublicCaseView.gd")
const PUBLIC_SUSPECT := preload("res://scripts/domain/cases/GeneratedPublicSuspectView.gd")
const PUBLIC_CLUE := preload("res://scripts/domain/cases/GeneratedPublicClue.gd")
const PUBLIC_SOLVER := preload("res://scripts/domain/cases/CaseGeneratorPublicSolver.gd")
const SOLVER_RESULT := preload("res://scripts/domain/cases/CaseGeneratorSolverResult.gd")


func inspect(case_definition: CaseDefinition, runtime_state: CaseRuntimeState, roles: Array[RoleDefinition]) -> Dictionary:
	var report: Dictionary = {"status": &"unsupported", "lines": PackedStringArray(), "steps": []}
	var lines: PackedStringArray = PackedStringArray()
	var steps: Array = []
	if case_definition == null or runtime_state == null:
		lines.append("Không có Kỳ Án hiện hành để kiểm tra.")
		return _unsupported_report(report, lines)
	lines.append("Kỳ Án: %s" % String(case_definition.case_id))
	if case_definition.has_meta(&"generator_seed"):
		lines.append("Seed tạo Kỳ Án: %s" % str(case_definition.get_meta(&"generator_seed")))
	lines.append("Nguồn: vai và lời khai đã công bố; không đưa đáp án ẩn vào solver.")
	var suspects: Array = []
	var evil_count: int = 0
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect == null:
			continue
		if suspect.obscure_target_suspect_id > 0:
			lines.append("Chưa hỗ trợ: Kỳ Án có thông tin bị che; không dùng lời khai chưa công bố.")
			return _unsupported_report(report, lines)
		if suspect.role_group in [CaseEnums.RoleGroup.TONG_PHAM, CaseEnums.RoleGroup.NGHICH_THAN]:
			evil_count += 1
		var state: SuspectRuntimeState = runtime_state.find_suspect(suspect.suspect_id)
		if state == null or not state.is_investigated:
			lines.append("Chưa hỗ trợ: Số Hiệu %d chưa được điều tra; thiếu vai công khai." % suspect.suspect_id)
			return _unsupported_report(report, lines)
		var group: int = _role_group(roles, suspect.displayed_role_id)
		if group < 0:
			lines.append("Chưa hỗ trợ: thiếu định nghĩa vai công khai của Số Hiệu %d." % suspect.suspect_id)
			return _unsupported_report(report, lines)
		suspects.append(PUBLIC_SUSPECT.create(suspect.suspect_id, suspect.board_slot, suspect.displayed_role_id, group))
	var columns: int = int(case_definition.get_meta(&"board_columns", 3))
	var slot_count: int = int(case_definition.get_meta(&"board_slot_count", 9))
	if columns <= 0 or slot_count % columns != 0:
		lines.append("Chưa hỗ trợ: kích thước bàn cờ không hợp lệ.")
		return _unsupported_report(report, lines)
	var view = PUBLIC_VIEW.create_manual(columns, int(slot_count / columns), evil_count, suspects)
	view.allowed_role_ids = CaseRolePoolService.suspected_role_ids_for_case(case_definition)
	lines.append("Tỷ lệ công khai: %d Phe Ác / %d nghi phạm." % [evil_count, suspects.size()])
	var solver = PUBLIC_SOLVER.new()
	var previous = solver.solve(view, roles)
	var initial_sets: Array = previous.candidate_evil_sets.duplicate()
	if previous.unsupported:
		lines.append(previous.error_message)
		return _unsupported_report(report, lines)
	var evaluator := RoleInformationEvaluationService.new()
	for suspect: SuspectDefinition in case_definition.suspects:
		if suspect == null:
			continue
		var state: SuspectRuntimeState = runtime_state.find_suspect(suspect.suspect_id)
		if state == null or state.is_dead:
			continue
		var information: InvestigationInformationResult = evaluator.evaluate(case_definition, suspect.suspect_id, roles, {}, runtime_state)
		if information == null or not information.has_public_information():
			continue
		if information.is_obscured or not information.text_information_visible or not information.role_identity_visible:
			lines.append("Chưa hỗ trợ: lời khai bị che của Số Hiệu %d." % suspect.suspect_id)
			return _unsupported_report(report, lines)
		var clue = PUBLIC_CLUE.from_information_result(information)
		view.public_clues.append(PUBLIC_VIEW._duplicate_public_clue(clue))
		var current = solver.solve(view, roles)
		if current.unsupported:
			lines.append("Lời khai #%d chưa được solver hỗ trợ: %s" % [suspect.suspect_id, current.error_message])
			previous = current
			break
		var removed: PackedStringArray = _removed_sets(previous.candidate_evil_sets, current.candidate_evil_sets)
		var reasons: PackedStringArray = PackedStringArray()
		for candidate_ids: PackedInt32Array in previous.candidate_evil_sets:
			if removed.has(_set_text(candidate_ids)):
				reasons.append(_contradiction_reason(clue, candidate_ids, view))
		var step: Dictionary = {
			"suspect_id": suspect.suspect_id,
			"displayed_role": _role_name(roles, suspect.displayed_role_id),
			"clue": clue.text,
			"before_sets": _set_list(previous.candidate_evil_sets),
			"remaining_sets": _set_list(current.candidate_evil_sets),
			"removed": removed,
			"reasons": reasons,
		}
		steps.append(step)
		previous = current
	report["status"] = previous.status
	var readable: PackedStringArray = PackedStringArray()
	readable.append_array(lines)
	readable.append("")
	readable.append("KẾT LUẬN")
	readable.append("%s (%s)" % [_status_label(previous.status), String(previous.status)])
	readable.append("")
	readable.append("CÁC GIẢ THUYẾT PHE ÁC BAN ĐẦU")
	readable.append(_set_list(initial_sets))
	readable.append("")
	readable.append("KIỂM TRA TỪNG LỜI KHAI")
	for step: Dictionary in steps:
		readable.append("#%d — %s" % [int(step["suspect_id"]), String(step["displayed_role"])])
		readable.append("Lời khai: %s" % String(step["clue"]))
		readable.append("Trước lời khai: %s" % String(step["before_sets"]))
		var removed_sets: PackedStringArray = step["removed"]
		var reasons: PackedStringArray = step["reasons"]
		if removed_sets.is_empty():
			readable.append("Không loại thêm giả thuyết nào.")
		else:
			for index: int in range(removed_sets.size()):
				readable.append("Loại %s: %s" % [removed_sets[index], reasons[index]])
		readable.append("Còn lại: %s" % String(step["remaining_sets"]))
		readable.append("")
	readable.append("KẾT LUẬN CUỐI")
	if previous.status == SOLVER_RESULT.STATUS_UNIQUE_SOLUTION:
		readable.append("Chỉ còn %s thỏa tất cả lời khai công khai; solver xác định đây là bộ Phe Ác." % _set_list(previous.candidate_evil_sets))
	elif previous.status == SOLVER_RESULT.STATUS_MULTIPLE_SOLUTIONS:
		readable.append("Còn %d bộ phù hợp (%s); chưa thể xác định duy nhất." % [previous.candidate_count, _set_list(previous.candidate_evil_sets)])
	elif previous.status == SOLVER_RESULT.STATUS_NO_SOLUTION:
		readable.append("Không có bộ Phe Ác nào phù hợp với toàn bộ dữ kiện công khai.")
	else:
		readable.append("Solver chưa hỗ trợ một phần dữ kiện của Kỳ Án này.")
	report["lines"] = readable
	report["steps"] = steps
	return report


func _unsupported_report(report: Dictionary, context: PackedStringArray) -> Dictionary:
	var lines: PackedStringArray = PackedStringArray(["KẾT LUẬN", "Chưa được solver hỗ trợ (unsupported)", ""])
	lines.append_array(context)
	report["lines"] = lines
	return report


func _role_group(roles: Array[RoleDefinition], role_id: StringName) -> int:
	for role: RoleDefinition in roles:
		if role != null and role.role_id == role_id:
			return role.role_group
	return -1


func _role_name(roles: Array[RoleDefinition], role_id: StringName) -> String:
	for role: RoleDefinition in roles:
		if role != null and role.role_id == role_id:
			return role.display_name
	return String(role_id)


func _status_label(status: StringName) -> String:
	if status == SOLVER_RESULT.STATUS_UNIQUE_SOLUTION:
		return "Một đáp án duy nhất"
	if status == SOLVER_RESULT.STATUS_MULTIPLE_SOLUTIONS:
		return "Nhiều đáp án còn khả thi"
	if status == SOLVER_RESULT.STATUS_NO_SOLUTION:
		return "Không có đáp án phù hợp"
	return "Chưa được solver hỗ trợ"


func _contradiction_reason(clue, candidate_ids: PackedInt32Array, public_view) -> String:
	if not candidate_ids.has(clue.suspect_id) and clue.numeric_value >= 0:
		if clue.behavior_role_id == &"mathematician":
			var sum_ids: int = 0
			for id: int in candidate_ids:
				sum_ids += id
			if sum_ids != clue.numeric_value:
				return "Nếu bộ này là Phe Ác thì tổng Số Hiệu sẽ là %d, không phải %d." % [sum_ids, clue.numeric_value]
		if clue.behavior_role_id == &"therapist" or clue.behavior_role_id == &"reporter":
			var source_slot: int = _public_slot(public_view, clue.suspect_id)
			var observed: int = 0 if clue.behavior_role_id == &"therapist" else -1
			for id: int in candidate_ids:
				var distance: int = _slot_distance(source_slot, _public_slot(public_view, id), public_view.board_columns)
				if clue.behavior_role_id == &"therapist" and distance == 1:
					observed += 1
				elif clue.behavior_role_id == &"reporter" and distance >= 0 and (observed < 0 or distance < observed):
					observed = distance
			if source_slot >= 0 and observed >= 0 and observed != clue.numeric_value:
				if clue.behavior_role_id == &"therapist":
					return "Bốn ô kề theo lưới sẽ có %d nghi phạm Ác, không phải %d." % [observed, clue.numeric_value]
				return "Phe Ác gần nhất cách %d bước trên lưới, không phải %d." % [observed, clue.numeric_value]
	return "Sau khi thêm lời khai này, solver không tìm được cách gán vai/giả danh hợp lệ nào cho bộ Phe Ác đó."


func _public_slot(public_view, suspect_id: int) -> int:
	for suspect in public_view.suspects:
		if suspect != null and suspect.suspect_id == suspect_id:
			return suspect.board_slot
	return -1


func _slot_distance(first: int, second: int, columns: int) -> int:
	if first < 0 or second < 0 or columns <= 0:
		return -1
	return absi(int(first / columns) - int(second / columns)) + absi(first % columns - second % columns)


func _removed_sets(before: Array, after: Array) -> PackedStringArray:
	var retained: Dictionary = {}
	for ids: PackedInt32Array in after:
		retained[_set_text(ids)] = true
	var removed: PackedStringArray = PackedStringArray()
	for ids: PackedInt32Array in before:
		var label: String = _set_text(ids)
		if not retained.has(label):
			removed.append(label)
	return removed


func _set_list(sets: Array) -> String:
	var labels: PackedStringArray = PackedStringArray()
	for ids: PackedInt32Array in sets:
		labels.append(_set_text(ids))
	return "; ".join(labels) if not labels.is_empty() else "không có"


func _set_text(ids: PackedInt32Array) -> String:
	var values: PackedStringArray = PackedStringArray()
	for suspect_id: int in ids:
		values.append("#%d" % suspect_id)
	return "{" + ", ".join(values) + "}"
