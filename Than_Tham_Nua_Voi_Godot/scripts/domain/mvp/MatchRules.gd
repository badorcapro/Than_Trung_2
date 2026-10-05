class_name MatchRules
extends RefCounted

const COURT_RANK_SERVICE := preload(
	"res://scripts/domain/progression/CourtRankService.gd"
)

enum Mode {
	CLASSIC,
	CUSTOM,
}

enum VictoryType {
	REACH_COURT_RANK,
	FIXED_ROUNDS,
}

const CLASSIC_TARGET_COURT_RANK: StringName = &"RANK_1"
const ROUND_LIMIT_OPTIONS: Array[int] = [1, 3, 5, 10]

var mode: int = Mode.CLASSIC
var victory_type: int = VictoryType.REACH_COURT_RANK
var target_court_rank: StringName = CLASSIC_TARGET_COURT_RANK
var round_limit: int = 0


static func classic() -> MatchRules:
	return MatchRules.new()


static func custom_reach_court_rank(rank_id: StringName) -> MatchRules:
	var rules := MatchRules.new()
	rules.mode = Mode.CUSTOM
	rules.victory_type = VictoryType.REACH_COURT_RANK
	rules.target_court_rank = rank_id
	rules.round_limit = 0
	return rules


static func custom_fixed_rounds(rounds: int) -> MatchRules:
	var rules := MatchRules.new()
	rules.mode = Mode.CUSTOM
	rules.victory_type = VictoryType.FIXED_ROUNDS
	rules.target_court_rank = &""
	rules.round_limit = rounds
	return rules


func validation_error() -> StringName:
	if mode == Mode.CLASSIC:
		if (
			victory_type != VictoryType.REACH_COURT_RANK
			or target_court_rank != CLASSIC_TARGET_COURT_RANK
			or round_limit != 0
		):
			return &"CLASSIC_RULES_INVALID"
		return &""
	if mode != Mode.CUSTOM:
		return &"MATCH_MODE_INVALID"
	if victory_type == VictoryType.REACH_COURT_RANK:
		if not COURT_RANK_SERVICE.is_valid_rank_id(target_court_rank) or round_limit != 0:
			return &"CUSTOM_RANK_RULES_INVALID"
		return &""
	if victory_type == VictoryType.FIXED_ROUNDS:
		if not target_court_rank.is_empty() or round_limit not in ROUND_LIMIT_OPTIONS:
			return &"CUSTOM_ROUND_RULES_INVALID"
		return &""
	return &"VICTORY_TYPE_INVALID"


func is_valid() -> bool:
	return validation_error().is_empty()


func to_dict() -> Dictionary:
	return {
		"mode": mode,
		"victory_type": victory_type,
		"target_court_rank": String(target_court_rank),
		"round_limit": round_limit,
	}


static func from_dict(data: Dictionary) -> MatchRules:
	var rules := MatchRules.new()
	rules.mode = int(data.get("mode", Mode.CLASSIC))
	rules.victory_type = int(
		data.get("victory_type", VictoryType.REACH_COURT_RANK)
	)
	rules.target_court_rank = StringName(
		data.get("target_court_rank", String(CLASSIC_TARGET_COURT_RANK))
	)
	rules.round_limit = int(data.get("round_limit", 0))
	return rules
