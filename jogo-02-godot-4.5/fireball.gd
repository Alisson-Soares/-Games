extends Area2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var speed = 4
var direction = 1


func _process(_delta: float) -> void :
    position.x += direction * speed
    if animated_sprite_2d.frame == 11:
        queue_free()

func get_direction(enemy_direction: int):
    direction = enemy_direction
    if enemy_direction < 0:
        animated_sprite_2d.flip_h = true
        collision_shape_2d.position.x += -20
    else:
        animated_sprite_2d.flip_h = false



func _on_area_entered(_area: Area2D) -> void :
    queue_free()
