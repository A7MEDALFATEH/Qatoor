extends PanelContainer
## Reusable Arabic-ready dialogue bubble. Optional voice tracks are never required.
signal finished

var is_talking: bool = false
var _body: Label
var _speaker: Label
var _elapsed: float = 0.0
var _full_text: String = ""
var _voice: AudioStreamPlayer
var characters_per_second: float = 48.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box := StyleBoxFlat.new()
	box.bg_color = Color("102936")
	box.border_color = Color("34515c")
	box.set_border_width_all(1)
	box.set_corner_radius_all(24)
	add_theme_stylebox_override("panel", box)
	var content := Control.new()
	content.custom_minimum_size = Vector2(1760, 136)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(content)
	_speaker = Label.new()
	_speaker.position = Vector2(28, 41)
	_speaker.size = Vector2(156, 54)
	_speaker.text = "QATOOR"
	_speaker.add_theme_color_override("font_color", Color("67d6ce"))
	_speaker.add_theme_font_size_override("font_size", 18)
	_speaker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	content.add_child(_speaker)
	_body = Label.new()
	_body.position = Vector2(202, 9)
	_body.size = Vector2(1528, 118)
	_body.add_theme_color_override("font_color", Color("f6f2e8"))
	_body.add_theme_font_size_override("font_size", 25)
	_body.add_theme_constant_override("line_spacing", 0)
	if ResourceLoader.exists("res://assets/fonts/NotoSansArabic-Regular.ttf"):
		_body.add_theme_font_override("font", load("res://assets/fonts/NotoSansArabic-Regular.ttf"))
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_body.text_direction = Control.TEXT_DIRECTION_RTL
	_body.language = "ar"
	# Shape the whole line before revealing letters, preserving Arabic connections.
	_body.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	content.add_child(_body)
	_voice = AudioStreamPlayer.new()
	add_child(_voice)

func speak(text: String, speaker: String = "QATOOR", voice_path: String = "") -> void:
	if not is_node_ready():
		await ready
	_full_text = text
	_voice.stop()
	_speaker.text = speaker.to_upper()
	_body.text = text
	_elapsed = 0.0
	_body.visible_characters = 0
	is_talking = not text.is_empty()
	visible = true
	var entrance := create_tween()
	modulate.a = 0.35
	entrance.tween_property(self, "modulate:a", 1.0, 0.28)
	if not voice_path.is_empty() and ResourceLoader.exists(voice_path):
		var stream = load(voice_path)
		if stream is AudioStream:
			_voice.stream = stream
			_voice.play()

func reveal_all() -> void:
	_body.visible_characters = -1
	if is_talking:
		is_talking = false
		finished.emit()

func set_muted(value: bool) -> void:
	_voice.volume_db = -80.0 if value else 0.0

func _process(delta: float) -> void:
	if not is_talking:
		return
	_elapsed += delta
	_body.visible_characters = int(_elapsed * characters_per_second)
	if _body.visible_characters >= _full_text.length():
		reveal_all()
