class_name ProductionHouseRepository
extends RefCounted

const HOUSE_PATHS: Array[String] = [
	"res://content/houses/house_hoang.tres",
	"res://content/houses/house_chu.tres",
	"res://content/houses/house_kim.tres",
	"res://content/houses/house_huyen.tres",
	"res://content/houses/house_lam.tres",
]


static func load_all() -> Array[HouseDefinition]:
	var houses: Array[HouseDefinition] = []
	for path: String in HOUSE_PATHS:
		var house: HouseDefinition = load(path) as HouseDefinition
		if house != null:
			houses.append(house)
	houses.sort_custom(func(a: HouseDefinition, b: HouseDefinition) -> bool:
		return a.display_order < b.display_order
	)
	return houses


static func find(house_id: StringName) -> HouseDefinition:
	for house: HouseDefinition in load_all():
		if house.house_id == house_id:
			return house
	return null
