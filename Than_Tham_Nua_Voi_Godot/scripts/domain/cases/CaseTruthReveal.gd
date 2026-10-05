class_name CaseTruthReveal
extends RefCounted

var case_id: StringName
var evil_suspect_ids := PackedInt32Array()
var suspect_truths: Array[SuspectTruthReveal] = []
var player_resolutions: Array[PlayerCaseResolution] = []
var public_function_records: Array[PublicFunctionRecord] = []
