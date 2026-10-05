class_name SuspectPublicViewData
extends RefCounted

var suspect_id: int
var board_slot := 0
var is_investigated: bool
var public_display_name: String
var public_role_name: String
var public_role_group := -1
var public_investigation_statement: String
var public_role_obscured := false
var public_information_obscured := false
var public_status_text: String
var has_public_function: bool
var is_function_available: bool
var public_function_text: String
var public_function_marker_state := ""
var full_truth_visible := false
var truth_original_true_role_name := ""
var truth_current_role_name := ""
var truth_true_role_name := ""
var truth_alignment_label := ""
var truth_role_group := -1
var truth_impersonated_role_name := ""
var truth_is_corrupted := false
var truth_obscure_target_suspect_id := 0
var truth_note := ""
var truth_relation_notes: PackedStringArray = PackedStringArray()
var reveal_default_statement := ""
var reveal_previous_statement := ""
var reveal_has_previous_statement := false
var public_relation_suspect_ids: PackedInt32Array = PackedInt32Array()
var public_relation_board_slots: PackedInt32Array = PackedInt32Array()
var public_relation_hover_enabled := false


func _init(source_suspect_id: int = 0) -> void:
	suspect_id = source_suspect_id
	is_investigated = false
	public_display_name = "Nghi phạm %d" % suspect_id
	public_role_name = ""
	public_role_group = -1
	public_investigation_statement = ""
	public_role_obscured = false
	public_information_obscured = false
	public_status_text = "Chưa điều tra"
	has_public_function = false
	is_function_available = false
	public_function_text = ""
	public_function_marker_state = ""


func visible_property_names() -> PackedStringArray:
	return PackedStringArray([
		"suspect_id",
		"board_slot",
		"is_investigated",
		"public_display_name",
		"public_role_name",
		"public_role_group",
		"public_investigation_statement",
		"public_role_obscured",
		"public_information_obscured",
		"public_status_text",
		"has_public_function",
		"is_function_available",
		"public_function_text",
		"public_function_marker_state",
		"public_relation_suspect_ids",
		"public_relation_board_slots",
		"public_relation_hover_enabled",
	])
