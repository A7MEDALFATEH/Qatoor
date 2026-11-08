extends CanvasLayer
## Exhibition interface. The story owns decisions; this layer owns presentation.
signal action(id: String)
signal toolbar(id: String)

const INK := Color("081b29")
const PANEL := Color("102b39")
const WHITE := Color("f5f1e7")
const MUTED := Color("a0b7bd")
const GOLD := Color("ffc66d")
const TEAL := Color("68dbcd")
const DialogueBubble = preload("res://scripts/dialogue_manager.gd")

var is_talking: bool:
	get:
		return _dialogue != null and _dialogue.is_talking

var _root: Control
var _menu: Control
var _stage: Control
var _actions: HBoxContainer
var _quiz_options: VBoxContainer
var _dialogue: PanelContainer
var _eyebrow: Label
var _title: Label
var _title_ar: Label
var _description: Label
var _mode_label: Label
var _notice: Label
var _progress_fill: ColorRect
var _progress_labels: Array[Label] = []
var _data_panel: PanelContainer
var _data_text: Label
var _details: Label
var _overlay: Control
var _sound_button: Button
var _stage_index: int = 0
var _notice_tween: Tween
var _font: Font
var _arabic_font: Font
var _automatic: bool = false
var _reduced_motion: bool = false
var _muted: bool = false
var _data_values: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	_root = Control.new()
	_root.name = "ExhibitionInterface"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	var ui_theme := Theme.new()
	ui_theme.default_font_size = 24
	for font_path in ["res://assets/fonts/ExhibitSans.ttf", "res://assets/fonts/NotoSansArabic-Regular.ttf", "res://assets/fonts/NotoSansArabic.ttf", "res://assets/fonts/DejaVuSans.ttf"]:
		if ResourceLoader.exists(font_path):
			_font = load(font_path).duplicate()
			# Keep Latin metrics independent of the much taller Arabic font.
			_font.fallbacks = []
			ui_theme.default_font = _font
			break
	if ResourceLoader.exists("res://assets/fonts/NotoSansArabic-Regular.ttf"):
		_arabic_font = load("res://assets/fonts/NotoSansArabic-Regular.ttf")
	_root.theme = ui_theme
	_build_header()
	_build_story()
	_build_menu()
	_build_data_panel()
	_build_footer()
	show_menu()

func _panel(parent: Node, rect: Rect2, color: Color = PANEL, radius: int = 20, border: Color = Color("2e4a55")) -> Panel:
	var result := Panel.new()
	result.position = rect.position
	result.size = rect.size
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	result.add_theme_stylebox_override("panel", style)
	parent.add_child(result)
	return result

func _label(parent: Node, text: String, pos: Vector2, dimensions: Vector2, font_size: int, color: Color = WHITE) -> Label:
	var result := Label.new()
	result.text = text
	result.position = pos
	result.size = dimensions
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(result)
	return result

func _button(text: String, id: String, secondary: bool = false, target: String = "action") -> Button:
	var result := Button.new()
	result.text = text
	result.custom_minimum_size = Vector2(194, 72)
	result.add_theme_font_size_override("font_size", 22)
	result.add_theme_color_override("font_color", INK if not secondary else WHITE)
	result.add_theme_color_override("font_hover_color", INK if not secondary else WHITE)
	result.add_theme_color_override("font_pressed_color", INK)
	result.focus_mode = Control.FOCUS_ALL
	result.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var normal := StyleBoxFlat.new()
	normal.bg_color = GOLD if not secondary else Color("153440")
	normal.border_color = Color("ffdda1") if not secondary else Color("42606a")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(18)
	normal.content_margin_left = 26
	normal.content_margin_right = 26
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("ffda97") if not secondary else Color("24515b")
	hover.border_color = TEAL
	hover.set_border_width_all(2)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = TEAL
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color("263a42")
	disabled.border_color = Color("344851")
	result.add_theme_stylebox_override("normal", normal)
	result.add_theme_stylebox_override("hover", hover)
	result.add_theme_stylebox_override("pressed", pressed)
	result.add_theme_stylebox_override("focus", hover)
	result.add_theme_stylebox_override("disabled", disabled)
	result.pressed.connect(func():
		var pulse := result.create_tween()
		pulse.tween_property(result, "modulate", Color(0.8, 1.0, 0.95), 0.07)
		pulse.tween_property(result, "modulate", Color.WHITE, 0.16)
		if target == "toolbar":
			_handle_toolbar(id)
		else:
			action.emit(id)
	)
	return result

func _build_header() -> void:
	_panel(_root, Rect2(42, 30, 1836, 104), Color("091e2a"), 28, Color("28424c"))
	var brand := _label(_root, "Q", Vector2(67, 42), Vector2(64, 72), 58, GOLD)
	brand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label(_root, "QATOOR", Vector2(147, 43), Vector2(250, 39), 27)
	_label(_root, "AN OIL DROP ODYSSEY", Vector2(148, 83), Vector2(320, 24), 14, MUTED)
	var track := ColorRect.new()
	track.color = Color("29434e")
	track.position = Vector2(640, 76)
	track.size = Vector2(478, 2)
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(track)
	_progress_fill = ColorRect.new()
	_progress_fill.color = GOLD
	_progress_fill.position = track.position
	_progress_fill.size = Vector2(0, 2)
	_progress_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_progress_fill)
	for i in range(7):
		var dot := _label(_root, "%02d" % (i + 1), Vector2(618 + i * 79, 50), Vector2(49, 50), 19, MUTED)
		dot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		dot.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_progress_labels.append(dot)
	var toolbar_box := HBoxContainer.new()
	toolbar_box.position = Vector2(1223, 47)
	toolbar_box.size = Vector2(632, 70)
	toolbar_box.add_theme_constant_override("separation", 10)
	_root.add_child(toolbar_box)
	for definition in [["DATA", "data"], ["SOUND", "sound"], ["SETTINGS", "settings"], ["PAUSE", "pause"], ["HOME", "menu"]]:
		var b := _button(definition[0], definition[1], true, "toolbar")
		b.custom_minimum_size = Vector2(108, 66)
		b.add_theme_font_size_override("font_size", 15)
		var sb := b.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
		sb.content_margin_left = 13
		sb.content_margin_right = 13
		b.add_theme_stylebox_override("normal", sb)
		toolbar_box.add_child(b)
		if definition[1] == "sound":
			_sound_button = b

func _build_story() -> void:
	_stage = Control.new()
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_stage)
	_eyebrow = _label(_stage, "01 / THE HIDDEN WORLD", Vector2(77, 184), Vector2(555, 37), 16, TEAL)
	_title = _label(_stage, "Beneath\nthe surface.", Vector2(72, 237), Vector2(555, 193), 62)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title.add_theme_constant_override("line_spacing", -6)
	_title_ar = _label(_stage, "", Vector2(76, 457), Vector2(525, 88), 30, GOLD)
	_title_ar.text_direction = Control.TEXT_DIRECTION_RTL
	_title_ar.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_title_ar.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title_ar.language = "ar"
	if _arabic_font:
		_title_ar.add_theme_font_override("font", _arabic_font)
	_description = _label(_stage, "", Vector2(77, 571), Vector2(470, 155), 23, MUTED)
	_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_description.add_theme_constant_override("line_spacing", 7)
	_notice = _label(_stage, "", Vector2(630, 746), Vector2(1200, 47), 22, TEAL)
	_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_notice.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_notice.position.y = 730
	_notice.size.y = 68
	_dialogue = DialogueBubble.new()
	_dialogue.position = Vector2(72, 790)
	_dialogue.size = Vector2(1776, 136)
	_root.add_child(_dialogue)
	_actions = HBoxContainer.new()
	_actions.position = Vector2(72, 944)
	_actions.size = Vector2(1776, 72)
	_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	_actions.add_theme_constant_override("separation", 18)
	_root.add_child(_actions)
	_quiz_options = VBoxContainer.new()
	_quiz_options.position = Vector2(75, 540)
	_quiz_options.size = Vector2(680, 244)
	_quiz_options.add_theme_constant_override("separation", 8)
	_root.add_child(_quiz_options)
	_quiz_options.hide()

func _build_menu() -> void:
	_menu = Control.new()
	_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_menu)
	_label(_menu, "AN INTERACTIVE PETROLEUM ADVENTURE", Vector2(80, 211), Vector2(700, 40), 17, TEAL)
	_label(_menu, "One little drop.", Vector2(72, 270), Vector2(900, 100), 76)
	_label(_menu, "An extraordinary\njourney.", Vector2(74, 382), Vector2(900, 188), 76, GOLD)
	var ar := _label(_menu, "رحلة قطرة النفط: من أعماق الأرض إلى السطح", Vector2(80, 603), Vector2(745, 78), 29)
	ar.text_direction = Control.TEXT_DIRECTION_RTL
	ar.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	ar.language = "ar"
	if _arabic_font:
		ar.add_theme_font_override("font", _arabic_font)
	var desc := _label(_menu, "Meet Qatoor. Help a curious oil drop travel from ancient rocks to the world around us.", Vector2(80, 706), Vector2(650, 96), 24, MUTED)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var box := HBoxContainer.new()
	box.position = Vector2(80, 846)
	box.add_theme_constant_override("separation", 18)
	_menu.add_child(box)
	var start := _button("START JOURNEY  →", "start")
	start.custom_minimum_size = Vector2(327, 84)
	box.add_child(start)
	var auto_button := _button("WATCH THE MOVIE", "auto", true)
	auto_button.custom_minimum_size = Vector2(307, 84)
	box.add_child(auto_button)
	_label(_menu, "TOUCH OR CLICK TO EXPLORE  ·  ARABIC STORYTELLING", Vector2(82, 960), Vector2(790, 32), 15, MUTED)

func _build_footer() -> void:
	_mode_label = _label(_root, "INTERACTIVE EXHIBITION", Vector2(77, 1036), Vector2(600, 24), 13, MUTED)
	var disclaimer := _label(_root, "ILLUSTRATIVE EDUCATIONAL SIMULATION", Vector2(1180, 1036), Vector2(664, 24), 13, MUTED)
	disclaimer.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

func _build_data_panel() -> void:
	_data_panel = PanelContainer.new()
	_data_panel.position = Vector2(1335, 160)
	_data_panel.size = Vector2(512, 602)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("0b202e")
	style.border_color = Color("46717a")
	style.set_border_width_all(1)
	style.set_corner_radius_all(22)
	style.content_margin_left = 25
	style.content_margin_top = 22
	style.content_margin_right = 25
	style.content_margin_bottom = 22
	_data_panel.add_theme_stylebox_override("panel", style)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_data_panel.add_child(scroll)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.custom_minimum_size.x = 450
	col.add_theme_constant_override("separation", 14)
	scroll.add_child(col)
	var title := Label.new()
	title.text = "ENGINEERING LIVE DATA"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", TEAL)
	col.add_child(title)
	_data_text = Label.new()
	_data_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_data_text.custom_minimum_size.x = 450
	_data_text.add_theme_font_size_override("font_size", 21)
	_data_text.add_theme_color_override("font_color", WHITE)
	_data_text.add_theme_constant_override("line_spacing", 12)
	col.add_child(_data_text)
	var details_button := _button("ENGINEERING DETAILS  +", "details", true, "toolbar")
	details_button.add_theme_font_size_override("font_size", 17)
	details_button.custom_minimum_size.y = 54
	col.add_child(details_button)
	_details = Label.new()
	_details.text = "Q = J × max(Pr − Pwf, 0)\n\nPr: reservoir pressure [bar]\nPwf: flowing bottomhole pressure [bar]\nJ: productivity index [m³/day/bar]\n\nFixed reservoir pressure; steady illustrative inflow. Surface choke and well losses constrain flow. Local gas appears below the assumed bubble point.\n\nAn educational model, not a field forecast."
	_details.add_theme_font_size_override("font_size", 16)
	_details.add_theme_color_override("font_color", MUTED)
	_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_details.custom_minimum_size = Vector2(456, 0)
	_details.hide()
	col.add_child(_details)
	_root.add_child(_data_panel)
	_data_panel.hide()

func show_menu() -> void:
	_quiz_options.hide()
	_menu.show()
	_stage.hide()
	_dialogue.hide()
	_actions.hide()
	_data_panel.hide()
	close_overlay()
	set_progress(0.0)
	for entry in _progress_labels:
		entry.modulate.a = 0.4

func set_stage(index: int, title: String, title_ar: String, description: String, eyebrow: String) -> void:
	_reset_stage_layout()
	_quiz_options.hide()
	_menu.hide()
	_stage.show()
	_dialogue.show()
	_actions.show()
	_stage_index = index
	_eyebrow.text = eyebrow.to_upper() if "/" in eyebrow else "%02d / %s" % [index + 1, eyebrow.to_upper()]
	_title.text = title
	var longest_line: int = 0
	for line in title.split("\n"):
		longest_line = maxi(longest_line, line.length())
	_title.add_theme_font_size_override("font_size", 50 if longest_line > 18 else 58)
	_title_ar.text = title_ar
	_description.text = description
	_notice.text = ""
	for i in range(_progress_labels.size()):
		_progress_labels[i].add_theme_color_override("font_color", GOLD if i <= index else MUTED)
		_progress_labels[i].modulate.a = 1.0 if i <= index else 0.5
	set_progress(float(index) / 6.0)

func _reset_stage_layout() -> void:
	_title.position = Vector2(72, 237)
	_title.size = Vector2(555, 193)
	_title.add_theme_font_size_override("font_size", 58)
	_title_ar.position = Vector2(76, 457)
	_title_ar.size = Vector2(525, 88)
	_description.position = Vector2(77, 571)
	_description.size = Vector2(470, 155)
	_description.add_theme_font_size_override("font_size", 23)
	_notice.position = Vector2(630, 730)
	_notice.size = Vector2(1200, 68)

func set_actions(items: Array) -> void:
	for child in _actions.get_children():
		_actions.remove_child(child)
		child.queue_free()
	for item in items:
		var entry: Dictionary = item
		var button := _button(str(entry.get("label", "CONTINUE")), str(entry.get("id", "next")), bool(entry.get("secondary", false)))
		button.disabled = bool(entry.get("disabled", false))
		button.custom_minimum_size.x = float(entry.get("width", 194))
		if items.size() >= 6:
			button.add_theme_font_size_override("font_size", 20)
		_actions.add_child(button)
	_actions.visible = not items.is_empty()

func speak(text: String, speaker: String = "QATOOR", voice_path: String = "") -> void:
	_dialogue.speak(text, speaker, voice_path)

func set_dialogue_visible(value: bool) -> void:
	_dialogue.visible = value

func set_progress(value: float) -> void:
	if _progress_fill:
		_progress_fill.size.x = 478 * clampf(value, 0.0, 1.0)

func set_mode(automatic: bool) -> void:
	_automatic = automatic
	_mode_label.text = "AUTOMATIC CINEMATIC PRESENTATION" if automatic else "INTERACTIVE EXHIBITION"

func set_sound(muted: bool) -> void:
	_muted = muted
	_dialogue.set_muted(muted)
	_sound_button.text = "MUTED" if muted else "SOUND"
	_sound_button.add_theme_color_override("font_color", MUTED if muted else WHITE)

func update_data(snapshot: Dictionary) -> void:
	_data_values = snapshot
	var pressure := float(snapshot.get("reservoir_pressure", 280.0))
	var bottomhole := float(snapshot.get("flowing_bottomhole_pressure", pressure))
	var rate := float(snapshot.get("flow_rate", 0.0))
	var temperature := float(snapshot.get("temperature", 85.0))
	var depth := float(snapshot.get("depth", 2400.0))
	var status := str(snapshot.get("status", "Flowing" if rate > 0.01 else "Shut in"))
	_data_text.text = "Reservoir pressure      %.1f bar\nBottomhole pressure    %.1f bar\nTemperature                %.0f °C\nDepth                             %.0f m\nProduction rate             %.1f m³/day\nWell status                     %s" % [pressure, bottomhole, temperature, depth, rate, status]
	_details.text = "Q = J × max(Pr − Pwf, 0)\n\nPr: reservoir pressure [bar]\nPwf: flowing bottomhole pressure [bar]\nJ: productivity index [m³/day/bar]\n\nILLUSTRATIVE ASSUMPTIONS\n" + str(snapshot.get("assumptions", "Constant reservoir pressure; simplified inflow and outflow.")) + "\n\nLocal pressure and temperature are interpolated for storytelling. Gas appears below the assumed bubble point; gas volume is not calculated. This is an educational model, not a field forecast."

func show_notice(text: String, positive: bool = true) -> void:
	_notice.text = text
	_notice.add_theme_font_size_override("font_size", 18 if text.length() > 95 else 22)
	_notice.add_theme_color_override("font_color", TEAL if positive else GOLD)
	_notice.modulate.a = 1.0
	if _notice_tween and _notice_tween.is_valid():
		_notice_tween.kill()
	_notice_tween = create_tween()
	_notice_tween.tween_interval(4.0)
	_notice_tween.tween_property(_notice, "modulate:a", 0.0, 0.6)

func toggle_data() -> void:
	_data_panel.visible = not _data_panel.visible

func _handle_toolbar(id: String) -> void:
	match id:
		"data":
			toggle_data()
		"details":
			_details.visible = not _details.visible
		"settings":
			show_settings()
		_:
			toolbar.emit(id)

func close_overlay() -> void:
	if is_instance_valid(_overlay):
		_root.remove_child(_overlay)
		_overlay.queue_free()
	_overlay = null

func _create_overlay(title_text: String, subtitle: String = "") -> VBoxContainer:
	close_overlay()
	_overlay = Control.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.04, 0.065, 0.85)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(shade)
	_root.add_child(_overlay)
	var panel := PanelContainer.new()
	panel.position = Vector2(580, 240)
	panel.size = Vector2(760, 604)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("102b39")
	style.border_color = Color("4e6c70")
	style.set_border_width_all(1)
	style.set_corner_radius_all(30)
	style.content_margin_left = 54
	style.content_margin_right = 54
	style.content_margin_top = 44
	style.content_margin_bottom = 44
	panel.add_theme_stylebox_override("panel", style)
	_overlay.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 20)
	panel.add_child(column)
	var heading := Label.new()
	heading.text = title_text
	heading.add_theme_font_size_override("font_size", 43)
	heading.add_theme_color_override("font_color", GOLD)
	column.add_child(heading)
	if not subtitle.is_empty():
		var sub := Label.new()
		sub.text = subtitle
		sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sub.custom_minimum_size.x = 640
		sub.add_theme_font_size_override("font_size", 22)
		sub.add_theme_color_override("font_color", MUTED)
		column.add_child(sub)
	return column

func show_pause(paused: bool) -> void:
	if not paused:
		close_overlay()
		return
	var column := _create_overlay("Take a little breath.", "Your journey is paused. Qatoor will be right here.")
	for pair in [["RESUME JOURNEY", "resume"], ["RESTART", "restart"], ["MAIN MENU", "menu"]]:
		var b := _button(pair[0], pair[1], pair[1] != "resume")
		column.add_child(b)

func show_settings() -> void:
	var column := _create_overlay("Exhibition settings", "Designed for mouse, touchscreen, and a room full of curious minds.")
	var sound := _button("SOUND: OFF" if _muted else "SOUND: ON", "sound", true, "toolbar")
	sound.pressed.connect(func(): sound.text = "SOUND: OFF" if _muted else "SOUND: ON")
	column.add_child(sound)
	var motion := _button("REDUCED MOTION: ON" if _reduced_motion else "REDUCED MOTION: OFF", "motion", true, "toolbar")
	motion.pressed.connect(func():
		_reduced_motion = not _reduced_motion
		motion.text = "REDUCED MOTION: ON" if _reduced_motion else "REDUCED MOTION: OFF"
	)
	motion.add_theme_font_size_override("font_size", 20)
	column.add_child(motion)
	var done := _button("BACK TO THE JOURNEY", "close_settings")
	done.pressed.connect(close_overlay)
	column.add_child(done)

func show_quiz(prompt: String, prompt_ar: String, answers: Array) -> void:
	_menu.hide()
	_stage.show()
	_dialogue.show()
	_actions.hide()
	_eyebrow.text = "BONUS / TEST YOUR KNOWLEDGE"
	_title.text = "You are the\nengineer."
	_title.add_theme_font_size_override("font_size", 52)
	_title.size = Vector2(680, 153)
	_title_ar.text = "اختبر معلوماتك"
	_title_ar.position = Vector2(76, 400)
	_title_ar.size = Vector2(680, 60)
	_description.text = prompt
	_description.position = Vector2(77, 472)
	_description.size = Vector2(680, 63)
	_description.add_theme_font_size_override("font_size", 22)
	_notice.position = Vector2(820, 700)
	_notice.size = Vector2(1010, 82)
	speak(prompt_ar, "YOUR CHALLENGE")
	for child in _quiz_options.get_children():
		_quiz_options.remove_child(child)
		child.queue_free()
	for i in range(answers.size()):
		var button := _button("", "answer_%d" % i, true)
		button.custom_minimum_size = Vector2(680, 76)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var caption := Label.new()
		caption.text = "%s   %s" % [char(65 + i), str(answers[i])]
		caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		caption.offset_left = 24
		caption.offset_right = -24
		caption.offset_top = 7
		caption.offset_bottom = -7
		caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		caption.add_theme_font_size_override("font_size", 20)
		caption.add_theme_color_override("font_color", WHITE)
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(caption)
		_quiz_options.add_child(button)
	_quiz_options.show()

func show_quiz_result(score: int) -> void:
	_reset_stage_layout()
	_quiz_options.hide()
	_title.text = "A brilliant\njourney."
	_title_ar.text = "أحسنتم يا أصدقاء قطّور!"
	_description.text = "You answered %d of 3 questions correctly. Every discovery starts with a little curiosity." % score
	speak("شكراً لكم! لقد تعلمنا معاً كيف يصل النفط من المكمن إلى حياتنا اليومية.", "QATOOR")
	set_actions([{"id": "restart", "label": "RESTART JOURNEY"}, {"id": "menu", "label": "MAIN MENU", "secondary": true}])

func _unhandled_key_input(event: InputEvent) -> void:
	if get_tree().paused and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		toolbar.emit("pause")
		get_viewport().set_input_as_handled()
