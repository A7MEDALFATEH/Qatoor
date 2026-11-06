extends SceneTree
## Run with: godot --headless --path . --script res://tests/run_checks.gd
## Drives the actual story controller and real UI action signal, with accelerated
## elapsed time. Cinematic transition tweens still run through normal scene frames.

var experience: Node
var checked: int = 0
var failed: int = 0
var visited: Dictionary = {}

func _init() -> void:
	_run.call_deferred()

func _check(condition: bool, message: String) -> void:
	checked += 1
	if condition:
		print("  PASS ", message)
	else:
		failed += 1
		push_error("  FAIL " + message)

func _frames(count: int = 2) -> void:
	for i in range(count):
		await process_frame

func _tick(seconds: float, step: float = 0.5) -> void:
	var left: float = seconds
	while left > 0.0:
		var dt: float = minf(step, left)
		if experience.transitions.busy:
			await _settle()
		experience._process(dt)
		visited[experience.stage_key] = true
		left -= dt
		await process_frame

func _act(id: String) -> void:
	experience.ui.action.emit(id)
	await _frames()
	if experience.transitions.busy:
		await _settle()

func _settle() -> void:
	# A short real-time wait lets the actual fade tweens and awaited initialization
	# finish. No cinematic logic is duplicated by the tests.
	for attempt in range(30):
		if not experience.transitions.busy:
			break
		await create_timer(0.05).timeout
	await _frames()
	_check(not experience.transitions.busy, "cinematic transition finishes and unlocks input")

func _test_model() -> void:
	print("Engineering model")
	var model = load("res://scripts/engineering_model.gd").new()
	model.update(1.0, 0.0)
	_check(is_zero_approx(model.flow_rate), "closed choke stops production")
	model.set_choke(0.4)
	model.update(10.0, 0.0)
	var partial: float = model.flow_rate
	_check(partial > 0.0, "partial opening produces under available pressure head")
	model.set_choke(1.0)
	model.update(10.0, 0.8)
	_check(model.flow_rate > partial, "larger choke increases model flow")
	_check(is_equal_approx(model.reservoir_pressure, 280.0), "surface choke leaves reservoir pressure unchanged")
	_check(is_equal_approx(model.flow_rate, 5.0 * (model.reservoir_pressure - model.flowing_bottomhole_pressure)), "flow matches the PI driving-pressure relationship")
	_check(model.snapshot().gas_visible, "gas appears below the local bubble-point pressure")
	model.update(1.0, 0.0)
	_check(not model.snapshot().gas_visible, "gas stays dissolved above the bubble-point pressure")
	model.reservoir_pressure = 160.0
	model.update(1.0, 0.0)
	_check(is_zero_approx(model.flow_rate) and not model.natural_flow_available, "insufficient natural-flow head gives zero production")

func _test_resources() -> void:
	print("Resources")
	for path in ["scenes/main.tscn", "scenes/reservoir.tscn", "scenes/drilling.tscn", "scenes/pressure_challenge.tscn", "scenes/production_journey.tscn", "scenes/separator.tscn", "scenes/refinery.tscn", "scenes/finale.tscn", "scenes/quiz.tscn", "characters/qatoor.tscn", "characters/ghazi.tscn", "characters/maee.tscn"]:
		_check(ResourceLoader.exists("res://" + path) and load("res://" + path) is PackedScene, path + " loads")

func _run() -> void:
	_test_model()
	_test_resources()
	var main_scene = load("res://scenes/main.tscn")
	if not main_scene is PackedScene:
		_check(false, "main scene loads")
		_finish()
		return
	experience = main_scene.instantiate()
	root.add_child(experience)
	await _frames(3)
	experience.set_process(false)
	experience.reduced_motion = true
	experience.transitions.reduced_motion = true
	await _run_story_checks()
	_finish()

func _run_story_checks() -> void:
	print("Interactive journey")
	_check(experience.stage_key == "menu", "project opens on its main menu")
	_check(experience.ui.action.is_connected(experience._on_action), "interface actions are connected to story decisions")
	_check(is_instance_valid(experience.qatoor) and is_instance_valid(experience.ghazi) and is_instance_valid(experience.maee), "all three reusable characters instantiate")
	_check(not experience.ui._data_panel.visible, "engineering data is hidden on startup")
	await _act("start")
	_check(experience.stage_key == "reservoir" and not experience.auto_mode, "Start Journey enters interactive reservoir chapter")
	await _tick(8.0)
	_check(is_equal_approx(float(experience.state.intro), 1.0), "reservoir descent reaches its pore-space closeup")
	# Invalid navigation cannot jump over the story graph.
	experience._go("refinery")
	await _frames()
	_check(experience.stage_key == "reservoir" and not experience.transitions.busy, "invalid chapter skips are rejected")
	# Repeated touches during the same transition must not spawn extra scenes.
	experience.ui.action.emit("drill_next")
	experience.ui.action.emit("drill_next")
	await _settle()
	_check(experience.stage_key == "drilling", "repeated drilling navigation enters exactly one chapter")
	await _act("drill_toggle")
	await _tick(3.0)
	var drilled: float = experience.state.drilling_progress
	_check(drilled > 0.0 and experience.state.drilling_running, "drill control advances animated well depth")
	await _act("drill_toggle")
	await _tick(3.0)
	_check(is_equal_approx(float(experience.state.drilling_progress), drilled), "Pause Drilling holds bit depth")
	await _act("faster")
	_check(float(experience.state.playback_speed) > 1.0, "playback control changes drilling animation speed")
	await _act("drill_toggle")
	await _tick(25.0)
	_check(experience.state.completed and not experience.state.drilling_running, "drilling finishes and installs production completion")
	_check(float(experience.state.completion_progress) >= 1.0, "completion sequence reaches a ready production pathway")
	await _act("production")
	_check(experience.stage_key == "pressure", "completed well opens the pressure challenge")
	await _tick(1.0)
	_check(is_zero_approx(experience.model.flow_rate), "closed-valve scene has no fluid production")
	var origin_x: float = experience.qatoor.position.x
	await _act("partial")
	await _tick(4.0)
	var partial_rate: float = experience.model.flow_rate
	_check(partial_rate > 0.0 and experience.qatoor.position.x > origin_x, "partial valve produces flow and visibly carries Qatoor toward the well")
	await _act("open")
	await _tick(4.0)
	_check(experience.model.flow_rate > partial_rate, "more-open valve increases both model and animation flow")
	await _act("closed")
	await _tick(1.0)
	_check(is_zero_approx(experience.model.flow_rate) and is_zero_approx(float(experience.state.flow_ratio)), "closing the valve stops the scene flow")
	# Verify the same scene communicates an insufficient natural-flow condition.
	experience.model.reservoir_pressure = 160.0
	await _act("open")
	_check(experience.ui._dialogue._body.text == experience.DATA.STAGES.pressure.no_flow_dialogue, "insufficient-pressure narration immediately matches the current model")
	await _tick(2.0)
	_check(not experience.model.natural_flow_available and is_zero_approx(experience.model.flow_rate), "low-pressure scene cannot manufacture natural production")
	await _act("ride")
	_check(experience.stage_key == "pressure", "audience cannot ride a nonproducing well")
	experience.model.reservoir_pressure = 280.0
	await _tick(2.0)
	await _act("ride")
	_check(experience.stage_key == "race", "flowing production begins the tubing journey")
	var before_choke: float = experience.model.choke
	await _act("choke_down")
	_check(experience.model.choke < before_choke, "race choke decrease changes the production control")
	await _act("choke_up")
	_check(is_equal_approx(experience.model.choke, before_choke), "race choke increase restores the control")
	await _act("zoom_in")
	_check(experience.camera_zoom > 1.0, "camera zoom-in changes the cinematic target")
	await create_timer(0.7).timeout
	_check(experience.camera.zoom.x > 1.0, "camera tween visibly changes world framing")
	await _act("zoom_out")
	await _tick(17.0)
	_check(float(experience.state.travel) > 0.5 and experience.gas_introduced and experience.ghazi.visible, "upward journey reveals Ghazi under bubble-point conditions")
	for i in range(8):
		await _act("choke_down")
	await _tick(1.0)
	var stalled: float = experience.state.travel
	await _tick(2.0)
	_check(is_equal_approx(float(experience.state.travel), stalled), "fully closed race choke halts Qatoor's ascent")
	for i in range(7):
		await _act("choke_up")
	await _tick(25.0)
	_check(experience.state.completed and is_equal_approx(float(experience.state.travel), 1.0), "Qatoor reaches the surface through flowing tubing")
	await _act("surface")
	_check(experience.stage_key == "separator", "surface arrival reveals the three-phase separator")
	await _act("outlet_water")
	_check(experience.state.sorted.is_empty() and not experience.interaction_locked and float(experience.state.feedback) < 0.0, "wrong separator outlet gives gentle feedback and permits retry")
	for phase in ["oil", "gas", "water"]:
		await _act("outlet_" + phase)
		_check(phase in experience.state.sorted and experience.interaction_locked, phase + " illuminates its correct pipe and starts character transport")
		# A second press while transport is active cannot count twice.
		await _act("outlet_" + phase)
		_check(experience.state.sorted.count(phase) == 1, "repeated " + phase + " selection is gated")
		await _tick(2.5)
	_check(experience.state.completed and experience.state.sorted.size() == 3, "all three phases complete the separation challenge")
	await _act("refine")
	_check(experience.stage_key == "refinery", "separated oil reaches later refining and petrochemistry")
	await _tick(0.3)
	_check(is_zero_approx(float(experience.model.snapshot().depth)), "surface engineering data stays at zero depth after separation")
	for product in ["car", "aviation", "plastic", "asphalt"]:
		await _act("product_" + product)
		_check(experience.state.product == product and experience.interaction_locked, product + " begins its distinct animated processing journey")
		await _tick(4.0)
		_check(float(experience.state.product_progress) > 0.0 and float(experience.state.product_progress) < 1.0, product + " has an advancing cinematic timeline")
		await _tick(6.0)
		_check(experience.state.product == "" and product in experience.products_seen and not experience.interaction_locked, product + " returns to working product selection")
	await _act("finish")
	_check(experience.stage_key == "finale" and experience.state.celebration, "journey finishes with a celebration")
	await _act("quiz")
	_check(experience.stage_key == "quiz" and experience.quiz_index == 0, "finale opens the three-question knowledge quiz")
	for question_index in range(3):
		var question: Dictionary = experience.DATA.QUIZ[question_index]
		if question_index == 0:
			await _act("answer_" + str((int(question.correct) + 1) % 3))
			_check(experience.quiz_index == 0 and not experience.quiz_pending, "incorrect quiz answer explains the concept and permits retry")
		await _act("answer_" + str(question.correct))
		_check(experience.quiz_pending and experience.interaction_locked, "correct quiz answer " + str(question_index + 1) + " triggers animated feedback")
		await _tick(3.5)
	_check(experience.quiz_index == 3 and experience.quiz_score == 2, "quiz result counts first-try answers consistently")
	# Global pause/resume and exhibition preferences remain usable.
	experience.ui.toolbar.emit("sound")
	_check(experience.muted and experience.audio.muted, "sound toggle reaches the audio system")
	experience.ui.toolbar.emit("sound")
	experience.ui._handle_toolbar("data")
	_check(experience.ui._data_panel.visible, "engineering data panel can be opened")
	experience.ui._handle_toolbar("details")
	_check(experience.ui._details.visible, "engineering assumptions can be expanded")
	experience.ui.toolbar.emit("pause")
	await _frames()
	_check(paused and experience.ui._overlay != null, "pause displays a usable exhibition overlay")
	await _act("resume")
	_check(not paused and experience.ui._overlay == null, "resume returns control to the same story")
	await _act("restart")
	_check(experience.stage_key == "reservoir" and not experience.auto_mode and is_zero_approx(experience.model.choke), "restart clears simulation and returns to the beginning")
	await _act("menu")
	_check(experience.stage_key == "menu", "main menu remains accessible after a full playthrough")
	print("Automatic cinematic presentation")
	visited.clear()
	await _act("auto")
	_check(experience.auto_mode and experience.stage_key == "reservoir", "automatic mode starts from the same reservoir scene")
	var simulation_time: float = 0.0
	while experience.stage_key != "finale" and simulation_time < 240.0:
		await _tick(1.0)
		simulation_time += 1.0
	_check(experience.stage_key == "finale", "automatic movie completes without user story decisions")
	for stage in ["reservoir", "drilling", "pressure", "race", "separator", "refinery", "finale"]:
		_check(visited.has(stage), "automatic presentation includes " + stage)
	_check(experience.products_seen.size() == 4, "automatic presentation explores all four product stories")
	_check(simulation_time >= 120.0 and simulation_time <= 180.0, "automatic movie timing stays within approximately two to three minutes")
	await _act("menu")
	_check(experience.stage_key == "menu" and not experience.auto_mode, "automatic mode exits cleanly to the main menu")

func _finish() -> void:
	print("\nQATOOR INTEGRATION: ", checked - failed, "/", checked, " checks passed; ", failed, " failed")
	if experience != null:
		# Release active audio before quitting the headless audio-server thread.
		for player in experience.audio.get_children():
			if player is AudioStreamPlayer:
				player.stop()
				player.stream = null
		experience.queue_free()
		experience = null
	await create_timer(0.15).timeout
	await process_frame
	quit(0 if failed == 0 else 1)
