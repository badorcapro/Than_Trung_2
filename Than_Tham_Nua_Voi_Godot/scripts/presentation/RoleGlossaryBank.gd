class_name RoleGlossaryBank
extends RefCounted

const META_PREFIX: String = "glossary:"
const TERM_CATEGORY_KEY_TERM: StringName = &"KEY_TERM"
const TERM_CATEGORY_LYING: StringName = &"LYING"
const TERM_CATEGORY_EVIL: StringName = &"EVIL"
const TERM_CATEGORY_TAINTED: StringName = &"TAINTED"
const TERM_CATEGORY_GROUP: StringName = &"GROUP"
const TERM_CATEGORY_ALIGNMENT: StringName = &"ALIGNMENT"


static func entries() -> Array[Dictionary]:
	return [
		_entry(&"investigate", "Điều tra", "Lật mở một nghi phạm để biết thân phận mà họ đang thể hiện cùng thông tin được công bố.", ["điều tra", "được điều tra", "chưa được điều tra"], TERM_CATEGORY_KEY_TERM),
		_entry(&"announce", "Thông báo", "Thông tin mà một thân phận đưa ra khi được điều tra. Nội dung này sẽ được hiển thị bên dưới tên của họ.", ["thông báo", "đã thông báo"], TERM_CATEGORY_KEY_TERM),
		_entry(&"lie", "Nói dối", "Khi một thân phận nói dối, thông tin hoặc kết quả họ tạo ra sẽ tuân theo quy tắc nói dối của thân phận đó.", ["nói dối", "đang nói dối"], TERM_CATEGORY_LYING),
		_entry(&"tainted", "Tha hóa", "Khi bị tha hóa, một thân phận sẽ hoạt động theo trạng thái tha hóa của mình. Với các thân phận cung cấp thông tin, điều này thường khiến họ nói dối.", ["tha hóa", "bị tha hóa", "Tha Hóa"], TERM_CATEGORY_TAINTED),
		_entry(&"self_confirm", "Tự xác thực", "Một vai trò có thể tự chứng minh mình vô tội. Không thể có nhiều vai trò tự xác thực cùng lúc trong Kỳ Án.", ["tự xác thực"], TERM_CATEGORY_KEY_TERM),
		_entry(&"role", "Thân phận", "Một thân phận có thể xuất hiện trong Kỳ Án và sở hữu những quy tắc, thông tin hoặc chức năng riêng.", ["vai trò", "Vai trò", "thân phận", "Thân phận"], TERM_CATEGORY_KEY_TERM),
		_entry(&"ability", "Chức năng", "Năng lực chủ động của một thân phận, được sử dụng khi người chơi đưa ra lựa chọn. Mỗi chức năng có quy tắc và thời điểm sử dụng riêng.", ["chức năng", "Chức năng"], TERM_CATEGORY_KEY_TERM),
		_entry(&"alignment", "Phe", "Mỗi thân phận thuộc Phe Thiện hoặc Phe Ác. Để phá giải Kỳ Án, cần xác định đầy đủ những thân phận thuộc Phe Ác.", ["phe"], TERM_CATEGORY_KEY_TERM),
		_entry(&"good_alignment", "Phe", "Mỗi thân phận thuộc Phe Thiện hoặc Phe Ác. Để phá giải Kỳ Án, cần xác định đầy đủ những thân phận thuộc Phe Ác.", ["Phe Thiện"], TERM_CATEGORY_ALIGNMENT),
		_entry(&"evil_alignment", "Phe", "Mỗi thân phận thuộc Phe Thiện hoặc Phe Ác. Để phá giải Kỳ Án, cần xác định đầy đủ những thân phận thuộc Phe Ác.", ["Phe Ác"], TERM_CATEGORY_ALIGNMENT),
		_entry(&"target", "Mục tiêu", "Một vai trò đã được một vai trò khác chọn.", ["mục tiêu"], TERM_CATEGORY_KEY_TERM),
		_entry(&"kill", "Giết", "Làm một vai trò chết. Vai trò đã chết không Công Bố Sự Thật, và mọi thông tin chúng từng thông báo sẽ bị mất.", ["Giết", "giết"], TERM_CATEGORY_KEY_TERM),
		_entry(&"dead", "Đã chết", "Một vai trò đã bị giết. Vai trò đã chết không bị lộ vai và thông tin họ từng thông báo sẽ bị mất.", ["đã chết", "chết", "bị giết"], TERM_CATEGORY_KEY_TERM),
		_entry(&"arrest", "Bắt", "Cách chính để ngăn chặn vai trò Phe Ác. Bắt một vai trò cũng sẽ làm lộ vai trò thật của họ.", ["bắt", "bị bắt", "đã bị bắt"], TERM_CATEGORY_KEY_TERM),
		_entry(&"address", "Số Hiệu", "Số Hiệu là số được gán cho mỗi nghi phạm/vai trò đang hiện diện trong Kỳ Án. Các Số Hiệu được đánh liên tiếp từ trái sang phải, từ trên xuống dưới và chỉ tính các ô nghi phạm, không tính Hiện Trường, địa điểm hay ô trống. Khi nghi phạm chưa được điều tra, Số Hiệu được hiển thị trên thẻ của họ; sau khi được điều tra, Số Hiệu vẫn được hiển thị cùng thông tin vai trò.", ["Số Hiệu", "Số hiệu", "số hiệu"], TERM_CATEGORY_KEY_TERM),
		_entry(&"in_play", "Xuất hiện trong Kỳ Án", "Thân phận này thực sự tồn tại trên bàn Kỳ Án hiện tại.", ["đang có trong Kỳ Án", "có trong Kỳ Án", "xuất hiện trong Kỳ Án"], TERM_CATEGORY_KEY_TERM),
		_entry(&"not_in_play", "Không xuất hiện trong Kỳ Án", "Thân phận này không thực sự tồn tại trên bàn Kỳ Án hiện tại.", ["không có trong Kỳ Án", "không xuất hiện trong Kỳ Án"], TERM_CATEGORY_KEY_TERM),
		_entry(&"steps", "Bước", "Một bước là một lần di chuyển từ một ô sang một ô kề cạnh.", ["bước"], TERM_CATEGORY_KEY_TERM),
		_entry(&"adjacent", "Kề cận", "Một nghi phạm kề cận là một vai trò nằm trực tiếp ở phía Bắc, Đông, Nam hoặc Tây của một vai trò khác.", ["kề cận", "nghi phạm kề cận"], TERM_CATEGORY_KEY_TERM),
		_entry(&"obscure", "Che giấu", "Biểu tượng, tên và thông tin của vai trò bị che giấu sẽ bị ẩn; các con số vẫn hiển thị.", ["che giấu", "bị che giấu"], TERM_CATEGORY_KEY_TERM),
		_entry(&"innocent_group", "Người Vô Tội", "Các vai trò Phe Thiện hữu ích, thường cung cấp những thông tin quan trọng để giải Kỳ Án.", ["Người Vô Tội"], TERM_CATEGORY_GROUP),
		_entry(&"meddler_group", "Kẻ Bao Đồng", "Các vai trò Phe Thiện không hữu ích, thường làm thông tin trở nên rối hơn và khiến Kỳ Án khó giải hơn.", ["Kẻ Bao Đồng"], TERM_CATEGORY_GROUP),
		_entry(&"underling_group", "Thuộc Hạ", "", ["Thuộc Hạ"], TERM_CATEGORY_GROUP),
		_entry(&"traitor_group", "Nghịch Thần", "", ["Nghịch Thần"], TERM_CATEGORY_GROUP),
		_entry(&"pretend", "Giả danh", "Khi một thân phận giả danh thân phận khác, họ sẽ xuất hiện dưới danh nghĩa của thân phận đó khi được điều tra và sử dụng thông tin hoặc chức năng tương ứng. Việc họ nói thật hay nói dối được xác định riêng.", ["giả danh", "đang giả danh"], TERM_CATEGORY_KEY_TERM),
		_entry(&"suspected", "Được liệt kê", "Thân phận này xuất hiện trong danh sách THÂN PHẬN của Kỳ Án. Điều đó không có nghĩa rằng họ nhất định sẽ xuất hiện trên bàn.", ["bị nghi ngờ", "vai trò bị nghi ngờ", "được liệt kê", "Được liệt kê"], TERM_CATEGORY_KEY_TERM),
		_entry(&"unarrested", "Chưa bị bắt", "Một vai trò chưa bị bắt.", ["chưa bị bắt"], TERM_CATEGORY_KEY_TERM),
		_entry(&"alive", "Còn sống", "Một vai trò chưa chết.", ["còn sống", "sống"], TERM_CATEGORY_KEY_TERM),
	]


static func style_only_terms() -> Array[Dictionary]:
	return [
		_term("nghi phạm", TERM_CATEGORY_KEY_TERM, &""),
	]


static func term_entries() -> Array[Dictionary]:
	var terms: Array[Dictionary] = []
	for entry: Dictionary in entries():
		var key: StringName = StringName(entry.get("key", &""))
		var category: StringName = StringName(entry.get("category", TERM_CATEGORY_KEY_TERM))
		var aliases: Array = entry.get("aliases", []) as Array
		for alias: Variant in aliases:
			terms.append(_term(String(alias), category, key))
	for style_entry: Dictionary in style_only_terms():
		terms.append(style_entry)
	return terms


static func entry_for_key(key: StringName) -> Dictionary:
	for entry: Dictionary in entries():
		if StringName(entry.get("key", &"")) == key:
			return entry
	return {}


static func resolve_alias(alias: String) -> StringName:
	for entry: Dictionary in entries():
		var key: StringName = StringName(entry.get("key", &""))
		var aliases: Array = entry.get("aliases", []) as Array
		for value: Variant in aliases:
			if String(value) == alias:
				return key
	return &""


static func key_from_meta(meta: Variant) -> StringName:
	var meta_text: String = String(meta)
	if not meta_text.begins_with(META_PREFIX):
		return &""
	return StringName(meta_text.substr(META_PREFIX.length()))


static func meta_for_key(key: StringName) -> String:
	return "%s%s" % [META_PREFIX, String(key)]


static func _entry(key: StringName, title: String, definition: String, aliases: Array, category: StringName) -> Dictionary:
	return {
		"key": key,
		"title": title,
		"definition": definition,
		"aliases": aliases,
		"category": category,
	}


static func _term(term: String, category: StringName, glossary_key: StringName) -> Dictionary:
	return {
		"term": term,
		"category": category,
		"glossary_key": glossary_key,
	}
