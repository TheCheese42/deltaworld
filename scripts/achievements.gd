extends CanvasLayer


var _label: Label
var _lawyer: TextureRect
var _not_bug_feature: TextureRect
var _poor_spectre: TextureRect
var _unique_playstyle: TextureRect
var _selected_index: int = 0

func _ready() -> void:
	_label = find_child("Label")
	_lawyer = find_child("TextureRect")
	_not_bug_feature = find_child("TextureRect2")
	_poor_spectre = find_child("TextureRect3")
	_unique_playstyle = find_child("TextureRect3")

	if GlobalVars.options_save.achievement_lawyer:
		_lawyer.texture = load("res://assets/textures/achievement_lawyer_color.png")
	if GlobalVars.options_save.achievement_not_bug_feature:
		_not_bug_feature.texture = load("res://assets/textures/achievement_not_bug_feature_color.png")
	if GlobalVars.options_save.achievement_poor_spectre:
		_poor_spectre.texture = load("res://assets/textures/achievement_poor_spectre_color.png")
	if GlobalVars.options_save.achievement_unique_playstyle:
		_unique_playstyle.texture = load("res://assets/textures/achievement_unique_playstyle_color.png")
	_update_achievements()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left"):
		_selected_index = clampi(_selected_index - 1, 0, 3)
	elif Input.is_action_just_pressed("right"):
		_selected_index = clampi(_selected_index + 1, 0, 3)
	elif Input.is_action_just_pressed("back"):
		_quit()
	_update_achievements()

func _update_achievements() -> void:
	_lawyer.scale = Vector2(1.0, 1.0)
	_not_bug_feature.scale = Vector2(1.0, 1.0)
	_poor_spectre.scale = Vector2(1.0, 1.0)
	_unique_playstyle.scale = Vector2(1.0, 1.0)
	if _selected_index == 0:
		_set_lawyer()
		_lawyer.scale = Vector2(1.1, 1.1)
	elif _selected_index == 1:
		_set_not_bug_feature()
		_not_bug_feature.scale = Vector2(1.1, 1.1)
	elif _selected_index == 2:
		_set_poor_spectre()
		_poor_spectre.scale = Vector2(1.1, 1.1)
	elif _selected_index == 3:
		_set_unique_playstyle()
		_unique_playstyle.scale = Vector2(1.1, 1.1)

func _set_lawyer() -> void:
	if GlobalVars.options_save.achievement_lawyer:
		_label.text = tr("ACHIEVEMENT_LAWYER")
	else:
		_label.text = tr("QUESTION_MARKS")

func _set_not_bug_feature() -> void:
	if GlobalVars.options_save.achievement_not_bug_feature:
		_label.text = tr("ACHIEVEMENT_NOT_BUG_FEATURE")
	else:
		_label.text = tr("QUESTION_MARKS")

func _set_poor_spectre() -> void:
	if GlobalVars.options_save.achievement_poor_spectre:
		_label.text = tr("ACHIEVEMENT_POOR_SPECTRE")
	else:
		_label.text = tr("QUESTION_MARKS")

func _set_unique_playstyle() -> void:
	if GlobalVars.options_save.achievement_unique_playstyle:
		_label.text = tr("ACHIEVEMENT_UNIQUE_PLAYSTYLE")
	else:
		_label.text = tr("QUESTION_MARKS")

func _quit() -> void:
	await get_tree().create_timer(0.01).timeout
	get_tree().call_group("main_menu", "set_main_menu_enabled", true)
	queue_free()
