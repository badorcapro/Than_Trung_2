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
	{"id": "resource", "label": "Tài Nguyên", "icon": "tai_nguyen", "icon_path": "res://assets/auction_items/tai_nguyen.png"},
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
		"silver_value": 11,
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
		"silver_value": 12,
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
	{
		"id": "rechargeable_battery",
		"display_name": "Rechargeable Battery",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.20KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a231.png",
		"description": "Bộ sạc pin kèm pin sạc tích điện cao cấp, cung cấp năng lượng ổn định."
	},
	{
		"id": "battery_9v",
		"display_name": "9V Battery",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.10KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a232.png",
		"description": "Khối pin 9V hiệu suất cao dùng kích hoạt các thiết bị điều tra đặc dụng."
	},
	{
		"id": "private_notebook",
		"display_name": "Private Notebook",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 5,
		"weight_str": "0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a233.png",
		"description": "Cuốn sổ tay bìa da cài quai bảo mật, lưu giữ những bí mật hoàng cung."
	},
	{
		"id": "stamped_through_document",
		"display_name": "Stamped Through Document",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 5,
		"weight_str": "0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a234.png",
		"description": "Văn bản triều đình đóng dấu đỏ thấu trang, có hiệu lực pháp lý cao."
	},
	{
		"id": "personal_note",
		"display_name": "Personal Note",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a235.png",
		"description": "Tập giấy ghi chú cá nhân với những dòng thư tay bí ẩn chưa giải mã."
	},
	{
		"id": "toothpaste",
		"display_name": "Toothpaste",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 1,
		"weight_str": "0.15KG",
		"category": "general",
		"asset_path": "res://assets/auction_items/a236.png",
		"description": "Tuýp kem đánh răng hương bạc hà thanh mát đồ dùng sinh hoạt."
	},
	{
		"id": "matches",
		"display_name": "Matches",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "<0.10KG",
		"category": "general",
		"asset_path": "res://assets/auction_items/a237.png",
		"description": "Hộp diêm quẹt đánh lửa bén nhạy tiện dụng trong bóng tối."
	},
	{
		"id": "precision_tool_set",
		"display_name": "Precision Tool Set",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 2,
		"weight_str": "1.00KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a238.png",
		"description": "Bộ tua vít và đầu khẩu đa năng sửa chữa thiết bị cơ khí chính xác."
	},
	{
		"id": "waterproof_tape",
		"display_name": "Waterproof Tape",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "0.10KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a239.png",
		"description": "Cuộn băng dính chống nước màu bạc chịu nhiệt và bám dính siêu bền."
	},
	{
		"id": "duct_tape",
		"display_name": "Duct Tape",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "<0.10KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a240.png",
		"description": "Cuộn băng keo màu xanh co giãn đa dụng gia cố đồ vật khẩn cấp."
	},
	{
		"id": "paint_brush",
		"display_name": "Paint Brush",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 1,
		"weight_str": "<0.10KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a241.png",
		"description": "Chổi quét sơn bản rộng lông mềm dùng phục chế hiện vật cổ vật."
	},
	{
		"id": "multitool",
		"display_name": "Multitool",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 2,
		"weight_str": "0.20KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a242.png",
		"description": "Dao rọc giấy đa năng cán vàng sắc bén phục vụ mở niêm phong hòm."
	},

	# --- Phẩm Xanh Lá (Green): Các vật phẩm trong ảnh 4 (a219 - a230) ---
	{
		"id": "african_wood_sculpture",
		"display_name": "African Wood Sculpture",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 6,
		"weight_str": "1.40KG",
		"category": "antique",
		"asset_path": "res://assets/auction_items/a219.png",
		"description": "Tượng gỗ châu Phi điêu khắc thủ công tinh xảo, cổ vật quý hiếm từ hải ngoại."
	},
	{
		"id": "rusty_pirate_copper_coin",
		"display_name": "Rusty Pirate Copper Coin",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 5,
		"weight_str": "0.20KG",
		"category": "antique",
		"asset_path": "res://assets/auction_items/a220.png",
		"description": "Đồng xu cổ mặt trời rỉ sét thời cướp biển, đúc bằng đồng thiếc cổ xưa."
	},
	{
		"id": "ahsarah_specialty_tajine_pot",
		"display_name": "Ahsarah Specialty Tajine Pot",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 8,
		"weight_str": "3.75KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a221.png",
		"description": "Nồi đất Tajine đặc sản Ahsarah nắp hình chóp đặc trưng dùng om hầm cung đình."
	},
	{
		"id": "hotel_poster",
		"display_name": "Hotel Poster",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 6,
		"weight_str": "<0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a222.png",
		"description": "Áp phích quảng cáo khách sạn hoàng gia Diamond Queen viền khung kính lưu niệm."
	},
	{
		"id": "ahsarah_news_weekly",
		"display_name": "Ahsarah News Weekly",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 6,
		"weight_str": "0.25KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a223.png",
		"description": "Tuần báo thời sự tổng hợp Ahsarah in ấn các phóng sự điều tra nóng hổi."
	},
	{
		"id": "ahsarah_entertainment_magazine",
		"display_name": "Ahsarah Entertainment Magazine",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 6,
		"weight_str": "0.25KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a224.png",
		"description": "Tạp chí giải trí và thời trang kinh kỳ Ahsarah bắt mắt và thịnh hành."
	},
	{
		"id": "seasoning_set",
		"display_name": "Seasoning Set",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 7,
		"weight_str": "0.45KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a225.png",
		"description": "Bộ giá xoay gia vị 6 lọ thủy tinh nắp bạc sang trọng dành cho ngự trù."
	},
	{
		"id": "bagged_coffee_beans",
		"display_name": "Bagged Coffee Beans",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 5,
		"weight_str": "0.35KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a226.png",
		"description": "Túi hạt cà phê rang mộc thượng hạng nhập khẩu giữ hương thơm nồng nàn."
	},
	{
		"id": "local_rebrewed_coffee",
		"display_name": "Local Rebrewed Coffee",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.28KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a227.png",
		"description": "Hũ cà phê hòa tan pha chế thủ công bản xứ giúp tỉnh táo trong ca trực."
	},
	{
		"id": "super_glue",
		"display_name": "Super Glue",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.25KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a228.png",
		"description": "Chai keo dán tức thì khô nhanh kết dính siêu bền các mảnh vỡ chứng cứ."
	},
	{
		"id": "stone_hammer",
		"display_name": "Stone Hammer",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 3,
		"grid_height": 1,
		"silver_value": 7,
		"weight_str": "5.00KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a229.png",
		"description": "Búa tạ đập đá cán dài đúc thép nặng 5kg dùng phá khóa và rào chắn kiên cố."
	},
	{
		"id": "handsaw",
		"display_name": "Handsaw",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 3,
		"grid_height": 1,
		"silver_value": 6,
		"weight_str": "1.50KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a230.png",
		"description": "Cưa tay khung kim loại răng cưa hợp kim bén ngọt cắt vật liệu cứng."
	},

	# --- Phẩm Xanh Lá (Green): Các vật phẩm trong ảnh 5 (a207 - a218) ---
	{
		"id": "apple",
		"display_name": "Apple",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.40KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a207.png",
		"description": "Quả táo đỏ tươi giòn ngọt thu hoạch từ vườn thượng uyển."
	},
	{
		"id": "sugar_free_energy_bar",
		"display_name": "Sugar Free Energy Bar",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "<0.10KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a208.png",
		"description": "Thanh năng lượng không đường hạt ngũ cốc giúp hồi phục thể lực cấp tốc."
	},
	{
		"id": "purified_water",
		"display_name": "Purified Water",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.60KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a209.png",
		"description": "Chai nước khoáng tinh khiết đóng chai nguồn suối ngầm thanh lọc cơ thể."
	},
	{
		"id": "field_energy_bar",
		"display_name": "Field Energy Bar",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.10KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a210.png",
		"description": "Thanh lương khô dã chiến cao năng lượng dành cho lực lượng tuần thám."
	},
	{
		"id": "architectural_drawing_1",
		"display_name": "Architectural Drawing I",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 5,
		"weight_str": "<0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a211.png",
		"description": "Bản vẽ phác thảo kiến trúc cung thành phần I vẽ trên giấy da cổ."
	},
	{
		"id": "architectural_drawing_2",
		"display_name": "Architectural Drawing II",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 5,
		"weight_str": "<0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a212.png",
		"description": "Bản vẽ phác thảo kiến trúc cung đình phần II thể hiện tiền điện nguy nga."
	},
	{
		"id": "architectural_drawing_3",
		"display_name": "Architectural Drawing III",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 5,
		"weight_str": "<0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a213.png",
		"description": "Bản vẽ phác thảo kiến trúc cung đình phần III mô tả quy hoạch hoa viên."
	},
	{
		"id": "architectural_drawing_4",
		"display_name": "Architectural Drawing IV",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 5,
		"weight_str": "<0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a214.png",
		"description": "Bản vẽ phác thảo kiến trúc cung đình phần IV ghi lại hệ thống tháp canh."
	},
	{
		"id": "architectural_drawing_5",
		"display_name": "Architectural Drawing V",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 5,
		"weight_str": "<0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a215.png",
		"description": "Bản vẽ phác thảo kiến trúc cung đình phần V lưu lại sơ đồ hậu cung mật thất."
	},
	{
		"id": "djembe",
		"display_name": "Djembe",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 6,
		"weight_str": "4.50KG",
		"category": "antique",
		"asset_path": "res://assets/auction_items/a216.png",
		"description": "Trống gỗ Djembe bọc da thú căng dây thừng truyền thống âm thanh trầm hùng."
	},
	{
		"id": "solar_dish",
		"display_name": "Solar Dish",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 7,
		"weight_str": "0.20KG",
		"category": "antique",
		"asset_path": "res://assets/auction_items/a217.png",
		"description": "Đĩa sứ tráng men hoa văn thái dương rực rỡ mang ý nghĩa trừ tà cầu phúc."
	},
	{
		"id": "bullet_pendant",
		"display_name": "Bullet Pendant",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 5,
		"weight_str": "<0.10KG",
		"category": "antique",
		"asset_path": "res://assets/auction_items/a218.png",
		"description": "Mặt dây chuyền vỏ đạn đồng khắc phù chú may mắn luồn dây xích kim loại."
	},

	# --- Phẩm Xanh Lá (Green): Các vật phẩm trong ảnh 6 (a195 - a206) ---
	{
		"id": "printed_circuit_board",
		"display_name": "Printed Circuit Board",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.30KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a195.png",
		"description": "Bản mạch in điện tử tích hợp chip vi xử lý dùng cho cơ quan cơ mật."
	},
	{
		"id": "keyboard",
		"display_name": "Keyboard",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 5,
		"weight_str": "1.10KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a196.png",
		"description": "Bàn phím cơ nhập liệu điều khiển hệ thống cơ khí và thiết bị tính toán."
	},
	{
		"id": "air_cooled_heat_sink",
		"display_name": "Air-Cooled Heat Sink",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.40KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a197.png",
		"description": "Cụm quạt tản nhiệt khí đôi với các lá nhôm làm mát bộ vi xử lý máy móc."
	},
	{
		"id": "hdd",
		"display_name": "HDD",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 5,
		"weight_str": "0.25KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a198.png",
		"description": "Ổ cứng từ tính cơ học lưu trữ toàn bộ hồ sơ mật và dữ liệu trinh thám."
	},
	{
		"id": "uhf_card_reader",
		"display_name": "UHF Card Reader",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.10KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a199.png",
		"description": "Mô-đun đầu đọc thẻ tần số siêu cao UHF nhận dạng thẻ định danh từ xa."
	},
	{
		"id": "ancient_sphinx_statue",
		"display_name": "Ancient Sphinx Statue",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 8,
		"weight_str": "3.20KG",
		"category": "antique",
		"asset_path": "res://assets/auction_items/a200.png",
		"description": "Bức tượng nhân sư có cánh cổ kính tạc từ đá khối hoa cương ngàn năm."
	},
	{
		"id": "socket",
		"display_name": "Socket",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.20KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a201.png",
		"description": "Ổ cắm điện đa chấu kèm công tắc an toàn phân phối nguồn điện ổn định."
	},
	{
		"id": "saline_solution",
		"display_name": "Saline Solution",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.60KG",
		"category": "medical",
		"asset_path": "res://assets/auction_items/a202.png",
		"description": "Bình nước muối sinh lý 0.9% 500ml dùng sát trùng và rửa vết thương."
	},
	{
		"id": "surgical_forceps",
		"display_name": "Surgical Forceps",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.20KG",
		"category": "medical",
		"asset_path": "res://assets/auction_items/a203.png",
		"description": "Kẹp phẫu thuật y tế bằng thép không gỉ mũi cong gắp dị vật chính xác."
	},
	{
		"id": "small_vial",
		"display_name": "Small Vial",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.10KG",
		"category": "medical",
		"asset_path": "res://assets/auction_items/a204.png",
		"description": "Lọ thuốc tiêm thủy tinh tối màu nắp cao su tím chứa dược chất giảm đau."
	},
	{
		"id": "injector",
		"display_name": "Injector",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "<0.10KG",
		"category": "medical",
		"asset_path": "res://assets/auction_items/a205.png",
		"description": "Ống tiêm y tế chia vạch chuẩn xác dùng trích lấy hoặc tiêm thuốc đặc trị."
	},
	{
		"id": "infusion_set",
		"display_name": "Infusion Set",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 5,
		"weight_str": "0.25KG",
		"category": "medical",
		"asset_path": "res://assets/auction_items/a206.png",
		"description": "Hộp bộ truyền dịch vô trùng cao cấp chuyên dụng cấp cứu hồi sinh lực."
	},

	# --- Phẩm Xanh Lá (Green): Các vật phẩm trong ảnh 7 (a183 - a194) ---
	{
		"id": "voltage_tester",
		"display_name": "Voltage Tester",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.10KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a183.png",
		"description": "Bút thử điện điện tử hiển thị số kiểm tra an toàn mạch điện."
	},
	{
		"id": "angle_grinder",
		"display_name": "Angle Grinder",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 7,
		"weight_str": "2.40KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a184.png",
		"description": "Máy mài góc cầm tay lắp đĩa cắt kim loại công suất lớn."
	},
	{
		"id": "corrugated_tube",
		"display_name": "Corrugated Tube",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.60KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a185.png",
		"description": "Ống ruột gà luồn dây điện chống cháy và cách điện bảo vệ đường dây."
	},
	{
		"id": "analog_thermometer",
		"display_name": "Analog Thermometer",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.30KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a186.png",
		"description": "Nhiệt kế cơ kim chỉ chân kim loại đo nhiệt độ buồng máy chính xác."
	},
	{
		"id": "spray_paint",
		"display_name": "Spray Paint",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 5,
		"weight_str": "0.40KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a187.png",
		"description": "Bình sơn xịt áp suất cao phủ bóng bề mặt kim loại chống ăn mòn."
	},
	{
		"id": "led_light",
		"display_name": "LED Light",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 5,
		"weight_str": "0.45KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a188.png",
		"description": "Thanh đèn LED dài chiếu sáng công nghiệp tiết kiệm điện năng."
	},
	{
		"id": "manometer",
		"display_name": "Manometer",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 5,
		"weight_str": "0.80KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a189.png",
		"description": "Đồng hồ đo áp suất khí kèm van đôi điều áp hệ thống đường ống."
	},
	{
		"id": "leveler",
		"display_name": "Leveler",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 5,
		"weight_str": "1.20KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a190.png",
		"description": "Thước thủy nivo cân bằng bọt nước đo độ nghiêng bề mặt công trình."
	},
	{
		"id": "capacitor",
		"display_name": "Capacitor",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.10KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a191.png",
		"description": "Tụ điện hóa cao áp tích trữ điện năng và ổn định điện áp mạch."
	},
	{
		"id": "lithium_battery",
		"display_name": "Lithium Battery",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.10KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a192.png",
		"description": "Khối pin Lithium mỏng dung lượng cao cho thiết bị liên lạc cầm tay."
	},
	{
		"id": "dvd_drive",
		"display_name": "DVD Drive",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.60KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a193.png",
		"description": "Ổ đĩa quang DVD cơ học đọc ghi đĩa quang dữ liệu lưu trữ."
	},
	{
		"id": "power_supply",
		"display_name": "Power",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 7,
		"weight_str": "2.60KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a194.png",
		"description": "Bộ nguồn chuyển mạch ATX quạt lưới tổ ong cung cấp điện tải nặng."
	},

	# --- Phẩm Xanh Dương (Blue) & Xanh Lá (Green): Các vật phẩm trong ảnh 8 (a171 - a182) ---
	{
		"id": "hunting_matches",
		"display_name": "Hunting Matches",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 8,
		"weight_str": "0.20KG",
		"category": "general",
		"asset_path": "res://assets/auction_items/a171.png",
		"description": "Hộp diêm săn bắn chuyên dụng chống gió và chống nước trong điều kiện khắc nghiệt."
	},
	{
		"id": "multi_purpose_battery",
		"display_name": "Multi-Purpose Battery",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 10,
		"weight_str": "0.10KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a172.png",
		"description": "Khối pin thông minh đa năng 5200mAh tích hợp đầu đèn chiếu sáng dã chiến."
	},
	{
		"id": "light_outdoor_stove",
		"display_name": "Light Outdoor Stove",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 11,
		"weight_str": "1.60KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a173.png",
		"description": "Bếp gas dã ngoại siêu nhẹ gấp gọn gắn bình áp suất cao phục vụ đun nấu sinh tồn."
	},
	{
		"id": "medical_uav",
		"display_name": "Medical UAV",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 15,
		"weight_str": "1.09KG",
		"category": "medical",
		"asset_path": "res://assets/auction_items/a174.png",
		"description": "Thiết bị bay không người lái bốn cánh vận chuyển huyết thanh và thuốc cấp cứu tự hành."
	},
	{
		"id": "electric_lighter",
		"display_name": "Electric Lighter",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 10,
		"weight_str": "0.10KG",
		"category": "general",
		"asset_path": "res://assets/auction_items/a175.png",
		"description": "Bật lửa điện tử phóng tia hồ quang plasma chống gió thổi mạnh."
	},
	{
		"id": "mini_hydrogen_battery",
		"display_name": "Mini Hydrogen Battery",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "<0.10KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a176.png",
		"description": "Thỏi pin nhiên liệu hydro mini cung cấp dòng điện ổn định cho cảm biến tinh vi."
	},
	{
		"id": "screwdriver",
		"display_name": "Screwdriver",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.15KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a177.png",
		"description": "Tua vít hai đầu cán bọc cao su cách điện chuyên dùng tháo lắp linh kiện cơ khí."
	},
	{
		"id": "electric_breaching_hammer",
		"display_name": "Electric Breaching Hammer",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 5,
		"weight_str": "2.20KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a178.png",
		"description": "Máy đục phá khóa thủy lực cầm tay chạy điện dùng cho đột nhập cứu nạn nhanh."
	},
	{
		"id": "wood_plank",
		"display_name": "Wood Plank",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 5,
		"weight_str": "0.60KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a179.png",
		"description": "Tấm ván gỗ ép xử lý chống ẩm dùng làm tấm kê gia cố công sự hoặc đóng hòm."
	},
	{
		"id": "wire",
		"display_name": "Wire",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.20KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a180.png",
		"description": "Cuộn dây đồng trần dẫn điện bọc sợi chịu lực dùng nối mạch và buộc cố định."
	},
	{
		"id": "portable_hydraulic_wrench",
		"display_name": "Portable Hydraulic Wrench",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.50KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a181.png",
		"description": "Cờ lê thủy lực cơ học đầu khẩu màng trập tự điều chỉnh kích cỡ đai ốc."
	},
	{
		"id": "needle_nose_pliers",
		"display_name": "Needle-Nose Pliers",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 4,
		"weight_str": "0.20KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a182.png",
		"description": "Kìm mỏ nhọn mũi thẳng thon dài chuyên kẹp gắp dây và uốn nắn chi tiết nhỏ."
	},

	# --- Phẩm Xanh Dương (Blue): Các vật phẩm trong ảnh 9 (a159 - a170) ---
	{
		"id": "ahsarah_fashion_magazine",
		"display_name": "Ahsarah Fashion Magazine",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 14,
		"weight_str": "0.23KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a159.png",
		"description": "Tạp chí thời trang cao cấp Venus số đặc biệt in hình bìa người mẫu danh tiếng."
	},
	{
		"id": "basic_ammo_production_kit",
		"display_name": "Basic Ammo Production Kit",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 13,
		"weight_str": "0.45KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a160.png",
		"description": "Khay chứa đạn và dụng cụ nạp thuốc súng cơ bản dùng cho huấn luyện xạ thủ."
	},
	{
		"id": "delta_force_black_hawk_down",
		"display_name": "Delta Force: Black Hawk Down",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 10,
		"weight_str": "<0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a161.png",
		"description": "Đĩa cài đặt trò chơi kinh điển Delta Force: Black Hawk Down bản Team Sabre nguyên gốc."
	},
	{
		"id": "delta_force_task_force_dagger",
		"display_name": "Delta Force: Task Force Dagger",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 10,
		"weight_str": "<0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a162.png",
		"description": "Đĩa quang trò chơi Task Force Dagger của hãng NovaLogic lưu giữ dữ liệu cổ xưa."
	},
	{
		"id": "electronic_thermostat",
		"display_name": "Electronic Thermostat",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 12,
		"weight_str": "0.50KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a163.png",
		"description": "Tủ ủ nhiệt điện tử điều khiển vi mạch duy trì nhiệt độ bảo quản mẫu sinh học."
	},
	{
		"id": "bone_saw",
		"display_name": "Bone Saw",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 3,
		"grid_height": 1,
		"silver_value": 11,
		"weight_str": "2.00KG",
		"category": "medical",
		"asset_path": "res://assets/auction_items/a164.png",
		"description": "Cưa xương phẫu thuật cán kim loại lưỡi răng cưa mịn chuyên dùng trong đại phẫu."
	},
	{
		"id": "mocha_coffee_pot",
		"display_name": "Mocha Coffee Pot",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 10,
		"weight_str": "0.80KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a165.png",
		"description": "Ấm pha cà phê Moka áp suất hơi nước bằng nhôm đúc tráng men đen sang trọng."
	},
	{
		"id": "vitamin_effervescent_tablets",
		"display_name": "Vitamin Effervescent Tablets",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 9,
		"weight_str": "0.10KG",
		"category": "medical",
		"asset_path": "res://assets/auction_items/a166.png",
		"description": "Ống viên sủi Vitamin C 1000mg hòa tan nhanh giúp tăng cường sức đề kháng tức thì."
	},
	{
		"id": "english_tea_bag",
		"display_name": "English Tea Bag",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 8,
		"weight_str": "0.10KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a167.png",
		"description": "Hộp thiếc hồng trà thượng hạng Sweet Tea ướp hương hoa sấy khô hảo hạng."
	},
	{
		"id": "wooden_carved_pipe",
		"display_name": "Wooden Carved Pipe",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 12,
		"weight_str": "0.20KG",
		"category": "antique",
		"asset_path": "res://assets/auction_items/a168.png",
		"description": "Tẩu thuốc lá chạm khắc gỗ thạch nam vân nổi tinh xảo viền kim loại quý phái."
	},
	{
		"id": "sugar_bun",
		"display_name": "Sugar Bun",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 8,
		"weight_str": "0.20KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a169.png",
		"description": "Bánh ngọt kim tự tháp hương đường mật nướng giòn điểm số ấn hoàng gia."
	},
	{
		"id": "intel_recorder",
		"display_name": "Intel Recorder",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 3,
		"silver_value": 15,
		"weight_str": "1.00KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a170.png",
		"description": "Máy ghi âm tình báo chuyên dụng đa kênh tích hợp mic định hướng bắt sóng tầm xa."
	},

	# --- Phẩm Xanh Dương (Blue): Các vật phẩm trong ảnh 10 (a147 - a158) ---
	{
		"id": "medical_alcohol",
		"display_name": "Medical Alcohol",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 9,
		"weight_str": "0.72KG",
		"category": "medical",
		"asset_path": "res://assets/auction_items/a147.png",
		"description": "Chai cồn y tế Isopropyl 75% sát khuẩn vết thương và khử trùng dụng cụ."
	},
	{
		"id": "fried_noodles",
		"display_name": "Fried Noodles",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 8,
		"weight_str": "0.27KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a148.png",
		"description": "Gói mì xào thịt xé dưa chua sấy khô ép chân không bổ dưỡng."
	},
	{
		"id": "coke",
		"display_name": "Coke",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 8,
		"weight_str": "0.27KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a149.png",
		"description": "Lon nước ngọt có ga Elis vị cola giải khát sảng khoái và tăng hưng phấn."
	},
	{
		"id": "canned_ration",
		"display_name": "Canned Ration",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 8,
		"weight_str": "0.31KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a150.png",
		"description": "Hộp đồ hộp khẩu phần thịt bò kho hầm chín kỹ dã chiến giàu đạm."
	},
	{
		"id": "soy_protein_powder",
		"display_name": "Soy Protein Powder",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 8,
		"weight_str": "0.45KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a151.png",
		"description": "Túi bột đạm đậu nành cô đặc bổ sung dinh dưỡng và tăng cơ bắp nhanh chóng."
	},
	{
		"id": "flash_drive",
		"display_name": "Flash Drive",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 15,
		"weight_str": "<0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a152.png",
		"description": "Ổ nhớ USB Flash Drive nhỏ gọn bảo mật dữ liệu quân sự mật mã cao."
	},
	{
		"id": "memory_card",
		"display_name": "Memory Card",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 14,
		"weight_str": "<0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a153.png",
		"description": "Thẻ nhớ ConDisk Extreme 256GB tốc độ cao lưu trữ hình ảnh và tọa độ mật."
	},
	{
		"id": "data_trade_documents",
		"display_name": "Data: Trade Documents",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 13,
		"weight_str": "<0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a154.png",
		"description": "Ổ cứng gắn trong chứa toàn bộ hồ sơ giao thương buôn bán bí mật giữa các phủ."
	},
	{
		"id": "intel_document",
		"display_name": "Intel Document",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 14,
		"weight_str": "0.22KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a155.png",
		"description": "Bìa kẹp tài liệu tình báo tuyệt mật đóng dấu mật thư phòng nội các."
	},
	{
		"id": "weird_pirate_silver_coin",
		"display_name": "Weird Pirate Silver Coin",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 13,
		"weight_str": "0.68KG",
		"category": "antique",
		"asset_path": "res://assets/auction_items/a156.png",
		"description": "Đồng bạc cổ hải tặc khắc hình thần mặt trời viền rắn ngậm đuôi Ouroboros kỳ bí."
	},
	{
		"id": "ancient_pirate_telescope",
		"display_name": "Ancient Pirate Telescope",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 14,
		"weight_str": "0.83KG",
		"category": "antique",
		"asset_path": "res://assets/auction_items/a157.png",
		"description": "Kính viễn vọng đơn thị cổ của hải tặc bọc da đen nạm vàng dùng viễn thám đường biển."
	},
	{
		"id": "dancing_girl_statue",
		"display_name": "Dancing Girl - Custom Statue",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 11,
		"weight_str": "0.45KG",
		"category": "antique",
		"asset_path": "res://assets/auction_items/a158.png",
		"description": "Tượng vũ nữ bạc nguyên khối tạo hình vũ điệu cung đình cổ đại duyên dáng."
	},

	# --- Phẩm Xanh Dương (Blue): Các vật phẩm trong ảnh 11 (a135 - a146) ---
	{
		"id": "cordless_portable_drill",
		"display_name": "Cordless Portable Drill",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 12,
		"weight_str": "0.86KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a135.png",
		"description": "Máy khoan pin cầm tay không dây trang bị động cơ không chổi than tốc độ cao."
	},
	{
		"id": "relay",
		"display_name": "Relay",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 9,
		"weight_str": "0.36KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a136.png",
		"description": "Rơ-le công nghiệp Hudson Industries chuyển mạch tự động đóng ngắt an toàn."
	},
	{
		"id": "military_power_bank",
		"display_name": "Military Power Bank",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 11,
		"weight_str": "0.90KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a137.png",
		"description": "Trạm sạc dự phòng quân sự vỏ kim loại chịu va đập kèm cáp đa chuẩn."
	},
	{
		"id": "audio_player",
		"display_name": "Audio Player",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 12,
		"weight_str": "0.18KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a138.png",
		"description": "Máy nghe nhạc kỹ thuật số bỏ túi lưu giữ các đoạn băng thu âm và giai điệu xưa."
	},
	{
		"id": "camera",
		"display_name": "Camera",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 15,
		"weight_str": "0.72KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a139.png",
		"description": "Camera hành trình khối lập phương chống nước ghi hình góc rộng độ phân giải cao."
	},
	{
		"id": "lcd_screen",
		"display_name": "LCD Screen",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 12,
		"weight_str": "1.81KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a140.png",
		"description": "Tấm nền màn hình LCD hiển thị tinh thể lỏng tích hợp cáp bẹ kết nối vi xử lý."
	},
	{
		"id": "solar_panel",
		"display_name": "Solar Panel",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 4,
		"grid_height": 2,
		"silver_value": 14,
		"weight_str": "2.26KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a141.png",
		"description": "Tấm pin năng lượng mặt trời quang điện gấp gọn khung hợp kim nhôm hấp thụ quang năng."
	},
	{
		"id": "gunpowder",
		"display_name": "Gunpowder",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 11,
		"weight_str": "0.54KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a142.png",
		"description": "Bình thuốc súng đen công nghiệp nguyên chất niêm phong phục vụ chế tạo đạn dược."
	},
	{
		"id": "firearm_parts",
		"display_name": "Firearm Parts",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 13,
		"weight_str": "0.50KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a143.png",
		"description": "Bộ linh kiện súng trường cơ bản gồm nòng súng, khóa nòng và ốp tay cầm gỗ."
	},
	{
		"id": "socket_adapter",
		"display_name": "Socket Adapter",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 8,
		"weight_str": "0.12KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a144.png",
		"description": "Bộ chuyển đổi đầu cắm điện mô-đun công nghiệp hỗ trợ nhiều chân tiếp xúc."
	},
	{
		"id": "forehead_thermometer",
		"display_name": "Forehead Thermometer",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 13,
		"weight_str": "0.58KG",
		"category": "medical",
		"asset_path": "res://assets/auction_items/a145.png",
		"description": "Nhiệt kế hồng ngoại đo trán không tiếp xúc quét thân nhiệt tức thì qua cảm biến."
	},
	{
		"id": "stethoscope",
		"display_name": "Stethoscope",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 14,
		"weight_str": "<0.10KG",
		"category": "medical",
		"asset_path": "res://assets/auction_items/a146.png",
		"description": "Ống nghe y tế màng kép khuếch đại âm thanh nhịp tim và tiếng thở nội tạng."
	},

	# --- Đợt 12: 12 Vật phẩm mới (Batch 12: 2 Purple + 10 Blue, a123 -> a134) ---
	{
		"id": "military_camping_lantern",
		"display_name": "Military Camping Lantern",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 3,
		"silver_value": 22,
		"weight_str": "2.20KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a123.png",
		"description": "Đèn cắm trại quân dụng dã chiến bằng kim loại bền chắc, chịu va đập và chiếu sáng xuyên đêm."
	},
	{
		"id": "portable_survival_kit",
		"display_name": "Portable Survival Kit",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 27,
		"weight_str": "2.60KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a124.png",
		"description": "Bộ hộp sinh tồn dã ngoại EDC chuyên nghiệp chứa đầy đủ dụng cụ khẩn cấp trong hộp thiếc."
	},
	{
		"id": "pack_of_cement",
		"display_name": "Pack of Cement",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 2,
		"grid_height": 3,
		"silver_value": 9,
		"weight_str": "4.52KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a125.png",
		"description": "Bao xi măng Kena Cement chất lượng cao dùng trong xây dựng và gia cố công trình kiến trúc."
	},
	{
		"id": "bucket_of_paint",
		"display_name": "Bucket of Paint",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 8,
		"weight_str": "4.52KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a126.png",
		"description": "Thùng sơn Rainbow Paint sắc vàng thu Autumn Yellow chống thấm và bền màu ngoại thất."
	},
	{
		"id": "mechanical_sledgehammer",
		"display_name": "Mechanical Sledgehammer",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 11,
		"weight_str": "4.98KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a127.png",
		"description": "Máy khoan búa cơ khí hạng nặng chạy điện dùng để phá đá và đục bê tông kiên cố."
	},
	{
		"id": "high_precision_caliper",
		"display_name": "High-precision Caliper",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 14,
		"weight_str": "0.45KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a128.png",
		"description": "Thước kẹp điện tử kỹ thuật số đo lường chuẩn xác đến từng mi-li-mét trong gia công cơ khí."
	},
	{
		"id": "polymer_fabric",
		"display_name": "Polymer Fabric",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 8,
		"weight_str": "<0.10KG",
		"category": "general",
		"asset_path": "res://assets/auction_items/a129.png",
		"description": "Tấm bạt vải sợi tổng hợp polymer siêu nhẹ chống thấm nước và che chắn bụi bẩn."
	},
	{
		"id": "fuel",
		"display_name": "Fuel",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 10,
		"weight_str": "2.90KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a130.png",
		"description": "Can dầu nhớt động cơ BSUIOLG 40W chuyên dụng bôi trơn máy móc và cơ cấu truyền động."
	},
	{
		"id": "basic_fuel",
		"display_name": "Basic Fuel",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 8,
		"weight_str": "0.45KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a131.png",
		"description": "Hộp nhiên liệu cồn đun dã chiến có bấc an toàn, tạo ngọn lửa xanh sạch không khói."
	},
	{
		"id": "gas_tank",
		"display_name": "Gas Tank",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 9,
		"weight_str": "4.73KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a132.png",
		"description": "Bình gas mini vỏ thép màu đỏ chứa khí hóa lỏng đun nấu di động tiện lợi."
	},
	{
		"id": "tool_kit",
		"display_name": "Tool Kit",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 13,
		"weight_str": "1.45KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a133.png",
		"description": "Hộp đồ nghề sửa chữa đa năng gồm tua-vít, kìm, cờ-lê và các đầu vặn cơ khí tiêu chuẩn."
	},
	{
		"id": "aramid_fiber",
		"display_name": "Aramid Fiber",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 12,
		"weight_str": "1.61KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a134.png",
		"description": "Tấm sợi Aramid cấu trúc gợn sóng chịu nhiệt cao và chống đâm xuyên dùng trong áo giáp."
	},

	# --- Đợt 13: 12 Vật phẩm phẩm Tím (Batch 13: 12 Purple, a111 -> a122) ---
	{
		"id": "military_thermal_imager",
		"display_name": "Military Thermal Imager",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 2,
		"grid_height": 3,
		"silver_value": 26,
		"weight_str": "1.81KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a111.png",
		"description": "Hệ thống camera ảnh nhiệt quân sự xoay quét tầm nhiệt mục tiêu trong màn đêm."
	},
	{
		"id": "wide_angle_lens",
		"display_name": "Wide-Angle Lens",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 25,
		"weight_str": "0.63KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a112.png",
		"description": "Ống kính góc rộng khẩu độ lớn với thấu kính quang học đa lớp chống lóa mắt."
	},
	{
		"id": "professional_sound_card",
		"display_name": "Professional Sound Card",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 24,
		"weight_str": "1.21KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a113.png",
		"description": "Card xử lý âm thanh chuyên nghiệp chuẩn phòng thu với bộ tản nhiệt nhôm đỏ NS."
	},
	{
		"id": "ceremony_dagger",
		"display_name": "Ceremony Dagger",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 3,
		"grid_height": 2,
		"silver_value": 28,
		"weight_str": "0.75KG",
		"category": "antique",
		"asset_path": "res://assets/auction_items/a114.png",
		"description": "Dao găm nghi lễ hoàng triều đúc từ thép hoa văn khảm vàng và chuôi ngọc tinh xảo."
	},
	{
		"id": "encrypted_router",
		"display_name": "Encrypted Router",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 25,
		"weight_str": "2.17KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a115.png",
		"description": "Bộ định tuyến truyền tin mã hóa phần cứng TGD bảo vệ mạng lưới liên lạc bí mật."
	},
	{
		"id": "sterile_dressing_pack",
		"display_name": "Sterile Dressing Pack",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 21,
		"weight_str": "0.50KG",
		"category": "medical",
		"asset_path": "res://assets/auction_items/a116.png",
		"description": "Gói băng gạc vô trùng cầm máu áp lực khẩn cấp tiêu chuẩn cứu thương chiến trường."
	},
	{
		"id": "ahsarah_guard_dossier",
		"display_name": "Ahsarah Guard Dossier",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 29,
		"weight_str": "<0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a117.png",
		"description": "Hồ sơ mật Black Tide đóng dấu sáp niêm phong của Cấm Vệ Quân Ahsarah hoàng gia."
	},
	{
		"id": "capsule_coffee_machine",
		"display_name": "Capsule Coffee Machine",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 22,
		"weight_str": "3.50KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a118.png",
		"description": "Máy pha cà phê viên nén áp suất cao hiện đại đi kèm bộ đôi ly đồng chạm khắc."
	},
	{
		"id": "delta_force_team_sabre",
		"display_name": "Delta Force: Team Sabre",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 23,
		"weight_str": "0.15KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a119.png",
		"description": "Hộp đĩa game kinh điển Delta Force - Team Sabre còn nguyên vỏ bảo quản nguyên bản."
	},
	{
		"id": "portable_speakers",
		"display_name": "Portable Speakers",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 24,
		"weight_str": "1.60KG",
		"category": "general",
		"asset_path": "res://assets/auction_items/a120.png",
		"description": "Hệ thống loa Bluetooth di động dã chiến chống nước với đèn LED đổi màu rực rỡ."
	},
	{
		"id": "signal_stick",
		"display_name": "Signal Stick",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 20,
		"weight_str": "1.00KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a121.png",
		"description": "Cây pháo hiệu cứu sinh hóa học màu cam phát tín hiệu cầu cứu tầm xa khẩn cấp."
	},
	{
		"id": "gas_torch",
		"display_name": "Gas Torch",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 21,
		"weight_str": "2.00KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a122.png",
		"description": "Đầu khò gas lửa xoáy nhiệt độ cao chuyên dụng hàn kim loại và mồi lửa dã ngoại."
	},

	# --- Đợt 14: 12 Vật phẩm phẩm Tím (Batch 14: 12 Purple, a099 -> a110) ---
	{
		"id": "ev_battery",
		"display_name": "EV Battery",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 3,
		"grid_height": 2,
		"silver_value": 24,
		"weight_str": "9.23KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a099.png",
		"description": "Bình ắc-quy xe điện công suất lớn vỏ chống rò rỉ dung tích lưu trữ cao."
	},
	{
		"id": "damaged_thermal_imager",
		"display_name": "Damaged Thermal Imager",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 21,
		"weight_str": "0.83KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a100.png",
		"description": "Kính ngắm ảnh nhiệt quân sự bị nứt kính ngoài nhưng cảm biến vi mạch vẫn hoạt động."
	},
	{
		"id": "blood_pressure_monitor",
		"display_name": "Blood Pressure Monitor",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 23,
		"weight_str": "1.27KG",
		"category": "medical",
		"asset_path": "res://assets/auction_items/a101.png",
		"description": "Máy đo huyết áp điện tử bắp tay tự động với màn hình tinh thể lỏng báo nhịp tim."
	},
	{
		"id": "lemon_tea",
		"display_name": "Lemon Tea",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 20,
		"weight_str": "0.27KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a102.png",
		"description": "Lon trà chanh SUE ướp lạnh giải khát, tăng cường thể lực và giải nhiệt tức thì."
	},
	{
		"id": "orange_energy_gel",
		"display_name": "Orange Energy Gel",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 20,
		"weight_str": "<0.10KG",
		"category": "kitchen",
		"asset_path": "res://assets/auction_items/a103.png",
		"description": "Gói gel năng lượng hương cam DHG đậm đặc bổ sung năng lượng tức thời cho vận động viên."
	},
	{
		"id": "data_military_intel",
		"display_name": "Data: Military Intel",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 30,
		"weight_str": "<0.10KG",
		"category": "document",
		"asset_path": "res://assets/auction_items/a104.png",
		"description": "Bo mạch lưu trữ dữ liệu bản đồ phòng thủ và tọa độ binh lực quân sự tối mật."
	},
	{
		"id": "cutlass",
		"display_name": "Cutlass",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 27,
		"weight_str": "1.70KG",
		"category": "antique",
		"asset_path": "res://assets/auction_items/a105.png",
		"description": "Đoản đao hải tặc chuôi đúc hình chim ưng mạ vàng nạm ngọc trong vỏ bao da thuộc."
	},
	{
		"id": "antler_wall_decoration",
		"display_name": "Antler Wall Decoration",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 22,
		"weight_str": "0.72KG",
		"category": "antique",
		"asset_path": "res://assets/auction_items/a106.png",
		"description": "Bộ gạc sừng linh dương chạm trổ hoa văn phong thủy treo tường trừ tà cầu an."
	},
	{
		"id": "empress_earrings",
		"display_name": "Empress Earrings",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 31,
		"weight_str": "0.18KG",
		"category": "antique",
		"asset_path": "res://assets/auction_items/a107.png",
		"description": "Đôi hoa tai bạc của bậc Hoàng Hậu chế tác tinh xảo đính ngọc hồng lựu quý giá."
	},
	{
		"id": "ahsarah_special_teapot",
		"display_name": "Ahsarah Special Teapot",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 28,
		"weight_str": "1.27KG",
		"category": "antique",
		"asset_path": "res://assets/auction_items/a108.png",
		"description": "Ấm trà sứ mạ vàng Ahsarah nạm đá quý với quai cầm uốn lượn phong cách cung đình."
	},
	{
		"id": "gold_crest",
		"display_name": "Gold Crest",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 29,
		"weight_str": "0.73KG",
		"category": "antique",
		"asset_path": "res://assets/auction_items/a109.png",
		"description": "Huy hiệu vương quyền hình tam giác đúc bằng vàng ròng nguyên khối biểu trưng cho quyền lực."
	},
	{
		"id": "intermediate_ammo_production_kit",
		"display_name": "Intermediate Ammo Kit",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 25,
		"weight_str": "1.09KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a110.png",
		"description": "Bộ khuôn đúc và máy ép đạn trung cấp kèm khay đựng đầu đạn hợp kim đồng."
	},

	# --- Đợt 15: 12 Vật phẩm phẩm Tím (Batch 15: 12 Purple, a087 -> a098) ---
	{
		"id": "ceramic_armor",
		"display_name": "Ceramic Armor",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 24,
		"weight_str": "1.36KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a087.png",
		"description": "Tấm giáp chống đạn chế tác từ gốm kỹ thuật nén áp lực cao siêu nhẹ và phân tán lực."
	},
	{
		"id": "special_steel",
		"display_name": "Special Steel",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 22,
		"weight_str": "2.49KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a088.png",
		"description": "Tấm thép cường lực đặc chủng chống xuyên giáp dùng gia cố áo giáp quân sự."
	},
	{
		"id": "titanium_alloy",
		"display_name": "Titanium Alloy",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 26,
		"weight_str": "2.04KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a089.png",
		"description": "Tấm hợp kim titan bề mặt phay xước sáng bóng, độ cứng vượt trội chịu nhiệt cực hạn."
	},
	{
		"id": "ssd",
		"display_name": "SSD",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 26,
		"weight_str": "<0.10KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a090.png",
		"description": "Ổ cứng thể rắn KINGSDEN dung lượng 1TB chứa dữ liệu sao lưu hệ thống tốc độ cao."
	},
	{
		"id": "ram",
		"display_name": "RAM",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 25,
		"weight_str": "<0.10KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a091.png",
		"description": "Thanh bộ nhớ RAM TWEAT bọc giáp tản nhiệt kim loại tối ưu tốc độ xử lý tác vụ."
	},
	{
		"id": "asos_motherboard",
		"display_name": "ASOS Motherboard",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 2,
		"grid_height": 2,
		"silver_value": 27,
		"weight_str": "2.31KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a092.png",
		"description": "Bo mạch chủ máy tính ASOS cao cấp trang bị tụ điện rắn và dàn tản nhiệt hầm hố."
	},
	{
		"id": "radio",
		"display_name": "Radio",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 21,
		"weight_str": "0.27KG",
		"category": "general",
		"asset_path": "res://assets/auction_items/a093.png",
		"description": "Máy thu thanh radio dã chiến vỏ kim loại có ăng-ten kéo dài bắt sóng đa băng tần."
	},
	{
		"id": "ecm_jammer",
		"display_name": "ECM Jammer",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 30,
		"weight_str": "0.27KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a094.png",
		"description": "Thiết bị áp chế điện tử ECM quân sự cực mạnh phá sóng liên lạc và làm nhiễu radar."
	},
	{
		"id": "hifi_sound_card",
		"display_name": "HiFi Sound Card",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 23,
		"weight_str": "1.00KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a095.png",
		"description": "Card xử lý âm thanh trung thực HiFi mạ vàng cho chất lượng tái tạo âm thanh chuẩn xác."
	},
	{
		"id": "gs5_controller",
		"display_name": "GS5 Controller",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 24,
		"weight_str": "0.36KG",
		"category": "cards",
		"asset_path": "res://assets/auction_items/a096.png",
		"description": "Tay cầm điều khiển thực tế ảo GS5 thiết kế công thái học uốn cong công nghệ tương lai."
	},
	{
		"id": "ahsarah_glamour_hookah",
		"display_name": "Ahsarah Glamour Hookah",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 2,
		"silver_value": 28,
		"weight_str": "0.72KG",
		"category": "antique",
		"asset_path": "res://assets/auction_items/a097.png",
		"description": "Bình shisha quý tộc Ahsarah chạm trổ tinh mỹ mạ vàng và nạm đá quý phong cách hoàng gia."
	},
	{
		"id": "spy_pen",
		"display_name": "Spy Pen",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 1,
		"grid_height": 1,
		"silver_value": 29,
		"weight_str": "0.50KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a098.png",
		"description": "Bút ký ngụy trang của điệp viên tích hợp vi mạch ghi âm siêu nhạy và camera siêu nhỏ."
	},

	# --- Tài nguyên Nâng cấp (Refinement Chips & Locking Component) ---
	{
		"id": "refinement_chips_2",
		"display_name": "Refinement Chips (2)",
		"rarity": ITEM_CLASS.Rarity.WHITE,
		"grid_width": 5,
		"grid_height": 1,
		"silver_value": 0,
		"weight_str": "0.05KG",
		"category": "resource",
		"asset_path": "res://assets/auction_items/refinement_chips.png",
		"is_resource": true,
		"can_sell": false,
		"quantity": 2,
		"description": "Chip tinh luyện phẩm Trắng dùng để nâng cấp thiết bị."
	},
	{
		"id": "refinement_chips_4",
		"display_name": "Refinement Chips (4)",
		"rarity": ITEM_CLASS.Rarity.GREEN,
		"grid_width": 5,
		"grid_height": 1,
		"silver_value": 0,
		"weight_str": "0.05KG",
		"category": "resource",
		"asset_path": "res://assets/auction_items/refinement_chips.png",
		"is_resource": true,
		"can_sell": false,
		"quantity": 4,
		"description": "Chip tinh luyện phẩm Xanh dùng để nâng cấp thiết bị."
	},
	{
		"id": "refinement_chips_8",
		"display_name": "Refinement Chips (8)",
		"rarity": ITEM_CLASS.Rarity.BLUE,
		"grid_width": 5,
		"grid_height": 1,
		"silver_value": 0,
		"weight_str": "0.05KG",
		"category": "resource",
		"asset_path": "res://assets/auction_items/refinement_chips.png",
		"is_resource": true,
		"can_sell": false,
		"quantity": 8,
		"description": "Chip tinh luyện phẩm Xanh Dương cao cấp."
	},
	{
		"id": "refinement_chips_16",
		"display_name": "Refinement Chips (16)",
		"rarity": ITEM_CLASS.Rarity.PURPLE,
		"grid_width": 5,
		"grid_height": 1,
		"silver_value": 0,
		"weight_str": "0.05KG",
		"category": "resource",
		"asset_path": "res://assets/auction_items/refinement_chips.png",
		"is_resource": true,
		"can_sell": false,
		"quantity": 16,
		"description": "Chip tinh luyện phẩm Tím quý giá phục vụ nghiên cứu."
	},
	{
		"id": "refinement_chips_32",
		"display_name": "Refinement Chips (32)",
		"rarity": ITEM_CLASS.Rarity.GOLD,
		"grid_width": 5,
		"grid_height": 1,
		"silver_value": 0,
		"weight_str": "0.05KG",
		"category": "resource",
		"asset_path": "res://assets/auction_items/refinement_chips.png",
		"is_resource": true,
		"can_sell": false,
		"quantity": 32,
		"description": "Bộ chip tinh luyện Vàng cực hiếm từ kho vũ khố hoàng gia."
	},
	{
		"id": "locking_component_5",
		"display_name": "Locking Component (5)",
		"rarity": ITEM_CLASS.Rarity.RED,
		"grid_width": 5,
		"grid_height": 1,
		"silver_value": 0,
		"weight_str": "0.20KG",
		"category": "resource",
		"asset_path": "res://assets/auction_items/locking_component.png",
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
		var is_res: bool = bool(it.get("is_resource", false)) or String(it.get("category", "")) == "resource"
		if is_res:
			if category_filter != "resource":
				continue
		elif not category_filter.is_empty() and String(it.get("category", "")) != category_filter:
			continue

		if rarity_filter >= 0 and int(it.get("rarity", -1)) != rarity_filter:
			continue

		if shape_filter != Vector2i.ZERO and not is_res:
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
		var is_res: bool = bool(it.get("is_resource", false)) or String(it.get("category", "")) == "resource"
		if is_res:
			# Tài nguyên chỉ xuất hiện khi bấm vào DUY NHẤT lựa chọn lọc loại tài nguyên
			if not (filter_category and allowed_categories.size() == 1 and allowed_categories.has("resource")):
				continue
		elif filter_category:
			var cat: String = String(it.get("category", ""))
			if not allowed_categories.has(cat):
				continue

		if filter_rarity:
			var r: int = int(it.get("rarity", -1))
			if not allowed_rarities.has(r):
				continue

		# Kích cỡ của tài nguyên là 5x1, không có bộ lọc kích cỡ cho chúng (chỉ có thể lọc qua tài nguyên)
		if filter_shape and not is_res:
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
