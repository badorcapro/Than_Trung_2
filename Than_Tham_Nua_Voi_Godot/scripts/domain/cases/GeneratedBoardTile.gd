class_name GeneratedBoardTile
extends RefCounted

var board_slot: int = -1
var tile_kind: StringName = &""
var location_id: StringName = &""
var suspect_id: int = 0


static func location(slot: int, source_location_id: StringName) -> GeneratedBoardTile:
	var tile := GeneratedBoardTile.new()
	tile.board_slot = slot
	tile.tile_kind = &"location"
	tile.location_id = source_location_id
	return tile


static func suspect(slot: int, source_suspect_id: int) -> GeneratedBoardTile:
	var tile := GeneratedBoardTile.new()
	tile.board_slot = slot
	tile.tile_kind = &"suspect"
	tile.suspect_id = source_suspect_id
	return tile


static func empty(slot: int) -> GeneratedBoardTile:
	var tile := GeneratedBoardTile.new()
	tile.board_slot = slot
	tile.tile_kind = &"empty"
	return tile


func fingerprint_text() -> String:
	return "%d:%s:%s:%d" % [
		board_slot,
		String(tile_kind),
		String(location_id),
		suspect_id,
	]
