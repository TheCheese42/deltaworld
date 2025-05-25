@tool
extends Resource
class_name Level

var mob_probabilities: Dictionary
var waves: Array
var special_waves: Dictionary

var current_wave: int = 0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(level: String) -> void:
	var level_file: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://levels/" + level + ".json"))
	mob_probabilities = level_file["mob_probabilities"]
	waves = level_file["waves"]
	special_waves = level_file["special_waves"]

func next_wave() -> Wave:
	var wave: Array = waves[current_wave]
	current_wave += 1
	var duration: float = wave[1]
	var mobs: Array = Array()
	if is_instance_of(wave[0], TYPE_INT) or is_instance_of(wave[0], TYPE_FLOAT):
		for i: int in wave[0]:
			mobs.append(mob_probabilities.keys()[rng.rand_weighted(mob_probabilities.values())])
	else:
		var special_wave: Dictionary = special_waves[wave[0]]
		for mob: String in special_wave.keys():
			var count: int = special_wave[mob]
			for i: int in count:
				mobs.append(mob)
	return Wave.new(mobs, duration)


class Wave:
	var mobs: Array
	var duration: float

	func _init(wave_mobs: Array, wave_duration: float) -> void:
		self.mobs = wave_mobs
		self.duration = wave_duration
