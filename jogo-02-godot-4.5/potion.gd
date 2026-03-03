extends Area2D


@export var cure: int

func _on_area_entered(_area: Area2D) -> void :
    PlayerStats.player_hp = PlayerStats.player_hp_max
    queue_free()
