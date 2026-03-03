extends Node2D
@onready var fase_1: Node2D = $spawn_points / fase_1
@onready var secret: Node2D = $spawn_points / secret
@onready var cave: Node2D = $spawn_points / cave

const player = preload("res://player_archer.tscn")
@onready var spawn_point: int
func _ready() -> void :
    var new_player = player.instantiate()
    add_child(new_player)
    match PlayerStats.last_entrade:
        1:
            new_player.global_position = fase_1.global_position
        2:
            new_player.global_position = secret.global_position
        3:
            new_player.global_position = cave.global_position
