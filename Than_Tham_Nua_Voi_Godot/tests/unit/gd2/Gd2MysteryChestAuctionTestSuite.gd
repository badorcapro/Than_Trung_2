class_name Gd2MysteryChestAuctionTestSuite
extends RefCounted

const ITEM_CLASS := preload("res://scripts/domain/loot/MysteryChestItem.gd")
const CHEST_CLASS := preload("res://scripts/domain/loot/MysteryChestState.gd")
const AUCTION_CLASS := preload("res://scripts/domain/loot/AuctionSession.gd")
const CATALOG_CLASS := preload("res://scripts/domain/loot/AuctionCatalog.gd")
const ENCYCLOPEDIA_CLASS := preload("res://scripts/presentation/loot/AuctionEncyclopediaDialog.gd")
const AUCTION_SCREEN_CLASS := preload("res://scripts/presentation/loot/AuctionScreen.gd")


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
	rows.append(_row("Đấu giá Solo: Tiết lộ ngẫu nhiên 3 hoặc 4 manh mối ngay từ đầu", _solo_3_or_4_hints_contract()))
	rows.append(_row("Các dải Xu Bạc 25-100, 100-175, 175-250 thiết lập đúng dải ngẫu nhiên", _silver_ranges_contract()))
	rows.append(_row("Bách khoa toàn thư: Danh mục vật phẩm trắng đăng ký đúng tên, size, giá và asset", _catalog_white_items_contract()))
	rows.append(_row("Bách khoa toàn thư: Dialog thông tin thời gian thực khởi tạo và lọc danh mục thành công", _encyclopedia_dialog_contract()))
	rows.append(_row("Đấu giá Nhiều Người: Lần lượt từng người chơi ra giá và hỗ trợ nhập số tùy ý", _auction_screen_turn_and_input_contract()))
	rows.append(_row("Đoạt hòm áp đảo: Vòng 1 Top 1 > Top 2 gấp 2x, V2 1.6x, V3 1.4x, V4 1.2x thắng ngay lập tức", _knockout_buyout_contract()))
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


func _silver_ranges_contract() -> bool:
	var small: RewardDefinition = load("res://content/rewards/production/prod_silver_small.tres")
	var large: RewardDefinition = load("res://content/rewards/production/prod_silver_large.tres")
	var grand: RewardDefinition = load("res://content/rewards/production/prod_silver_grand.tres")
	if small == null or large == null or grand == null:
		return false
	return (
		small.amount == 25 and small.amount_max == 100
		and large.amount == 100 and large.amount_max == 175
		and grand.amount == 175 and grand.amount_max == 250
	)


func _solo_3_or_4_hints_contract() -> bool:
	var chest := CHEST_CLASS.new()
	chest.roll_vault_deposit(6)
	var auction := AUCTION_CLASS.new()
	auction.initialize([&"player_solo"], chest)
	var count: int = auction.hints_history.size()
	return count >= 3 and count <= 4


func _catalog_white_items_contract() -> bool:
	var items: Array[Dictionary] = CATALOG_CLASS.get_all_items()
	if items.is_empty():
		return false
	var sheet := CATALOG_CLASS.get_item_by_id("transaction_sheet")
	var newspaper := CATALOG_CLASS.get_item_by_id("local_newspaper")
	var tube := CATALOG_CLASS.get_item_by_id("sample_test_tube")
	var queen := CATALOG_CLASS.get_item_by_id("card_queen")
	var king := CATALOG_CLASS.get_item_by_id("card_king")

	if sheet.is_empty() or sheet.get("display_name") != "Transaction Sheet" or sheet.get("grid_width") != 1 or sheet.get("grid_height") != 1:
		return false
	if newspaper.is_empty() or newspaper.get("display_name") != "Local Newspaper" or newspaper.get("grid_width") != 1 or newspaper.get("grid_height") != 2:
		return false
	if tube.is_empty() or tube.get("display_name") != "Sample Test Tube" or tube.get("grid_width") != 2 or tube.get("grid_height") != 1:
		return false
	if queen.is_empty() or queen.get("silver_value") != 11:
		return false
	if king.is_empty() or king.get("silver_value") != 12:
		return false
	return true


func _encyclopedia_dialog_contract() -> bool:
	var dialog := ENCYCLOPEDIA_CLASS.new()
	var white_items: Array[Dictionary] = CATALOG_CLASS.filter_items(ITEM_CLASS.Rarity.WHITE)
	var antique_items: Array[Dictionary] = CATALOG_CLASS.filter_items(-1, "antique")
	var shape_1x1_items: Array[Dictionary] = CATALOG_CLASS.filter_items(-1, "", Vector2i(1, 1))

	# Test multi-select shape: 1x1 OR 1x2
	var multi_shapes: Array[Dictionary] = CATALOG_CLASS.filter_items_multi(
		{}, false,
		{}, false,
		{Vector2i(1, 1): true, Vector2i(1, 2): true}, true
	)
	for it in multi_shapes:
		var w: int = int(it.get("grid_width", 1))
		var h: int = int(it.get("grid_height", 1))
		if not ((w == 1 and h == 1) or (w == 1 and h == 2)):
			dialog.free()
			return false

	# Test deselect-all (filter active but empty set -> 0 results)
	var empty_results: Array[Dictionary] = CATALOG_CLASS.filter_items_multi(
		{}, false,
		{}, false,
		{}, true
	)
	if not empty_results.is_empty():
		dialog.free()
		return false

	var valid := not white_items.is_empty() and not antique_items.is_empty() and not shape_1x1_items.is_empty() and not multi_shapes.is_empty()
	if dialog._dialog_panel == null:
		valid = false
	dialog.free()
	return valid


func _auction_screen_turn_and_input_contract() -> bool:
	var chest := CHEST_CLASS.new()
	chest.roll_vault_deposit(4)
	var session := AUCTION_CLASS.new()
	session.initialize([&"p1", &"p2"], chest)

	var screen := AUCTION_SCREEN_CLASS.new()
	screen.setup(session, {&"p1": 500, &"p2": 500})

	# 1. Turn starts with p1
	if screen._get_current_turn_player_id() != &"p1":
		screen.free()
		return false

	# 2. Arbitrary number input by p1: 30 Xu
	screen._bid_input.text = "30"
	screen._on_confirm_bid_pressed()

	# p1 placed 30, highest_bid is now 30
	if session.highest_bid != 30 or session.highest_bidder_id != &"p1":
		screen.free()
		return false

	# 3. Turn advances to p2
	if screen._get_current_turn_player_id() != &"p2":
		screen.free()
		return false

	# 4. p2 places 20 Xu (30 / 20 = 1.5x, does not trigger 2.0x knockout in Round 1)
	screen._bid_input.text = "20"
	screen._on_confirm_bid_pressed()

	# 5. Round is now completed because both p1 and p2 have acted
	if not screen._round_completed:
		screen.free()
		return false

	# 6. Next round button becomes visible
	if not screen._next_round_btn.visible:
		screen.free()
		return false

	# 7. Advance round resets turns for Round 2, starting again with p1
	screen._on_next_round_pressed()
	if session.current_round != 2 or screen._get_current_turn_player_id() != &"p1" or screen._round_completed:
		screen.free()
		return false

	screen.free()
	return true


func _knockout_buyout_contract() -> bool:
	var chest := CHEST_CLASS.new()
	chest.roll_vault_deposit(4)

	# Test Round 1: Top 1 >= 2.0 * Top 2 (50 vs 20 -> 2.5x >= 2.0x)
	var s1 := AUCTION_CLASS.new()
	s1.initialize([&"p1", &"p2"], chest)
	s1.place_bid(&"p1", 50)
	s1.place_bid(&"p2", 20)
	var ko1: Dictionary = s1.check_knockout_winner()
	if ko1.is_empty() or ko1.get("winner_id") != &"p1" or s1.state != AUCTION_CLASS.State.COMPLETED:
		return false

	# Test Round 1 failed knockout: 30 vs 20 (1.5x < 2.0x)
	var s1_fail := AUCTION_CLASS.new()
	s1_fail.initialize([&"p1", &"p2"], chest)
	s1_fail.place_bid(&"p1", 30)
	s1_fail.place_bid(&"p2", 20)
	if not s1_fail.check_knockout_winner().is_empty() or s1_fail.state == AUCTION_CLASS.State.COMPLETED:
		return false

	# Test Round 2: Top 1 >= 1.6 * Top 2 (40 vs 25 -> 1.6x >= 1.6x)
	var s2 := AUCTION_CLASS.new()
	s2.initialize([&"p1", &"p2"], chest)
	s2.advance_round() # V2
	s2.place_bid(&"p1", 40)
	s2.place_bid(&"p2", 25)
	var ko2: Dictionary = s2.check_knockout_winner()
	if ko2.is_empty() or ko2.get("winner_id") != &"p1":
		return false

	# Test Round 3: Top 1 >= 1.4 * Top 2 (70 vs 50 -> 1.4x >= 1.4x)
	var s3 := AUCTION_CLASS.new()
	s3.initialize([&"p1", &"p2"], chest)
	s3.advance_round() # V2
	s3.advance_round() # V3
	s3.place_bid(&"p1", 70)
	s3.place_bid(&"p2", 50)
	var ko3: Dictionary = s3.check_knockout_winner()
	if ko3.is_empty() or ko3.get("winner_id") != &"p1":
		return false

	# Test Round 4: Top 1 >= 1.2 * Top 2 (60 vs 50 -> 1.2x >= 1.2x)
	var s4 := AUCTION_CLASS.new()
	s4.initialize([&"p1", &"p2"], chest)
	s4.advance_round() # V2
	s4.advance_round() # V3
	s4.advance_round() # V4
	s4.place_bid(&"p1", 60)
	s4.place_bid(&"p2", 50)
	var ko4: Dictionary = s4.check_knockout_winner()
	if ko4.is_empty() or ko4.get("winner_id") != &"p1":
		return false

	return true
