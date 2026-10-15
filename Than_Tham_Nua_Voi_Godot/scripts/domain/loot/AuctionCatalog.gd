class_name AuctionCatalog
extends RefCounted

const ITEM_CLASS := preload("res://scripts/domain/loot/MysteryChestItem.gd")

# Danh mục phân loại (8 chủng loại thực tế)
const CATEGORIES: Array[Dictionary] = [
	{"id": "antique", "label": "Đồ Cổ", "icon": "🏺", "icon_path": "res://assets/auction_items/do_co.png"},
	{"id": "tool", "label": "Công Cụ", "icon": "🔨", "icon_path": "res://assets/auction_items/cong_cu.png"},
	{"id": "document", "label": "Tài Liệu", "icon": "📄", "icon_path": "res://assets/auction_items/tai_lieu.png"},
	{"id": "medical", "label": "Y Tế", "icon": "🧪", "icon_path": "res://assets/auction_items/y_te.png"},
	{"id": "kitchen", "label": "Nhà Bếp", "icon": "🍴", "icon_path": "res://assets/auction_items/nha_bep.png"},
	{"id": "cards", "label": "Bài / Giải Trí", "icon": "🃏", "icon_path": "res://assets/auction_items/bai_giai_tri.png"},
	{"id": "general", "label": "Gia Dụng", "icon": "📦", "icon_path": "res://assets/auction_items/gia_dung.png"},
	{"id": "resource", "label": "Tài Nguyên", "icon": "💾", "icon_path": "res://assets/auction_items/tai_nguyen.png"},
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
		"grid_width": 2,
		"grid_height": 1,
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
		"grid_width": 1,
		"grid_height": 2,
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
		"grid_width": 1,
		"grid_height": 1,
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
		"grid_height": 1,
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
		"grid_height": 1,
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
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a267.png",
		"description": "Lá bài Joker Đỏ quyền lực, biểu tượng biến hóa khôn lường."
	},
	{
		"id": "card_10",
		"display_name": "Card - 10",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a255.png",
		"description": "Lá bài 10 Bích sắc bén, thuộc bộ bài Tây giải trí chốn cung đình."
	},
	{
		"id": "card_9",
		"display_name": "Card - 9",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a256.png",
		"description": "Lá bài 9 Bích quyền năng, thuộc bộ bài Tây giải trí chốn cung đình."
	},
	{
		"id": "card_8",
		"display_name": "Card - 8",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a257.png",
		"description": "Lá bài 8 Bích sắc sảo, thuộc bộ bài Tây giải trí chốn cung đình."
	},
	{
		"id": "card_7",
		"display_name": "Card - 7",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a258.png",
		"description": "Lá bài 7 Cơ đỏ rực, biểu trưng cho may mắn và vận hội."
	},
	{
		"id": "card_6",
		"display_name": "Card - 6",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a259.png",
		"description": "Lá bài 6 Cơ hòa nhã, biểu trưng cho sự trôi chảy thuận lợi."
	},
	{
		"id": "card_5",
		"display_name": "Card - 5",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a260.png",
		"description": "Lá bài 5 Cơ cân bằng, biểu trưng cho phúc lộc ngũ hành."
	},
	{
		"id": "card_4",
		"display_name": "Card - 4",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a261.png",
		"description": "Lá bài 4 Tép thanh lịch, biểu trưng cho sự vững chãi tứ phương."
	},
	{
		"id": "card_3",
		"display_name": "Card - 3",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a262.png",
		"description": "Lá bài 3 Tép gắn kết, biểu trưng cho tam tài tương sinh."
	},
	{
		"id": "card_2",
		"display_name": "Card - 2",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a263.png",
		"description": "Lá bài 2 Rô son sắc, biểu trưng cho song hỷ hòa hợp."
	},
	{
		"id": "card_ace",
		"display_name": "Card - Ace",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 2,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a264.png",
		"description": "Lá bài Át Rô viên mãn, biểu tượng đứng đầu quyền quý."
	},
	{
		"id": "document_fragment",
		"display_name": "Document Fragment",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "<0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a265.png",
		"description": "Mảnh tài liệu bị xé rách, lưu giữ những manh mối còn dang dở."
	},
	{
		"id": "card_small_joker",
		"display_name": "Card - Small Joker",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 3,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a266.png",
		"description": "Lá bài Joker Đen huyền bí với biểu tượng la bàn phong thủy bí ẩn."
	},
	{
		"id": "sonic_distance_tape",
		"display_name": "Sonic Distance Tape",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 2,
		"weight_str": "0.15KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a243.png",
		"description": "Thước đo khoảng cách sóng âm tinh chuẩn dùng trong khảo sát kiến trúc."
	},
	{
		"id": "set_square",
		"display_name": "Set Square",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 2,
		"weight_str": "0.80KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a244.png",
		"description": "Thước góc vuông chữ L kim loại chắc chắn của thợ mộc hoàng cung."
	},
	{
		"id": "mouse",
		"display_name": "Mouse",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "<0.10KG",
		"category": "general",
		"asset_path": "res://assets/auction_items/a245.png",
		"description": "Chuột quang điều khiển hệ thống cơ khí vi mạch cổ xưa."
	},
	{
		"id": "card_jack",
		"display_name": "Card - Jack",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 2,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a246.png",
		"description": "Lá bài J Cơ mang hình ảnh kỵ sĩ trung thành của vương triều."
	},
	{
		"id": "card_queen",
		"display_name": "Card - Queen",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 2,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a247.png",
		"description": "Lá bài Q Tép mang hình ảnh hoàng hậu tôn quý và thông thái."
	},
	{
		"id": "card_king",
		"display_name": "Card - King",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 2,
		"weight_str": "<0.10KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a248.png",
		"description": "Lá bài K Bích mang hình ảnh bậc đế vương oai nghiêm trị quốc."
	},
	{
		"id": "network_cable",
		"display_name": "Network Cable",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "0.60KG",
		"category": "general",
		"asset_path": "res://assets/auction_items/a249.png",
		"description": "Cuộn cáp truyền dẫn tín hiệu mạng nơ-ron liên lạc nội bộ."
	},
	{
		"id": "surgical_scissors",
		"display_name": "Surgical Scissors",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 2,
		"weight_str": "<0.10KG",
		"category": "medical",
		"asset_path": "res://assets/auction_items/a250.png",
		"description": "Kéo phẫu thuật thép không gỉ sắc bén từ Thái Y Viện."
	},
	{
		"id": "surgical_gloves",
		"display_name": "Surgical Gloves",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "<0.10KG",
		"category": "medical",
		"asset_path": "res://assets/auction_items/a251.png",
		"description": "Găng tay phẫu thuật y tế phủ sợi cảm ứng vi mô."
	},
	{
		"id": "yogurt",
		"display_name": "Yogurt",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "0.25KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a252.png",
		"description": "Hộp sữa chua lên men thơm ngon của ngự trù phòng."
	},
	{
		"id": "basic_protein_powder",
		"display_name": "Basic Protein Powder",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 2,
		"weight_str": "2.30KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a253.png",
		"description": "Hũ bột đạm dinh dưỡng tăng cường thể lực cho thị vệ hoàng cung."
	},
	{
		"id": "crispy_noodles",
		"display_name": "Crispy Noodles",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "<0.10KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a254.png",
		"description": "Gói mì giòn ăn liền tiện lợi cho các chuyến tuần tra đêm."
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


static func filter_items_multi(
	allowed_rarities: Dictionary = {},
	filter_rarity: bool = false,
	allowed_categories: Dictionary = {},
	filter_category: bool = false,
	allowed_shapes: Dictionary = {},
	filter_shape: bool = false
) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for it in _CATALOG_ITEMS:
		if filter_rarity:
			var r: int = int(it.get("rarity", -1))
			if not allowed_rarities.has(r):
				continue
		if filter_category:
			var cat: String = String(it.get("category", ""))
			if not allowed_categories.has(cat):
				continue
		if filter_shape:
			var w := int(it.get("grid_width", 1))
			var h := int(it.get("grid_height", 1))
			var sh := Vector2i(w, h)
			if not allowed_shapes.has(sh):
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
