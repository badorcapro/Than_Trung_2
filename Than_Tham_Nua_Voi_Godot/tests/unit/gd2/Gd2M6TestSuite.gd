class_name Gd2M6TestSuite
extends RefCounted

const PROTOTYPE_B_PLAYER_SUMMARY := preload(
	"res://scripts/domain/prototype_b/PrototypeBPlayerSummary.gd"
)
const PROTOTYPE_B_SUMMARY := preload("res://scripts/domain/prototype_b/PrototypeBSummary.gd")
const PROTOTYPE_B_SESSION := preload("res://scripts/domain/prototype_b/PrototypeBSession.gd")
const PROTOTYPE_B_VALIDATION_REPORT := preload(
	"res://scripts/domain/prototype_b/PrototypeBValidationReport.gd"
)
const PROTOTYPE_B_COMPLETION_VALIDATOR := preload(
	"res://scripts/application/prototype_b/PrototypeBCompletionValidator.gd"
)
const PROTOTYPE_B_SUMMARY_SERVICE := preload(
	"res://scripts/application/prototype_b/PrototypeBSummaryService.gd"
)
const PROTOTYPE_B_EXPORT_SERVICE := preload(
	"res://scripts/application/prototype_b/PrototypeBExportService.gd"
)
const PROTOTYPE_B_FLOW_SERVICE := preload(
	"res://scripts/application/prototype_b/PrototypeBFlowService.gd"
)

var flow: PROTOTYPE_B_FLOW_SERVICE = PROTOTYPE_B_FLOW_SERVICE.new()
var summaries: PROTOTYPE_B_SUMMARY_SERVICE = PROTOTYPE_B_SUMMARY_SERVICE.new()
var validator: PROTOTYPE_B_COMPLETION_VALIDATOR = PROTOTYPE_B_COMPLETION_VALIDATOR.new()
var exporter: PROTOTYPE_B_EXPORT_SERVICE = PROTOTYPE_B_EXPORT_SERVICE.new()


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	_add(
		rows,
		"GĐ2-M6 scene loads",
		load("res://scenes/loot/Gd2M6PrototypeBFullFlow.tscn") is PackedScene
	)
	_add(rows, "M6 summary schema is 1", PROTOTYPE_B_SUMMARY.SCHEMA_VERSION == 1)
	_add(rows, "M6 export schema is 1", PROTOTYPE_B_EXPORT_SERVICE.SCHEMA_VERSION == 1)
	_add(
		rows,
		"M6 fixture remains TEST_ONLY",
		(
			PROTOTYPE_B_SUMMARY.new().fixture_marker.contains("NOT_CANON_LOCKED")
			and PROTOTYPE_B_PLAYER_SUMMARY.new() != null
			and PROTOTYPE_B_VALIDATION_REPORT.new() != null
		)
	)
	for count: int in [1, 3, 4]:
		_test_full_flow(rows, count)
	_test_blockers(rows)
	_test_export_and_complete(rows)
	return rows


func _test_full_flow(rows: Array[Dictionary], count: int) -> void:
	var session: PROTOTYPE_B_SESSION = flow.create_test_only_session(count)
	var player_refs: Array[PlayerPhaseState] = session.players.duplicate()
	_add(rows, "%dP selection creates players" % count, session.players.size() == count)
	_add(
		rows,
		"%dP starts IN_PROGRESS" % count,
		session.status == PROTOTYPE_B_SESSION.Status.IN_PROGRESS
	)
	_add(
		rows,
		"%dP character selection preserved" % count,
		not session.players[0].character_id.is_empty()
	)
	_add(
		rows,
		"%dP fast flow reaches ready" % count,
		(
			bool(flow.complete_test_only_flow(session).get("success", false))
			and session.status == PROTOTYPE_B_SESSION.Status.READY_FOR_SUMMARY
		)
	)
	_add(
		rows,
		"%dP movement completes" % count,
		session.movement_session.completed and session.movement_session.all_exhausted()
	)
	_add(
		rows,
		"%dP reward reaches confirmation" % count,
		session.reward_session.phase == LootRewardSession.Phase.LOOT_END_CONFIRMATION_READY
	)
	_add(
		rows,
		"%dP management reaches READY_FOR_M6" % count,
		session.management_session.phase == EquipmentManagementSession.Phase.READY_FOR_M6
	)
	_add(
		rows,
		"%dP carries same player state objects" % count,
		(
			session.players[0] == player_refs[0]
			and session.reward_session.players[0] == player_refs[0]
			and session.management_session.players[0] == player_refs[0]
		)
	)
	_add(
		rows,
		"%dP resources carry through" % count,
		(
			session.players[0].silver_coin_count == 10
			and session.players[0].orb_count == 1
			and session.players[0].gacha_ticket_count == 3
		)
	)
	_add(
		rows,
		"%dP equipment and progression carry" % count,
		(
			session.players[0].equipment_collection.size() == 1
			and session.players[0].equipment_collection[0].gold_star_level == 2
			and session.players[0].equipment_collection[0].purple_star_level == 1
		)
	)
	_add(
		rows,
		"%dP enters typed summary" % count,
		bool(flow.enter_summary(session).get("success", false)) and session.summary != null
	)
	_add(rows, "%dP summary player count" % count, session.summary.player_summaries.size() == count)
	_add(
		rows,
		"%dP aggregate movement count" % count,
		int(session.summary.aggregates.get("movement_actions", -1)) == count
	)
	_add(rows, "%dP open policies reported" % count, session.summary.open_policy_ids.size() == 7)


func _test_blockers(rows: Array[Dictionary]) -> void:
	var session: PROTOTYPE_B_SESSION = flow.create_test_only_session(1)
	_add(
		rows,
		"Incomplete movement blocks summary",
		validator.validate_completion_ready(session).codes().has("MOVEMENT_UNRESOLVED")
	)
	flow.complete_test_only_flow(session)
	session.reward_session.pending_trace = [&"pending"]
	_add(
		rows,
		"Pending reward trace blocks summary",
		validator.validate_completion_ready(session).codes().has("REWARD_TRACE_PENDING")
	)
	session.reward_session.pending_trace_index = 1
	session.reward_session.overflow.active = true
	_add(
		rows,
		"Pending overflow blocks summary",
		validator.validate_completion_ready(session).codes().has("OVERFLOW_PENDING")
	)
	session.reward_session.overflow.active = false
	session.management_session.pending_choice.kind = PendingEquipmentChoice.Kind.S_EQUIPMENT
	_add(
		rows,
		"Pending Gacha choice blocks summary",
		validator.validate_completion_ready(session).codes().has("PENDING_CHOICE")
	)
	session.management_session.pending_choice = PendingEquipmentChoice.new()
	session.management_session.done_player_ids.clear()
	_add(
		rows,
		"Management done mismatch blocks summary",
		validator.validate_completion_ready(session).codes().has("MANAGEMENT_DONE_MISMATCH")
	)
	var invalid_loadout: PROTOTYPE_B_SESSION = flow.create_test_only_session(1)
	flow.complete_test_only_flow(invalid_loadout)
	invalid_loadout.players[0].relic_instance_id = &"missing_instance"
	_add(
		rows,
		"Invalid Equipment reference blocks summary",
		validator.validate_completion_ready(invalid_loadout).codes().has("PLAYER_STATE_INVALID")
	)
	var invalid_gacha: PROTOTYPE_B_SESSION = flow.create_test_only_session(1)
	flow.complete_test_only_flow(invalid_gacha)
	invalid_gacha.players[0].gacha_state.rate_up_consecutive_without_a_plus = -1
	_add(
		rows,
		"Invalid Gacha state blocks summary",
		validator.validate_completion_ready(invalid_gacha).codes().has("GACHA_STATE_INVALID")
	)


func _test_export_and_complete(rows: Array[Dictionary]) -> void:
	var session: PROTOTYPE_B_SESSION = flow.create_test_only_session(3)
	flow.complete_test_only_flow(session)
	flow.enter_summary(session)
	var summary_report: PROTOTYPE_B_VALIDATION_REPORT = validator.validate_summary(
		session, session.summary
	)
	_add(rows, "Completed state validates for summary", summary_report.passed())
	_add(
		rows,
		"Summary preserves resources",
		int(session.summary.player_summaries[0].data.get("resources", {}).get("silver", -1)) == 10
	)
	_add(
		rows,
		"Summary preserves loadout",
		(
			String(session.summary.player_summaries[0].data.get("loadout", {}).get("relic", ""))
			== "m6_relic_1"
		)
	)
	_add(
		rows,
		"Summary preserves pity",
		int(session.summary.player_summaries[1].data.get("basic_pity", -1)) == 1
	)
	_add(
		rows,
		"Summary preserves Perfect pool",
		(
			int(
				session.summary.player_summaries[0].data.get("perfect_remaining_pool", {}).get(
					"regular_exp", -1
				)
			)
			== 2
		)
	)
	var export_result: Dictionary = exporter.export_snapshot(session)
	var path := String(export_result.get("path", ""))
	_add(
		rows,
		"Export JSON succeeds",
		(
			bool(export_result.get("success", false))
			and path.begins_with("user://prototype_b_summary_")
		)
	)
	_add(
		rows,
		"Export parse and semantic validation",
		exporter.parse_and_validate(path, session).passed()
	)
	var export_data: Dictionary = exporter.build_export(session)
	_add(
		rows,
		"Export contains no Node reference",
		not JSON.stringify(export_data).contains("Object(Node")
	)
	var policies_value: Variant = export_data.get("open_policy_ids", {})
	var snapshot_value: Variant = export_data.get("resumable_state_snapshot", {})
	_add(
		rows,
		"Export preserves OPEN config ids",
		policies_value is Dictionary and policies_value.size() == 7
	)
	_add(
		rows,
		"Export preserves safe resumable snapshot",
		snapshot_value is Dictionary and snapshot_value.has("management_session")
	)
	var invalid_schema := export_data.duplicate(true)
	invalid_schema["prototype_b_summary_schema"] = 99
	_add(
		rows,
		"Invalid export schema is rejected",
		exporter.validate_export_data(invalid_schema, session).codes().has("EXPORT_SCHEMA")
	)
	var missing_snapshot := export_data.duplicate(true)
	missing_snapshot.erase("resumable_state_snapshot")
	_add(
		rows,
		"Missing export snapshot is rejected",
		exporter.validate_export_data(missing_snapshot, session).codes().has("EXPORT_SNAPSHOT")
	)
	var mismatched_summary: PROTOTYPE_B_SUMMARY = summaries.build_session_summary(session)
	mismatched_summary.player_summaries.remove_at(0)
	_add(
		rows,
		"Summary player-count mismatch rejected",
		validator.validate_summary(session, mismatched_summary).codes().has("SUMMARY_PLAYER_COUNT")
	)
	var duplicate_summary: PROTOTYPE_B_SUMMARY = summaries.build_session_summary(session)
	duplicate_summary.player_summaries[1].data["player_id"] = (
		duplicate_summary.player_summaries[0].data["player_id"]
	)
	_add(
		rows,
		"Duplicate summary player rejected",
		validator.validate_summary(session, duplicate_summary).codes().has("SUMMARY_PLAYER_ID")
	)
	var missing_aggregate: PROTOTYPE_B_SUMMARY = summaries.build_session_summary(session)
	missing_aggregate.aggregates.erase("perfect_spins")
	_add(
		rows,
		"Missing aggregate field rejected",
		validator.validate_summary(session, missing_aggregate).codes().has(
			"AGGREGATE_FIELD_MISSING"
		)
	)
	_add(
		rows,
		"Finalize enters PROTOTYPE_B_COMPLETE",
		(
			bool(summaries.finalize_prototype_b(session).get("success", false))
			and session.is_complete()
		)
	)
	for action_id: StringName in [
		&"MOVEMENT", &"REWARD", &"ITEM_USE", &"EQUIPMENT_UPGRADE", &"GACHA_ROLL", &"SELECTION_EDIT"
	]:
		var rejection: Dictionary = flow.reject_gameplay_action(session, action_id)
		_add(
			rows,
			"Complete rejects %s" % action_id,
			(
				not bool(rejection.get("success", true))
				and String(rejection.get("code", "")) == "PROTOTYPE_B_COMPLETE_IMMUTABLE"
			)
		)
	_add(
		rows,
		"Summary remains viewable after complete",
		session.summary != null and session.summary.completion_status == &"PROTOTYPE_B_COMPLETE"
	)


func _add(rows: Array[Dictionary], name: String, passed: bool) -> void:
	rows.append(
		{"name": name, "passed": passed, "detail": "GĐ2-M6 Prototype B Summary/Export invariant"}
	)
