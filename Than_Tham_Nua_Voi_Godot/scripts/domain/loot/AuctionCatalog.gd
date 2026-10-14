class_name AuctionCatalog
extends RefCounted

const ITEM_CLASS := preload("res://scripts/domain/loot/MysteryChestItem.gd")

# Danh mục phân loại
const CATEGORIES: Array[Dictionary] = [
	{"id": "", "label": "Tất cả", "icon": "⊞"},
	{"id": "antique", "label": "Đồ Cổ", "icon": "🏺"},
	{"id": "tool", "label": "Công Cụ", "icon": "🔨"},
	{"id": "document", "label": "Tài Liệu", "icon": "📄"},
	{"id": "medical", "label": "Y Tế", "icon": "🧪"},
	{"id": "kitchen", "label": "Nhà Bếp", "icon": "🍴"},
	{"id": "cards", "label": "Bài / Giải Trí", "icon": "🃏"},
	{"id": "general", "label": "Gia Dụng", "icon": "📦"},
	{"id": "resource", "label": "Tài Nguyên", "icon": "💾"},
]

# Danh mục toàn bộ vật phẩm theo đặc tả Bidking & Hoàng Cung
static var _CATALOG_ITEMS: Array[Dictionary] = [
	# --- Phẩm Trắng (Common): Các vật phẩm trong ảnh 1 ---
	{
		"id": "transaction_sheet",
		"display_name": "Transaction Sheet",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a276.png",
		"description": "Bản sao kê giao dịch ngân quỹ được niêm phong kỹ càng."
	},
	{
		"id": "local_newspaper",
		"display_name": "Local Newspaper",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 1,
		"weight_str": "0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a275.png",
		"description": "Báo địa phương ghi chép tin đồn và các vụ án kinh thành."
	},
	{
		"id": "sample_test_tube",
		"display_name": "Sample Test Tube",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 2,
		"weight_str": "<0.10KG",
		"category": "medical",
		"asset_path": "res://assets/auction_items/a274.png",
		"description": "Ống nghiệm lấy mẫu dung dịch chiết xuất từ Thái Y Viện."
	},
	{
		"id": "portrait_photo",
		"display_name": "Portrait Photo",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "<0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a273.png",
		"description": "Bức ảnh chân dung gia đình lưu lại dấu ấn một thời kỳ."
	},
	{
		"id": "military_photo",
		"display_name": "Military Photo",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "<0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a272.png",
		"description": "Ảnh chụp quân sự ngoài chiến tuyến biên cương."
	},
	{
		"id": "boxed_candles",
		"display_name": "Boxed Candles",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 2,
		"weight_str": "0.40KG",
		"category": "general",
		"asset_path": "res://assets/auction_items/a271.png",
		"description": "Hộp 4 cây nến dã ngoại thắp sáng hầm tối."
	},
	{
		"id": "box_of_nails",
		"display_name": "Box of Nails",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 2,
		"weight_str": "0.50KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a270.png",
		"description": "Hộp đinh sắt đúc chuyên dùng gia cố đồ gỗ và hòm kho báu."
	},
	{
		"id": "claw_hammer",
		"display_name": "Claw Hammer",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 3,
		"weight_str": "3.00KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a269.png",
		"description": "Búa nhổ đinh cán cao su cứng cáp, chịu lực tốt."
	},
	{
		"id": "pepper_bottle",
		"display_name": "Pepper Bottle",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 2,
		"weight_str": "0.25KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a268.png",
		"description": "Lọ tiêu xay kim loại chống ẩm của ngự trù ngự thiện phòng."
	},
	{
		"id": "card_big_joker",
		"display_name": "Card - Big Joker",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 2,
		"grid_height": 3,
		"silver_value": 4,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a267.png",
		"description": "Lá bài Joker Đỏ quyền lực, biểu tượng biến hóa khôn lường."
	},
	{
		"id": "card_joker",
		"display_name": "Card - Joker",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 2,
		"grid_height": 3,
		"silver_value": 4,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a266.png",
		"description": "Lá bài Joker Đen huyền bí trong bộ bài cổ điển."
	},
	{
		"id": "card_queen",
		"display_name": "Card - Queen",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 2,
		"grid_height": 3,
		"silver_value": 11,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a264.png",
		"description": "Lá bài Hoàng Hậu (Q) quý giá với trị giá cao đặc biệt."
	},
	{
		"id": "card_king",
		"display_name": "Card - King",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 2,
		"grid_height": 3,
		"silver_value": 12,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a264.png",
		"description": "Lá bài Quốc Vương (K) đứng đầu bộ bài với trị giá 12 xu bạc."
	},

	# --- Tài nguyên Nâng cấp (Refinement Chips & Locking Component) ---
	{
		"id": "refinement_chips_2",
		"display_name": "Refinement Chips (2)",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 0,
		"weight_str": "0.05KG",
		"category": "resource",
		"is_resource": true,
		"can_sell": false,
		"quantity": 2,
		"description": "Chip tinh luyện phẩm Trắng dùng để nâng cấp thiết bị."
	},
	{
		"id": "refinement_chips_4",
		"display_name": "Refinement Chips (4)",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 0,
		"weight_str": "0.05KG",
		"category": "resource",
		"is_resource": true,
		"can_sell": false,
		"quantity": 4,
		"description": "Chip tinh luyện phẩm Xanh dùng để nâng cấp thiết bị."
	},
	{
		"id": "refinement_chips_8",
		"display_name": "Refinement Chips (8)",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 0,
		"weight_str": "0.05KG",
		"category": "resource",
		"is_resource": true,
		"can_sell": false,
		"quantity": 8,
		"description": "Chip tinh luyện phẩm Xanh Dương cao cấp."
	},
	{
		"id": "refinement_chips_16",
		"display_name": "Refinement Chips (16)",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 0,
		"weight_str": "0.05KG",
		"category": "resource",
		"is_resource": true,
		"can_sell": false,
		"quantity": 16,
		"description": "Chip tinh luyện phẩm Tím quý giá phục vụ nghiên cứu."
	},
	{
		"id": "refinement_chips_32",
		"display_name": "Refinement Chips (32)",
		"rarity": ITEM_CLASS.Rarity.GOLD,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 0,
		"weight_str": "0.05KG",
		"category": "resource",
		"is_resource": true,
		"can_sell": false,
		"quantity": 32,
		"description": "Bộ chip tinh luyện Vàng cực hiếm từ kho vũ khố hoàng gia."
	},
	{
		"id": "locking_component_5",
		"display_name": "Locking Component (5)",
		"rarity": ITEM_CLASS.Rarity.RED,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 0,
		"weight_str": "0.20KG",
		"category": "resource",
		"is_resource": true,
		"can_sell": false,
		"quantity": 5,
		"description": "Linh kiện khóa cơ khí phẩm Đỏ giữ lại phục vụ phòng thí nghiệm."
	},

	# --- Cổ vật & Bảo vật Đỏ (Tham chiếu Bidking ảnh 2) ---
	{
		"id": "ngoc_mo_cuu",
		"display_name": "Ngọc Mỡ Cừu Hòa Điền",
		"rarity": ITEM_CLASS.Rarity.RED,
		"grid_width": 1,
		"grid_height": 4,
		"silver_value": 2516,
		"weight_str": "0.80KG",
		"category": "antique",
		"description": "Khối ngọc thạch Hòa Điền trắng tinh khôi như mỡ cừu, bảo vật vô giá."
	},
	{
		"id": "vinh_lac_quyen_2",
		"display_name": "Vĩnh Lạc Đại Điển Quyển 2",
		"rarity": ITEM_CLASS.Rarity.RED,
		"grid_width": 2,
		"grid_height": 3,
		"silver_value": 1553,
		"weight_str": "1.20KG",
		"category": "antique",
		"description": "Cuốn cổ thư bách khoa đồ sộ đính lụa vàng từ hoàng cung."
	},
	{
		"id": "vinh_lac_quyen_1",
		"display_name": "Vĩnh Lạc Đại Điển Quyển 1",
		"rarity": ITEM_CLASS.Rarity.RED,
		"grid_width": 2,
		"grid_height": 3,
		"silver_value": 1491,
		"weight_str": "1.20KG",
		"category": "antique",
		"description": "Tập đầu tiên của bộ cổ thư ghi chép toàn bộ tinh hoa triều đại."
	},
	{
		"id": "phu_xuan_son_cu",
		"display_name": "Phú Xuân Sơn Cư Đồ",
		"rarity": ITEM_CLASS.Rarity.RED,
		"grid_width": 4,
		"grid_height": 1,
		"silver_value": 1236,
		"weight_str": "0.50KG",
		"category": "antique",
		"description": "Bức họa cuộn thủy mặc phong cảnh Phú Xuân Sơn danh bất hư truyền."
	},
	{
		"id": "binh_phong_phi_thuy",
		"display_name": "Bình Phong Phỉ Thúy",
		"rarity": ITEM_CLASS.Rarity.RED,
		"grid_width": 3,
		"grid_height": 3,
		"silver_value": 844,
		"weight_str": "4.50KG",
		"category": "antique",
		"description": "Bình phong 3 cánh tạc từ ngọc phỉ thúy nguyên khối chạm trổ tinh xảo."
	},
	{
		"id": "binh_song_duong",
		"display_name": "Bình Song Dương",
		"rarity": ITEM_CLASS.Rarity.RED,
		"grid_width": 3,
		"grid_height": 3,
		"silver_value": 567,
		"weight_str": "3.20KG",
		"category": "antique",
		"description": "Bình đồng cổ khắc họa hình đôi dê tế lễ thời thượng cổ."
	}
]


static func get_all_items() -> Array[Dictionary]:
	return _CATALOG_ITEMS.duplicate(true)


static func get_item_by_id(item_id: String) -> Dictionary:
	for it in _CATALOG_ITEMS:
		if String(it.get("id", "")) == item_id:
			return it.duplicate(true)
	return {}


static func filter_items(
	rarity_filter: int = -1,
	category_filter: String = "",
	shape_filter: Vector2i = Vector2i.ZERO
) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for it in _CATALOG_ITEMS:
		if rarity_filter >= 0 and int(it.get("rarity", -1)) != rarity_filter:
			continue
		if not category_filter.is_empty() and String(it.get("category", "")) != category_filter:
			continue
		if shape_filter != Vector2i.ZERO:
			var w := int(it.get("grid_width", 1))
			var h := int(it.get("grid_height", 1))
			if w != shape_filter.x or h != shape_filter.y:
				continue
		results.append(it.duplicate(true))
	return results


static func create_item_instance(data: Dictionary) -> MysteryChestItem:
	var it := MysteryChestItem.new()
	it.item_id = StringName(data.get("id", "item"))
	it.display_name = String(data.get("display_name", "Vật Phẩm"))
	it.rarity = int(data.get("rarity", ITEM_CLASS.Rarity.WHITE)) as MysteryChestItem.Rarity
	it.grid_width = int(data.get("grid_width", 1))
	it.grid_height = int(data.get("grid_height", 1))
	it.silver_value = int(data.get("silver_value", 1))
	it.weight_str = String(data.get("weight_str", "<0.10KG"))
	it.category = String(data.get("category", "general"))
	it.asset_path = String(data.get("asset_path", ""))
	it.description = String(data.get("description", ""))
	it.quantity = int(data.get("quantity", 1))
	it.is_resource = bool(data.get("is_resource", false))
	it.can_sell = bool(data.get("can_sell", true))
	it.reward_type = String(data.get("reward_type", "silver"))
	return it
