extends Node
## One transition gate protects scene changes from repeated touch input.
var busy: bool = false
var veil: ColorRect
var reduced_motion: bool = false

func _ready() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 90
	add_child(layer)
	veil = ColorRect.new()
	veil.color = Color("081523")
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	veil.modulate.a = 0.0
	layer.add_child(veil)

func cover() -> void:
	busy = true
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(veil, "modulate:a", 1.0, 0.12 if reduced_motion else 0.42).set_trans(Tween.TRANS_SINE)
	await tween.finished

func reveal() -> void:
	var tween := create_tween()
	tween.tween_property(veil, "modulate:a", 0.0, 0.12 if reduced_motion else 0.55).set_trans(Tween.TRANS_SINE)
	await tween.finished
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	busy = false

