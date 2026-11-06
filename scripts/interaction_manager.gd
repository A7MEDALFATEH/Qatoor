extends RefCounted
## Explicit story graph; invalid or repeated navigation cannot skip a chapter.
const PATH: Array[String] = ["reservoir", "drilling", "pressure", "race", "separator", "refinery", "finale"]

static func permits(from_stage: String, to_stage: String) -> bool:
	if to_stage == "menu" or to_stage == "reservoir":
		return true
	if from_stage == "menu":
		return to_stage == "reservoir"
	if to_stage == "quiz":
		return from_stage == "finale"
	if from_stage == "quiz":
		return to_stage == "finale"
	var index: int = PATH.find(from_stage)
	return index >= 0 and index + 1 < PATH.size() and PATH[index + 1] == to_stage

