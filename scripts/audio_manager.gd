class_name JourneyAudio
extends Node
## Dependency-free generated audio. Replace cues with recorded sounds if desired.

var muted: bool = false
var _players: Array[AudioStreamPlayer] = []
var _streams: Dictionary = {}
var _ambience: AudioStreamPlayer
var _current_ambience: String = ""
var _next_player: int = 0
const SAMPLE_RATE: int = 48000

func _ready() -> void:
	for i in range(5):
		var player := AudioStreamPlayer.new()
		player.volume_db = -12.0
		add_child(player)
		_players.append(player)
	_ambience = AudioStreamPlayer.new()
	_ambience.volume_db = -29.0
	add_child(_ambience)
	for cue in ["click", "success", "error", "whoosh", "bubble", "celebrate"]:
		_streams[cue] = _synthesize(cue)

func set_muted(value: bool) -> void:
	muted = value
	for player in _players:
		player.volume_db = -80.0 if muted else -12.0
	if _ambience != null:
		_ambience.volume_db = -80.0 if muted else -29.0

func play_cue(cue: String) -> void:
	if muted or _players.is_empty():
		return
	if not _streams.has(cue):
		cue = "click"
	var player: AudioStreamPlayer = _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	player.stream = _streams[cue]
	player.play()

func set_ambience(mode: String, intensity: float = 1.0) -> void:
	if _ambience == null:
		return
	_ambience.volume_db = -80.0 if muted else lerpf(-36.0, -25.0, clampf(intensity, 0.0, 1.0))
	if mode == _current_ambience:
		return
	_current_ambience = mode
	_ambience.stop()
	if mode in ["", "silent", "none"]:
		return
	var key: String = "ambient_" + mode
	if not _streams.has(key):
		_streams[key] = _synthesize(key)
	_ambience.stream = _streams[key]
	_ambience.play()

func _synthesize(cue: String) -> AudioStreamWAV:
	var ambient: bool = cue.begins_with("ambient_")
	var duration: float = 2.0 if ambient else 0.18
	if cue == "whoosh": duration = 0.7
	if cue == "success": duration = 0.5
	if cue == "celebrate": duration = 0.95
	if cue == "error": duration = 0.33
	if cue == "bubble": duration = 0.28
	var count: int = int(duration * SAMPLE_RATE)
	var pcm := PackedByteArray()
	pcm.resize(count * 2)
	var random := RandomNumberGenerator.new()
	random.seed = absi(hash(cue))
	var phase: float = 0.0
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var p: float = t / duration
		var value: float = 0.0
		if ambient:
			# Integer-cycle tones make a seamless 2-second loop; quiet noise adds texture.
			var base: float = 55.0 if "drill" in cue else 82.0
			value = sin(TAU * base * t) * 0.24 + sin(TAU * (base * 2.0) * t) * 0.08
			value += random.randf_range(-0.1, 0.1) * (0.6 if "drill" in cue else 0.15)
		elif cue == "whoosh":
			value = random.randf_range(-1.0, 1.0) * sin(PI * p) * 0.4
		elif cue == "click":
			value = sin(TAU * 620.0 * t) * exp(-p * 14.0) * 0.55
		elif cue == "error":
			value = sin(TAU * lerpf(260.0, 165.0, p) * t) * sin(PI * p) * 0.4
		elif cue == "bubble":
			phase += TAU * lerpf(300.0, 1100.0, p * p) / SAMPLE_RATE
			value = sin(phase) * sin(PI * p) * exp(-p * 2.0) * 0.6
		else:
			var notes: Array[float] = [523.25, 659.25, 783.99, 1046.5]
			var note: int = mini(int(p * notes.size()), notes.size() - 1)
			var local: float = fmod(p * notes.size(), 1.0)
			value = (sin(TAU * notes[note] * t) + 0.15 * sin(TAU * notes[note] * 2.0 * t)) * sin(PI * local) * 0.4
		if not ambient:
			value *= minf(1.0, t / 0.006) * minf(1.0, (duration - t) / 0.012)
		pcm.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 32760.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = pcm
	if ambient:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = count
	return stream
