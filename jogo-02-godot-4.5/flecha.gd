extends Area2D
@onready var timer: Timer = $Timer
@onready var sprite_2d: Sprite2D = $Sprite2D

@export
var speed = 7
var direction = 1

func _ready() -> void :
    timer.start()
    pass


func _process(_delta: float) -> void :
    position.x += speed * direction
    if direction < 0:
        sprite_2d.flip_h = true
    else:
        sprite_2d.flip_h = false


func get_direction(player_direction: int):
    self.direction = player_direction


func _on_timer_timeout() -> void :
    queue_free()
