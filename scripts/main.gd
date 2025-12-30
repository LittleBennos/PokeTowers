extends Node2D

@onready var wave_manager: WaveManager = $WaveManager
@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
	wave_manager.set_hud(hud)
	GameManager.reset_game()
