extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

@onready var ray_cast_2d = $RayCast2D
@onready var ray_cast_2e = $RayCast2E

@onready var timer_ataque_1 = $Timers / ataque_1
@onready var timer_ataque_2 = $Timers / ataque_2
@onready var timer_ataque_3 = $Timers / ataque_3
@onready var timer_run_attack = $Timers / run_attack
@onready var timer_wait_to_attack = $Timers / wait_to_attack

@onready var C_attack_1: CollisionShape2D = $collision / attack_1
@onready var C_attack_2: CollisionShape2D = $collision / attack_2
@onready var C_attack_3: CollisionShape2D = $collision / attack_3
@onready var C_run_attack: CollisionShape2D = $collision / run_attack

var alvo: CharacterBody2D = null
const SPEED = 150.0
var direction = 1
var see_player = false
var player_distance
var combo_attack = 1

@export
var hp: int = 5
@export
var damage: int = 1


enum EnemyStates{
    idle, 
    walk, 
    run, 
    attack1, 
    attack2, 
    attack3, 
    run_attack, 
    hurt, 
    dead
}

var status: EnemyStates


func _ready() -> void :

    status = EnemyStates.walk


func _physics_process(_delta: float) -> void :

    if see_player == true:
        match status:
            EnemyStates.idle:
                idle_status()
            EnemyStates.walk:
                walk_status()
            EnemyStates.run:
                run_status()
            EnemyStates.attack1:
                attack1_status()
            EnemyStates.attack2:
                attack2_status()
            EnemyStates.attack3:
                attack3_status()
            EnemyStates.run_attack:
                run_attack_status()
            EnemyStates.dead:
                dead_status()
            EnemyStates.hurt:
                hurt_status()
    else:
        move()
    move_and_slide()

func move():
    if ray_cast_2d.is_colliding():
        direction = -1
        animated_sprite.flip_h = true
    elif ray_cast_2e.is_colliding():
        direction = 1
        animated_sprite.flip_h = false
    velocity.x = SPEED * direction

func move_to_player():
    if (alvo.global_position.x > position.x):
        direction = 1
        animated_sprite.flip_h = false
    else:
        direction = -1
        animated_sprite.flip_h = true
    velocity.x = SPEED * direction

func _on_see_player_body_entered(_body: Node2D):
    alvo = get_tree().get_first_node_in_group("player")
    see_player = true

func idle_status():
    velocity = Vector2.ZERO
    change_direction()
    if not ((alvo.global_position.x - position.x) <= 100 and (alvo.global_position.x - position.x) >= -100):
        go_to_walk_status()
    else:
        choice_attack()

func walk_status():
    var h_dir: int
    h_dir = 1 if alvo.global_position.y > global_position.y else -1
    if abs(alvo.global_position.y - self.global_position.y) > 40:
        velocity.y = h_dir * SPEED
    if abs(alvo.global_position.x - global_position.x) < 60:
        go_to_idle_status()
        if timer_wait_to_attack.is_stopped():
            go_to_run_attack_status()
    else:
        move_to_player()

func run_status():
    pass

func run_attack_status():
    if animated_sprite.frame == 3:
        C_run_attack.disabled = false
        C_run_attack.position = Vector2(32.5 * direction, 1)
    if timer_wait_to_attack.is_stopped():
        C_run_attack.disabled = true
        go_to_idle_status()


func attack1_status():
    if animated_sprite.frame == 3:
        C_attack_1.disabled = false
        C_attack_1.position = Vector2(28 * direction, -8.5)
    if animated_sprite.frame == 4:
        C_attack_1.disabled = true
    if not animated_sprite.is_playing():
        go_to_idle_status()
    pass

func attack2_status():
    if animated_sprite.frame == 2:
        C_attack_2.disabled = false
        C_attack_2.position = Vector2(30.5 * direction, -15.5)
        return
    if animated_sprite.frame == 4:
        C_attack_2.disabled = true
        return
    if not animated_sprite.is_playing():
        go_to_idle_status()
    return

func attack3_status():
    if animated_sprite.frame == 2:
        C_attack_3.disabled = false
        C_attack_3.position = Vector2(27 * direction, 0)
        return
    if animated_sprite.frame == 3:
        C_attack_3.disabled = true
        return
    if not animated_sprite.is_playing():
        go_to_idle_status()

func dead_status():
    timer_ataque_1.stop()
    timer_ataque_2.stop()
    timer_ataque_3.stop()
    timer_run_attack.stop()
    timer_wait_to_attack.stop()

    if not animated_sprite.is_playing():
        queue_free()

func hurt_status():
    if not animated_sprite.is_playing():
        go_to_attack1_status()



func go_to_idle_status():
    velocity = Vector2.ZERO
    status = EnemyStates.idle
    animated_sprite.play("idle")
    player_distance = (alvo.position)
    change_direction()

func go_to_walk_status():
    status = EnemyStates.walk
    animated_sprite.play("walk")
    timer_wait_to_attack.start()
    change_direction()

func go_to_run_status():
    change_direction()
    status = EnemyStates.run
    velocity.x = SPEED * 2 * direction
    if abs(alvo.global_position.x - position.x) >= 100:
        choice_attack()

func go_to_run_attack_status():
    status = EnemyStates.run_attack
    velocity.x = SPEED * 2 * direction
    animated_sprite.play("run and attack")
    timer_run_attack.start()
    change_direction()

func go_to_attack1_status():
    velocity = Vector2.ZERO
    status = EnemyStates.attack1
    animated_sprite.play("attack_1")
    change_direction()
    pass

func go_to_attack2_status():
    velocity = Vector2.ZERO
    status = EnemyStates.attack2
    animated_sprite.play("attack_2")
    change_direction()
    pass

func go_to_attack3_status():
    velocity = Vector2.ZERO
    status = EnemyStates.attack3
    animated_sprite.play("attack_3")
    change_direction()
    pass

func go_to_dead_status():
    animated_sprite.play("dead")
    status = EnemyStates.dead
    velocity = Vector2.ZERO

func go_to_hurt_status():
    animated_sprite.play("hurt")
    status = EnemyStates.hurt
    velocity = Vector2.ZERO
    change_direction()


func choice_attack():
    if combo_attack == 1:
        timer_ataque_1.start()
        combo_attack = 2
        go_to_attack1_status()
        return
    elif combo_attack == 2:
        timer_ataque_2.start()
        combo_attack = 3
        go_to_attack2_status()
        return
    else:
        combo_attack = 1
        timer_ataque_3.start()
        go_to_attack3_status()

func disable_collision():
    if combo_attack == 1:
        C_attack_1.disabled = true
    elif combo_attack == 2:
        C_attack_2.disabled = true
    elif combo_attack == 3:
        C_attack_3.disabled = true

func take_damage():
    hp -= PlayerStats.player_damage
    if hp <= 0:
        go_to_dead_status()
    else:
        go_to_hurt_status()

func change_direction():
    if (alvo.global_position.x > position.x):
        direction = 1
        animated_sprite.flip_h = false
    else:
        direction = -1
        animated_sprite.flip_h = true

func _on_wait_to_attack_timeout() -> void :
    go_to_run_attack_status()

func _on_ataque_1_timeout() -> void :
    pass

func _on_ataque_2_timeout() -> void :
    pass

func _on_ataque_3_timeout() -> void :
    pass

func _on_run_attack_timeout() -> void :
    pass

func _on_hitbox_area_entered(_area: Area2D) -> void :
    alvo = get_tree().get_first_node_in_group("player")
    take_damage()
    see_player = true
