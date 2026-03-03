extends Node2D

@onready var door: TileMapLayer = $door


func _ready() -> void :
    if PlayerStats.player_key:
        door.visible = false
        door.collision_enabled = false
