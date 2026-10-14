class_name MysteryChestItem
extends RefCounted

enum Rarity {
	WHITE = 0,      # Trắng - Thường
	GREEN = 1,      # Xanh lá - Tinh xảo
	BLUE = 2,       # Xanh dương - Quý hiếm
	PURPLE = 3,     # Tím - Sử thi
	GOLD = 4,       # Vàng - Huyền thoại
	RED = 5,        # Đỏ - Thần bí / Cổ vật (Nâng cấp phòng thí nghiệm)
}

var item_id: StringName = &""
var display_name: String = ""
var rarity: Rarity = Rarity.WHITE
var silver_value: int = 10
var grid_width: int = 1
var grid_height: int = 1
var icon: String = "📦"
var description: String = ""


static func rarity_name(r: Rarity) -> String:
	match r:
		Rarity.WHITE: return "Trắng"
		Rarity.GREEN: return "Xanh lá"
		Rarity.BLUE: return "Xanh dương"
		Rarity.PURPLE: return "Tím"
		Rarity.GOLD: return "Vàng"
		Rarity.RED: return "Đỏ"
		_: return "Không rõ"


static func rarity_color(r: Rarity) -> Color:
	match r:
		Rarity.WHITE: return Color(0.9, 0.9, 0.92)
		Rarity.GREEN: return Color(0.32, 0.86, 0.44)
		Rarity.BLUE: return Color(0.28, 0.68, 1.0)
		Rarity.PURPLE: return Color(0.78, 0.38, 0.98)
		Rarity.GOLD: return Color(1.0, 0.84, 0.22)
		Rarity.RED: return Color(0.96, 0.22, 0.28)
		_: return Color.WHITE


func is_lab_upgrade_material() -> bool:
	return rarity == Rarity.RED


func to_dict() -> Dictionary:
	return {
		"item_id": String(item_id),
		"display_name": display_name,
		"rarity": int(rarity),
		"silver_value": silver_value,
		"grid_width": grid_width,
		"grid_height": grid_height,
		"icon": icon,
		"description": description,
	}


static func from_dict(data: Dictionary) -> MysteryChestItem:
	var item := MysteryChestItem.new()
	item.item_id = StringName(data.get("item_id", ""))
	item.display_name = String(data.get("display_name", ""))
	item.rarity = int(data.get("rarity", Rarity.WHITE)) as Rarity
	item.silver_value = int(data.get("silver_value", 10))
	item.grid_width = int(data.get("grid_width", 1))
	item.grid_height = int(data.get("grid_height", 1))
	item.icon = String(data.get("icon", "📦"))
	item.description = String(data.get("description", ""))
	return item
