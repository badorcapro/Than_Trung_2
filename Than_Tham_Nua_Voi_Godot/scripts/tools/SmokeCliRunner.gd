extends SceneTree


func _init() -> void:
	var report := SmokeTestRunner.new().run_all()
	print("SMOKE_RESULT %d/%d PASS, %d FAIL" % [
		int(report.get("passed", 0)),
		int(report.get("total", 0)),
		int(report.get("failed", 0)),
	])
	var failure_text := String(report.get("failure_text", ""))
	if not failure_text.is_empty():
		print(failure_text)
	quit(0 if int(report.get("failed", 0)) == 0 else 1)
