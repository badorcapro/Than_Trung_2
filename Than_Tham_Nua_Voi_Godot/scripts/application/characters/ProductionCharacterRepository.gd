class_name ProductionCharacterRepository
extends RefCounted

const CHARACTER_PATHS: Array[String] = [
	"res://content/characters/production/character_hoang_linh_lam.tres",
	"res://content/characters/production/character_chu_tue_nguyet.tres",
	"res://content/characters/production/character_kim_thanh_giai.tres",
	"res://content/characters/production/character_huyen_ca_xuy.tres",
	"res://content/characters/production/character_lam_phuong_xuan.tres",
]


static func load_all() -> Array[CharacterDefinition]:
	var characters: Array[CharacterDefinition] = []
	for path: String in CHARACTER_PATHS:
		var character: CharacterDefinition = load(path) as CharacterDefinition
		if character != null:
			characters.append(character)
	return characters


static func find(character_id: StringName) -> CharacterDefinition:
	for character: CharacterDefinition in load_all():
		if character.character_id == character_id:
			return character
	return null
