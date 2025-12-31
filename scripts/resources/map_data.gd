class_name MapData extends Resource

@export var map_name: String = ""
@export var description: String = ""
@export var difficulty: int = 1  # 1-5 stars
@export var background: Texture2D
@export var path_points: PackedVector2Array = PackedVector2Array()
@export var zones: PackedVector2Array = PackedVector2Array()
@export var zone_size: int = 40
@export var waves_count: int = 10
