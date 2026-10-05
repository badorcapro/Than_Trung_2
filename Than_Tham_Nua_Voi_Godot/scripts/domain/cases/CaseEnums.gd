class_name CaseEnums
extends RefCounted

enum Alignment {
	GOOD,
	EVIL,
}

enum RoleGroup {
	CHINH_NHAN,
	HIEU_SU,
	TONG_PHAM,
	NGHICH_THAN,
}

enum SubmissionStatus {
	NOT_SUBMITTED,
	SUBMITTED_CORRECT,
	SUBMITTED_WRONG,
	NOT_SUBMITTED_CASE_ENDED,
	FINAL_LOCKED_PENDING,
}

enum SubmissionPhase { EARLY, FINAL }

enum PlayerResolutionOutcome {
	CORRECT_EARLY,
	WRONG_EARLY,
	CORRECT_FINAL,
	WRONG_FINAL,
	NOT_SUBMITTED_CASE_ENDED,
}

enum CaseOutcome {
	IN_PROGRESS,
	EARLY_SOLVED,
	ALL_FAILED_EARLY,
	POST_REVEAL_FUNCTIONS,
	AWAITING_FINAL_VERDICT,
	FINAL_VERDICT_RESOLVED,
}

enum FunctionType {
	NONE,
	TAILOR_COMPARE_ALIGNMENT,
	VIGILANTE_KILL,
}

enum UnlockTiming {
	NONE,
	NEXT_TURN_AFTER_INVESTIGATION,
}

enum InformationResultType {
	NONE,
	SAME_OR_DIFFERENT_ALIGNMENT,
}


static func is_valid_alignment(value: int) -> bool:
	return value in Alignment.values()


static func is_valid_role_group(value: int) -> bool:
	return value in RoleGroup.values()


static func is_valid_submission_status(value: int) -> bool:
	return value in SubmissionStatus.values()
