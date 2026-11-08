extends Node2D
## Original, layered vector illustration for the surface chapters.
## The story supplies state; this canvas adds only non-blocking visual motion.
@export_enum("separator", "refinery", "finale", "quiz") var stage: String = "separator"
var state: Dictionary = {}
var clock: float = 0.0
var font: Font

const INK := Color("101e31")
const NAVY := Color("13263b")
const BLUE := Color("213f56")
const CYAN := Color("70dce0")
const GOLD := Color("f6c778")
const ORANGE := Color("ed9160")
const WHITE := Color("e7eee9")

func _ready() -> void:
	font = ThemeDB.fallback_font

func _process(delta: float) -> void:
	clock += delta
	queue_redraw()

func _draw() -> void:
	_background()
	match stage:
		"separator": _separator()
		"refinery": _refinery()
		"finale": _finale()
		"quiz": _quiz()

func _background() -> void:
	# Soft sky gradient is kept intentionally restrained behind the exhibits.
	for band in range(36):
		var blend: float = float(band) / 35.0
		draw_rect(Rect2(0, band * 30, 1920, 31), Color("101e31").lerp(Color("244755"), blend))
	_ellipse(Vector2(1550, 330), Vector2(300, 230), Color(0.28, 0.47, 0.48, 0.055))
	_ellipse(Vector2(1540, 320), Vector2(210, 170), Color(0.5, 0.68, 0.58, 0.035))
	for i in range(24):
		var x: float = 590.0 + fmod(float(i) * 137.3 + clock * (2.0 + i % 3), 1280.0)
		var y: float = 180.0 + fmod(float(i * 71), 550.0)
		draw_circle(Vector2(x, y), 1.2 + float(i % 2), Color(0.8, 0.88, 0.81, 0.12 + sin(clock + i) * 0.05))
	# Distant coastal hills, a warm horizon, and a working yard.
	_poly([Vector2(0, 670), Vector2(110, 628), Vector2(300, 642), Vector2(450, 585), Vector2(610, 660), Vector2(810, 608), Vector2(1050, 655), Vector2(1250, 610), Vector2(1510, 649), Vector2(1700, 584), Vector2(1920, 640), Vector2(1920, 850), Vector2(0, 850)], Color("294350"))
	_poly([Vector2(0, 735), Vector2(230, 680), Vector2(420, 730), Vector2(720, 683), Vector2(1010, 735), Vector2(1240, 695), Vector2(1520, 722), Vector2(1800, 680), Vector2(1920, 716), Vector2(1920, 850), Vector2(0, 850)], Color("263a43"))
	draw_rect(Rect2(0, 758, 1920, 322), Color("1a2c38"))
	draw_line(Vector2(570, 759), Vector2(1850, 759), Color("51625d"), 2, true)
	for i in range(21):
		var x: float = 580.0 + float(i) * 62.0
		draw_line(Vector2(x, 777), Vector2(x + 30, 777), Color(0.7, 0.72, 0.57, 0.08), 2, true)
	# Slow atmospheric cloud ribbons.
	for i in range(3):
		var cx: float = 800.0 + fmod(i * 430.0 + clock * 5.0, 1000.0)
		_cloud(Vector2(cx, 218 + i * 34), 0.6, Color(0.7, 0.85, 0.82, 0.045))

func _separator() -> void:
	var sorted: Array = state.get("sorted", [])
	var selected: String = str(state.get("selected_outlet", ""))
	var feedback: float = float(state.get("feedback", 0.0))
	# Concrete pad, skids, instrumentation, inlet and maintenance rails.
	_ellipse(Vector2(1210, 742), Vector2(570, 20), Color(0.0, 0.0, 0.0, 0.23))
	_round(Rect2(690, 718, 1050, 23), Color("4a5d62"), 8)
	for x in [865.0, 1345.0]:
		_poly([Vector2(x - 50, 695), Vector2(x - 30, 595), Vector2(x + 30, 595), Vector2(x + 50, 695)], Color("547078"))
		draw_rect(Rect2(x - 35, 618, 70, 77), Color("344c5a"))
		_round(Rect2(x - 66, 695, 132, 17), Color("718384"), 4)
		for bolt in [-43.0, 43.0]:
			draw_circle(Vector2(x + bolt, 705), 4, GOLD)
	_pipe([Vector2(630, 570), Vector2(730, 570), Vector2(730, 480), Vector2(820, 480)], Color("e09d65"), 25)
	_draw_flow([Vector2(630, 570), Vector2(730, 570), Vector2(730, 480), Vector2(820, 480)], ORANGE, 0.65)
	_label("WELLSTREAM", Vector2(650, 620), 17, Color("c9a989"))
	# Vessel outer shell, translucent liquid levels, rounded end heads.
	_round(Rect2(792, 318, 700, 306), Color("64818a"), 114)
	_round(Rect2(800, 326, 684, 290), Color("263e50"), 108)
	_round(Rect2(817, 345, 650, 252), Color("3d5b62"), 92)
	# Inset tank volume is flat in the middle, elliptical at the rounded heads.
	_round(Rect2(830, 357, 624, 228), Color("42666e"), 84)
	_poly(_fluid_polygon(844, 1438, 435, 580, 6.0, 1.4), Color("a98550"))
	_poly(_fluid_polygon(844, 1438, 525, 580, 4.0, 1.8), Color("417d94"))
	# Masks restore the rounded heads to keep the cutaway readable.
	_ellipse(Vector2(849, 470), Vector2(49, 123), Color("46636b"))
	_ellipse(Vector2(849, 470), Vector2(35, 108), Color("71828a"))
	_ellipse(Vector2(849, 470), Vector2(25, 96), Color("3f6570"))
	_ellipse(Vector2(1441, 470), Vector2(36, 123), Color("506f76"))
	_ellipse(Vector2(1441, 470), Vector2(22, 108), Color("3c5a63"))
	# Internals: inlet diverter, perforated baffle, oil weir and mist extractor.
	draw_line(Vector2(909, 370), Vector2(909, 527), Color("9da79a"), 8, true)
	draw_line(Vector2(909, 390), Vector2(938, 416), Color("9da79a"), 7, true)
	draw_line(Vector2(1317, 470), Vector2(1317, 580), Color("c3aa7a"), 7, true)
	for i in range(7):
		draw_line(Vector2(1230 + i * 9, 366), Vector2(1220 + i * 9, 412), Color(0.67, 0.79, 0.75, 0.45), 2, true)
	for i in range(8):
		var bx: float = 955.0 + i * 56.0
		var by: float = 517.0 - fmod(clock * (19.0 + i % 3 * 4) + i * 33.0, 130.0)
		draw_circle(Vector2(bx + sin(clock + i) * 4.0, by), 3.0 + float(i % 3), Color(0.7, 0.9, 0.86, 0.23))
	for i in range(12):
		draw_circle(Vector2(950 + i * 36, 550 + sin(i * 1.7 + clock) * 6), 2.0, Color(0.65, 0.86, 0.91, 0.22))
	# Vessel seam, rivets, reflected light, outer hoops.
	for x in [961.0, 1370.0]:
		draw_line(Vector2(x, 337), Vector2(x, 607), Color(0.70, 0.80, 0.77, 0.28), 5, true)
		for y in [352.0, 588.0]:
			draw_circle(Vector2(x, y), 5, Color("afc1b6"))
	draw_line(Vector2(955, 343), Vector2(1320, 343), Color(0.84, 0.95, 0.87, 0.4), 5, true)
	# Outlets are arranged by phase height, each route illuminates after sorting.
	var oil_color: Color = GOLD if sorted.has("oil") or selected == "oil" else Color("727b64")
	var gas_color: Color = CYAN if sorted.has("gas") or selected == "gas" else Color("496e78")
	var water_color: Color = Color("73b8ed") if sorted.has("water") or selected == "water" else Color("4b6d84")
	_pipe([Vector2(1213, 329), Vector2(1213, 280), Vector2(1590, 280)], gas_color, 20)
	_pipe([Vector2(1460, 480), Vector2(1640, 480)], oil_color, 25)
	_pipe([Vector2(1167, 603), Vector2(1167, 670), Vector2(1640, 670)], water_color, 23)
	if sorted.has("gas"): _draw_flow([Vector2(1213, 329), Vector2(1213, 280), Vector2(1590, 280)], CYAN, 0.8)
	if sorted.has("oil"): _draw_flow([Vector2(1460, 480), Vector2(1640, 480)], GOLD, 0.7)
	if sorted.has("water"): _draw_flow([Vector2(1167, 603), Vector2(1167, 670), Vector2(1640, 670)], Color("73b8ed"), 0.75)
	_valve(Vector2(1430, 280), gas_color, sorted.has("gas"))
	_valve(Vector2(1560, 480), oil_color, sorted.has("oil"))
	_valve(Vector2(1440, 670), water_color, sorted.has("water"))
	_outlet_tag(Vector2(1624, 280), "GAS", gas_color, sorted.has("gas"))
	_outlet_tag(Vector2(1672, 480), "OIL", oil_color, sorted.has("oil"))
	_outlet_tag(Vector2(1672, 670), "WATER", water_color, sorted.has("water"))
	# Pressure gauge and tiny instrument tube.
	_pipe([Vector2(1095, 322), Vector2(1095, 298)], Color("9ab2ac"), 7)
	draw_circle(Vector2(1095, 280), 26, Color("789397"))
	draw_circle(Vector2(1095, 280), 20, Color("e1e7d6"))
	draw_arc(Vector2(1095, 280), 14, PI, TAU, 20, Color("708580"), 2, true)
	draw_line(Vector2(1095, 280), Vector2(1103, 267), Color("3c5e68"), 3, true)
	_label("THREE-PHASE SEPARATOR", Vector2(870, 702), 18, Color("b1c9bf"))
	if feedback < 0.0:
		var alpha: float = clampf(absf(feedback), 0.0, 1.0)
		draw_arc(Vector2(1120, 470), 175 + sin(clock * 20) * 5, 0, TAU, 70, Color(0.96, 0.57, 0.38, alpha * 0.45), 4, true)

func _refinery() -> void:
	# Flare, stacks and storage occupy the horizon; the foreground carries product stories.
	_ellipse(Vector2(1260, 750), Vector2(590, 24), Color(0, 0, 0, 0.22))
	for i in range(3):
		_storage_tank(Vector2(1510 + i * 124, 650 - i * 20), 88 - i * 8, 93 + i * 11)
	_tower(Vector2(905, 672), 105, 367, 8, ORANGE)
	_tower(Vector2(1110, 671), 91, 463, 10, GOLD)
	_tower(Vector2(1312, 672), 72, 285, 6, Color("8cbcb7"))
	# Stairs, platforms, interconnects and safe-working railings.
	for y in [421.0, 520.0, 620.0]:
		draw_line(Vector2(976, y), Vector2(1050, y), Color("7d9799"), 10, true)
		draw_line(Vector2(978, y - 22), Vector2(1048, y - 22), GOLD, 2, true)
		for x in [980.0, 1016.0, 1046.0]: draw_line(Vector2(x, y - 22), Vector2(x, y), GOLD, 2, true)
	_pipe([Vector2(900, 677), Vector2(900, 704), Vector2(1330, 704), Vector2(1330, 628)], Color("b7b791"), 14)
	_pipe([Vector2(1150, 383), Vector2(1217, 383), Vector2(1217, 640), Vector2(1447, 640)], Color("83aeb2"), 11)
	_draw_flow([Vector2(900, 677), Vector2(900, 704), Vector2(1330, 704), Vector2(1330, 628)], GOLD, 0.9)
	for i in range(4):
		var sy: float = 315.0 - fmod(clock * 23 + i * 24.0, 110.0)
		_cloud(Vector2(912 + sin(clock + i) * 16, sy), 0.3 + (315.0 - sy) / 220.0, Color(0.81, 0.87, 0.79, 0.12 * (sy - 205.0) / 110.0))
	# Flare tower, animated pilot flame.
	for dx in [-14.0, 14.0]: draw_line(Vector2(1765 + dx, 695), Vector2(1765 + dx * 0.3, 342), Color("607e84"), 5, true)
	for y in range(360, 680, 42):
		draw_line(Vector2(1751, y + 42), Vector2(1779, y), Color("66868a"), 3, true)
	_poly([Vector2(1756, 345), Vector2(1749, 322), Vector2(1760, 306), Vector2(1767 + sin(clock * 7) * 4, 282), Vector2(1779, 316), Vector2(1773, 344)], Color("ef9d62"))
	_poly([Vector2(1760, 343), Vector2(1758, 327), Vector2(1766, 315), Vector2(1770, 342)], GOLD)
	_label("REFINING + PROCESSING", Vector2(891, 744), 18, Color("b9cbc0"))
	var product: String = str(state.get("product", ""))
	var progress: float = clampf(float(state.get("product_progress", 0.0)), 0.0, 1.0)
	if not product.is_empty():
		# The foreground vignette intentionally covers the lower plant during a story.
		_round(Rect2(738, 482, 1058, 256), Color(0.055, 0.12, 0.18, 0.96), 28)
		_round(Rect2(753, 497, 1028, 226), Color("203847"), 21)
		match product:
			"car": _car_story(progress)
			"aviation": _aviation_story(progress)
			"marine": _marine_story(progress)
			"plastic": _plastic_story(progress)
			"asphalt": _asphalt_story(progress)

func _car_story(p: float) -> void:
	_label("REFINE  →  DISTRIBUTE  →  DRIVE", Vector2(792, 536), 18, GOLD)
	draw_rect(Rect2(787, 674, 952, 21), Color("40545a"))
	for i in range(14): draw_line(Vector2(790 + i * 70, 685), Vector2(825 + i * 70, 685), Color("c3c6ac"), 3, true)
	# Pump and delivery hose, then a clear departure.
	_round(Rect2(931, 568, 56, 103), ORANGE, 9)
	_round(Rect2(940, 579, 38, 31), INK, 4)
	_label("FUEL", Vector2(943, 599), 12, GOLD)
	_round(Rect2(945, 622, 29, 28), Color("b76f4d"), 3)
	var distance: float = pow(clampf((p - 0.5) / 0.5, 0.0, 1.0), 1.5) * 560.0
	if p < 0.55:
		_polyline([Vector2(987, 592), Vector2(1008, 595), Vector2(1012, 630), Vector2(1085, 630)], Color("0f2534"), 8)
		if p > 0.12: _draw_flow([Vector2(987, 592), Vector2(1008, 595), Vector2(1012, 630), Vector2(1085, 630)], GOLD, 1.0)
	_car(Vector2(1170 + distance, 645), 1.0, CYAN)
	if p < 0.5:
		_round(Rect2(1100, 555, 122, 12), Color("122a38"), 6)
		_round(Rect2(1100, 555, maxf(8.0, clampf(p / 0.5, 0, 1) * 122), 12), GOLD, 6)
	else:
		for i in range(4): draw_line(Vector2(1080 + distance - i * 24, 630 + i * 8), Vector2(1025 + distance - i * 24, 630 + i * 8), Color(0.57, 0.84, 0.81, 0.2), 3, true)

func _aviation_story(p: float) -> void:
	_label("JET FUEL  →  AIRPORT  →  TAKE-OFF", Vector2(792, 536), 18, GOLD)
	for i in range(3): _cloud(Vector2(1000 + i * 270 - p * 200, 565 + (i % 2) * 30), 0.6, Color(0.76, 0.87, 0.86, 0.12))
	draw_rect(Rect2(787, 674, 952, 21), Color("40545a"))
	for i in range(12): draw_line(Vector2(800 + i * 85, 685), Vector2(845 + i * 85, 685), Color("c3c6ac"), 3, true)
	var departure: float = clampf((p - 0.36) / 0.64, 0, 1)
	var plane_position := Vector2(1100 + departure * 580, 633 - departure * departure * 148)
	_plane(plane_position, 1.0, -departure * 0.18)
	if p < 0.37:
		_round(Rect2(820, 615, 134, 42), Color("bf8e60"), 12)
		_label("JET", Vector2(862, 642), 18, INK)
		for wx in [846.0, 929.0]:
			draw_circle(Vector2(wx, 665), 12, INK)
			draw_circle(Vector2(wx, 665), 6, Color("80928d"))
		_polyline([Vector2(952, 626), Vector2(990, 626), Vector2(1000, 647), Vector2(1075, 647)], GOLD, 5)
		_draw_flow([Vector2(952, 626), Vector2(990, 626), Vector2(1000, 647), Vector2(1075, 647)], CYAN, 1.0)

func _plastic_story(p: float) -> void:
	_label("FEEDSTOCK  →  POLYMER  →  MOULDING", Vector2(792, 536), 18, GOLD)
	# An actual intermediate processing chain, never a direct crude-to-bottle morph.
	_round(Rect2(824, 587, 100, 82), Color("ac8455"), 25)
	_label("FEED", Vector2(850, 632), 15, WHITE)
	_pipe([Vector2(925, 627), Vector2(1025, 627)], Color("b3baa2"), 13)
	_round(Rect2(1026, 569, 150, 100), Color("4d7379"), 20)
	_label("REACTOR", Vector2(1051, 626), 15, WHITE)
	for i in range(3):
		var x: float = 1055.0 + i * 34.0
		draw_circle(Vector2(x, 588 + sin(clock * 4 + i) * 4), 7, GOLD)
	_pipe([Vector2(1177, 627), Vector2(1278, 627)], Color("b3baa2"), 13)
	_round(Rect2(1278, 577, 168, 92), Color("8f7770"), 12)
	_label("MOULD", Vector2(1330, 635), 15, WHITE)
	for i in range(8):
		var px: float = 1185 + fmod(clock * 70 + i * 13, 90)
		draw_circle(Vector2(px, 622 + sin(i) * 3), 3, GOLD)
	if p > 0.1: _draw_flow([Vector2(925, 627), Vector2(1025, 627)], GOLD, 0.8)
	var reveal: float = smoothstep(0.35, 0.78, p)
	var bottle_position := Vector2(1580, 668 - reveal * 6)
	_bottle(bottle_position, 0.65 + reveal * 0.35, reveal)
	if reveal > 0.8:
		for i in range(7):
			var angle: float = float(i) / 7.0 * TAU + clock * 0.4
			var star_pos: Vector2 = bottle_position + Vector2(cos(angle) * 91, -70 + sin(angle) * 69)
			_star(star_pos, 5, Color(GOLD, 0.8))

func _asphalt_story(p: float) -> void:
	_label("BITUMEN + AGGREGATE  →  ROAD", Vector2(792, 536), 18, GOLD)
	draw_rect(Rect2(789, 671, 950, 29), Color("776b53"))
	for i in range(50):
		var x: float = 795 + fmod(i * 37.0, 930)
		draw_circle(Vector2(x, 677 + i % 5 * 3), 2, Color("b4a381"))
	var paved: float = clampf(p / 0.72, 0, 1)
	draw_rect(Rect2(790, 668, maxf(1, paved * 920), 30), Color("142633"))
	for i in range(14):
		if float(i) / 14.0 < paved: draw_line(Vector2(805 + i * 65, 683), Vector2(837 + i * 65, 683), GOLD, 3, true)
	var px: float = 900 + paved * 790
	# Paver hopper, screed and big roller wheels.
	_round(Rect2(px - 95, 603, 155, 55), ORANGE, 8)
	_poly([Vector2(px + 53, 609), Vector2(px + 91, 589), Vector2(px + 79, 650), Vector2(px + 53, 650)], Color("a86e4c"))
	_round(Rect2(px - 48, 563, 54, 47), Color("6399a2"), 5)
	draw_line(Vector2(px - 63, 559), Vector2(px + 14, 559), GOLD, 6, true)
	for wx in [-58.0, 33.0]:
		draw_circle(Vector2(px + wx, 655), 22, INK)
		draw_circle(Vector2(px + wx, 655), 12, Color("a99c7c"))
	_polyline([Vector2(px - 95, 647), Vector2(px - 119, 667), Vector2(px - 150, 667)], Color("a6a183"), 8)
	if p > 0.73: _car(Vector2(850 + (p - 0.73) / 0.27 * 700, 644), 0.75, CYAN)

func _finale() -> void:
	# A halo behind the protagonist, with six little illustrated memories.
	for i in range(10):
		var radius: float = 122.0 + i * 18.0
		draw_arc(Vector2(1060, 465), radius, 0, TAU, 80, Color(0.93, 0.72, 0.40, 0.024 * (10.0 - i) / 10.0), 15, true)
	var centers: Array[Vector2] = [Vector2(786, 310), Vector2(1070, 234), Vector2(1360, 310), Vector2(1471, 568), Vector2(1130, 690), Vector2(790, 610)]
	for i in range(6):
		var pos: Vector2 = centers[i] + Vector2(0, sin(clock * 0.8 + i * 0.8) * 7.0)
		draw_line(Vector2(1060, 470), pos, Color(0.66, 0.75, 0.65, 0.12), 2, true)
		_memory(pos, i)
	for i in range(52):
		var x: float = 620.0 + fmod(i * 113.0 + sin(clock * 0.7 + i) * 40, 1140)
		var y: float = 173.0 + fmod(i * 59.0 + clock * (27 + i % 5 * 6), 605)
		var col: Color = [GOLD, CYAN, ORANGE][i % 3]
		col.a = 0.35 + float(i % 4) * 0.12
		if i % 3 == 0: _star(Vector2(x, y), 4 + i % 3, col)
		else: draw_line(Vector2(x, y), Vector2(x + sin(clock + i) * 7, y + 7), col, 3, true)

func _quiz() -> void:
	# Knowledge is framed as another part of the exhibition, with no charts.
	_round(Rect2(725, 225, 1000, 484), Color("193746"), 40)
	_round(Rect2(741, 241, 968, 452), Color("214652"), 31)
	for i in range(4):
		var pos := Vector2(855 + i * 240, 619)
		draw_circle(pos, 46, Color("2a5360"))
		draw_arc(pos, 35, -PI * 0.5, PI * 1.5, 40, Color(0.55, 0.85, 0.79, 0.22), 3, true)
		_star(pos, 12, Color(GOLD, 0.8))
	# Pressure arrows, fluid tiers, and a pipeline become decorative learning cues.
	for i in range(6):
		var x: float = 850 + i * 130
		var y: float = 310 + sin(clock + i * 0.8) * 8
		_poly([Vector2(x, y), Vector2(x + 14, y + 11), Vector2(x, y + 22), Vector2(x + 7, y + 11)], Color(0.57, 0.83, 0.79, 0.25))
	label_center("EXPLORE · DISCOVER · REMEMBER", Vector2(1220, 384), 23, Color("b8d3c3"))
	_pipe([Vector2(830, 479), Vector2(950, 479), Vector2(950, 444), Vector2(1100, 444), Vector2(1100, 494), Vector2(1600, 494)], Color("668d87"), 16)
	_draw_flow([Vector2(830, 479), Vector2(950, 479), Vector2(950, 444), Vector2(1100, 444), Vector2(1100, 494), Vector2(1600, 494)], GOLD, 0.6)

func _memory(pos: Vector2, index: int) -> void:
	var radius: float = 67.0
	draw_circle(pos + Vector2(0, 6), radius + 5, Color(0, 0, 0, 0.15))
	draw_circle(pos, radius, Color("4a6262"))
	draw_circle(pos, radius - 3, Color("193544"))
	var text: String = ["RESERVOIR", "DRILLING", "PRODUCTION", "SEPARATION", "REFINING", "EVERYDAY LIFE"][index]
	match index:
		0:
			for i in range(4):
				_round(Rect2(pos.x - 45 + (i % 2) * 10, pos.y - 34 + i * 18, 82, 14), Color("8f7554").lightened(i * 0.05), 6)
			for i in range(5): draw_circle(pos + Vector2(-27 + i * 14, 1 + sin(i * 1.3) * 16), 6, GOLD)
		1:
			_polyline([pos + Vector2(-30, 37), pos + Vector2(-7, -44), pos + Vector2(7, -44), pos + Vector2(30, 37)], ORANGE, 5)
			for i in range(4): draw_line(pos + Vector2(-24 + i * 4, 29 - i * 18), pos + Vector2(24 - i * 4, 29 - i * 18), GOLD, 3, true)
			draw_line(pos + Vector2(0, -43), pos + Vector2(0, 43), CYAN, 3, true)
		2:
			_pipe([pos + Vector2(-30, 37), pos + Vector2(0, 37), pos + Vector2(0, -32), pos + Vector2(29, -32)], Color("82b6ae"), 11)
			_valve(pos + Vector2(0, -3), GOLD, true, 0.6)
		3:
			_round(Rect2(pos.x - 47, pos.y - 27, 94, 56), Color("66858b"), 23)
			_round(Rect2(pos.x - 38, pos.y - 18, 76, 38), Color("b18a58"), 16)
			draw_rect(Rect2(pos.x - 27, pos.y + 6, 54, 12), Color("528da4"))
			for i in range(3): draw_circle(pos + Vector2(-18 + i * 18, -10), 3, CYAN)
		4:
			for i in range(3):
				var h: float = 56 + (i % 2) * 24
				_round(Rect2(pos.x - 41 + i * 29, pos.y + 34 - h, 23, h), [ORANGE, GOLD, CYAN][i], 10)
				for j in range(3): draw_line(pos + Vector2(-41 + i * 29, 16 - j * 13), pos + Vector2(-18 + i * 29, 16 - j * 13), Color("284b58"), 2, true)
		5: _car(pos + Vector2(0, 10), 0.48, CYAN)
	label_center(text, pos + Vector2(0, radius + 25), 15, Color("b7c8b8"))

func _tower(base: Vector2, width: float, height: float, trays: int, tint: Color) -> void:
	var rect := Rect2(base.x - width / 2, base.y - height, width, height)
	_round(rect, tint.darkened(0.18), int(width / 2))
	draw_rect(Rect2(rect.position.x + width * 0.18, rect.position.y + 36, width * 0.26, height - 41), Color(tint.lightened(0.12), 0.55))
	draw_rect(Rect2(rect.end.x - width * 0.22, rect.position.y + 32, width * 0.15, height - 43), Color(tint.darkened(0.36), 0.55))
	for i in range(1, trays + 1):
		var y: float = rect.position.y + 40 + i * (height - 61) / trays
		_ellipse(Vector2(base.x, y), Vector2(width * 0.49, 8), tint.darkened(0.3))
		draw_line(Vector2(base.x - width * 0.43, y - 2), Vector2(base.x + width * 0.43, y - 2), tint.lightened(0.25), 2, true)
	# Access ladder and safety cage details.
	var ladder_x: float = base.x + width * 0.64
	for dx in [-7.0, 7.0]: draw_line(Vector2(ladder_x + dx, rect.position.y + 27), Vector2(ladder_x + dx, base.y), Color("94a99f"), 2, true)
	for i in range(int(height / 14)):
		draw_line(Vector2(ladder_x - 7, base.y - i * 14), Vector2(ladder_x + 7, base.y - i * 14), Color("94a99f"), 2, true)
	_round(Rect2(base.x - width * 0.7, base.y - 6, width * 1.4, 13), Color("557274"), 4)
	draw_circle(Vector2(base.x, rect.position.y + 28), 8, tint.lightened(0.3))

func _storage_tank(base: Vector2, width: float, height: float) -> void:
	_ellipse(base + Vector2(0, -1), Vector2(width * 0.5, 10), Color("243d49"))
	draw_rect(Rect2(base.x - width * 0.5, base.y - height, width, height), Color("688388"))
	draw_rect(Rect2(base.x - width * 0.30, base.y - height, width * 0.21, height), Color("809994"))
	_ellipse(base + Vector2(0, -height), Vector2(width * 0.5, 17), Color("91a59d"))
	_ellipse(base + Vector2(0, -height + 3), Vector2(width * 0.43, 10), Color("7b9690"))
	for y in [base.y - height * 0.28, base.y - height * 0.65]: draw_line(Vector2(base.x - width * 0.49, y), Vector2(base.x + width * 0.49, y), Color("4c6a71"), 3, true)

func _car(pos: Vector2, size: float, tint: Color) -> void:
	var points: Array[Vector2] = [Vector2(-106, 9), Vector2(-101, -20), Vector2(-66, -31), Vector2(-35, -64), Vector2(30, -64), Vector2(65, -27), Vector2(102, -18), Vector2(109, 13)]
	var scaled: Array[Vector2] = []
	for point in points: scaled.append(pos + point * size)
	_poly(scaled, tint)
	_poly([pos + Vector2(-49, -30) * size, pos + Vector2(-28, -55) * size, pos + Vector2(-4, -55) * size, pos + Vector2(-4, -30) * size], Color("224555"))
	_poly([pos + Vector2(6, -55) * size, pos + Vector2(26, -55) * size, pos + Vector2(48, -30) * size, pos + Vector2(6, -30) * size], Color("224555"))
	draw_line(pos + Vector2(-90, -18) * size, pos + Vector2(87, -18) * size, tint.lightened(0.3), 3 * size, true)
	for x in [-65.0, 65.0]:
		draw_circle(pos + Vector2(x, 13) * size, 23 * size, INK)
		draw_circle(pos + Vector2(x, 13) * size, 13 * size, Color("819d9d"))
		draw_arc(pos + Vector2(x, 13) * size, 8 * size, clock * 4, clock * 4 + PI * 1.4, 12, Color("bdd0bc"), 2 * size, true)
	_round(Rect2(pos + Vector2(91, -15) * size, Vector2(13, 11) * size), GOLD, 3)
	_round(Rect2(pos + Vector2(-102, -14) * size, Vector2(10, 11) * size), ORANGE, 3)

func _plane(pos: Vector2, size: float, angle: float) -> void:
	var points: Array[Vector2] = [Vector2(-142, 3), Vector2(-112, -5), Vector2(-127, -49), Vector2(-106, -49), Vector2(-70, -9), Vector2(17, -12), Vector2(95, -67), Vector2(114, -63), Vector2(68, -10), Vector2(130, -5), Vector2(152, 5), Vector2(136, 15), Vector2(50, 20), Vector2(101, 56), Vector2(78, 59), Vector2(7, 21), Vector2(-96, 18)]
	var result: Array[Vector2] = []
	for point in points: result.append(pos + point.rotated(angle) * size)
	_poly(result, Color("d8e4d9"))
	for i in range(8): draw_circle(pos + Vector2(-63 + i * 19, 2).rotated(angle) * size, 3 * size, BLUE)
	draw_line(pos + Vector2(-94, 15).rotated(angle) * size, pos + Vector2(111, 11).rotated(angle) * size, CYAN, 4 * size, true)

func _bottle(pos: Vector2, size: float, alpha: float) -> void:
	var points: Array[Vector2] = [Vector2(-20, -127), Vector2(20, -127), Vector2(20, -100), Vector2(35, -84), Vector2(40, -64), Vector2(40, -7), Vector2(29, 0), Vector2(-29, 0), Vector2(-40, -7), Vector2(-40, -64), Vector2(-35, -84), Vector2(-20, -100)]
	var result: Array[Vector2] = []
	for point in points: result.append(pos + point * size)
	_poly(result, Color(CYAN, alpha * 0.8))
	_round(Rect2(pos + Vector2(-23, -140) * size, Vector2(46, 18) * size), Color(GOLD, alpha), 4)
	_round(Rect2(pos + Vector2(-39, -70) * size, Vector2(78, 37) * size), Color(WHITE, alpha * 0.9), 3)
	draw_line(pos + Vector2(-24, -92) * size, pos + Vector2(-24, -13) * size, Color(WHITE, alpha * 0.6), 4 * size, true)

func _outlet_tag(pos: Vector2, text: String, tint: Color, done: bool) -> void:
	_round(Rect2(pos.x - 4, pos.y - 24, 140, 48), tint.darkened(0.65), 14)
	_label(("✓  " if done else "") + text, pos + Vector2(12, 7), 19, tint.lightened(0.2))

func _valve(pos: Vector2, tint: Color, opened: bool, size: float = 1.0) -> void:
	_poly([pos + Vector2(-19, -13) * size, pos, pos + Vector2(-19, 13) * size], tint)
	_poly([pos + Vector2(19, -13) * size, pos + Vector2(19, 13) * size, pos], tint)
	draw_line(pos + Vector2(0, -11) * size, pos + Vector2(0, -37) * size, tint.lightened(0.2), 5 * size, true)
	var turn: float = clock * 0.2 if opened else 0.0
	var axis: Vector2 = Vector2(19, 0).rotated(turn) * size
	draw_line(pos + Vector2(0, -39) * size - axis, pos + Vector2(0, -39) * size + axis, tint, 6 * size, true)
	draw_circle(pos + Vector2(0, -39) * size, 5 * size, tint.lightened(0.4))

func _draw_flow(points: Array[Vector2], tint: Color, speed: float) -> void:
	if points.size() < 2: return
	var total: float = 0.0
	for i in range(points.size() - 1): total += points[i].distance_to(points[i + 1])
	for i in range(int(total / 47) + 1):
		var distance: float = fmod(i * 47.0 + clock * 70 * speed, total)
		for segment in range(points.size() - 1):
			var length: float = points[segment].distance_to(points[segment + 1])
			if distance <= length:
				var direction: Vector2 = (points[segment + 1] - points[segment]).normalized()
				var point: Vector2 = points[segment] + direction * distance
				draw_line(point - direction * 8, point + direction * 5, tint.lightened(0.25), 4, true)
				break
			distance -= length

func _pipe(points: Array[Vector2], tint: Color, width: float) -> void:
	_polyline(points, Color("122635"), width + 8)
	_polyline(points, tint.darkened(0.26), width)
	var shifted: Array[Vector2] = []
	for point in points: shifted.append(point + Vector2(0, -width * 0.15))
	_polyline(shifted, Color(tint.lightened(0.15), 0.8), width * 0.35)
	for point in points: draw_circle(point, width * 0.42, tint.darkened(0.05))

func _fluid_polygon(left: float, right: float, top: float, bottom: float, wave: float, frequency: float) -> Array[Vector2]:
	var points: Array[Vector2] = []
	for i in range(41):
		var x: float = lerpf(left, right, i / 40.0)
		points.append(Vector2(x, top + sin(x * 0.016 + clock * frequency) * wave))
	points.append(Vector2(right, bottom))
	points.append(Vector2(left, bottom))
	return points

func _round(rect: Rect2, tint: Color, radius: int) -> void:
	var r: float = minf(float(radius), minf(rect.size.x, rect.size.y) * 0.5)
	if r <= 0:
		draw_rect(rect, tint)
		return
	draw_rect(Rect2(rect.position + Vector2(r, 0), rect.size - Vector2(r * 2, 0)), tint)
	draw_rect(Rect2(rect.position + Vector2(0, r), rect.size - Vector2(0, r * 2)), tint)
	for corner in [rect.position + Vector2(r, r), Vector2(rect.end.x - r, rect.position.y + r), rect.end - Vector2(r, r), Vector2(rect.position.x + r, rect.end.y - r)]: draw_circle(corner, r, tint)

func _ellipse(pos: Vector2, radii: Vector2, tint: Color) -> void:
	draw_set_transform(pos, 0, radii)
	draw_circle(Vector2.ZERO, 1.0, tint)
	draw_set_transform(Vector2.ZERO)

func _cloud(pos: Vector2, size: float, tint: Color) -> void:
	_ellipse(pos, Vector2(80, 17) * size, tint)
	_ellipse(pos + Vector2(-29, -12) * size, Vector2(30, 25) * size, tint)
	_ellipse(pos + Vector2(15, -22) * size, Vector2(38, 29) * size, tint)
	_ellipse(pos + Vector2(47, -6) * size, Vector2(36, 19) * size, tint)

func _star(pos: Vector2, size: float, tint: Color) -> void:
	_poly([pos + Vector2(0, -size), pos + Vector2(size * 0.28, -size * 0.28), pos + Vector2(size, 0), pos + Vector2(size * 0.28, size * 0.28), pos + Vector2(0, size), pos + Vector2(-size * 0.28, size * 0.28), pos + Vector2(-size, 0), pos + Vector2(-size * 0.28, -size * 0.28)], tint)

func _poly(points: Array[Vector2], tint: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points), tint)

func _polyline(points: Array[Vector2], tint: Color, width: float) -> void:
	draw_polyline(PackedVector2Array(points), tint, width, true)

func _label(value: String, pos: Vector2, size: int, tint: Color) -> void:
	if font: draw_string(font, pos, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, tint)

func label_center(value: String, pos: Vector2, size: int, tint: Color) -> void:
	if font: draw_string(font, pos - Vector2(font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x / 2, 0), value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, tint)

func _marine_story(p: float) -> void:
	_label("MARINE FUEL  →  BUNKERING  →  SEA TRANSPORT", Vector2(786, 530), 17, GOLD)
	# Car and aircraft keep all three petroleum transport applications in view.
	_car(Vector2(849, 574), 0.28, CYAN)
	_plane(Vector2(1630, 560), 0.36, -0.05)
	for band in range(9):
		draw_rect(Rect2(771, 627 + band * 10, 988, 10), Color("183e56").lerp(Color("0c263d"), band / 8.0))
	for i in range(17):
		var x: float = 780 + fmod(i * 61.0 - clock * 18, 970)
		draw_line(Vector2(x, 667 + (i % 4) * 11), Vector2(x + 36, 667 + (i % 4) * 11), Color(0.4, 0.76, 0.86, 0.25), 2, true)
	var departure: float = smoothstep(0.38, 1.0, p) * 230
	_ship(Vector2(1180 + departure, 650 + sin(clock * 1.2) * 1.4))
	if p < 0.4:
		draw_rect(Rect2(784, 610, 92, 44), Color("7a8b92"))
		_polyline([Vector2(846, 610), Vector2(846, 590), Vector2(1000, 590), Vector2(1000, 616)], GOLD, 5)
		_draw_flow([Vector2(846, 610), Vector2(846, 590), Vector2(1000, 590), Vector2(1000, 616)], CYAN, 0.7)
	_label("Refined fuel • engine-specific specifications", Vector2(1000, 711), 17, WHITE)

func _ship(pos: Vector2) -> void:
	# Side elevation: displacement hull, bulbous bow, deck cargo and aft bridge.
	draw_set_transform(pos, 0.0, Vector2(0.85, 0.85))
	_poly([Vector2(-225,-17),Vector2(234,-17),Vector2(208,10),Vector2(172,29),Vector2(-194,29),Vector2(-216,10)],Color("a8483e"))
	_poly([Vector2(-225,-17),Vector2(234,-17),Vector2(218,1),Vector2(-216,1)],Color("1c2637"))
	draw_line(Vector2(-216,-19),Vector2(226,-19),WHITE,3,true)
	for row in range(2):
		for col in range(6):
			var tint: Color = [Color("b16b48"),Color("528d98"),Color("bdab78")][(row+col)%3]
			draw_rect(Rect2(-102+col*45,-43-row*24,43,22),tint)
			for rib in range(4): draw_line(Vector2(-98+col*45+rib*10,-41-row*24),Vector2(-98+col*45+rib*10,-24-row*24),tint.darkened(0.2),1,true)
	draw_rect(Rect2(-191,-78,69,59),Color("dce4dc"))
	draw_rect(Rect2(-198,-87,83,17),Color("e9eee5"))
	for i in range(6): draw_rect(Rect2(-192+i*12,-84,9,9),Color("244855"))
	draw_rect(Rect2(-170,-105,14,18),Color("c8874e"))
	draw_line(Vector2(-133,-87),Vector2(-133,-121),WHITE,2,true)
	draw_line(Vector2(-148,-110),Vector2(-119,-110),WHITE,2,true)
	for x in range(-211,220,23): draw_line(Vector2(x,-19),Vector2(x,-29),Color("acb9b4"),1,true)
	draw_line(Vector2(-211,-29),Vector2(219,-29),Color("acb9b4"),1,true)
	draw_circle(Vector2(200,-24),3,Color("8ce7b2"))
	_label("QATOOR",Vector2(-49,17),13,WHITE)
	for i in range(4): draw_arc(Vector2(-230-i*16,30),Vector2(15+i*7,15+i*7).x,3.3,5.9,16,Color(0.72,0.88,0.9,0.25),2,true)
	draw_set_transform(Vector2.ZERO)
