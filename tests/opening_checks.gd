extends SceneTree
var failed: int = 0
func _init() -> void:
	go.call_deferred()
func check(value: bool, message: String) -> void:
	print("PASS " if value else "FAIL ", message)
	if not value: failed += 1
func go() -> void:
	root.content_scale_size = Vector2i(1920,1080)
	var title = load("res://scenes/opening_title.tscn").instantiate()
	root.add_child(title)
	current_scene = title
	await process_frame
	var contents: String = ""
	for node in title.get_children():
		if node is Label:
			contents += node.text + "\n"
			check(node.get_minimum_size().x <= node.size.x + 1 and node.get_minimum_size().y <= node.size.y + 1, "title text fits: " + node.text.split("\n")[0])
		if node is TextureRect: check(node.size.x <= 150 and node.size.y <= 158, "logo fits header")
	for name in ["Ahmed Al-Fatih Mohammed Al-Sadiq Fuad Al-Din Qawam", "Clarita Korkis Belshasar Benjamin", "Bahaa Khalid Abd-Allah", "Zakaria Salah Al-Deen", "Assist. Prof. Dr. Mohammed Jawad Zeinalabideen"]:
		check(name in contents, "credit present: " + name)
	title._start(false)
	await create_timer(1.0).timeout
	check(current_scene.get_script().resource_path == "res://scripts/story_manager.gd", "opening starts original journey")
	check(current_scene.stage_key == "menu", "interactive start preserves original menu")
	current_scene.queue_free()
	await process_frame
	print("OPENING CHECKS: ", failed, " failed")
	quit(1 if failed else 0)
