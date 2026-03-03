extends CharacterBody2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@onready var c_hitbox: CollisionShape2D = $Hitbox / c_hitbox

var speed = 85.0
var alvo: CharacterBody2D = null
var deslocamento: int
var direction_x = 0
var direction_y = 0
var can_move: bool = false


func _ready() -> void :
    anim.play("spawn")
    alvo = get_tree().get_first_node_in_group("player")
func _physics_process(_delta: float) -> void :
    if not is_instance_valid(alvo):
        queue_free()
    elif not can_move:
        await anim.animation_finished
        start_move()
    else:
        if (alvo.global_position.x - rng()) > self.global_position.x:
            direction_x = 1
        else:
            direction_x = -1

        if (alvo.global_position.y - rng()) > self.global_position.y:
            direction_y = 1
        else:
            direction_y = -1
        velocity.x = speed * direction_x
        velocity.y = speed * direction_y
        move_and_slide()

func rng():
    deslocamento = randi_range(-20, 20)
    return deslocamento

func start_move():
    if anim.animation == "spawn":
        anim.play("idle")
        can_move = true
    elif anim.animation == "despawn":
        queue_free()



func _on_hitbox_area_entered(_area: Area2D) -> void :
    c_hitbox.set_deferred("disable", true)
    anim.play("despawn")
    can_move = false
