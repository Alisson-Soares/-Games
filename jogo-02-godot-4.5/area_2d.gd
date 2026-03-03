extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@onready var timer: Timer = $Timer


@export
var speed = 4
var direction: int = 0

func _ready() -> void :
    timer.start()

func _process(_delta: float) -> void :
    position.x += speed * direction

func get_direction(direction_player: int):
    if direction_player == 1:
        direction = 1
        sprite_2d.flip_h = false
    else:
        direction = -1
        sprite_2d.flip_h = true

func _on_timer_timeout() -> void :
    queue_free()


func _on_area_entered(_area: Area2D) -> void :
    queue_free()


func _on_hitbox_to_break_area_entered(_area: Area2D) -> void :
    queue_free()
