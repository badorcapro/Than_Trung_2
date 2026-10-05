class_name PrototypeBSession
extends RefCounted

const PROTOTYPE_B_SUMMARY := preload("res://scripts/domain/prototype_b/PrototypeBSummary.gd")

enum Status { IN_PROGRESS, READY_FOR_SUMMARY, PROTOTYPE_B_SUMMARY, PROTOTYPE_B_COMPLETE }
var status := Status.IN_PROGRESS
var session_id: StringName
var round_id: StringName
var players: Array[PlayerPhaseState] = []
var characters_by_id: Dictionary = {}
var movement_session: LootMovementSession
var reward_session: LootRewardSession
var management_session: EquipmentManagementSession
var summary: PROTOTYPE_B_SUMMARY
var export_path := ""


func status_name() -> StringName:
	match status:
		Status.READY_FOR_SUMMARY:
			return &"READY_FOR_SUMMARY"
		Status.PROTOTYPE_B_SUMMARY:
			return &"PROTOTYPE_B_SUMMARY"
		Status.PROTOTYPE_B_COMPLETE:
			return &"PROTOTYPE_B_COMPLETE"
		_:
			return &"IN_PROGRESS"


func is_complete() -> bool:
	return status == Status.PROTOTYPE_B_COMPLETE


func action_allowed(action_id: StringName) -> Dictionary:
	if is_complete():
		return {
			"success": false,
			"code": "PROTOTYPE_B_COMPLETE_IMMUTABLE",
			"action_id": String(action_id)
		}
	return {"success": true, "code": "OK", "action_id": String(action_id)}


func safe_snapshot() -> Dictionary:
	var player_rows: Array[Dictionary] = []
	for player: PlayerPhaseState in players:
		# Explicit legacy resumable snapshot; movement_session remains authoritative.
		player_rows.append(player.to_dict())
	return {
		"status": String(status_name()),
		"session_id": String(session_id),
		"round_id": String(round_id),
		"players": player_rows,
		"movement_session": movement_session.to_dict() if movement_session != null else {},
		"reward_session": reward_session.to_dict() if reward_session != null else {},
		"management_session": management_session.to_dict() if management_session != null else {}
	}
