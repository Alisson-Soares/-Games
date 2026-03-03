extends Area2D
@export var next_level = ""
@export var distancia: int
@export var last_entrade: int


func _on_body_entered(_body: Node2D) -> void :
    PlayerStats.last_entrade = last_entrade
    call_deferred("load_next_scene")



func load_next_scene():
    get_tree().change_scene_to_file("res://fases/" + next_level + ".tscn")
