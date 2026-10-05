class_name LootRewardSession
extends RefCounted

enum Phase { ITEM_WINDOW, MOVEMENT, REWARD_RESOLUTION, BAG_OVERFLOW_PENDING, LOOT_END_CONFIRMATION_READY }

var schema_version := 1
var phase := Phase.ITEM_WINDOW
var round_id: StringName
var map_id: StringName
var movement_session: LootMovementSession
var players: Array[PlayerPhaseState] = []
# Compatibility projection retained for prototype readers. RoundLootInventoryState
# is the runtime authority for bag capacity and carried map loot.
var bag_capacity_by_player: Dictionary = {}
var round_loot_states: Array[RoundLootInventoryState] = []
var reward_snapshots: Array[RewardNodeSnapshot] = []
var consumed_special_node_ids: Array[StringName] = []
var reward_history: Array[RewardResolutionResult] = []
var pending_trace: Array[StringName] = []
var pending_trace_index := 0
var overflow: BagOverflowState = BagOverflowState.new()
var item_used_this_turn := false

func find_player(player_id: StringName) -> PlayerPhaseState:
	for player: PlayerPhaseState in players:
		if player.player_id == player_id: return player
	return null

func find_round_loot_state(player_id: StringName) -> RoundLootInventoryState:
	for state: RoundLootInventoryState in round_loot_states:
		if state.player_id == player_id:
			return state
	return null

func ensure_round_loot_state(
	player_id: StringName, capacity: int = 0
) -> RoundLootInventoryState:
	var existing: RoundLootInventoryState = find_round_loot_state(player_id)
	if existing != null:
		return existing
	var state := RoundLootInventoryState.new()
	state.player_id = player_id
	state.capacity = capacity
	round_loot_states.append(state)
	return state

func find_snapshot(node_id: StringName) -> RewardNodeSnapshot:
	for snapshot: RewardNodeSnapshot in reward_snapshots:
		if snapshot.node_id == node_id: return snapshot
	return null

func to_dict() -> Dictionary:
	var player_rows: Array[Dictionary] = []
	for player: PlayerPhaseState in players:
		player_rows.append(player.to_persistent_dict())
	var snapshot_rows: Array[Dictionary] = []
	for snapshot: RewardNodeSnapshot in reward_snapshots:
		snapshot_rows.append(snapshot.to_dict())
	var history_rows: Array[Dictionary] = []
	for result: RewardResolutionResult in reward_history:
		history_rows.append(result.to_dict())
	var round_loot_rows: Array[Dictionary] = []
	for state: RoundLootInventoryState in round_loot_states:
		round_loot_rows.append(state.to_dict())
	var trace: Array[String] = []
	for node_id: StringName in pending_trace:
		trace.append(String(node_id))
	var consumed: Array[String] = []
	for node_id: StringName in consumed_special_node_ids:
		consumed.append(String(node_id))
	var normalized_capacities: Dictionary = {}
	for player_id_value: Variant in bag_capacity_by_player.keys():
		var capacity_value: Variant = bag_capacity_by_player.get(player_id_value, 0)
		normalized_capacities[String(player_id_value)] = int(capacity_value)
	return {"schema_version":schema_version, "phase":phase, "round_id":String(round_id), "map_id":String(map_id), "movement_session":movement_session.to_dict() if movement_session != null else {}, "players":player_rows, "bag_capacity_by_player":normalized_capacities, "round_loot_states":round_loot_rows, "reward_snapshots":snapshot_rows, "consumed_special_node_ids":consumed, "reward_history":history_rows, "pending_trace":trace, "pending_trace_index":pending_trace_index, "overflow":overflow.to_dict(), "item_used_this_turn":item_used_this_turn}

static func from_dict(data: Dictionary) -> LootRewardSession:
	var session := LootRewardSession.new()
	session.schema_version = int(data.get("schema_version", 1))
	session.phase = int(data.get("phase", 0))
	session.round_id = StringName(data.get("round_id", ""))
	session.map_id = StringName(data.get("map_id", ""))
	session.pending_trace_index = int(data.get("pending_trace_index", 0))
	session.item_used_this_turn = bool(data.get("item_used_this_turn", false))
	var movement_value: Variant = data.get("movement_session", {})
	if movement_value is Dictionary and not movement_value.is_empty():
		session.movement_session = LootMovementSession.from_dict(movement_value)
	var players_value: Variant = data.get("players", [])
	if players_value is Array:
		for value: Variant in players_value:
			if value is Dictionary:
				session.players.append(PlayerPhaseState.from_persistent_dict(value))
	var capacities_value: Variant = data.get("bag_capacity_by_player", {})
	if capacities_value is Dictionary:
		for player_id_value: Variant in capacities_value.keys():
			var capacity_value: Variant = capacities_value.get(player_id_value, 0)
			session.bag_capacity_by_player[String(player_id_value)] = int(capacity_value)
	var round_loot_value: Variant = data.get("round_loot_states", [])
	if round_loot_value is Array:
		for value: Variant in round_loot_value:
			if value is Dictionary:
				session.round_loot_states.append(RoundLootInventoryState.from_dict(value))
	# Older prototype snapshots had only the capacity projection. They restore an
	# empty round bag because persistent inventory cannot identify map-loot origin.
	if session.round_loot_states.is_empty():
		for player_id_value: Variant in session.bag_capacity_by_player.keys():
			session.ensure_round_loot_state(
				StringName(player_id_value),
				int(session.bag_capacity_by_player.get(player_id_value, 0))
			)
	var snapshots_value: Variant = data.get("reward_snapshots", [])
	if snapshots_value is Array:
		for value: Variant in snapshots_value:
			if value is Dictionary:
				session.reward_snapshots.append(RewardNodeSnapshot.from_dict(value))
	var consumed_value: Variant = data.get("consumed_special_node_ids", [])
	if consumed_value is Array:
		for value: Variant in consumed_value:
			session.consumed_special_node_ids.append(StringName(value))
	var history_value: Variant = data.get("reward_history", [])
	if history_value is Array:
		for value: Variant in history_value:
			if value is Dictionary:
				session.reward_history.append(RewardResolutionResult.from_dict(value))
	var trace_value: Variant = data.get("pending_trace", [])
	if trace_value is Array:
		for value: Variant in trace_value:
			session.pending_trace.append(StringName(value))
	var overflow_value: Variant = data.get("overflow", {})
	if overflow_value is Dictionary:
		session.overflow = BagOverflowState.from_dict(overflow_value)
	return session

func semantically_equals(other: LootRewardSession) -> bool:
	return other != null and to_dict() == other.to_dict()
