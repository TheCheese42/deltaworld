extends Node2D
class_name LightBeam

signal setup_finished
signal beam_finished

@onready var beam: AnimatedSprite2D = $Beam


func start_setup() -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	var target_color: Color = beam.modulate
	target_color.a = 1.0
	tween.tween_property(beam, "modulate", target_color, 0.8)
	beam.play("setup")
	await tween.finished
	emit_signal("setup_finished")

func start_beam() -> void:
	beam.play("beam")
	await beam.animation_finished
	emit_signal("beam_finished")
