extends Label
class_name DamageNumber

var velocity: Vector2 = Vector2(0, -60)
var lifetime: float = 0.8
var age: float = 0.0

func _ready() -> void:
	pivot_offset = size / 2

func _process(delta: float) -> void:
	age += delta
	position += velocity * delta
	velocity.y += 80 * delta  # gravity

	# Fade out
	var alpha = 1.0 - (age / lifetime)
	modulate.a = alpha

	if age >= lifetime:
		queue_free()

static func spawn(parent: Node, pos: Vector2, amount: float, multiplier: float = 1.0) -> void:
	var label = DamageNumber.new()
	label.text = str(int(amount))
	label.position = pos - Vector2(20, 10)
	label.add_theme_font_size_override("font_size", 16)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Color based on effectiveness
	if multiplier > 1.5:
		label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))  # Gold - super effective
		label.add_theme_font_size_override("font_size", 20)
		label.text += "!"
	elif multiplier > 1.0:
		label.add_theme_color_override("font_color", Color(1, 1, 0.4))  # Yellow
	elif multiplier < 1.0 and multiplier > 0:
		label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))  # Grey - not effective
		label.add_theme_font_size_override("font_size", 12)
	elif multiplier == 0:
		label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		label.text = "IMMUNE"
		label.add_theme_font_size_override("font_size", 12)
	else:
		label.add_theme_color_override("font_color", Color.WHITE)

	# Random spread
	label.velocity.x = randf_range(-20, 20)
	label.velocity.y = randf_range(-80, -50)

	parent.add_child(label)
