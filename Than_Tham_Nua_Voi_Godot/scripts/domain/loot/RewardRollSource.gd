class_name RewardRollSource
extends RefCounted

func pick_index(option_count: int) -> int:
	return 0 if option_count > 0 else -1
