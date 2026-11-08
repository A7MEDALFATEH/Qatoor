extends Control
## Verified transcription and original logos from the supplied QATOOR.docx.
const FONT = preload("res://assets/fonts/ExhibitSans.ttf")
var leaving: bool = false
var controls: HBoxContainer

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("081a2c")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	for i in range(24):
		var line := ColorRect.new()
		line.position = Vector2(1100 + i * 36, 0)
		line.size = Vector2(1, 1080)
		line.color = Color(0.25, 0.62, 0.67, 0.035)
		add_child(line)
	_logo("res://assets/identity/university.png", Rect2(100, 65, 130, 158))
	_logo("res://assets/identity/college.png", Rect2(1685, 65, 150, 158))
	_text("UNIVERSITY OF KIRKUK", Rect2(280, 85, 1360, 45), 30, Color("f1d397"))
	_text("COLLEGE OF ENGINEERING  /  DEPARTMENT OF PETROLEUM ENGINEERING", Rect2(270, 140, 1380, 40), 20, Color("b6c8cc"))
	var rule := ColorRect.new()
	rule.position = Vector2(100, 257)
	rule.size = Vector2(1720, 2)
	rule.color = Color("b4955f")
	add_child(rule)
	_text("A SCIENTIFIC PROJECT", Rect2(100, 302, 1720, 38), 22, Color("7bd1d4"))
	_text("QATOOR", Rect2(100, 340, 1720, 168), 132, Color("f5d391"))
	_text("The Interactive Journey of an Oil Drop", Rect2(100, 510, 1720, 65), 43, Color("f0f3ed"))
	_text("Submitted to the Department of Petroleum Engineering,\nCollege of Engineering, University of Kirkuk.", Rect2(240, 590, 1440, 76), 24, Color("b6c8cc"))
	_text("PREPARED BY  ·  4th Year Undergraduate Students", Rect2(100, 675, 1720, 38), 22, Color("7bd1d4"))
	_text("Ahmed Al-Fatih Mohammed Al-Sadiq Fuad Al-Din Qawam\nClarita Korkis Belshasar Benjamin\nBahaa Khalid Abd-Allah\nZakaria Salah Al-Deen", Rect2(150, 716, 1620, 140), 27, Color("f0f3ed"))
	_text("SUPERVISED BY", Rect2(100, 871, 1720, 30), 19, Color("7bd1d4"))
	_text("Assist. Prof. Dr. Mohammed Jawad Zeinalabideen", Rect2(140, 909, 1640, 43), 30, Color("f5d391"))
	_text("2026–2027", Rect2(100, 958, 1720, 34), 23, Color("b6c8cc"))
	controls = HBoxContainer.new()
	controls.position = Vector2(660, 1010)
	controls.size = Vector2(600, 48)
	controls.alignment = BoxContainer.ALIGNMENT_CENTER
	controls.add_theme_constant_override("separation", 22)
	add_child(controls)
	for item in [["Start journey  →", false], ["Watch movie", true]]:
		var button := Button.new()
		button.text = item[0]
		button.custom_minimum_size = Vector2(250, 46)
		button.add_theme_font_override("font", FONT)
		button.add_theme_font_size_override("font_size", 21)
		button.pressed.connect(_start.bind(item[1]))
		controls.add_child(button)
	controls.visible = not "--title-only" in OS.get_cmdline_user_args()
	if "--movie" in OS.get_cmdline_user_args():
		await get_tree().create_timer(7.0).timeout
		_start(true)

func _logo(path: String, rect: Rect2) -> void:
	var image := TextureRect.new()
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.texture = load(path)
	image.position = rect.position
	image.size = rect.size
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(image)

func _text(value: String, rect: Rect2, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = value
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	add_child(label)

func _start(movie: bool = false) -> void:
	if leaving: return
	leaving = true
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.65).set_trans(Tween.TRANS_SINE)
	await tween.finished
	var packed := preload("res://scenes/main.tscn")
	var scene := packed.instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	if movie and not scene.auto_mode: scene._on_action("auto")
	queue_free()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if event.keycode == KEY_ENTER and controls.visible: _start()
	if event.keycode == KEY_F11:
		var full: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if full else DisplayServer.WINDOW_MODE_FULLSCREEN)
