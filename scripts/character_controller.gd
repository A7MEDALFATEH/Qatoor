class_name JourneyCharacter
extends Node2D
## Reusable, resolution-independent cartoon cast. All artwork is original vector drawing.
## Expressions describe emotion; gestures describe motion, so dialogue can coexist with either.

@export_enum("oil", "gas", "water") var character_kind: String = "oil"
@export var animation_pulse: float = 0.0
var expression: String = "idle"
var talking: bool = false
var motion: String = "idle"
var _clock: float = 0.0
var _gesture_time: float = 0.0
var _blink: float = 0.0
var _blink_clock: float = 2.8
var _excitement: float = 0.0
var _body_points: PackedVector2Array
var _inner_points: PackedVector2Array
var _anim: AnimationPlayer

const EXPRESSIONS: Array[String] = ["idle", "blinking", "happy", "excited", "surprised", "worried", "scared", "confused", "thinking", "talking", "jumping", "floating", "swimming", "carried", "celebrating", "pointing", "audience", "incorrect"]

func _ready() -> void:
	_body_points = _drop_points()
	_inner_points = _scaled_points(_body_points, Vector2(0.86, 0.9), Vector2(-4, 3))
	_anim = get_node_or_null("AnimationPlayer") as AnimationPlayer
	if _anim:
		_anim.play("breathe")
	set_process(true)

func set_expression(value: String) -> void:
	expression = value
	if value in ["jumping", "floating", "swimming", "carried", "pointing", "celebrating"]:
		gesture(value)
	if value == "blinking":
		_blink_clock = 0.0
	if value in ["happy", "excited", "celebrating"]:
		_excitement = 1.0
	if value == "talking":
		talking = true

func set_talking(value: bool) -> void:
	talking = value

func gesture(value: String) -> void:
	motion = value
	_gesture_time = 0.0
	if _anim and value in ["celebrating", "jumping"]:
		_anim.play("bounce")
		_anim.queue("breathe")

func celebrate() -> void:
	set_expression("celebrating")
	gesture("celebrating")

func _process(delta: float) -> void:
	_clock += delta
	_gesture_time += delta
	_excitement = move_toward(_excitement, 0.0, delta * 0.24)
	_blink_clock -= delta
	if _blink_clock <= -0.15:
		_blink_clock = 2.7 + sin(_clock * 0.73) * 0.85
	_blink = clampf(1.0 - absf(_blink_clock + 0.075) / 0.075, 0.0, 1.0) if _blink_clock < 0.0 else 0.0
	if motion in ["jumping", "celebrating", "incorrect"] and _gesture_time > 2.4:
		motion = "idle"
	queue_redraw()

func _draw() -> void:
	var bob: float = sin(_clock * 2.6) * 4.0
	var twist: float = sin(_clock * 1.7) * 0.025
	var squash: float = sin(_clock * 2.6) * 0.018 + animation_pulse * 0.045
	if motion == "swimming":
		twist += sin(_clock * 5.3) * 0.11
		bob += sin(_clock * 5.3) * 7.0
	elif motion == "carried":
		twist += sin(_clock * 7.0) * 0.07
		squash -= 0.055
	elif motion in ["jumping", "celebrating"]:
		bob -= absf(sin(minf(_gesture_time, 2.4) * PI * 2.0)) * 26.0
		twist += sin(_gesture_time * 10.0) * 0.08
	elif motion == "incorrect":
		twist += sin(_gesture_time * 22.0) * maxf(0.0, 0.14 - _gesture_time * 0.09)
	if expression == "scared":
		twist += sin(_clock * 35.0) * 0.018
	_draw_shadow(bob)
	draw_set_transform(Vector2(0, bob), twist, Vector2(1.0 + squash, 1.0 - squash))
	_draw_arms()
	if character_kind == "gas":
		_draw_gas_body()
	else:
		_draw_drop_body()
	_draw_face()
	_draw_sparkles()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_shadow(bob: float) -> void:
	for i in range(5, 0, -1):
		draw_set_transform(Vector2(0, 134), 0.0, Vector2(1.0, 0.19))
		draw_circle(Vector2.ZERO, 48.0 + float(i) * 9.0 + bob * 0.25, Color(0.015, 0.025, 0.045, 0.025))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_drop_body() -> void:
	var oil: bool = character_kind == "oil"
	var rim: Color = Color("e6a252") if oil else Color("94f3ff")
	var base: Color = Color("1b1722") if oil else Color("006bc2")
	var points: PackedVector2Array = _body_points
	draw_colored_polygon(points, Color("101522") if oil else Color("043a72"))
	var colors := PackedColorArray()
	for p in _inner_points:
		var side: float = clampf((p.x + 95.0) / 190.0, 0.0, 1.0)
		var high: float = clampf(1.0 - (p.y + 80.0) / 260.0, 0.0, 1.0)
		if oil:
			colors.append(base.lerp(Color("805238"), side * 0.62 + high * 0.12))
		else:
			colors.append(base.lerp(Color("43d8f2"), (1.0 - side) * 0.65 + high * 0.25))
	draw_polygon(_inner_points, colors)
	# Soft warm belly, curved silhouette rim, and the long glossy forehead reflection.
	var belly := PackedVector2Array([Vector2(-55, 38), Vector2(-23, 83), Vector2(27, 86), Vector2(65, 45), Vector2(65, -5), Vector2(37, 35), Vector2(0, 52)])
	draw_colored_polygon(belly, Color(0.65, 0.34, 0.17, 0.12) if oil else Color(0.02, 0.4, 0.95, 0.14))
	_curve(Vector2(23, -99), Vector2(90, -32), Vector2(103, 48), Vector2(40, 95), Color(rim, 0.6), 3.2)
	_curve(Vector2(-28, -104), Vector2(-42, -78), Vector2(-62, -47), Vector2(-64, -16), Color(0.95, 0.86, 0.69, 0.14) if oil else Color(0.8, 1.0, 1.0, 0.38), 14.0)
	_curve(Vector2(-24, -99), Vector2(-34, -81), Vector2(-45, -65), Vector2(-50, -44), Color(1.0, 0.96, 0.86, 0.68), 5.0)
	draw_circle(Vector2(-46, -35), 4.1, Color(1, 0.96, 0.89, 0.8))
	# A small swooping tip gives the silhouette character and follow-through.
	_curve(Vector2(-7, -137), Vector2(3, -146), Vector2(17, -143), Vector2(24, -155), Color(rim, 0.8), 3.0)

func _draw_gas_body() -> void:
	for i in range(4, 0, -1):
		draw_circle(Vector2(0, -4), 90.0 + float(i) * 5.0, Color(0.35, 0.86, 0.95, 0.035))
	draw_circle(Vector2(0, -4), 90.0, Color(0.26, 0.72, 0.79, 0.3))
	draw_circle(Vector2(-5, -9), 83.0, Color(0.39, 0.91, 0.93, 0.29))
	draw_arc(Vector2(0, -4), 89, 0, TAU, 90, Color(0.72, 1.0, 0.92, 0.85), 3.0, true)
	draw_arc(Vector2(-3, -6), 74, PI * 1.1, PI * 1.68, 24, Color(1, 1, 0.94, 0.88), 8.0, true)
	draw_arc(Vector2(0, -4), 82, 0.05, 1.25, 20, Color(0.82, 1, 0.65, 0.7), 4.0, true)
	draw_circle(Vector2(-49, -48), 7.0, Color(1, 1, 0.93, 0.82))
	# Gas curl: a distinct silhouette from the oil and water drops.
	_curve(Vector2(-8, -92), Vector2(-27, -121), Vector2(30, -129), Vector2(15, -106), Color("c9ffd1"), 4.0)

func _draw_arms() -> void:
	var wave: float = sin(_clock * 3.2) * 8.0
	var raised: bool = motion in ["celebrating", "jumping"] or expression in ["excited", "happy", "celebrating"]
	var pointing: bool = motion == "pointing" or expression == "pointing"
	var worried: bool = expression in ["worried", "scared", "thinking", "confused", "incorrect"]
	var arm_color: Color = Color("6b4636") if character_kind == "oil" else Color("49b7df")
	if character_kind == "gas":
		arm_color = Color("89ded7")
	var left_hand := Vector2(-135, 0 if raised else 62 + wave)
	var right_hand := Vector2(136, -23 if raised else 43 - wave)
	if raised:
		left_hand.y = -72 + wave
		right_hand.y = -82 - wave
	if pointing:
		right_hand = Vector2(151, -11 + wave * 0.2)
	if worried:
		right_hand = Vector2(68, 25 + wave * 0.2)
	_curve(Vector2(-74, 18), Vector2(-105, 12), Vector2(-111, left_hand.y + 21), left_hand, Color("0f1927"), 14.0)
	_curve(Vector2(-74, 18), Vector2(-105, 12), Vector2(-111, left_hand.y + 21), left_hand, arm_color, 8.0)
	_curve(Vector2(74, 14), Vector2(111, 4), Vector2(109, right_hand.y + 25), right_hand, Color("0f1927"), 14.0)
	_curve(Vector2(74, 14), Vector2(111, 4), Vector2(109, right_hand.y + 25), right_hand, arm_color, 8.0)
	_draw_hand(left_hand, false, raised)
	_draw_hand(right_hand, pointing, raised)

func _draw_hand(center: Vector2, pointing: bool, raised: bool) -> void:
	var glove := Color("fce7c8") if character_kind == "oil" else Color("d9ffff")
	draw_circle(center, 14.5, Color("1c2937"))
	draw_circle(center + Vector2(0, -1), 11.0, glove)
	if pointing:
		draw_line(center + Vector2(3, -7), center + Vector2(24, -11), Color("1c2937"), 10.0, true)
		draw_line(center + Vector2(3, -7), center + Vector2(24, -11), glove, 6.0, true)
		draw_circle(center + Vector2(24, -11), 3.0, glove)
	elif raised:
		for i in range(3):
			var start := center + Vector2(float(i - 1) * 6.0, -6)
			var end := start + Vector2(float(i - 1) * 3.0, -12 - (3.0 if i == 1 else 0.0))
			draw_line(start, end, Color("1c2937"), 9.0, true)
			draw_line(start, end, glove, 5.0, true)
			draw_circle(end, 2.5, glove)
	draw_arc(center + Vector2(2, 2), 6, 0.2, 1.7, 12, Color(0.45, 0.39, 0.31, 0.5), 1.5, true)

func _draw_face() -> void:
	var worried: bool = expression in ["worried", "scared", "confused", "thinking", "incorrect"]
	var amazed: bool = expression in ["surprised", "excited", "scared"]
	var cheerful: bool = expression in ["happy", "excited", "celebrating", "audience"]
	var face_y: float = -6.0 if character_kind == "gas" else 0.0
	var gaze := Vector2(sin(_clock * 0.7) * 2.5, 0)
	if motion == "pointing":
		gaze.x = 7.0
	if expression == "thinking":
		gaze = Vector2(6, -7)
	var eye_open: float = maxf(0.055, 1.0 - _blink)
	for side in [-1, 1]:
		var center := Vector2(float(side) * 31.0, -25 + face_y)
		var height: float = 32.0 if amazed else 28.0
		if cheerful:
			height = 26.0
		_ellipse(center + Vector2(0, 2), Vector2(26, height + 2.0), Color(0.02, 0.02, 0.035, 0.38))
		_ellipse(center, Vector2(24, height * eye_open), Color("fff5dd"))
		if eye_open > 0.2:
			_ellipse(center + Vector2(0, 3), Vector2(22, (height - 4.0) * eye_open), Color("fffdf7"))
			var iris := center + gaze + Vector2(3, 2)
			_ellipse(iris, Vector2(11.5, 15.5 * eye_open), Color("704d33") if character_kind == "oil" else Color("257c93"))
			_ellipse(iris + Vector2(1, 0), Vector2(7.8, 11.8 * eye_open), Color("131c2a"))
			draw_circle(iris + Vector2(-3, -5 * eye_open), 4.0 * eye_open, Color("ffffff"))
			draw_circle(iris + Vector2(4, 5 * eye_open), 1.9 * eye_open, Color("ffffff"))
		var brow_y: float = -64.0 + face_y
		var slope: float = -float(side) * 3.0
		if worried:
			slope = -float(side) * 11.0
			brow_y -= 3.0
		if amazed:
			brow_y -= 8.0
		_curve(center + Vector2(-17, brow_y - center.y + slope), center + Vector2(-7, brow_y - center.y - 6), center + Vector2(7, brow_y - center.y - 6), center + Vector2(17, brow_y - center.y - slope), Color("160f1d") if character_kind == "oil" else Color("105469"), 5.5)
	# Blush and muzzle highlights keep the dark oil character friendly and readable.
	_ellipse(Vector2(-57, 17 + face_y), Vector2(12, 6), Color(0.92, 0.42, 0.25, 0.22))
	_ellipse(Vector2(58, 17 + face_y), Vector2(12, 6), Color(0.92, 0.42, 0.25, 0.22))
	var mouth_center := Vector2(2, 40 + face_y)
	if expression in ["surprised", "scared"] and not talking:
		_ellipse(mouth_center, Vector2(15, 21), Color("170e1a"))
		_ellipse(mouth_center + Vector2(1, 10), Vector2(9, 5), Color("d87572"))
	elif worried and not talking:
		_curve(mouth_center + Vector2(-20, 7), mouth_center + Vector2(-5, -7), mouth_center + Vector2(8, -7), mouth_center + Vector2(22, 7), Color("120e1a"), 5.0)
	else:
		var jaw: float = 12.0 + (absf(sin(_clock * 13.5)) * 13.0 if talking else 0.0)
		if cheerful:
			jaw += 5.0
		var mouth := PackedVector2Array()
		for i in range(17):
			var f: float = float(i) / 16.0
			mouth.append(mouth_center + Vector2(lerpf(-29, 29, f), sin(f * PI) * 3.0))
		for i in range(17):
			var f: float = float(i) / 16.0
			mouth.append(mouth_center + Vector2(lerpf(29, -29, f), sin(f * PI) * jaw))
		draw_colored_polygon(mouth, Color("160c17"))
		_curve(mouth_center + Vector2(-21, 4), mouth_center + Vector2(-8, 8), mouth_center + Vector2(8, 8), mouth_center + Vector2(21, 4), Color("fff5e3"), 4.5)
		if jaw > 16.0:
			_ellipse(mouth_center + Vector2(1, jaw - 6), Vector2(12, 4), Color("d97b7c"))
		_curve(mouth_center + Vector2(-29, 0), mouth_center + Vector2(-12, jaw * 1.15), mouth_center + Vector2(16, jaw * 1.15), mouth_center + Vector2(29, 0), Color(0.68, 0.41, 0.25, 0.35), 2.0)

func _draw_sparkles() -> void:
	if expression not in ["excited", "celebrating", "happy"] and _excitement <= 0.0:
		return
	for i in range(5):
		var angle: float = float(i) * 1.4 + _clock * 0.4
		var p := Vector2(cos(angle) * 132.0, sin(angle) * 129.0 - 18.0)
		var a: float = (0.45 + sin(_clock * 4.0 + float(i)) * 0.3) * maxf(0.3, _excitement)
		var c := Color(1.0, 0.78, 0.31, a)
		draw_line(p - Vector2(5, 0), p + Vector2(5, 0), c, 2.0, true)
		draw_line(p - Vector2(0, 5), p + Vector2(0, 5), c, 2.0, true)

func _drop_points() -> PackedVector2Array:
	var result := PackedVector2Array()
	_append_cubic(result, Vector2(-7, -142), Vector2(-15, -112), Vector2(-92, -51), Vector2(-92, 22))
	_append_cubic(result, Vector2(-92, 22), Vector2(-94, 81), Vector2(-49, 115), Vector2(3, 113))
	_append_cubic(result, Vector2(3, 113), Vector2(58, 113), Vector2(100, 79), Vector2(93, 20))
	_append_cubic(result, Vector2(93, 20), Vector2(88, -48), Vector2(30, -91), Vector2(-7, -142))
	return result

func _scaled_points(points: PackedVector2Array, amount: Vector2, offset: Vector2) -> PackedVector2Array:
	var result := PackedVector2Array()
	for p in points:
		result.append(p * amount + offset)
	return result

func _append_cubic(points: PackedVector2Array, a: Vector2, b: Vector2, c: Vector2, d: Vector2) -> void:
	for i in range(20):
		var f: float = float(i) / 20.0
		points.append(a.bezier_interpolate(b, c, d, f))

func _curve(a: Vector2, b: Vector2, c: Vector2, d: Vector2, color: Color, width: float) -> void:
	var points := PackedVector2Array()
	for i in range(25):
		points.append(a.bezier_interpolate(b, c, d, float(i) / 24.0))
	draw_polyline(points, color, width, true)

func _ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(40):
		var angle: float = float(i) / 40.0 * TAU
		points.append(center + Vector2(cos(angle), sin(angle)) * radii)
	draw_colored_polygon(points, color)
