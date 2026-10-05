class_name MatchFinalStanding
extends RefCounted

var player_id: StringName
var display_name: String = ""
var court_rank_id: StringName
var court_rank_name: String = ""
var merit: float = 0.0
var place: int = 0


func to_dict() -> Dictionary:
	return {
		"player_id": String(player_id),
		"display_name": display_name,
		"court_rank_id": String(court_rank_id),
		"court_rank_name": court_rank_name,
		"merit": merit,
		"place": place,
	}


static func from_dict(data: Dictionary) -> MatchFinalStanding:
	var result := MatchFinalStanding.new()
	result.player_id = StringName(data.get("player_id", ""))
	result.display_name = String(data.get("display_name", ""))
	result.court_rank_id = StringName(data.get("court_rank_id", ""))
	result.court_rank_name = String(data.get("court_rank_name", ""))
	result.merit = float(data.get("merit", 0.0))
	result.place = int(data.get("place", 0))
	return result
