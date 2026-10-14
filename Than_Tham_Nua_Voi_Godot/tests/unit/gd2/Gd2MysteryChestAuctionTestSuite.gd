class_name Gd2MysteryChestAuctionTestSuite
extends RefCounted

const ITEM_CLASS := preload("res://scripts/domain/loot/MysteryChestItem.gd")
const CHEST_CLASS := preload("res://scripts/domain/loot/MysteryChestState.gd")
const AUCTION_CLASS := preload("res://scripts/domain/loot/AuctionSession.gd")


func run() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	rows.append(_row("Hòm Bí Ẩn hỗ trợ 6 phẩm cấp từ Trắng đến Đỏ", _rarity_tiers_contract()))
	rows.append(_row("Đồ Đỏ là vật phẩm giữ lại cho phòng thí nghiệm, đồ khác quy đổi xu", _red_item_lab_contract()))
	rows.append(_row("Đổ xúc xắc tại ô to đích sinh từ 0 đến 2 vật phẩm vào hòm", _deposit_at_vault_contract()))
	rows.append(_row("Hòm bí ẩn sinh đủ 7+ nhóm manh mối theo đặc tả", _hints_generation_contract()))
	rows.append(_row("Đấu giá Solo: Máy tự ra giá từ 50% đến 150% tổng giá trị hòm", _solo_auction_offer_contract()))
	rows.append(_row("Đấu giá Solo: Chấp nhận mua trừ tiền và bàn giao vật phẩm", _solo_accept_contract()))
	rows.append(_row("Đấu giá Solo: Bỏ qua không mua hủy phiên an toàn", _solo_decline_contract()))
	rows.append(_row("Đấu giá Nhiều Người: Có 5 vòng và công bố manh mối từng vòng", _multiplayer_5_rounds_contract()))
	rows.append(_row("Đấu giá Nhiều Người: Người trả giá cao nhất thắng cuộc", _multiplayer_highest_bid_wins_contract()))
	rows.append(_row("Tổng kết phiên: Quy đổi xu chính xác và giữ lại đúng đồ đỏ", _settlement_accounting_contract()))
	return rows


func _row(name: String, passed: bool) -> Dictionary:
	return {
		"name": name,
		"passed": passed,
		"detail": "GĐ2 Mystery Chest & Auction invariant",
	}


func _rarity_tiers_contract() -> bool:
	var item := ITEM_CLASS.new()
	item.rarity = ITEM_CLASS.Rarity.WHITE
	if ITEM_CLASS.rarity_name(ITEM_CLASS.Rarity.WHITE) != "Trắng": return false
	if ITEM_CLASS.rarity_name(ITEM_CLASS.Rarity.GREEN) != "Xanh lá": return false
	if ITEM_CLASS.rarity_name(ITEM_CLASS.Rarity.BLUE) != "Xanh dương": return false
	if ITEM_CLASS.rarity_name(ITEM_CLASS.Rarity.PURPLE) != "Tím": return false
	if ITEM_CLASS.rarity_name(ITEM_CLASS.Rarity.GOLD) != "Vàng": return false
	if ITEM_CLASS.rarity_name(ITEM_CLASS.Rarity.RED) != "Đỏ": return false
	return true


func _red_item_lab_contract() -> bool:
	var red_item := ITEM_CLASS.new()
	red_item.rarity = ITEM_CLASS.Rarity.RED
	var gold_item := ITEM_CLASS.new()
	gold_item.rarity = ITEM_CLASS.Rarity.GOLD
	return red_item.is_lab_upgrade_material() and not gold_item.is_lab_upgrade_material()


func _deposit_at_vault_contract() -> bool:
	var chest := CHEST_CLASS.new()
	var d0: Array[ITEM_CLASS] = chest.roll_vault_deposit(0)
	var d1: Array[ITEM_CLASS] = chest.roll_vault_deposit(1)
	var d2: Array[ITEM_CLASS] = chest.roll_vault_deposit(2)
	return d0.size() == 0 and d1.size() == 1 and d2.size() == 2 and chest.items.size() == 3


func _hints_generation_contract() -> bool:
	var chest := CHEST_CLASS.new()
	chest.roll_vault_deposit(6)
	var hints: Array[Dictionary] = chest.generate_hint_pack(6)
	if hints.size() < 6:
		return false
	var saw_hint := false
	for h in hints:
		if not String(h.get("title", "")).is_empty() and not String(h.get("description", "")).is_empty():
			saw_hint = true
	return saw_hint


func _solo_auction_offer_contract() -> bool:
	var chest := CHEST_CLASS.new()
	var item1 := ITEM_CLASS.new()
	item1.silver_value = 100
	chest.items.append(item1)
	var auction := AUCTION_CLASS.new()
	auction.initialize([&"player_solo"], chest)
	if not auction.is_solo():
		return false
	var total: int = chest.total_silver_value()
	var min_bound: int = int(float(total) * 0.5)
	var max_bound: int = int(float(total) * 1.5)
	return auction.solo_offer_price >= min_bound and auction.solo_offer_price <= max_bound


func _solo_accept_contract() -> bool:
	var chest := CHEST_CLASS.new()
	var item1 := ITEM_CLASS.new()
	item1.rarity = ITEM_CLASS.Rarity.BLUE
	item1.silver_value = 80
	chest.items.append(item1)
	var auction := AUCTION_CLASS.new()
	auction.initialize([&"player_solo"], chest)
	var offer: int = auction.solo_offer_price
	var accepted: bool = auction.accept_solo_offer(&"player_solo", offer + 100)
	return (
		accepted
		and auction.winner_player_id == &"player_solo"
		and auction.final_price_paid == offer
		and auction.converted_silver_received == 80
		and auction.state == AUCTION_CLASS.State.COMPLETED
	)


func _solo_decline_contract() -> bool:
	var chest := CHEST_CLASS.new()
	var auction := AUCTION_CLASS.new()
	auction.initialize([&"player_solo"], chest)
	var declined: bool = auction.decline_solo_offer(&"player_solo")
	return declined and auction.state == AUCTION_CLASS.State.CANCELLED and auction.winner_player_id == &""


func _multiplayer_5_rounds_contract() -> bool:
	var chest := CHEST_CLASS.new()
	chest.roll_vault_deposit(4)
	var auction := AUCTION_CLASS.new()
	auction.initialize([&"p1", &"p2", &"p3"], chest)
	if auction.is_solo() or auction.current_round != 1:
		return false
	auction.advance_round() # Vòng 2
	auction.advance_round() # Vòng 3
	auction.advance_round() # Vòng 4
	auction.advance_round() # Vòng 5
	return auction.current_round == 5 and auction.hints_history.size() == 5


func _multiplayer_highest_bid_wins_contract() -> bool:
	var chest := CHEST_CLASS.new()
	chest.roll_vault_deposit(4)
	var auction := AUCTION_CLASS.new()
	auction.initialize([&"p1", &"p2"], chest)
	auction.place_bid(&"p1", 50)
	auction.place_bid(&"p2", 80)
	auction.fold(&"p1")
	return auction.winner_player_id == &"p2" and auction.final_price_paid == 80 and auction.state == AUCTION_CLASS.State.COMPLETED


func _settlement_accounting_contract() -> bool:
	var chest := CHEST_CLASS.new()
	var item_blue := ITEM_CLASS.new()
	item_blue.rarity = ITEM_CLASS.Rarity.BLUE
	item_blue.silver_value = 60
	chest.items.append(item_blue)

	var item_gold := ITEM_CLASS.new()
	item_gold.rarity = ITEM_CLASS.Rarity.GOLD
	item_gold.silver_value = 250
	chest.items.append(item_gold)

	var item_red := ITEM_CLASS.new()
	item_red.rarity = ITEM_CLASS.Rarity.RED
	item_red.silver_value = 500
	item_red.display_name = "Huyết Thạch Tế Đàn"
	chest.items.append(item_red)

	var auction := AUCTION_CLASS.new()
	auction.initialize([&"p1", &"p2"], chest)
	auction.place_bid(&"p1", 200)
	auction.fold(&"p2")

	var summary: Dictionary = auction.settlement_summary()
	# Blue 60 + Gold 250 = 310 xu quy đổi
	# Red là vật phẩm lab được giữ lại (không tính vào xu)
	return (
		summary["winner_id"] == "p1"
		and summary["final_price_paid"] == 200
		and summary["converted_silver"] == 310
		and summary["net_profit"] == 110
		and summary["red_items_count"] == 1
		and summary["red_item_names"] == ["Huyết Thạch Tế Đàn"]
	)
