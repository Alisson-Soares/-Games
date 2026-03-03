extends Node2D
@onready var spawn_point_1: Node2D = $fase_inicial / spawner / spawn_point_1
@onready var spawn_point_2: Node2D = $fase_inicial / spawner / spawn_point_2
@onready var spawn_point_3: Node2D = $fase_inicial / spawner / spawn_point_3
const player = preload("res://player_archer.tscn")
@onready var block_area: TileMapLayer = $fase_inicial / cenario / block_area
@onready var spawn_point: int
func _ready() -> void :
    if PlayerStats.player_key:
        block_area.visible = true
        block_area.collision_enabled = true
    var new_player = player.instantiate()
    add_child(new_player)
    var anim: AnimatedSprite2D = new_player.get_node("AnimatedSprite2D")
    match PlayerStats.last_entrade:
        1:
            new_player.global_position = spawn_point_1.global_position
        2:
            new_player.global_position = spawn_point_2.global_position
        3:
            anim.flip_h = true
            new_player.global_position = spawn_point_3.global_position
