class_name SuspectTruthReveal
extends RefCounted

var suspect_id := 0
var displayed_role_name := ""
var original_true_role_name := ""
var current_role_id: StringName = &""
var current_role_name := ""
var true_role_name := ""
var impersonated_role_name := ""
var alignment_label := ""
var role_group_label := ""
var is_impersonating := false
var is_corrupted := false
var obscure_target_suspect_id := 0
var truth_note := ""
var relation_notes: PackedStringArray = PackedStringArray()
