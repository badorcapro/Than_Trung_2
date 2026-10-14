class_name AuctionSession
extends RefCounted

const CHEST_STATE_CLASS := preload("res://scripts/domain/loot/MysteryChestState.gd")
const ITEM_CLASS := preload("res://scripts/domain/loot/MysteryChestItem.gd")

enum State {
	IDLE = 0,
	SOLO_OFFER = 1,
	AUCTION_ACTIVE = 2,
	COMPLETED = 3,
	CANCELLED = 4,
}

const MAX_ROUNDS: int = 5

var session_id: StringName = &""
var mystery_chest: MysteryChestState
var eligible_player_ids: Array[StringName] = []
var active_bidder_ids: Array[StringName] = []
var state: State = State.IDLE

# Solo Offer state
var solo_offer_price: int = 0
var solo_accepted: bool = false

# Auction state
var current_round: int = 1
var current_hint: Dictionary = {}
var hints_history: Array[Dictionary] = []
var highest_bid: int = 0
var highest_bidder_id: StringName = &""
var round_bids: Dictionary = {} # player_id -> int
var folded_player_ids: Array[StringName] = []

# Final Settlement
var winner_player_id: StringName = &""
var final_price_paid: int = 0
var converted_silver_received: int = 0
var retained_red_items: Array[MysteryChestItem] = []
var net_silver_profit: int = 0


func initialize(vault_reach_player_ids: Array[StringName], chest: MysteryChestState = null) -> void:
	session_id = StringName("auction_%d" % (randi() % 100000))
	eligible_player_ids = vault_reach_player_ids.duplicate()
	active_bidder_ids = vault_reach_player_ids.duplicate()
	mystery_chest = chest if chest != null else MysteryChestState.new()
	mystery_chest.generate_hint_pack(8)

	if eligible_player_ids.is_empty():
		state = State.CANCELLED
		return

	if eligible_player_ids.size() == 1:
		state = State.SOLO_OFFER
		var total_val: int = maxi(20, mystery_chest.total_silver_value())
		# Giá máy tự ra: 50% - 150% tổng giá trị hòm
		var ratio: float = randf_range(0.5, 1.5)
		solo_offer_price = maxi(5, int(round(float(total_val) * ratio)))
		var solo_clue_count: int = randi_range(3, 4)
		for idx in range(solo_clue_count):
			_publish_next_hint("Ưu Đãi Solo (%d/%d)" % [idx + 1, solo_clue_count])
	else:
		state = State.AUCTION_ACTIVE
		current_round = 1
		highest_bid = 0
		highest_bidder_id = &""
		folded_player_ids.clear()
		_publish_next_hint("Khởi Điểm Đấu Giá")


func is_solo() -> bool:
	return eligible_player_ids.size() == 1


## Xử lý khi solo: Người chơi duy nhất quyết định Mua
func accept_solo_offer(player_id: StringName, player_silver: int) -> bool:
	if state != State.SOLO_OFFER or player_id != eligible_player_ids[0]:
		return false
	if player_silver < solo_offer_price:
		return false
	solo_accepted = true
	winner_player_id = player_id
	final_price_paid = solo_offer_price
	_settle_auction()
	state = State.COMPLETED
	return true


## Xử lý khi solo: Người chơi từ chối mua
func decline_solo_offer(player_id: StringName) -> bool:
	if state != State.SOLO_OFFER or player_id != eligible_player_ids[0]:
		return false
	solo_accepted = false
	winner_player_id = &""
	final_price_paid = 0
	state = State.CANCELLED
	return true


## Đặt giá trong đấu giá nhiều người
func place_bid(player_id: StringName, bid_amount: int) -> bool:
	if state != State.AUCTION_ACTIVE:
		return false
	if not active_bidder_ids.has(player_id):
		return false
	if bid_amount <= highest_bid:
		return false

	highest_bid = bid_amount
	highest_bidder_id = player_id
	round_bids[player_id] = bid_amount
	return true


## Bỏ cuộc / dừng theo giá
func fold(player_id: StringName) -> void:
	if not active_bidder_ids.has(player_id):
		return
	active_bidder_ids.erase(player_id)
	folded_player_ids.append(player_id)

	# Nếu chỉ còn đúng 1 người chơi
	if active_bidder_ids.size() == 1:
		highest_bidder_id = active_bidder_ids[0]
		_conclude_auction()


## Chuyển sang vòng đấu giá kế tiếp (1 đến 5)
func advance_round() -> void:
	if state != State.AUCTION_ACTIVE:
		return

	if current_round >= MAX_ROUNDS or active_bidder_ids.size() <= 1:
		_conclude_auction()
		return

	current_round += 1
	round_bids.clear()
	_publish_next_hint("Vòng Đấu Giá %d" % current_round)


func _publish_next_hint(phase_title: String) -> void:
	current_hint = mystery_chest.next_hint()
	current_hint["phase"] = phase_title
	hints_history.append(current_hint)


func _conclude_auction() -> void:
	if not highest_bidder_id.is_empty():
		winner_player_id = highest_bidder_id
		final_price_paid = highest_bid
		_settle_auction()
	else:
		winner_player_id = &""
		final_price_paid = 0
	state = State.COMPLETED


var granted_tickets: int = 0


func _settle_auction() -> void:
	retained_red_items.clear()
	converted_silver_received = 0
	granted_tickets = 0

	for item: MysteryChestItem in mystery_chest.items:
		if item == null:
			continue
		if item.is_lab_upgrade_material() or item.rarity == MysteryChestItem.Rarity.RED:
			retained_red_items.append(item)
		else:
			converted_silver_received += item.silver_value
			if item.reward_type == "black_ticket":
				granted_tickets += 1

	net_silver_profit = converted_silver_received - final_price_paid


func settlement_summary() -> Dictionary:
	var red_names: Array[String] = []
	for it: MysteryChestItem in retained_red_items:
		red_names.append(it.display_name)
	return {
		"session_id": String(session_id),
		"winner_id": String(winner_player_id),
		"final_price_paid": final_price_paid,
		"converted_silver": converted_silver_received,
		"net_profit": net_silver_profit,
		"red_items_count": retained_red_items.size(),
		"red_item_names": red_names,
		"total_items_in_chest": mystery_chest.items.size(),
		"granted_tickets": granted_tickets,
	}
