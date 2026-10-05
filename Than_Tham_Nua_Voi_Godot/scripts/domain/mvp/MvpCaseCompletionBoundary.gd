class_name MvpCaseCompletionBoundary
extends RefCounted

var case_id: StringName
var completion_reason: StringName
var runtime_state: CaseRuntimeState
var settlement_result: CaseSettlementResult


func is_valid() -> bool:
	return (
		not case_id.is_empty()
		and not completion_reason.is_empty()
		and runtime_state != null
		and settlement_result != null
		and settlement_result.success
	)
