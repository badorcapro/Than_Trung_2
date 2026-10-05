class_name GachaConfig
extends Resource

enum RateUpPityScope { SHARED_TEST_ONLY, PER_BANNER_TEST_ONLY }
enum PerfectPersistence { ROUND_TEST_ONLY, MATCH_TEST_ONLY }
@export var basic_rates := {"B":65,"A":25,"S":10}
@export var rate_up_rates := {"B":65,"A":25,"S":10}
@export var featured_s_split := {"RELIC":14,"A":22,"B":22,"C":22,"OTHER_S":20}
@export var rate_up_pity_scope: RateUpPityScope = RateUpPityScope.SHARED_TEST_ONLY
@export var rate_up_grants_exchange_material := false
@export var rate_up_exchange_scope: StringName = &"TEST_ONLY_DISABLED"
@export var perfect_persistence: PerfectPersistence = PerfectPersistence.MATCH_TEST_ONLY
@export var ss_shop_currency_type: StringName = &"TEST_ONLY_SS_SHOP_CURRENCY"
@export var test_only_not_canon_locked := true
