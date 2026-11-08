extends Node2D
## One state machine powers both exhibition interaction and the automatic movie.
const DATA = preload("res://data/story_data.gd")
const MODEL = preload("res://scripts/engineering_model.gd")
const UI = preload("res://scripts/exhibition_ui.gd")
const AUDIO = preload("res://scripts/audio_manager.gd")
const CAMERA = preload("res://scripts/camera_controller.gd")
const TRANSITIONS = preload("res://scripts/scene_manager.gd")
const INTERACTIONS = preload("res://scripts/interaction_manager.gd")
const SCENES: Dictionary = {
	"menu": "res://scenes/reservoir.tscn",
	"reservoir": "res://scenes/reservoir.tscn",
	"drilling": "res://scenes/drilling.tscn",
	"pressure": "res://scenes/pressure_challenge.tscn",
	"race": "res://scenes/production_journey.tscn",
	"separator": "res://scenes/separator.tscn",
	"refinery": "res://scenes/refinery.tscn",
	"finale": "res://scenes/finale.tscn",
	"quiz": "res://scenes/quiz.tscn"
}
const PRODUCT_ORDER: Array[String] = ["car", "aviation", "marine", "plastic", "asphalt"]
const PHASE_ORDER: Array[String] = ["oil", "gas", "water"]
const OUTLETS: Dictionary = {"oil": Vector2(1640, 480), "gas": Vector2(1590, 280), "water": Vector2(1640, 670)}

var stage_key: String = "menu"
var state: Dictionary = {}
var model = MODEL.new()
var ui: CanvasLayer
var audio: Node
var camera: Camera2D
var transitions: Node
var environment: Node2D
var world: Node2D
var qatoor: Node2D
var ghazi: Node2D
var maee: Node2D
var auto_mode: bool = false
var muted: bool = false
var reduced_motion: bool = false
var stage_clock: float = 0.0
var phase_timer: float = 0.0
var dialogue_clock: float = 0.0
var secondary_dialogue_shown: bool = false
var gas_introduced: bool = false
var completion_clock: float = -1.0
var interaction_locked: bool = false
var character_tween: Tween
var camera_zoom: float = 1.0
var products_seen: Array[String] = []
var quiz_index: int = 0
var quiz_score: int = 0
var quiz_first_try: bool = true
var quiz_pending: bool = false
var auto_flags: Dictionary = {}
var speaking_character: String = "oil"
var data_clock: float = 0.0

func _ready() -> void:
	world = Node2D.new()
	world.name = "IllustratedWorld"
	add_child(world)
	camera = CAMERA.new()
	add_child(camera)
	audio = AUDIO.new()
	add_child(audio)
	ui = UI.new()
	add_child(ui)
	ui.action.connect(_on_action)
	ui.toolbar.connect(_on_toolbar)
	transitions = TRANSITIONS.new()
	add_child(transitions)
	qatoor = preload("res://characters/qatoor.tscn").instantiate()
	ghazi = preload("res://characters/ghazi.tscn").instantiate()
	maee = preload("res://characters/maee.tscn").instantiate()
	for character in [qatoor, ghazi, maee]:
		world.add_child(character)
		character.z_index = 12
	_initialize_stage("menu")
	if "--movie" in OS.get_cmdline_user_args():
		_on_action("auto")

func _reset_state() -> void:
	state = {"intro": 0.0, "drilling_progress": 0.0, "drilling_running": false,
		"playback_speed": 1.0, "completed": false, "completion_progress": 0.0,
		"choke": model.choke, "flow_ratio": 0.0, "travel": 0.0,
		"gas_visible": false, "depth": 2400.0, "separation_index": 0,
		"sorted": [], "selected_outlet": "", "feedback": 0.0,
		"product": "", "product_progress": 0.0, "celebration": false}
	stage_clock = 0.0
	phase_timer = 0.0
	dialogue_clock = 0.0
	secondary_dialogue_shown = false
	completion_clock = -1.0
	interaction_locked = false
	auto_flags.clear()
	speaking_character = "oil"
	if character_tween != null and character_tween.is_valid():
		character_tween.kill()
	for character in [qatoor, ghazi, maee]:
		character.visible = false
		character.scale = Vector2.ONE
		character.modulate = Color.WHITE
		character.rotation = 0.0
		character.set_expression("happy")
		character.set_talking(false)

func _initialize_stage(next_stage: String) -> void:
	stage_key = next_stage
	_reset_state()
	if environment != null:
		environment.free()
	environment = load(SCENES[stage_key]).instantiate()
	world.add_child(environment)
	world.move_child(environment, 0)
	environment.state = state
	camera.reset_frame()
	camera_zoom = 1.0
	qatoor.visible = true
	ui.set_mode(auto_mode)
	ui.set_dialogue_visible(true)
	if stage_key == "menu":
		state.intro = 1.0
		qatoor.position = Vector2(1250, 515)
		qatoor.scale = Vector2.ONE * 1.25
		qatoor.gesture("pointing")
		ui.show_menu()
		audio.set_ambience("reservoir", 0.4)
		return
	if stage_key == "quiz":
		state.travel = 1.0
		qatoor.position = Vector2(1410, 540)
		qatoor.scale = Vector2.ONE * 1.05
		quiz_index = 0
		quiz_score = 0
		quiz_first_try = true
		quiz_pending = false
		ui.set_stage(7, "A curious mind.\nA brighter future.", "اختبر معلوماتك", "Three small questions from a remarkable journey.", "BONUS / TEST YOUR KNOWLEDGE")
		_show_question()
		return
	var entry: Dictionary = DATA.STAGES[stage_key]
	var index: int = INTERACTIONS.PATH.find(stage_key)
	ui.set_stage(index, entry.title, entry.title_ar, entry.description, entry.eyebrow)
	_speak(entry.dialogue)
	match stage_key:
		"reservoir":
			model.set_choke(0.0)
			qatoor.position = Vector2(1090, 510)
			qatoor.modulate.a = 0.0
			qatoor.gesture("floating")
			ui.set_dialogue_visible(false)
			if not reduced_motion:
				camera.frame(Vector2(960, 430), 0.96, 0.01)
				camera.frame(Vector2(960, 540), 1.0, 7.0)
			audio.set_ambience("reservoir", 0.5)
		"drilling":
			model.set_choke(0.0)
			qatoor.position = Vector2(690, 620)
			qatoor.scale = Vector2.ONE * 0.68
			qatoor.set_expression("excited")
			audio.set_ambience("reservoir", 0.3)
		"pressure":
			model.set_choke(0.0)
			qatoor.position = Vector2(930, 540)
			qatoor.set_expression("confused")
			audio.set_ambience("flow", 0.2)
		"race":
			state.travel = 0.0
			qatoor.position = Vector2(1040, 510)
			qatoor.gesture("carried")
			ghazi.position = Vector2(1200, 370)
			ghazi.scale = Vector2.ONE * 0.6
			gas_introduced = false
			if model.choke <= 0.001:
				model.set_choke(0.55)
			audio.set_ambience("flow", 0.55)
		"separator":
			state.travel = 1.0
			_set_phase_character()
			audio.set_ambience("surface", 0.3)
		"refinery":
			state.travel = 1.0
			products_seen.clear()
			qatoor.position = Vector2(655, 570)
			qatoor.scale = Vector2.ONE * 0.78
			qatoor.gesture("pointing")
			audio.set_ambience("surface", 0.3)
		"finale":
			state.travel = 1.0
			state.celebration = true
			qatoor.position = Vector2(1080, 495)
			qatoor.scale = Vector2.ONE * 1.1
			qatoor.celebrate()
			audio.play_cue("celebrate")
			audio.set_ambience("surface", 0.25)
	_update_actions()

func _go(next_stage: String) -> void:
	if transitions.busy or not INTERACTIONS.permits(stage_key, next_stage):
		return
	audio.play_cue("whoosh")
	await transitions.cover()
	_initialize_stage(next_stage)
	await transitions.reveal()

func _speak(text: String, speaker: String = "QATOOR") -> void:
	speaking_character = "gas" if speaker == "GHAZI" else ("water" if speaker == "MAEE" else "oil")
	var voice_path: String = ""
	if DATA.STAGES.has(stage_key):
		var voices: Dictionary = DATA.STAGES[stage_key].get("voice_tracks", {})
		voice_path = str(voices.get(text, ""))
	ui.speak(text, speaker, voice_path)
	dialogue_clock = 0.0

func _process(delta: float) -> void:
	if ui == null or transitions.busy:
		return
	stage_clock += delta
	dialogue_clock += delta
	for character in [qatoor, ghazi, maee]:
		character.set_talking(ui.is_talking and character.character_kind == speaking_character)
	if stage_key == "menu":
		return
	model.update(delta, float(state.travel))
	var snapshot: Dictionary = model.snapshot()
	state.choke = model.choke
	state.flow_ratio = snapshot.flow_ratio
	state.gas_visible = snapshot.gas_visible
	state.depth = snapshot.depth
	state.feedback = move_toward(float(state.feedback), 0.0, delta * 0.5)
	data_clock += delta
	if data_clock > 0.18:
		data_clock = 0.0
		if stage_key == "drilling":
			snapshot.depth = float(state.drilling_progress) * model.depth
			snapshot.status = "Well completed — shut in" if state.completed else ("Completion in progress" if completion_clock >= 0.0 else ("Drilling" if state.drilling_running else "Drilling paused"))
		elif stage_key == "reservoir":
			snapshot.status = "Reservoir — no production well yet"
		ui.update_data(snapshot)
	var can_explain_flow: bool = stage_key != "pressure" or (model.choke > 0.0 and model.natural_flow_available and model.flow_rate > 0.1)
	if stage_key in ["reservoir", "pressure", "finale"] and can_explain_flow and not secondary_dialogue_shown and dialogue_clock > 10.0:
		secondary_dialogue_shown = true
		_speak(DATA.STAGES[stage_key].dialogues[1])
	match stage_key:
		"reservoir":
			state.intro = minf(stage_clock / 7.0, 1.0)
			qatoor.modulate.a = smoothstep(0.65, 0.9, float(state.intro))
			if state.intro >= 0.9 and not auto_flags.has("intro_ready"):
				auto_flags.intro_ready = true
				ui.set_dialogue_visible(true)
				_speak(DATA.STAGES.reservoir.dialogue)
				_update_actions()
		"drilling":
			if not reduced_motion:
				camera.position.y = lerpf(camera.position.y, 515.0 + float(state.drilling_progress) * 50.0, minf(delta, 1.0))
			if state.drilling_running and not state.completed:
				state.drilling_progress = minf(float(state.drilling_progress) + delta * float(state.playback_speed) / 28.0, 1.0)
				if state.drilling_progress >= 1.0:
					state.drilling_running = false
					completion_clock = 0.0
					interaction_locked = true
					_speak(DATA.STAGES.drilling.dialogues[1])
					audio.set_ambience("surface", 0.2)
					_update_actions()
			if completion_clock >= 0.0 and not state.completed:
				completion_clock += delta
				state.completion_progress = minf(completion_clock / 3.5, 1.0)
				if completion_clock >= 3.5:
					state.completed = true
					interaction_locked = false
					qatoor.celebrate()
					audio.play_cue("success")
					ui.show_notice("Well completed · production tubing is ready")
					_update_actions()
		"pressure":
			qatoor.position.x = lerpf(qatoor.position.x, 930.0 + float(state.flow_ratio) * 230.0, minf(delta * 1.5, 1.0))
			if model.choke > 0.0 and not model.natural_flow_available and not auto_flags.has("insufficient"):
				auto_flags.insufficient = true
				_speak(DATA.STAGES.pressure.no_flow_dialogue)
				ui.show_notice("Insufficient pressure head · natural production cannot continue", false)
				_update_actions()
			elif model.natural_flow_available and auto_flags.has("insufficient"):
				auto_flags.erase("insufficient")
				_update_actions()
		"race":
			state.travel = minf(float(state.travel) + delta * float(state.flow_ratio) / 22.0, 1.0)
			ghazi.visible = bool(state.gas_visible)
			if ghazi.visible and not gas_introduced:
				gas_introduced = true
				audio.play_cue("bubble")
				_speak(DATA.STAGES.race.gas_dialogue, "GHAZI")
			if state.travel >= 1.0 and not state.completed:
				state.completed = true
				qatoor.celebrate()
				audio.play_cue("success")
				_speak("وصلنا إلى السطح! هيا نلتقي أصدقاءنا في فاصل النفط والغاز والماء.")
				_update_actions()
		"separator":
			if phase_timer > 0.0:
				phase_timer -= delta
				if phase_timer <= 0.0:
					state.separation_index = int(state.separation_index) + 1
					interaction_locked = false
					if state.separation_index >= 3:
						state.completed = true
						qatoor.visible = true
						qatoor.position = Vector2(900, 530)
						qatoor.celebrate()
						_speak("أحسنتم! فصلنا الأطوار الثلاثة. النفط جاهز للانتقال إلى مراحل المعالجة والتكرير.")
					else:
						_set_phase_character()
					_update_actions()
		"refinery":
			if state.product != "":
				state.product_progress = minf(float(state.product_progress) + delta / 9.0, 1.0)
				if state.product_progress >= 1.0:
					var finished_product: String = state.product
					if finished_product not in products_seen:
						products_seen.append(finished_product)
					state.product = ""
					interaction_locked = false
					ui.show_notice("Journey discovered · choose another product or continue")
					qatoor.set_expression("happy")
					_update_actions()
		"quiz":
			if quiz_pending:
				phase_timer -= delta
				if phase_timer <= 0.0:
					quiz_pending = false
					interaction_locked = false
					quiz_index += 1
					if quiz_index >= DATA.QUIZ.size():
						ui.show_quiz_result(quiz_score)
						qatoor.celebrate()
						audio.play_cue("celebrate")
					else:
						quiz_first_try = true
						_show_question()
	if auto_mode:
		_automatic_step()
	var index: int = INTERACTIONS.PATH.find(stage_key)
	ui.set_progress((float(maxi(index, 0)) + _chapter_progress()) / 7.0)

func _chapter_progress() -> float:
	match stage_key:
		"reservoir": return clampf(stage_clock / 15.0, 0.0, 1.0)
		"drilling": return float(state.drilling_progress)
		"pressure": return model.choke
		"race": return float(state.travel)
		"separator": return float(state.sorted.size()) / 3.0
		"refinery": return float(products_seen.size()) / 4.0
		"finale": return 1.0
	return 0.0

func _update_actions() -> void:
	var actions: Array = []
	match stage_key:
		"reservoir":
			if state.intro >= 0.9:
				actions = [{"id":"drill_next", "label":"Help Qatoor · Start drilling   →"}]
		"drilling":
			if state.completed:
				actions = [{"id":"production", "label":"Open production path   →"}]
			elif interaction_locked:
				actions = [{"id":"wait", "label":"Installing production tubing…", "disabled":true}]
			else:
				actions = [{"id":"drill_toggle", "label":"Pause drilling" if state.drilling_running else "Start drilling"},
					{"id":"faster", "label":"Playback ×%.1f" % float(state.playback_speed), "secondary":true}]
		"pressure":
			actions = [{"id":"closed", "label":"Valve closed", "secondary":true}, {"id":"partial", "label":"Partially open", "secondary":true}, {"id":"open", "label":"More open"}]
			if model.choke > 0.0:
				actions.append({"id":"ride", "label":"Follow the flow   →", "disabled":not model.natural_flow_available})
		"race":
			actions = [{"id":"choke_down", "label":"− Choke", "secondary":true}, {"id":"choke_up", "label":"+ Choke"},
				{"id":"zoom_out", "label":"− Zoom", "secondary":true}, {"id":"zoom_in", "label":"+ Zoom", "secondary":true}]
			if state.completed:
				actions.append({"id":"surface", "label":"Meet the separator   →"})
		"separator":
			if state.completed:
				actions = [{"id":"refine", "label":"Discover everyday products   →"}]
			else:
				actions = [{"id":"outlet_oil", "label":"Oil outlet", "disabled":interaction_locked}, {"id":"outlet_gas", "label":"Gas outlet", "secondary":true,"disabled":interaction_locked}, {"id":"outlet_water", "label":"Water outlet", "secondary":true,"disabled":interaction_locked}]
		"refinery":
			if state.product != "":
				actions = [{"id":"wait", "label":"Following the product journey…", "disabled":true}]
			else:
				actions = [{"id":"product_car", "label":"Car fuel"}, {"id":"product_aviation", "label":"Aviation fuel", "secondary":true}, {"id":"product_marine", "label":"Marine fuel", "secondary":true}, {"id":"product_plastic", "label":"Plastic products", "secondary":true}, {"id":"product_asphalt", "label":"Asphalt", "secondary":true}]
				if products_seen.size() > 0:
					actions.append({"id":"finish", "label":"Finale   →"})
		"finale":
			actions = [{"id":"restart", "label":"Restart journey"}, {"id":"auto", "label":"Watch automatic movie", "secondary":true}, {"id":"quiz", "label":"Test your knowledge", "secondary":true}]
	ui.set_actions(actions)

func _on_action(id: String) -> void:
	if transitions.busy:
		return
	if id in ["resume", "menu", "restart", "auto", "start"]:
		get_tree().paused = false
		ui.show_pause(false)
		match id:
			"resume": return
			"menu":
				auto_mode = false
				_go("menu")
				return
			"auto", "start", "restart":
				auto_mode = id == "auto"
				model = MODEL.new()
				_go("reservoir")
				return
	if interaction_locked:
		return
	audio.play_cue("click")
	match stage_key:
		"reservoir":
			if id == "drill_next":
				qatoor.gesture("jumping")
				_go("drilling")
		"drilling":
			if id == "drill_toggle" and not state.completed:
				state.drilling_running = not state.drilling_running
				qatoor.set_expression("excited" if state.drilling_running else "thinking")
				audio.set_ambience("drilling" if state.drilling_running else "reservoir", 0.55)
			elif id == "faster" and not state.completed:
				state.playback_speed = 1.0 if float(state.playback_speed) >= 2.0 else float(state.playback_speed) + 0.5
				qatoor.gesture("excited")
				ui.show_notice("Educational playback speed · not a physical drilling-rate prediction")
			elif id == "production" and state.completed:
				_go("pressure")
		"pressure":
			if id in ["closed", "partial", "open"]:
				model.set_choke({"closed":0.0, "partial":0.4, "open":0.9}[id])
				model.update(0.0, float(state.travel))
				var producing: bool = id != "closed" and model.natural_flow_available
				qatoor.set_expression("confused" if id == "closed" else ("excited" if producing else "worried"))
				qatoor.gesture("floating" if producing else "thinking")
				if id != "closed":
					_speak(DATA.STAGES.pressure.dialogues[1] if model.natural_flow_available else DATA.STAGES.pressure.no_flow_dialogue)
			elif id == "ride" and model.choke > 0.0 and model.flow_rate > 0.1:
				_go("race")
		"race":
			if id in ["choke_down", "choke_up"]:
				model.set_choke(model.choke + (-0.15 if id == "choke_down" else 0.15))
				qatoor.set_expression("worried" if model.choke <= 0.001 else "excited")
				ui.show_notice("Choke opening  %d%%" % roundi(model.choke * 100.0))
			elif id in ["zoom_in", "zoom_out"]:
				camera_zoom = clampf(camera_zoom + (0.12 if id == "zoom_in" else -0.12), 0.88, 1.36)
				camera.frame(Vector2(960, 540), camera_zoom, 0.65)
			elif id == "surface" and state.completed:
				_go("separator")
		"separator":
			if id.begins_with("outlet_") and not state.completed:
				_select_outlet(id.trim_prefix("outlet_"))
			elif id == "refine" and state.completed:
				_go("refinery")
		"refinery":
			if id.begins_with("product_") and state.product == "":
				var product_id: String = id.trim_prefix("product_")
				if product_id in PRODUCT_ORDER:
					state.product = product_id
					state.product_progress = 0.0
					interaction_locked = true
					_speak(DATA.STAGES.refinery.products[product_id].dialogue)
					ui.show_notice(DATA.STAGES.refinery.products[product_id].caption)
					qatoor.gesture("pointing")
			elif id == "finish" and products_seen.size() > 0:
				_go("finale")
		"finale":
			if id == "quiz":
				_go("quiz")
		"quiz":
			if id.begins_with("answer_") and quiz_index < DATA.QUIZ.size():
				_answer_question(id.trim_prefix("answer_").to_int())
	if stage_key != "quiz":
		_update_actions()

func _set_phase_character() -> void:
	qatoor.visible = true
	qatoor.position = Vector2(650, 620)
	qatoor.scale = Vector2.ONE * 0.58
	ghazi.visible = false
	maee.visible = false
	var active: Node2D = _phase_character()
	active.visible = true
	active.position = Vector2(1120, 470)
	active.scale = Vector2.ONE * 0.64
	active.set_expression("happy")
	state.selected_outlet = ""
	if int(state.separation_index) > 0:
		_speak("أنا غازي! أرتفع إلى أعلى الفاصل، فأي مخرج يناسبني؟" if int(state.separation_index) == 1 else "أنا مائي! كثافتي أعلى من النفط في مثالنا، لذلك أستقر في الأسفل.", "GHAZI" if int(state.separation_index) == 1 else "MAEE")

func _phase_character() -> Node2D:
	return [qatoor, ghazi, maee][mini(int(state.separation_index), 2)]

func _select_outlet(outlet: String) -> void:
	var expected: String = PHASE_ORDER[int(state.separation_index)]
	var character: Node2D = _phase_character()
	if outlet != expected:
		state.feedback = -1.0
		character.gesture("incorrect")
		character.set_expression("confused")
		audio.play_cue("error")
		ui.show_notice(DATA.STAGES.separator.hints[expected], false)
		return
	interaction_locked = true
	state.feedback = 1.0
	state.selected_outlet = outlet
	state.sorted.append(outlet)
	character.celebrate()
	character_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	character_tween.tween_property(character, "position", OUTLETS[outlet], 1.6)
	character_tween.parallel().tween_property(character, "scale", Vector2.ONE * 0.24, 1.6)
	phase_timer = 2.2
	audio.play_cue("success")
	ui.show_notice("Perfect! %s found the correct outlet." % {"oil":"Qatoor", "gas":"Ghazi", "water":"Maee"}[outlet])
	_update_actions()

func _show_question() -> void:
	var question: Dictionary = DATA.QUIZ[quiz_index]
	ui.show_quiz(question.prompt, question.prompt_ar, question.answers)
	_speak(question.prompt_ar)
	qatoor.set_expression("thinking")

func _answer_question(answer: int) -> void:
	var question: Dictionary = DATA.QUIZ[quiz_index]
	if answer == int(question.correct):
		if quiz_first_try:
			quiz_score += 1
		quiz_pending = true
		interaction_locked = true
		phase_timer = 3.0
		qatoor.celebrate()
		audio.play_cue("success")
		ui.show_notice("Correct! " + question.explanation)
		_speak(question.explanation_ar)
	else:
		quiz_first_try = false
		qatoor.gesture("incorrect")
		audio.play_cue("error")
		ui.show_notice(question.explanation + " Try again!", false)
		_speak(question.explanation_ar)

func _automatic_step() -> void:
	match stage_key:
		"reservoir":
			if stage_clock >= 14.0: _on_action("drill_next")
		"drilling":
			if stage_clock >= 5.0 and not auto_flags.has("started"):
				auto_flags.started = true
				_on_action("drill_toggle")
			if state.completed and stage_clock > 37.0: _on_action("production")
		"pressure":
			if stage_clock >= 5.0 and not auto_flags.has("partial"):
				auto_flags.partial = true
				_on_action("partial")
			if stage_clock >= 11.0 and not auto_flags.has("open"):
				auto_flags.open = true
				_on_action("open")
			if stage_clock >= 15.0: _on_action("ride")
		"race":
			if stage_clock > 9.0 and not auto_flags.has("zoom"):
				auto_flags.zoom = true
				_on_action("zoom_in")
			if state.completed and stage_clock > 26.0: _on_action("surface")
		"separator":
			if stage_clock >= 7.0 + float(state.separation_index) * 7.0 and not interaction_locked and not state.completed:
				_on_action("outlet_" + PHASE_ORDER[int(state.separation_index)])
			if state.completed and stage_clock >= 25.0: _on_action("refine")
		"refinery":
			if stage_clock > 7.0 and not interaction_locked:
				if products_seen.size() < PRODUCT_ORDER.size():
					_on_action("product_" + PRODUCT_ORDER[products_seen.size()])
				else:
					_on_action("finish")

func _on_toolbar(id: String) -> void:
	match id:
		"pause":
			if stage_key != "menu":
				get_tree().paused = not get_tree().paused
				ui.show_pause(get_tree().paused)
		"menu": _on_action("menu")
		"sound":
			muted = not muted
			audio.set_muted(muted)
			ui.set_sound(muted)
		"motion":
			reduced_motion = not reduced_motion
			transitions.reduced_motion = reduced_motion
			if reduced_motion: camera.reset_frame()
			ui.show_notice("Gentle camera motion enabled" if reduced_motion else "Cinematic camera motion enabled")
		"data": ui.toggle_data()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_ESCAPE: _on_toolbar("pause")
		KEY_T: get_tree().change_scene_to_file("res://scenes/opening_title.tscn")
		KEY_M: _on_toolbar("sound")
		KEY_D: ui.toggle_data()
		KEY_R: _on_action("restart")
		KEY_F11:
			var full: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if full else DisplayServer.WINDOW_MODE_FULLSCREEN)
