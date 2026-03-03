extends Area2D


@onready var sprite_2d: Sprite2D = $Sprite2D


func _on_area_entered(_area: Area2D) -> void :
    PlayerStats.player_key = true
    get_tree().change_scene_to_file("res://fases/master.tscn")
