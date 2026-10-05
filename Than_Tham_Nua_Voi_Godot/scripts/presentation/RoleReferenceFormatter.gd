class_name RoleReferenceFormatter
extends RefCounted

const BODY_FONT_SIZE: int = 13
const TERM_CATEGORY_KEY_TERM: StringName = &"KEY_TERM"
const TERM_CATEGORY_LYING: StringName = &"LYING"
const TERM_CATEGORY_EVIL: StringName = &"EVIL"
const TERM_CATEGORY_TAINTED: StringName = &"TAINTED"
const TERM_CATEGORY_GROUP: StringName = &"GROUP"
const TERM_CATEGORY_ALIGNMENT: StringName = &"ALIGNMENT"
const GLOSSARY_LINK_COLOR: Color = Color(0.82, 0.90, 1.0, 1.0)
const LYING_COLOR: Color = Color(1.0, 0.30, 0.28, 1.0)
const TAINTED_COLOR: Color = Color(0.78, 0.55, 1.0, 1.0)


static func role_reference_text(role: RoleDefinition) -> String:
	var lines: Array[String] = [
		"Nhóm: %s" % role_group_full_label(role.role_group),
		"Phe: %s" % role_alignment_label(role.role_group),
		role_body_text(role),
	]
	return "\n".join(lines)


static func role_reference_bbcode(role: RoleDefinition) -> String:
	var group_label: String = role_group_full_label(role.role_group)
	var alignment_label: String = role_alignment_label(role.role_group)
	var lines: Array[String] = [
		"Nhóm: %s" % style_glossary_term(group_label, TERM_CATEGORY_GROUP, RoleGlossaryBank.resolve_alias(group_label)),
		"Phe: %s" % style_glossary_term(alignment_label, TERM_CATEGORY_ALIGNMENT, RoleGlossaryBank.resolve_alias(alignment_label)),
		role_body_bbcode(role),
	]
	return "\n".join(lines)


static func role_body_text(role: RoleDefinition) -> String:
	if role.help_text.is_empty():
		return "Thông tin luật vai đang ở mức tối giản."
	return player_facing_text(role.help_text)


static func role_body_bbcode(role: RoleDefinition) -> String:
	if role.help_text.is_empty():
		return "Thông tin luật vai đang ở mức tối giản."
	return style_role_reference_terms(player_facing_text(role.help_text))


static func apply_uniform_body_font(label: RichTextLabel) -> void:
	if label == null:
		return
	label.add_theme_font_size_override("normal_font_size", BODY_FONT_SIZE)
	label.add_theme_font_size_override("bold_font_size", BODY_FONT_SIZE)
	label.add_theme_font_size_override("italics_font_size", BODY_FONT_SIZE)
	label.add_theme_font_size_override("bold_italics_font_size", BODY_FONT_SIZE)


static func style_role_reference_terms(value: String) -> String:
	var terms: Array[Dictionary] = term_bank()
	var result: String = ""
	var index: int = 0
	while index < value.length():
		var matched: bool = false
		for entry: Dictionary in terms:
			var term: String = String(entry.get("term", ""))
			if term.is_empty():
				continue
			if value.substr(index, term.length()) == term:
				var category: StringName = StringName(entry.get("category", TERM_CATEGORY_KEY_TERM))
				var glossary_key: StringName = StringName(entry.get("glossary_key", &""))
				result += style_glossary_term(term, category, glossary_key)
				index += term.length()
				matched = true
				break
		if not matched:
			result += value.substr(index, 1)
			index += 1
	return result


static func term_bank() -> Array[Dictionary]:
	var terms: Array[Dictionary] = RoleGlossaryBank.term_entries()
	return _sorted_terms_longest_first(terms)


static func style_glossary_term(term: String, category: StringName, glossary_key: StringName) -> String:
	var styled: String = style_term(term, category)
	if String(glossary_key).is_empty():
		return styled
	return "[url=%s]%s[/url]" % [RoleGlossaryBank.meta_for_key(glossary_key), styled]


static func style_term(term: String, category: StringName) -> String:
	match category:
		TERM_CATEGORY_KEY_TERM:
			return color_bbcode(term, GLOSSARY_LINK_COLOR)
		TERM_CATEGORY_LYING, TERM_CATEGORY_EVIL:
			return color_bbcode(term, LYING_COLOR)
		TERM_CATEGORY_TAINTED:
			return color_bbcode(term, TAINTED_COLOR)
		TERM_CATEGORY_GROUP:
			return color_bbcode(term, role_group_label_color(term))
		TERM_CATEGORY_ALIGNMENT:
			return color_bbcode(term, alignment_label_color(term))
		_:
			return term


static func role_group_label_color(label: String) -> Color:
	match label:
		"Người Vô Tội":
			return role_group_color(CaseEnums.RoleGroup.CHINH_NHAN)
		"Kẻ Bao Đồng":
			return role_group_color(CaseEnums.RoleGroup.HIEU_SU)
		"Thuộc Hạ":
			return role_group_color(CaseEnums.RoleGroup.TONG_PHAM)
		"Nghịch Thần":
			return role_group_color(CaseEnums.RoleGroup.NGHICH_THAN)
		_:
			return role_group_color(-1)


static func alignment_label_color(label: String) -> Color:
	if label == "Phe Ác":
		return role_alignment_color(CaseEnums.RoleGroup.TONG_PHAM)
	return role_alignment_color(CaseEnums.RoleGroup.CHINH_NHAN)


static func _sorted_terms_longest_first(terms: Array[Dictionary]) -> Array[Dictionary]:
	var sorted: Array[Dictionary] = []
	for entry: Dictionary in terms:
		var inserted: bool = false
		var sorted_index: int = 0
		while sorted_index < sorted.size():
			if _term_precedes(entry, sorted[sorted_index]):
				sorted.insert(sorted_index, entry)
				inserted = true
				break
			sorted_index += 1
		if not inserted:
			sorted.append(entry)
	return sorted


static func _term_precedes(a: Dictionary, b: Dictionary) -> bool:
	var a_term: String = String(a.get("term", ""))
	var b_term: String = String(b.get("term", ""))
	if a_term.length() == b_term.length():
		return a_term < b_term
	return a_term.length() > b_term.length()


static func color_bbcode(value: String, color: Color) -> String:
	return "[color=#%s]%s[/color]" % [color.to_html(false), value]


static func role_group_full_label(group: int) -> String:
	match group:
		CaseEnums.RoleGroup.CHINH_NHAN:
			return "Người Vô Tội"
		CaseEnums.RoleGroup.HIEU_SU:
			return "Kẻ Bao Đồng"
		CaseEnums.RoleGroup.TONG_PHAM:
			return "Thuộc Hạ"
		CaseEnums.RoleGroup.NGHICH_THAN:
			return "Nghịch Thần"
		_:
			return "Không xác định"


static func role_alignment_label(group: int) -> String:
	return "Phe Ác" if group in [CaseEnums.RoleGroup.TONG_PHAM, CaseEnums.RoleGroup.NGHICH_THAN] else "Phe Thiện"


static func role_group_color(group: int) -> Color:
	match group:
		CaseEnums.RoleGroup.CHINH_NHAN:
			return Color(0.67, 0.86, 1.0, 1.0)
		CaseEnums.RoleGroup.HIEU_SU:
			return Color(0.96, 0.82, 0.28, 1.0)
		CaseEnums.RoleGroup.TONG_PHAM:
			return Color(1.0, 0.58, 0.55, 1.0)
		CaseEnums.RoleGroup.NGHICH_THAN:
			return Color(0.78, 0.55, 1.0, 1.0)
		_:
			return Color(0.84, 0.88, 0.94, 1.0)


static func role_alignment_color(group: int) -> Color:
	if group in [CaseEnums.RoleGroup.TONG_PHAM, CaseEnums.RoleGroup.NGHICH_THAN]:
		return Color(1.0, 0.58, 0.55, 1.0)
	return Color(0.67, 0.86, 1.0, 1.0)


static func player_facing_text(value: String) -> String:
	return value.replace(" (Fixture)", "").replace("(Fixture)", "").replace(" fixture", "").strip_edges()
