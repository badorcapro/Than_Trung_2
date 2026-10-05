extends Node

const GAME_VERSION := "0.0.1-dev"
const BUILD_LABEL := "pf-m7-court-rank-progression"
const CURRENT_MILESTONE := "pf-m7-implementation-complete-static-pass-awaiting-user-runtime"
const G2I_HISTORICAL_BUILD_LABEL := "g2i-overlay-regression-fix"
const SCHEMA_VERSION := 1


func summary() -> String:
	return "%s | %s | %s | schema %d" % [GAME_VERSION, BUILD_LABEL, CURRENT_MILESTONE, SCHEMA_VERSION]
