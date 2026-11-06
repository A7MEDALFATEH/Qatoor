class_name JourneyCamera
extends Camera2D
## Shared cinematic framing. UI lives on a CanvasLayer and is unaffected.

var _framing: Tween

func _ready() -> void:
	position = Vector2(960.0, 540.0)
	position_smoothing_enabled = false

func frame(center: Vector2, zoom_factor: float = 1.0, duration: float = 1.0) -> void:
	if _framing != null and _framing.is_valid():
		_framing.kill()
	_framing = create_tween().set_parallel(true)
	_framing.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_framing.tween_property(self, "position", center, maxf(duration, 0.01))
	_framing.tween_property(self, "zoom", Vector2.ONE * clampf(zoom_factor, 0.65, 1.75), maxf(duration, 0.01))

func reset_frame() -> void:
	frame(Vector2(960.0, 540.0), 1.0, 0.8)
