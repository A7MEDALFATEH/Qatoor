extends Node2D
## Layered, original vector illustrations for the four underground chapters.
## StoryManager owns state; this renderer has no timers that advance the story.
@export_enum("reservoir", "drilling", "pressure", "race") var stage: String = "reservoir"
var state: Dictionary = {}
var clock: float = 0.0
var flow_clock: float = 0.0
const INK := Color("101d2e")
const NAVY := Color("102335")
const GOLD := Color("f7bd62")
const CYAN := Color("80e2dd")
const WHITE := Color("e5edf0")

func _process(delta: float) -> void:
	clock += delta
	flow_clock += delta * float(state.get("flow_ratio", 0.0))
	queue_redraw()

func _draw() -> void:
	_backdrop()
	match stage:
		"reservoir": _reservoir()
		"drilling": _drilling()
		"pressure": _pressure()
		"race": _race()
	_editorial_scrim()
	_dust()

func _editorial_scrim() -> void:
	# The illustration stays visible through a soft navy veil behind editorial text.
	var dark := Color(0.035, 0.075, 0.12, 0.94)
	var clear := Color(0.035, 0.075, 0.12, 0.0)
	draw_rect(Rect2(0, 145, 390, 750), dark)
	draw_polygon(PackedVector2Array([Vector2(390, 145), Vector2(980, 145), Vector2(980, 895), Vector2(390, 895)]), PackedColorArray([dark, clear, clear, dark]))

func _backdrop() -> void:
	draw_rect(Rect2(0, 0, 1920, 1080), INK)
	for i in range(22):
		var f: float = float(i) / 21.0
		draw_rect(Rect2(0, 145 + i * 31, 1920, 33), Color("15293a").lerp(Color("071622"), f))
	_glow(Vector2(1230, 440), 600, Color(0.20, 0.39, 0.43, 0.075))

func _glow(center: Vector2, radius: float, color: Color) -> void:
	for i in range(15, 0, -1):
		var c: Color = color
		c.a *= 0.10
		draw_circle(center, radius * float(i) / 15.0, c)

func _line(points: Array, color: Color, width: float = 3.0) -> void:
	var vertices: PackedVector2Array = PackedVector2Array(points)
	if vertices.size() > 1:
		draw_polyline(vertices, color, width, true)

func _poly(points: Array, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points), color)

func _label(at: Vector2, caption: String, color: Color = WHITE, size: int = 18) -> void:
	draw_string(ThemeDB.fallback_font, at, caption, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _strata(top: float, bottom: float, shift: float = 0.0) -> void:
	var colors: Array[Color] = [Color("6d5450"), Color("8c6653"), Color("a67b5d"), Color("574741"), Color("73544a"), Color("9a7355"), Color("4d5150")]
	var band_h: float = (bottom - top) / 7.0
	for k in range(7):
		var yy: float = top + k * band_h
		var points: Array = []
		for j in range(25):
			var x: float = j * 80.0
			points.append(Vector2(x, yy + sin(x * 0.004 + k * 1.3 + shift) * 13 + sin(x * 0.011 + k) * 4))
		for j in range(24, -1, -1):
			var x: float = j * 80.0
			points.append(Vector2(x, yy + band_h + 4 + sin(x * 0.004 + (k + 1) * 1.3 + shift) * 13))
		_poly(points, colors[k])
		var seam: Array = []
		for j in range(25):
			var x: float = j * 80.0
			seam.append(Vector2(x, yy + 5 + sin(x * 0.004 + k * 1.3 + shift) * 13))
		_line(seam, Color(0.95, 0.77, 0.58, 0.13), 2)
		for n in range(42):
			var xx: float = fposmod(n * 137.7 + k * 89.5, 1920.0)
			var y: float = yy + 17 + fposmod(n * 29.1, maxf(band_h - 22, 1.0))
			draw_line(Vector2(xx, y), Vector2(xx + 9 + fposmod(n * 7, 17), y - 1), Color(0.12, 0.13, 0.14, 0.18), 2, true)

func _rock(center: Vector2, radius: float, seed_value: float, color: Color) -> void:
	var points: Array = []
	for j in range(12):
		var angle: float = float(j) * TAU / 12.0
		var r: float = radius * (0.84 + 0.13 * sin(j * 5.0 + seed_value))
		points.append(center + Vector2(cos(angle) * r, sin(angle) * r * 0.72))
	_poly(points, Color("2a2830"))
	var inner: Array = []
	for p: Vector2 in points:
		inner.append(center + (p - center) * 0.91 + Vector2(0, -3))
	_poly(inner, color)
	_line([center + Vector2(-radius * 0.55, -radius * 0.2), center + Vector2(-radius * 0.2, -radius * 0.42), center + Vector2(radius * 0.32, -radius * 0.35)], color.lightened(0.18), 3)
	for k in range(4):
		var p: Vector2 = center + Vector2(sin(k * 2.4 + seed_value) * radius * 0.5, cos(k * 3.3 + seed_value) * radius * 0.28)
		draw_circle(p, 2.0 + fposmod(seed_value + k, 3.0), Color(0.12, 0.12, 0.14, 0.18))

func _reservoir() -> void:
	var intro: float = float(state.get("intro", 1.0))
	_strata(175, 810)
	# Dense sealing formation above the connected, oil-filled sandstone pores.
	var seal: Array = [Vector2(0, 220), Vector2(250, 235), Vector2(620, 295), Vector2(1000, 260), Vector2(1420, 225), Vector2(1920, 290), Vector2(1920, 385), Vector2(1420, 310), Vector2(1000, 335), Vector2(620, 370), Vector2(250, 315), Vector2(0, 310)]
	_poly(seal, Color("3c3e47"))
	_line([Vector2(0, 233), Vector2(250, 248), Vector2(620, 308), Vector2(1000, 273), Vector2(1420, 238), Vector2(1920, 303)], Color("606165"), 7)
	# Oil and water occupy connected voids, rather than an underground lake.
	_poly([Vector2(460, 390), Vector2(700, 355), Vector2(1000, 390), Vector2(1450, 350), Vector2(1830, 405), Vector2(1920, 690), Vector2(500, 750)], Color("302722"))
	_glow(Vector2(1080, 510), 420, Color(1.0, 0.54, 0.16, 0.15))
	for i in range(11):
		var path: Array = []
		for j in range(40):
			var x: float = 530 + j * 34
			var y: float = 412 + i * 28 + sin(x * 0.012 + i * 0.72 + clock * 0.28) * 9
			path.append(Vector2(x, y))
		_line(path, Color(0.61, 0.35, 0.13, 0.10), 3)
	# Water-wet lower pores form a visually distinct connected phase.
	_poly([Vector2(500, 690), Vector2(790, 668), Vector2(1150, 698), Vector2(1530, 658), Vector2(1920, 682), Vector2(1920, 810), Vector2(460, 810)], Color("295264"))
	for row in range(5):
		for col in range(10):
			var xx: float = 550 + col * 142 + sin(row * 1.8 + col * 1.2) * 19
			var yy: float = 380 + row * 88 + sin(col * 1.9 + row) * 17
			if (Vector2(xx, yy) - Vector2(1020, 515)).length() < 168:
				continue
			var shade: Color = Color("a17854").lerp(Color("6f594b"), fposmod(row * 0.3 + col * 0.17, 1.0))
			_rock(Vector2(xx, yy), 55 + sin(col * 2.1 + row) * 13, col + row * 5.4, shade)
	for i in range(20):
		var xx: float = 620 + fposmod(i * 173.0 + clock * 7.0, 1160)
		var yy: float = 400 + fposmod(i * 73.0, 270)
		draw_circle(Vector2(xx, yy), 2 + sin(i) * 0.7, Color(0.98, 0.72, 0.33, 0.43))
	# Geological scale, a thin, understated etched guide.
	draw_line(Vector2(1820, 220), Vector2(1820, 770), Color(0.95, 0.85, 0.67, 0.32), 1.5)
	for i in range(6):
		var yy: float = 240 + i * 100
		draw_line(Vector2(1809, yy), Vector2(1831, yy), Color(0.95, 0.85, 0.67, 0.5), 2)
		_label(Vector2(1728, yy + 5), "%d m" % (i * 500), Color(0.92, 0.87, 0.76, 0.65), 17)
	# A wide landscape moves above the camera; real strata then cross the
	# frame before the enlarged pore illustration beneath it is revealed.
	if intro < 0.90:
		var descent: float = smoothstep(0.05, 0.88, intro)
		var ground_y: float = lerpf(830.0, -920.0, descent)
		_strata(ground_y, ground_y + 850.0, intro * 0.5)
		for i in range(16):
			var y: float = ground_y - 1600.0 + i * 100.0
			draw_rect(Rect2(0, y, 1920, 101.0), Color("386078").lerp(Color("82b4b4"), float(i) / 16.0))
		# Atmospheric distance, sun halo, wind and a tiny surface well site.
		_glow(Vector2(1490, ground_y - 395), 190, Color(1.0, 0.83, 0.54, 0.22))
		draw_circle(Vector2(1490, ground_y - 395), 47, Color("f8d49c"))
		for i in range(4):
			_cloud(Vector2(580 + i * 400 + sin(clock * 0.05 + i) * 18, ground_y - 385 + i * 35), 1.9)
		_poly([Vector2(0, ground_y), Vector2(0, ground_y - 118), Vector2(320, ground_y - 180), Vector2(540, ground_y - 97), Vector2(820, ground_y - 155), Vector2(1100, ground_y - 98), Vector2(1430, ground_y - 159), Vector2(1750, ground_y - 98), Vector2(1920, ground_y - 133), Vector2(1920, ground_y)], Color("5d9290"))
		_poly([Vector2(0, ground_y), Vector2(0, ground_y - 32), Vector2(230, ground_y - 72), Vector2(540, ground_y - 24), Vector2(840, ground_y - 61), Vector2(1080, ground_y - 19), Vector2(1390, ground_y - 54), Vector2(1650, ground_y - 24), Vector2(1920, ground_y - 45), Vector2(1920, ground_y)], Color("436e68"))
		_poly([Vector2(0, ground_y), Vector2(0, ground_y - 7), Vector2(370, ground_y - 15), Vector2(810, ground_y - 3), Vector2(1240, ground_y - 18), Vector2(1600, ground_y - 8), Vector2(1920, ground_y - 13), Vector2(1920, ground_y)], Color("a9a277"))
		_line([Vector2(0, ground_y), Vector2(1920, ground_y)], Color("deb57b"), 9)
		var rx: float = 1230.0
		for side in [-1, 1]:
			draw_line(Vector2(rx + side * 55, ground_y - 9), Vector2(rx + side * 13, ground_y - 168), Color("293f45"), 7, true)
		for k in range(4):
			var yy: float = ground_y - 145 + k * 37
			var h: float = 20 + k * 10
			_line([Vector2(rx - h, yy), Vector2(rx + h + 9, yy + 37), Vector2(rx - h - 9, yy + 37), Vector2(rx + h, yy)], Color("587675"), 3)
		draw_rect(Rect2(rx - 67, ground_y - 14, 134, 12), Color("dbb97a"))
		draw_rect(Rect2(1370, ground_y - 42, 130, 37), Color("496b6b"))
		draw_rect(Rect2(1380, ground_y - 45, 110, 5), Color("aec0a5"))
		# Small fossils and sediment laminations slide past during the descent.
		for k in range(5):
			var yy: float = ground_y + 140 + k * 128
			var xx: float = 910 + sin(k * 1.8) * 280
			draw_arc(Vector2(xx, yy), 16, 0.2, PI * 1.8, 28, Color(0.89, 0.76, 0.58, 0.25), 2, true)
			draw_arc(Vector2(xx + 3, yy - 2), 9, 0.4, PI * 1.8, 20, Color(0.89, 0.76, 0.58, 0.25), 2, true)
			_label(Vector2(1735, yy), "%d m" % ((k + 1) * 400), Color(0.92, 0.87, 0.76, 0.65), 17)

func _drilling() -> void:
	var progress: float = clampf(float(state.get("drilling_progress", 0.0)), 0.0, 1.0)
	var running: bool = bool(state.get("drilling_running", false))
	var completed: bool = bool(state.get("completed", false))
	var speed: float = float(state.get("playback_speed", 1.0))
	var completion: float = clampf(float(state.get("completion_progress", 1.0 if completed else 0.0)), 0.0, 1.0)
	if completed:
		completion = 1.0
	var well_end: float = lerpf(373, 744, progress)
	var bit_y: float = lerpf(well_end, 340.0, smoothstep(0.0, 0.30, completion))
	# Amber dusk above a richly layered geological cutaway.
	for i in range(8):
		draw_rect(Rect2(0, 150 + i * 25, 1920, 26), Color("315166").lerp(Color("aa805b"), float(i) / 8.0))
	_glow(Vector2(1570, 236), 145, Color(1.0, 0.74, 0.41, 0.20))
	draw_circle(Vector2(1570, 236), 34, Color("e4ba7a"))
	for i in range(3):
		var xx: float = 480 + i * 570 + sin(clock * 0.03 + i) * 40
		_cloud(Vector2(xx, 208 + i * 21), 1.0 - i * 0.12)
	_poly([Vector2(0, 345), Vector2(0, 320), Vector2(260, 275), Vector2(470, 320), Vector2(710, 287), Vector2(950, 328), Vector2(1250, 288), Vector2(1600, 315), Vector2(1920, 280), Vector2(1920, 345)], Color("4d6869"))
	_strata(352, 835)
	draw_rect(Rect2(0, 344, 1920, 10), Color("d3a06a"))
	# Target sandstone with repeating intergranular pores.
	draw_rect(Rect2(0, 706, 1920, 94), Color("544234"))
	for n in range(38):
		_rock(Vector2(30 + n * 53, 744 + sin(n * 2.0) * 20), 27, n * 3.2, Color("92714e"))
	_line([Vector2(650, 706), Vector2(1840, 706)], Color(0.98, 0.76, 0.36, 0.45), 2)
	_label(Vector2(1555, 695), "TARGET SANDSTONE", Color("f2c281"), 16)
	# The drill rig includes a framed derrick, crown block, platform, drawworks,
	# mud pit and a separate return line. Its shaking stops when paused.
	var shake: float = sin(clock * 39) * 1.4 if running else 0.0
	var rig_x: float = 1120 + shake
	for side in [-1, 1]:
		var foot: Vector2 = Vector2(rig_x + side * 103, 331)
		var top: Vector2 = Vector2(rig_x + side * 22, 167)
		draw_line(foot, top, Color("192b3a"), 13, true)
		draw_line(foot + Vector2(2, 0), top + Vector2(2, 0), Color("d1b18a"), 4, true)
	for k in range(5):
		var y1: float = 178 + k * 31
		var y2: float = y1 + 31
		var half1: float = 22 + (y1 - 167) * 0.494
		var half2: float = 22 + (y2 - 167) * 0.494
		_line([Vector2(rig_x - half1, y1), Vector2(rig_x + half2, y2), Vector2(rig_x - half2, y2), Vector2(rig_x + half1, y1)], Color("a18a6b"), 4)
	draw_rect(Rect2(rig_x - 29, 158, 58, 15), Color("e9b55e"))
	draw_rect(Rect2(rig_x - 123, 325, 246, 19), Color("172a37"))
	draw_rect(Rect2(rig_x - 123, 325, 246, 5), GOLD)
	for x in [rig_x - 100, rig_x + 85]:
		draw_rect(Rect2(x, 344, 15, 19), Color("263c47"))
	# Wellbore is wider than the drill string; casing is visible at surface.
	draw_line(Vector2(1120, 352), Vector2(1120, well_end), Color("252834"), 48, true)
	draw_line(Vector2(1120, 352), Vector2(1120, minf(well_end, 470)), Color("818a8d"), 47, true)
	draw_line(Vector2(1120, 352), Vector2(1120, well_end), Color("1b2830"), 30, true)
	if completion < 0.30:
		draw_line(Vector2(1120, 182), Vector2(1120, bit_y - 15), Color("c7c8bb"), 10, true)
		draw_line(Vector2(1118, 182), Vector2(1118, bit_y - 15), Color("f1e0bd"), 3, true)
		for i in range(14):
			var y: float = 365 + i * 28
			if y < bit_y - 8:
				draw_line(Vector2(1114, y), Vector2(1126, y), Color("768b90"), 3, true)
	if not completed and completion < 0.30:
		var spin: float = clock * 18 * speed if running else 0.0
		_poly([Vector2(1102, bit_y - 14), Vector2(1138, bit_y - 14), Vector2(1141, bit_y), Vector2(1130, bit_y + 11), Vector2(1110, bit_y + 11), Vector2(1099, bit_y)], Color("d8b677"))
		for i in range(4):
			var xx: float = 1120 + sin(spin + i * PI / 2) * 15
			draw_line(Vector2(xx, bit_y - 10), Vector2(xx + 5, bit_y + 6), Color("5d6263"), 5, true)
		if running:
			for i in range(18):
				var f: float = fposmod(clock * speed * 1.8 + i * 0.117, 1.0)
				var xx: float = 1120 + sin(i * 2.12) * f * 48
				var yy: float = bit_y + f * 18 - sin(f * PI) * 24
				draw_circle(Vector2(xx, yy), 2 + fposmod(i * 3, 3), Color("ceaa70"))
	# Drilling fluid circulates down the hollow string and back up the annulus.
	if running and not completed:
		for i in range(24):
			var f: float = fposmod(clock * speed * 0.22 + i / 24.0, 1.0)
			var yy: float = lerpf(356, bit_y - 8, f)
			draw_line(Vector2(1120, yy), Vector2(1120, yy + 8), CYAN, 3, true)
			var y_back: float = lerpf(bit_y - 8, 356, f)
			draw_line(Vector2(1104, y_back), Vector2(1104, y_back - 7), Color("73ad9a"), 3, true)
	if completion > 0.30:
		# Drill string has been pulled before casing and then production tubing
		# descend visibly. Production is unavailable until this sequence ends.
		var casing_y: float = lerpf(352.0, 744.0, smoothstep(0.30, 0.69, completion))
		draw_line(Vector2(1120, 352), Vector2(1120, casing_y), Color("b3b3a4"), 46, true)
		draw_line(Vector2(1120, 352), Vector2(1120, casing_y), Color("263c48"), 35, true)
		for k in range(9):
			var yy: float = 355 + k * 44
			if yy < casing_y:
				draw_line(Vector2(1097, yy), Vector2(1104, yy), Color("e5dcc2"), 3, true)
				draw_line(Vector2(1136, yy), Vector2(1143, yy), Color("e5dcc2"), 3, true)
		if completion > 0.65:
			var tubing_y: float = lerpf(352.0, 744.0, smoothstep(0.65, 0.98, completion))
			draw_line(Vector2(1120, 352), Vector2(1120, tubing_y), Color("79b9b4"), 18, true)
			draw_line(Vector2(1120, 352), Vector2(1120, tubing_y), Color("152e38"), 10, true)
			draw_line(Vector2(1116, 352), Vector2(1116, tubing_y), Color("c2e1ce"), 2, true)
		if completion > 0.88:
			for k in range(4):
				var yy: float = 713 + k * 9
				draw_line(Vector2(1090, yy - 4), Vector2(1101, yy), GOLD, 3, true)
				draw_line(Vector2(1139, yy), Vector2(1150, yy - 4), GOLD, 3, true)
		if completion > 0.52:
			_label(Vector2(1230, 490), "CASING", Color("d5d5be"), 16)
			_line([Vector2(1210, 485), Vector2(1170, 485), Vector2(1143, 505)], Color("d5d5be"), 1)
		if completion > 0.84:
			_label(Vector2(1230, 545), "PRODUCTION TUBING", CYAN, 16)
			_line([Vector2(1210, 540), Vector2(1160, 540), Vector2(1128, 560)], CYAN, 1)
	if completion > 0.0 and not completed:
		var caption: String = "REMOVING DRILL STRING" if completion < 0.30 else ("INSTALLING STEEL CASING" if completion < 0.65 else "LOWERING PRODUCTION TUBING")
		_label(Vector2(1230, 431), caption, Color("f2d5a6"), 15)
	# Mud treatment equipment.
	_pipe([Vector2(1103, 363), Vector2(1330, 363), Vector2(1330, 325), Vector2(1480, 325)], Color("79aaa4"), 9)
	draw_rect(Rect2(1420, 288, 220, 55), Color("254553"))
	draw_rect(Rect2(1428, 293, 204, 9), Color("6eaaa6"))
	for i in range(5):
		draw_line(Vector2(1440 + i * 44, 307), Vector2(1440 + i * 44, 338), Color("395d69"), 4)
	_label(Vector2(1450, 278), "MUD CIRCULATION", Color("bcd9d2"), 15)
	draw_rect(Rect2(800, 297, 154, 46), Color("213b4a"))
	draw_rect(Rect2(815, 282, 78, 16), Color("d4a15d"))
	for i in range(7):
		draw_line(Vector2(811 + i * 19, 309), Vector2(811 + i * 19, 329), Color("4f6e78"), 3)
	draw_circle(Vector2(925, 322), 14, Color("122633"))
	draw_arc(Vector2(925, 322), 9, clock * 2 if running else 0.0, (clock * 2 if running else 0.0) + PI * 1.6, 14, GOLD, 3, true)
	# A deliberate depth scale reads like a film annotation, not a dashboard.
	draw_line(Vector2(1780, 376), Vector2(1780, 744), Color(0.95, 0.86, 0.70, 0.40), 2)
	for i in range(5):
		var yy: float = 376 + i * 92
		draw_line(Vector2(1772, yy), Vector2(1790, yy), Color("c6ad8c"), 2)
		_label(Vector2(1800, yy + 5), "%d" % (i * 625), Color("d3c3a9"), 16)
	draw_circle(Vector2(1780, well_end), 7, GOLD)

func _cloud(center: Vector2, size: float) -> void:
	for i in range(6):
		draw_circle(center + Vector2((i - 2.5) * 22 * size, sin(i * 1.5) * 6), (17 + sin(i * 2.0) * 4) * size, Color(0.82, 0.86, 0.79, 0.17))

func _pipe(points: Array, color: Color, width: float = 30) -> void:
	_line(points, Color("0d1d2b"), width + 10)
	_line(points, color.darkened(0.18), width)
	_line(points, color.lightened(0.2), width * 0.55)
	_line(points, color.darkened(0.12), width * 0.25)

func _pressure() -> void:
	var choke: float = float(state.get("choke", 0.0))
	var flow: float = float(state.get("flow_ratio", 0.0))
	_strata(165, 850)
	# A wide reservoir pore connected to a completed well on the right.
	_poly([Vector2(610, 420), Vector2(780, 390), Vector2(1090, 435), Vector2(1380, 410), Vector2(1470, 650), Vector2(1210, 700), Vector2(880, 670), Vector2(610, 725)], Color("302c29"))
	_glow(Vector2(1000, 530), 360, Color(0.98, 0.54, 0.19, 0.12))
	for i in range(7):
		_rock(Vector2(665 + i * 118, 422 + sin(i * 1.9) * 12), 59, i * 2.4, Color("997451"))
		_rock(Vector2(670 + i * 117, 689 + sin(i * 1.4) * 15), 63, i * 1.7, Color("88694e"))
	for i in range(4):
		_rock(Vector2(650, 468 + i * 66), 45, i * 1.7, Color("9c7755"))
	# Steel casing, cement sheath and a narrow separate production string.
	_pipe([Vector2(1320, 745), Vector2(1320, 219), Vector2(1540, 219)], Color("adb0a2"), 80)
	_pipe([Vector2(1320, 735), Vector2(1320, 219), Vector2(1540, 219)], Color("224653"), 57)
	_pipe([Vector2(1320, 730), Vector2(1320, 219), Vector2(1540, 219)], Color("6ebcb6"), 27)
	_line([Vector2(1320, 730), Vector2(1320, 219), Vector2(1540, 219)], Color("182d34"), 16)
	for k in range(5):
		var yy: float = 520 + k * 32
		draw_line(Vector2(1269, yy - 9), Vector2(1290, yy), GOLD, 4, true)
		draw_line(Vector2(1350, yy), Vector2(1371, yy - 9), GOLD, 4, true)
	# Choke body and actuator visibly rotate with the opening.
	draw_circle(Vector2(1320, 300), 49, Color("102331"))
	draw_circle(Vector2(1320, 300), 39, Color("d5aa68"))
	draw_circle(Vector2(1320, 300), 29, Color("55473a"))
	var a: float = -PI * 0.5 + choke * PI * 0.5
	var v: Vector2 = Vector2(cos(a), sin(a)) * 31
	draw_line(Vector2(1320, 300) - v, Vector2(1320, 300) + v, Color("f9d892"), 10, true)
	draw_circle(Vector2(1320, 300), 6, Color("fce9bd"))
	_label(Vector2(1430, 303), "SURFACE CHOKE", Color("f2d5a6"), 18)
	_line([Vector2(1380, 300), Vector2(1414, 300)], Color("bca27c"), 1)
	_label(Vector2(1430, 328), "%.0f%% OPEN" % (choke * 100), CYAN if choke > 0 else Color("d6aa81"), 16)
	# Streamlines originate from the reservoir; reservoir itself remains full.
	for row in range(5):
		var path: Array = []
		for k in range(23):
			var f: float = k / 22.0
			var x: float = lerpf(770, 1320, f)
			var y: float = lerpf(466 + row * 42, 596, f) + sin(f * PI) * 13
			path.append(Vector2(x, y))
		_line(path, Color(0.95, 0.64, 0.27, 0.07 + flow * 0.16), 2)
	if flow > 0.001:
		for i in range(42):
			var f: float = fposmod(flow_clock * 0.18 + i * 0.077, 1.0)
			var row: float = float(i % 5)
			var x: float = lerpf(770, 1320, f)
			var y: float = lerpf(466 + row * 42, 596, f) + sin(f * PI) * 13
			draw_line(Vector2(x - 5, y), Vector2(x + 5 + flow * 9, y), Color(0.99, 0.76, 0.35, 0.55), 3, true)
		for i in range(18):
			var yy: float = 730 - fposmod(flow_clock * 165 + i * 31, 510)
			draw_line(Vector2(1320, yy), Vector2(1320, yy - 12), GOLD, 6, true)
	# Calm, stable formation-pressure contour rings outside the moving phase.
	for i in range(4):
		draw_arc(Vector2(940, 540), 150 + i * 27 + sin(clock * 0.6) * 3, -0.8, 0.8, 30, Color(0.97, 0.71, 0.33, 0.10), 2, true)
	_label(Vector2(1460, 640), "FLOW TO TUBING", Color("b9d4cb"), 16)
	_line([Vector2(1450, 632), Vector2(1400, 632), Vector2(1358, 603)], Color("8ab8ac"), 1)

func _race() -> void:
	var travel: float = clampf(float(state.get("travel", 0.0)), 0.0, 1.0)
	var flow: float = float(state.get("flow_ratio", 0.0))
	var light: Color = Color("31414c").lerp(Color("85c0c0"), smoothstep(0.68, 1.0, travel))
	# Stratigraphic bands slip down behind the tracking camera.
	for k in range(10):
		var yy: float = 140 + fposmod(k * 100 + travel * 920, 900)
		var c: Color = Color("715449") if k % 2 == 0 else Color("4c4445")
		draw_rect(Rect2(0, yy, 1920, 95), c.lerp(light, travel * 0.30))
		_line([Vector2(0, yy + 8), Vector2(500, yy + 13), Vector2(830, yy + 3)], Color(0.93, 0.73, 0.53, 0.13), 3)
		_line([Vector2(1290, yy + 3), Vector2(1600, yy + 15), Vector2(1920, yy + 5)], Color(0.93, 0.73, 0.53, 0.13), 3)
		for j in range(9):
			var xx: float = 80 + j * 214
			draw_line(Vector2(xx, yy + 47), Vector2(xx + 17, yy + 43), Color(0.05, 0.09, 0.11, 0.25), 3, true)
	# Cement sheath, steel casing, annulus, and inner tubing remain distinct.
	draw_rect(Rect2(750, 145, 580, 750), Color("30434c"))
	for side in [-1, 1]:
		var xx: float = 1040 + side * 266
		draw_rect(Rect2(xx - 21, 145, 42, 750), Color("7a8684"))
		draw_rect(Rect2(xx - 9, 145, 12, 750), Color("a8b3ac"))
		for n in range(12):
			var yy: float = 140 + fposmod(n * 79 + travel * 920, 800)
			draw_line(Vector2(xx - 12, yy), Vector2(xx + 12, yy + 13), Color("536b72"), 3, true)
		draw_rect(Rect2(1040 + side * 221 - 12, 145, 24, 750), Color("759c9e"))
		draw_rect(Rect2(1040 + side * 210 - 4, 145, 8, 750), Color("b7d7cc"))
	draw_rect(Rect2(838, 145, 404, 750), Color("252b2d").lerp(Color("454c42"), travel * 0.5))
	_glow(Vector2(1040, 400), 390, Color(0.98, 0.65, 0.29, 0.13))
	# Layered streamlines provide a liquid sense of motion at any flow rate.
	for i in range(17):
		var path: Array = []
		for j in range(35):
			var yy: float = 140 + j * 22
			var xx: float = 850 + i * 23 + sin(yy * 0.018 + clock * flow * 3 + i * 1.2) * 4
			path.append(Vector2(xx, yy))
		_line(path, Color(0.84, 0.56, 0.23, 0.07 + sin(i) * 0.025), 3)
	if flow > 0.001:
		for i in range(44):
			var xx: float = 853 + fposmod(i * 67.4, 371)
			var yy: float = 140 + fposmod(i * 51.3 + flow_clock * 360, 660)
			var trail: float = 13 + flow * 32 + sin(i) * 6
			draw_line(Vector2(xx, yy), Vector2(xx, yy + trail), Color(0.98, 0.77, 0.40, 0.10 + fposmod(i * 0.17, 0.25)), 2, true)
			if i % 4 == 0:
				draw_circle(Vector2(xx, yy), 2.6, Color(1.0, 0.82, 0.43, 0.6))
	if bool(state.get("gas_visible", false)):
		for i in range(10):
			var xx: float = 880 + fposmod(i * 77.3, 310)
			var yy: float = 150 + fposmod(i * 123.7 + flow_clock * 175, 650)
			draw_circle(Vector2(xx, yy), 8 + i % 4, Color(0.46, 0.90, 0.92, 0.06))
			draw_arc(Vector2(xx, yy), 8 + i % 4, PI * 0.9, PI * 1.8, 14, Color(0.60, 0.94, 0.92, 0.38), 1.5, true)
	# Passing collar joints sell upward camera tracking.
	for i in range(5):
		var yy: float = 130 + fposmod(i * 200 + travel * 920, 820)
		for side in [-1, 1]:
			var xx: float = 1040 + side * 221
			draw_rect(Rect2(xx - 20, yy, 40, 16), Color("b2bbb0"))
			draw_rect(Rect2(xx - 20, yy + 12, 40, 5), Color("4d747c"))
	# Documentary depth annotations on rock, safely away from character faces.
	var depth: float = maxf(0.0, 2500 * (1.0 - travel))
	draw_line(Vector2(1540, 265), Vector2(1540, 700), Color(0.86, 0.87, 0.76, 0.4), 2)
	for i in range(6):
		var yy: float = 280 + i * 77
		draw_line(Vector2(1530, yy), Vector2(1551, yy), Color("c1c4ad"), 2)
	_label(Vector2(1580, 447), "TO THE SURFACE", Color("d7dec7"), 16)
	_label(Vector2(1580, 488), "%04d m" % int(depth), Color("f3cf8b"), 33)
	_label(Vector2(1580, 518), "ILLUSTRATIVE DEPTH", Color("aebfb3"), 13)
	if travel > 0.78:
		var reveal: float = (travel - 0.78) / 0.22
		var surface_y: float = lerpf(-200, 215, reveal)
		draw_rect(Rect2(0, 0, 1920, maxf(surface_y, 0.0)), Color("77aaad"))
		_glow(Vector2(1080, surface_y), 350, Color(0.98, 0.86, 0.62, reveal * 0.15))
		_line([Vector2(0, surface_y), Vector2(760, surface_y)], Color("d4b181"), 20)
		_line([Vector2(1320, surface_y), Vector2(1920, surface_y)], Color("d4b181"), 20)

func _dust() -> void:
	for i in range(32):
		var xx: float = fposmod(i * 173.61 + sin(clock * 0.08 + i) * 17, 1920.0)
		var yy: float = 177 + fposmod(i * 83.41 - clock * (2 + i % 3), 600.0)
		draw_circle(Vector2(xx, yy), 1.0 + i % 2, Color(0.95, 0.85, 0.66, 0.07 + sin(clock + i) * 0.025))
	# Gentle vignette keeps the viewer's eye on the illustrated scene.
	for i in range(8):
		var alpha: float = (8 - i) * 0.008
		draw_rect(Rect2(0, 145, 14, 665), Color(0.03, 0.07, 0.12, alpha))
