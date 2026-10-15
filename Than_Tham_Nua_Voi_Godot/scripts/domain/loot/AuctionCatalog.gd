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
		"grid_height": 1,
		"silver_value": 5,
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
		"grid_width": 2,
		"grid_height": 1,
		"silver_value": 5,
		"weight_str": "1.50KG",
		"category": "tool",
		"asset_path": "res://assets/auction_items/a230.png",
		"description": "Cưa tay khung kim loại răng cưa hợp kim bén ngọt cắt vật liệu cứng."
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
